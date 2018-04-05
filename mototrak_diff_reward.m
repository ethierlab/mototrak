function behav_stats = mototrak_diff_reward(GUI_h)
%
%       This function controls a mototrak behavioral experiment, in which
%       the rats are required to pull and hold on the lever to obtain
%       different levels of rewards. These levels (e.g. jackpot=5, normal=1,
%       no_reward=0), are indicated to the rats at the beginning of the
%       trial (upon force detection) by different tones.
%       usage:   behav_stats = mototrak_diff_reward(varargin)
%               GUI_h           : handle from GUI calling this function
%                                 (see mototrak_diff_reward_GUI.m)
%
%           behav_stats         : summary of performance along with
%                                 saved experimental parameters
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% EXPERIMENTAL PARAMETERS

params = GUI_h.params;
GUI_h.params = [];

%% Mototrak and sound initialization
moto=Connect_MotoTrak;
moto.autopositioner(params.lever_pos);
b=moto.baseline();
m=moto.cal_grams()/moto.n_per_cal_grams();

%  sounds = speaker_sounds(freqs,duration,amplitude);
trial_type_sounds = speaker_sounds(params.trial_type_sounds,0.3,10);
reward_sound      = speaker_sounds(params.reward_sound ,0.3,10);

%% Initialization

% current_trial = [level;position;hit window;hold time;threshold] -> from ME 'experiment.m' code
[force_plot,force_fig,threshold_line,hit_window_line]=create_lever_force_fig(params.force_target, params.hit_window);
reset_gui_counters(GUI_h);

experiment_start=tic;
experiment_start_time = datetime('now');
disp('experiment started!')

% structure to save all results, as well as experimental parameters
behav_stats = struct(...
    'params'            ,params,...
    'num_rewards'       ,zeros(size(params.trial_type)),...
    'num_pellets'       ,zeros(size(params.trial_type)),...
    'num_trials'        ,zeros(size(params.trial_type)),...
    'lever_force'       ,{{}},...
    'trial_data'        ,{{}},...
    'session_time'      ,experiment_start_time,...
    'results'           ,[]...  % for back compatibility with ME 'experiment.m' analysis code
    );

tmp_force_buffer   = [nan nan]; % [time force], first row is oldest data
trial_force_buffer = [nan nan];
trial_started      = false;
post_trial_pause   = false; 
pause_duration     = 0;
send_pellets       = 0;
trial_counter      = 0;
last_pellet_time   = toc(experiment_start);
stop_button        = set(GUI_h.stop_button,'userdata',0);
feed_button        = set(GUI_h.feed_button,'userdata',0);
session_rank       = 0; % get this somehow with the GUI, from previously recorded data
success_trial      = false;

% --->these are for backcompatibility but should be removed soon
max_value   = 0;
jackpot_val = [1 0 -1];
% <-----

try
    %% Main experiment loop
    while toc(experiment_start)<params.duration && ~get(GUI_h.stop_button,'userdata')
        
        time_now   = toc(experiment_start);
        force_now  = m*(moto.read_Pull()-b);
        
        %limiter taille buffer temporaire à 0.5s
        tmp_force_buffer = [tmp_force_buffer(time_now-tmp_force_buffer(:,1)<=0.5,:); time_now force_now];

        
        %% trial initiation?
        if ~trial_started && force_now > params.init_thresh
            trial_started    = true;
            trial_start_time = time_now;
            
            % decide trial type
            trial_type_select = 100*rand;
            for i=1:length(params.trial_type_pct)
                if trial_type_select <= sum(params.trial_type_pct(1:i));
                    trial_type = i;
                    disp([ params.trial_type{i} ' trial initiated']);
                    behav_stats.num_trials(i) =  behav_stats.num_trials(i)+1;
                    break
                end
            end
            
            % send corresponding sound
            play(trial_type_sounds{trial_type});
            
            % send digital pulses out
            for i = 1:params.trial_type_digout(trial_type)
                moto.trigger_stim(1);
            end
            
            % start recording force
            trial_force_buffer = [tmp_force_buffer(:,1)-trial_start_time tmp_force_buffer(:,2)];
        end
        
        %% during trial
        if trial_started

            trial_time = time_now-trial_start_time;
            trial_force_buffer = [trial_force_buffer; trial_time force_now];
            
            if post_trial_pause
                % pause after trial, and give pellets as needed
                if send_pellets && trial_time-last_pellet_time>params.pellets_pause
                    moto.trigger_feeder(1);
                    last_pellet_time = trial_time;
                    send_pellets = send_pellets-1;
                elseif trial_time-trial_end_time > pause_duration
                    %pause is over, fill result structure and start new trial
                    behav_stats.lever_force = [behav_stats.lever_force {trial_force_buffer'}];
                    % TODO: behav_stats.trial_data  data table instead of .lever_force with all trial info;
                    
                    %----> this is for back compatibility and should be removed soon
                    new_results = [session_rank;params.task_level;params.lever_pos;params.hit_window;...
                                    params.hold_time,params.force_target;success_trial;max_value;...
                                    trial_end_time;params.num_pellets(trial_type); jackpot_val(trial_type)];
                    behav_stats.results = [ behav_stats.results new_results];
                    max_value           = 0;
                    %<----
                    
                    post_trial_pause   = false;
                    trial_started      = false;
                    success_trial      = false;
                    trial_force_buffer = [nan nan];
                    
                end
            else
                
                % Failed?
                if trial_time > params.hit_window && force_now < params.force_target
                    %trial failed
                    fprintf('trial failed\n\n');
                    post_trial_pause = true;
                    max_value=max(trial_force_buffer(:,2));
                    trial_end_time = trial_time;
                    pause_duration = params.mastication_time;
                end
                
                % Success?
                % if we are at least 'hold_time' past trial init, and if force was always above 'force_target'
                % for the last 'hold_time'...
                if trial_time >= params.hold_time && ...
                        all( trial_force_buffer( trial_force_buffer(:,1)>=trial_time-params.hold_time ,2)>= params.force_target)
                    % we have a success
                    fprintf('trial successful!\n\n');
                    play(reward_sound{1});
                    success_trial  = true;
                    trial_end_time = trial_time;
                    max_value=max(trial_force_buffer(:,2));
                    send_pellets   = params.num_pellets(trial_type);
                    
                    % send digital pulses out
                    for i=1:3
                        moto.trigger_stim(1);
                    end
                    
                    %update stats
                    behav_stats.num_rewards(trial_type) = behav_stats.num_rewards(trial_type)+1;
                    behav_stats.num_pellets(trial_type) = behav_stats.num_pellets(trial_type)+params.num_pellets(trial_type);
                     
                    % update GUI stats
                    set(GUI_h.pellets_delivered_txt,'String', sprintf('%d (%.3f g)', ...
                        sum(behav_stats.num_pellets), sum(behav_stats.num_pellets)*0.045));
                    
                    %force pause
                    post_trial_pause = true;
                    pause_duration = max(params.mastication_time*[1 params.num_pellets(trial_type)]);
                    % pause is at least 1x mastication time, or more if more than 1 pellet
                end
            end
        end
        
        
        % update force fig
        set(force_plot,'XData', trial_force_buffer(:,1),...
            'YData',trial_force_buffer(:,2));
        
        % update GUI time
        set(GUI_h.time_elapsed_txt,'String',datestr(time_now/86400,'HH:MM:SS'));
        
        % check feed button
        if get(GUI_h.feed_button,'userdata')
            set(GUI_h.feed_button,'userdata',0);
            moto.moto.trigger_feeder(1);
        end
        
        drawnow; %update GUI and force fig
        
    end
    
    %% end of session: display and save results
    disp('session ended');
    disp('summary:');
    disp('type    trials  reward  pellets');
    for i=1:length(params.trial_type)
        disp([params.trial_type{i} sprintf('\t\t%d',behav_stats.num_trials(i))...
               sprintf('\t\t%d',behav_stats.num_rewards(i)) sprintf('\t\t%d',behav_stats.num_pellets(i))]);
    end
    
    %save results
    if params.cno
        save_name = [params.animal_name,'_cno_',datestr(experiment_start_time,30)];
    else
        save_name = [params.animal_name,'_',datestr(experiment_start_time,30),'s.mat'];
    end
    
    save([save_name 's.mat'],behav_stats);
    save([save_name 's_ME.mat'],results);
    
    
%     nnn=char(beginning_session_time);
%     keep animal_name nnn results current_trial lever_force cno
%
%     if strfind(cno,'y')
%         save([animal_name,'_cno_',nnn(1:11),'_',nnn(end-7:end-6),'h',nnn(end-4:end-3),'m',nnn(end-1:end),'s.mat'])
%     else
%         save([animal_name,'_',nnn(1:11),'_',nnn(end-7:end-6),'h',nnn(end-4:end-3),'m',nnn(end-1:end),'s.mat'])
%     end
    
    % cleanup
    fclose(moto.serialcon);
    close(force_fig);
    
catch ME
    fclose(moto.serialcon);
    close(force_fig);
    rethrow(ME);
end


%     %% old code
%
%     if current_trial(4)==0 %hold time nul (levels 1, 2 et 3)
%         if current_trial(5)==10 %jamais vrai quand hold time différent de 0 (level1 et début level2)
%             if force_now>=10 %essai démarré et immédiatement réussi (level1 et début level2)
%                 [jackpot]=eval_trial_type(moto,sons,current_trial,jackpot_percentage,noreward_percentage);
%                 trial_started=1; trial_start=tic;
%                 lever_force{current_trial_rank}=[buffer_force(1,:)-buffer_force(1,end);buffer_force(2,:)];
%                 set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                     'YData',lever_force{current_trial_rank}(2,:));
%                 drawnow
%                 success_trial=1;moment_reussite=tic;
%                 %pas de son de récompense: il serait concomittant avec début essai
%                 time_to_success=0;
%                 for i=1:3
%                     moto.trigger_stim(1)
%                 end
%                 if jackpot==1
%                     disp('jackpot reward!')
%                     for i=1:5
%                         moto.trigger_feeder(1)
%                         fin_dispense_pellet=tic;
%                         while toc(fin_dispense_pellet)<1.5
%                             force_now=m*(moto.read_Pull()-b);
%                             lever_force{current_trial_rank}=[lever_force{current_trial_rank} ...
%                                 [toc(trial_start);force_now]];
%                             set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                                 'YData',lever_force{current_trial_rank}(2,:));
%                             drawnow
%                         end
%                     end
%                 else
%                     disp('single reward!')
%                     moto.trigger_feeder(1)
%                     while toc(trial_start)<current_trial(3) %hit window
%                         force_now=m*(moto.read_Pull()-b);
%                         lever_force{current_trial_rank}=[lever_force{current_trial_rank} ...
%                             [toc(trial_start);force_now]];
%                         set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                             'YData',lever_force{current_trial_rank}(2,:));
%                         drawnow
%                     end
%                 end
%                 max_value=max(lever_force{current_trial_rank}(2,:));
%                 if success_trial==0
%                     time_to_success=nan;
%                     disp('end of hit window')
%                     disp('failed')
%                     fin_hit_window=tic;
%                     temps_post_reussite=2;
%                     while toc(fin_hit_window)<temps_post_reussite
%                         force_now=m*(moto.read_Pull()-b);
%                         lever_force{current_trial_rank}=[lever_force{current_trial_rank} ...
%                             [toc(trial_start);force_now]];
%                         set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                             'YData',lever_force{current_trial_rank}(2,:));
%                         drawnow
%                     end
%                 else
%                     if jackpot==1
%                         temps_post_reussite=temps_mastication_pellet*5;
%                     else
%                         temps_post_reussite=temps_mastication_pellet;
%                     end
%                     while toc(moment_reussite)<temps_post_reussite
%                         force_now=m*(moto.read_Pull()-b);
%                         lever_force{current_trial_rank}=[lever_force{current_trial_rank} ...
%                             [toc(trial_start);force_now]];
%                         set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                             'YData',lever_force{current_trial_rank}(2,:));
%                         drawnow
%                     end
%                 end
%                 for i=1:6
%                     moto.trigger_stim(1)
%                 end
%             end
%         elseif force_now>=10 %essai démarré mais non immédiatement réussi sans hold time (levels 2 et 3)
%             [jackpot]=eval_trial_type(moto,sons,current_trial,jackpot_percentage,noreward_percentage);
%             k=1; trial_started=1; trial_start=tic;
%             lever_force{current_trial_rank}=[buffer_force(1,:)-buffer_force(1,end);buffer_force(2,:)];
%             set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                 'YData',lever_force{current_trial_rank}(2,:));
%             drawnow
%             while toc(trial_start)<current_trial(3) %hit window
%                 force_now=m*(moto.read_Pull()-b);
%                 lever_force{current_trial_rank}=[lever_force{current_trial_rank} ...
%                     [toc(trial_start);force_now]];
%                 set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                     'YData',lever_force{current_trial_rank}(2,:));
%                 drawnow
%                 if force_now>=current_trial(5) && k==1
%                     play(sons.success); success_trial=1; time_to_success=toc(trial_start);moment_reussite=tic;
%                     for i=1:3
%                         moto.trigger_stim(1)
%                     end
%                     if jackpot==1
%                         disp('jackpot reward!');
%                         for i=1:5
%                             moto.trigger_feeder(1)
%                             fin_dispense_pellet=tic;
%                             while toc(fin_dispense_pellet)<1.5
%                                 force_now=m*(moto.read_Pull()-b);
%                                 lever_force{current_trial_rank}=[lever_force{current_trial_rank} ...
%                                     [toc(trial_start);force_now]];
%                                 set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                                     'YData',lever_force{current_trial_rank}(2,:));
%                                 drawnow
%                             end
%                         end
%                     elseif jackpot==0
%                         disp('single reward!')
%                         moto.trigger_feeder(1)
%                     elseif jackpot==-1
%                         disp('successful but no reward')
%                     end
%                     k=k+1;
%                 end
%             end
%             max_value=max(lever_force{current_trial_rank}(2,:));
%             if success_trial==0
%                 time_to_success=nan;
%                 disp('end of hit window')
%                 disp('failed')
%                 fin_hit_window=tic;
%                 temps_post_reussite=2;
%                 while toc(fin_hit_window)<temps_post_reussite
%                     force_now=m*(moto.read_Pull()-b);
%                     lever_force{current_trial_rank}=[lever_force{current_trial_rank} ...
%                         [toc(trial_start);force_now]];
%                     set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                         'YData',lever_force{current_trial_rank}(2,:));
%                     drawnow
%                 end
%             else
%                 if jackpot==1
%                     temps_post_reussite=temps_mastication_pellet*5;
%                 else
%                     temps_post_reussite=temps_mastication_pellet;
%                 end
%                 while toc(moment_reussite)<temps_post_reussite
%                     force_now=m*(moto.read_Pull()-b);
%                     lever_force{current_trial_rank}=[lever_force{current_trial_rank} ...
%                         [toc(trial_start);force_now]];
%                     set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                         'YData',lever_force{current_trial_rank}(2,:));
%                     drawnow
%                 end
%             end
%             for i=1:6
%                 moto.trigger_stim(1)
%             end
%         end
%     else %hold time non nul (niveau 4)
%         if force_now>=10 %essai démarre
%             [jackpot]=eval_trial_type(moto,sons,current_trial,jackpot_percentage,noreward_percentage);
%             k=1; trial_started=1; trial_start=tic;
%             lever_force{current_trial_rank}=[buffer_force(1,:)-buffer_force(1,end);buffer_force(2,:)];
%             set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                 'YData',lever_force{current_trial_rank}(2,:));
%             drawnow
%             while toc(trial_start)<current_trial(3) %hit window
%                 force_now=m*(moto.read_Pull()-b);
%                 lever_force{current_trial_rank}=[lever_force{current_trial_rank} ...
%                     [toc(trial_start);force_now]];
%                 set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                     'YData',lever_force{current_trial_rank}(2,:));
%                 drawnow
%                 if force_now>=current_trial(5) && k==1
%                     %le k==1 permet: 1) d'éviter que réussite sur première hold time puis échec
%                     %sur deuxième, si hit window non dépassée après première réussite; 2)
%                     %d'éviter que plusieurs récompenses par essai
%                     hold_start=tic;
%                     while toc(hold_start)<current_trial(4) %hold time
%                         force_now=m*(moto.read_Pull()-b);
%                         lever_force{current_trial_rank}=[lever_force{current_trial_rank} ...
%                             [toc(trial_start);force_now]];
%                         set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                             'YData',lever_force{current_trial_rank}(2,:));
%                         drawnow
%                         if force_now>=current_trial(5)
%                             success_trial=1;
%                         else
%                             success_trial=0;
%                             break
%                         end
%                     end
%                     if success_trial==1 %&& k==1
%                         play(sons.success); time_to_success=toc(trial_start);moment_reussite=tic;
%                         for i=1:3
%                             moto.trigger_stim(1)
%                         end
%                         if jackpot==1
%                             disp('jackpot reward!');
%                             for i=1:5
%                                 moto.trigger_feeder(1)
%                                 fin_dispense_pellet=tic;
%                                 while toc(fin_dispense_pellet)<1.5
%                                     force_now=m*(moto.read_Pull()-b);
%                                     lever_force{current_trial_rank}=[lever_force{current_trial_rank} ...
%                                         [toc(trial_start);force_now]];
%                                     set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                                         'YData',lever_force{current_trial_rank}(2,:));
%                                     drawnow
%                                 end
%                             end
%                         elseif jackpot==0
%                             disp('single reward!')
%                             moto.trigger_feeder(1)
%                         elseif jackpot==-1
%                             disp('successful but no reward')
%                         end
%                         k=k+1;
%                     end
%                 end
%             end
%             max_value=max(lever_force{current_trial_rank}(2,:));
%             if success_trial==0
%                 time_to_success=nan;
%                 disp('end of hit window')
%                 disp('failed')
%                 fin_hit_window=tic;
%                 temps_post_reussite=2;
%                 while toc(fin_hit_window)<temps_post_reussite
%                     force_now=m*(moto.read_Pull()-b);
%                     lever_force{current_trial_rank}=[lever_force{current_trial_rank} ...
%                         [toc(trial_start);force_now]];
%                     set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                         'YData',lever_force{current_trial_rank}(2,:));
%                     drawnow
%                 end
%             else
%                 if jackpot==1
%                     temps_post_reussite=temps_mastication_pellet*5;
%                 else
%                     temps_post_reussite=temps_mastication_pellet;
%                 end
%                 while toc(moment_reussite)<temps_post_reussite
%                     force_now=m*(moto.read_Pull()-b);
%                     lever_force{current_trial_rank}=[lever_force{current_trial_rank} ...
%                         [toc(trial_start);force_now]];
%                     set(force_plot,'XData',lever_force{current_trial_rank}(1,:),...
%                         'YData',lever_force{current_trial_rank}(2,:));
%                     drawnow
%                 end
%             end
%             for i=1:6
%                 moto.trigger_stim(1)
%             end
%         end
%     end
%
%     if trial_started==1;
%         disp('end of trial'); fprintf('\n')
%         if success_trial==1
%             if jackpot==1
%                 pellet_dispensed=5;
%             elseif jackpot==0
%                 pellet_dispensed=1;
%             elseif jackpot==-1
%                 pellet_dispensed=0;
%             end
%         else
%             pellet_dispensed=nan;
%         end
%         results=[results [session_rank;current_trial;success_trial;max_value;time_to_success;pellet_dispensed;jackpot]];
%         results_all=[results_all results(:,end)];
%         [current_trial]=eval_performance(results_all);
%
%         %ajouté le 18 octobre 2017:
%         if animal_name=='jui-8-1' | animal_name=='jui-8-2'
%             if current_trial(1)==4
%                 if current_trial(4)>.8
%                     current_trial(4)=.8;
%                 end
%                 current_trial(5)=80;
%             end
%         end
%         if animal_name=='oct-4-2'
%             current_trial(2)=450;
%         end
%
%         set(threshold_line,'YData',[current_trial(5) current_trial(5)]);
%         set(hit_window_line,'XData',[current_trial(3) current_trial(3)]);
%         set(force_plot,'XData',0,'YData',0)
%         if current_trial(1)~=results(2,end) & current_trial(1)==4
%             xlim([-.5 15])
%             set(threshold_line,'XData',[-.5 15],'YData',[current_trial(5) current_trial(5)],'Color','red');
%         end
%         drawnow
%         trial_started=0; success_trial=0;current_trial_rank=size(results,2)+1;buffer_force=[];
%         if numel(results)>=1 & current_trial(2)~=results(3,end)
%             moto.autopositioner(current_trial(2))
%         end
%     end
%
% end
%
% %% Saving experiment
%
% disp('end of the session')
% if numel(results)~=0
%     disp(['number of successes: ', num2str(sum(results(7,:)))])
%     disp(['dispensed pellets: ', num2str(.045*nansum(results(10,:))),' grams'])
%     cd('D:\customized_behavioral_task_results'); %dossier où résultats
%     cd(animal_name)
%
%     nnn=char(beginning_session_time);
%     keep animal_name nnn results current_trial lever_force cno
%
%     if strfind(cno,'y')
%         save([animal_name,'_cno_',nnn(1:11),'_',nnn(end-7:end-6),'h',nnn(end-4:end-3),'m',nnn(end-1:end),'s.mat'])
%     else
%         save([animal_name,'_',nnn(1:11),'_',nnn(end-7:end-6),'h',nnn(end-4:end-3),'m',nnn(end-1:end),'s.mat'])
%     end
%
%     cd('C:\Users\TDT\Dropbox\EthierLab Team Folder\MotoTrak\customized_behavioral_task') %dossier scripts
% end
% close all

% succes_rate(results,3)
% succes_rate(results,4)