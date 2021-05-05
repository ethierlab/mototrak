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
moto   = GUI_h.moto;
GUI_h.params = [];
GUI_h.moto   = [];

%% Mototrak and sound initialization
if params.lever_pos > 4 || params.lever_pos < -2
    warning('specified lever position was %.2f, but it must be between -2 and 4 (cm)',params.lever_pos);
    return;
end
moto_reset = dialog('WindowStyle', 'normal','units','normalized','position',[.5 .5 .2 .1],'Name','Lever Positionning');
uicontrol(moto_reset,'style','text','string',sprintf('Repositionning lever\nPlease wait...'),'units','normalized','position',[0 0 1 0.75],'FontSize',16);
% reset position
% moto.autopositioner(0); %reset position
% drawnow;
% pause(8);

% move to specified position
moto.autopositioner(-100*(params.lever_pos-4.5));
if ishandle(moto_reset)
    close(moto_reset);
end
b=moto.baseline();
m=moto.cal_grams()/moto.n_per_cal_grams();

%  sounds = speaker_sounds(freqs,duration,amplitude);
trial_type_sounds = speaker_sounds(params.trial_type_sounds,0.3,10);
reward_sound      = speaker_sounds(params.reward_sound ,0.3,10);

%% Initialization

% current_trial = [level;position;hit window;hold time;threshold] -> from ME 'experiment.m' code
[force_plot,force_fig,threshold_line,hit_window_line]=create_lever_force_fig(params.force_target, params.hit_window);
reset_gui_counters(GUI_h);

% turn off trial LED
moto.lights(1);

% wait until user is ready to start
ready_start = msgbox('Click OK when ready to start!','Are you ready?','warn');
uiwait(ready_start);

experiment_start=tic;
loop_timer = tic;
experiment_start_time = datetime('now');
disp('experiment started!')

% structure to save all results, as well as experimental parameters
behav_stats = struct(...
    'params'            ,params,...
    'trial_type_labels' ,{params.trial_type},...
    'num_rewards_tt'    ,zeros(size(params.trial_type)),...
    'num_rewards_int'   ,zeros(size(params.trial_type)),...
    'num_pellets'       ,zeros(size(params.trial_type)),...
    'num_trials_tt'     ,zeros(size(params.trial_type)),...
    'num_trials_int'    ,zeros(size(params.trial_type)),...
    'start_time'        ,experiment_start_time, ...
    'duration'          ,0,...
    'trials_duration'   ,[],...
    'trials_lever_force',[],...
    'trials_success'    ,[],...
    'trials_hold_time'  ,[],...
    'trials_type'       ,[], ...
    'intervale_type'    ,[] ...
    );

% behav_stats = struct(...
%     'params'            ,params,...
%     'num_rewards_tt'       ,zeros(size(params.trial_type)),...
%     'num_rewards_int'       ,zeros(size(params.trial_type)),...
%     'num_pellets'       ,zeros(size(params.trial_type)),...
%     'num_trials_tt'        ,zeros(size(params.trial_type)),...
%     'num_trials_int'        ,zeros(size(params.trial_type)),...
%     'trials_duration'   ,{cell(size(params.trial_type))},...
%     'lever_force'       ,{cell(size(params.trial_type))},...
%     'hold_time'         ,{cell(size(params.trial_type))},...
%     'success'           ,{cell(size(params.trial_type))},...
%     'start_time'        ,experiment_start_time, ...
%     'duration'          ,0 ...
%     );
% trials_duration    = {};
% trials_lever_force = {};
% trials_hold_time   = {};
% trials_success     = {};
% trials_type        = {};

tmp_force_buffer   = [nan nan]; % [time force], first row is oldest data
trial_force_buffer = [nan nan]; % [time force]
trial_started      = false;
post_trial_pause   = false;
current_hold_time  = nan;
current_force      = nan;
current_distance   = nan;
pause_duration     = 0;
send_pellets       = 0;
force_before       = 0;
force_now          = 0;
last_pellet_time   = toc(experiment_start);
success_trial      = false;
man_pellets        = 0; % number of pellets given manually (feed button)
check               = 0;
set(GUI_h.stop_button,'userdata',0);
set(GUI_h.feed_button,'userdata',0);

try
    %% Main experiment loop
    while toc(experiment_start)<params.duration && ~GUI_h.stop_button.UserData && ishandle(force_plot)
        
        time_now     = toc(experiment_start);
        force_before = force_now;
        force_now    = m*(moto.read_Pull()-b);
        
        %limiter taille buffer temporaire à fbuf_dur
        tmp_force_buffer = [tmp_force_buffer(time_now-tmp_force_buffer(:,1)<=params.fbuf_dur,:); time_now force_now];
        
        % warn if longer than expected loop delays
        loop_time = toc(loop_timer);
        if loop_time > 0.1
            fprintf('--- WARNING --- \nlong delay in while loop (%.0f ms)\n',loop_time*1000);
        end
        loop_timer = tic;        
        
        %% trial initiation
        if ~trial_started && force_now >= params.init_thresh && force_before < params.init_thresh
            trial_started     = true;
            trial_start_time  = time_now;
            current_hold_time = min(params.hold_time,params.hold_time_max);
            current_force = min(params.force_target,params.force_max);
            current_distance = min(params.lever_pos,params.distance_max);
            
            % decide trial type
            if params.min_int == 0
                trial_type_select = 100*rand;
                for i=1:length(params.trial_type_pct)
                    if trial_type_select <= sum(params.trial_type_pct(1:i));
                        trial_type = i;
                        disp([ params.trial_type{i} ' trial initiated']);
                        behav_stats.num_trials(i) =  behav_stats.num_trials(i)+1;
                        break
                    end
                end
            else
                if params.synchronisation == false
            %  trials type and intervales independant               
                trial_type_select = 100*rand;
                    for i=1:length(params.trial_type_pct)
                        if trial_type_select <= sum(params.trial_type_pct(1:i));
                            trial_type = i;
                            disp([ params.trial_type{i} ' trial initiated']);
                            behav_stats.num_trials(i) =  behav_stats.num_trials(i)+1;
                            break
                        end
                    end
                intervale_type_select = 100*rand;
                    for i=1:length(params.intervale_type_pct)
                        if intervale_type_select <= sum(params.intervale_type_pct(1:i));
                            intervale_type = i;
                            disp([ params.intervale_type{i} ' intervale initiated']);
                            behav_stats.num_intervale(i) =  behav_stats.num_intervale(i)+1;
                            break
                        end
                    end
                else
                    
             % trials type and intervales corelate
                    trial_type_select = 100*rand;
                    for i=1:length(params.trial_type_pct)
                        if trial_type_select <= sum(params.trial_type_pct(1:i));
                            trial_type = i;
                            disp([ params.trial_type{i} ' trial initiated']);
                            behav_stats.num_trials(i) =  behav_stats.num_trials(i)+1;
                            intervale_type = i;
                            disp([ params.intervale_type{i} ' intervale initiated']);
                            behav_stats.num_intervale(i) =  behav_stats.num_intervale(i)+1;
                            break
                        end
                    end
                                        
                end
                
            end
            % send corresponding sound and lights
            
            if params.sound == true
            play(trial_type_sounds{trial_type});
            end
            moto.lights(0)
            
            % send digital pulses out
            for i = 1:params.trial_type_digout(trial_type)
                moto.trigger_stim(1);
            end
            
            fprintf('Hold time : %.0f ms\n',current_hold_time*1000);
            
            % update GUI
            eval( ['GUI_h.tt' num2str(trial_type) '_num_trials_txt.String =  behav_stats.num_trials(trial_type);']);
            eval( ['GUI_h.int' num2str(intervale_type) '_num_intervale_txt.String =  behav_stats.num_trials(intervale_type);']);
            % start recording force
            trial_force_buffer = [tmp_force_buffer(:,1)-trial_start_time tmp_force_buffer(:,2)];
        end
        
        %% ongoing trial
        if trial_started
            
            trial_time = time_now-trial_start_time;
            trial_force_buffer = [trial_force_buffer; trial_time force_now];
            
            if post_trial_pause
                % turn off trial LED
                moto.lights(1);
                
                if trial_time-trial_end_time > pause_duration && ~send_pellets              
                    %pause is over, trial is over. fill result structure and start new trial
                    behav_stats.trials_duration    = [behav_stats.trials_duration; {trial_end_time}];
                    behav_stats.trials_lever_force = [behav_stats.trials_lever_force; {trial_force_buffer}];
                    behav_stats.trials_hold_time   = [behav_stats.trials_hold_time; {current_hold_time}];
                    behav_stats.trials_success     = [behav_stats.trials_success; {success_trial}];
                    behav_stats.trials_type        = [behav_stats.trials_type; {trial_type}];
                    behav_stats.intervale_type     = [behav_stats.intervale_type; {intervale_type}];
                    
                    %reset trial variables
                    post_trial_pause   = false;
                    trial_started      = false;
                    success_trial      = false;
                    trial_force_buffer = [nan nan];
                    
                    % send digital pulses out
                    for i=1:6
                        moto.trigger_stim(1);
                    end
                end
            else
                
                %force target LED
                if params.min_int.value == 1
                    if force_now > params.force_target
                        moto.sound_1000(1);
                        force_ok=1;
                    else
                        force_ok=0;
                    end
                else
                    if force_now > params.min_intervale(intervale_type) && force_now < params.max_intervale(intervale_type)
                        moto.sound_1000(1);
                        force_ok=1;
                        else
                        force_ok=0;
                    end
                end
                             
                    
                
                % Failed?
                
                if trial_time > params.hit_window && force_ok == 0
                    %trial failed
                    fprintf('trial failed\n\n');
                    post_trial_pause = true;
                    trial_end_time   = trial_time;
                    % pause_duration   = params.mastication_time;
                    pause_duration   = 0;
                    params.past_10_trials_succ = [false params.past_10_trials_succ(1:end-1)];
                    
                %decrease hold_time?
                    if params.adapt_hold_time && sum(params.past_10_trials_succ)<=3
                        % less than 40% success rate, decrease hold time by 1%.
                        % update hold time
                        params.hold_time = current_hold_time * 0.99;
                        set(GUI_h.hold_time_edit,'String',num2str(params.hold_time*1000));
                    end
                    
                    %decrease lever distance?
                    if params.adapt_distance && sum(params.past_10_trials_succ)<=3
                        % less than 40% success rate, decrease distance by 0.5 if distance >0.
                        % update lever distance
                        if current_distance >0
                            params.distance = current_distance -0.5;
                        end
                        set(GUI_h.lever_pos_edit,'String',num2str(params.distance));
                    end
                    
                    %decrease force?
                    if params.adapt_force && sum(params.past_10_trials_succ)<=3
                        % less than 40% success rate, decrease force by 1%.
                        % update force
                        params.hold_time = current_force * 0.99;
                        set(GUI_h.force_level_edit,'String',num2str(params.force));
                    end
                end
                
                % Success?
                % if we are at least 'hold_time' past trial init, and if force was always above 'force_target'
                % for the last 'hold_time'...
                if params.min_int.value == 1
                    if all( trial_force_buffer( trial_force_buffer(:,1)>=trial_time-current_hold_time ,2)>= params.force_target)
                        check =1;
                    else
                        check =0;
                    end
                else
                    if all( trial_force_buffer( trial_force_buffer(:,1)>=trial_time-current_hold_time ,2)>= params.min_intervale(intervale_type)) && ...
                            all( trial_force_buffer( trial_force_buffer(:,1)>=trial_time-current_hold_time ,2)<= params.max_intervale(intervale_type))
                        check =1;
                    else
                        check =0;
                    end                    
                end
                
                  
                if trial_time >= current_hold_time && check == 1
                    % we have a success
                    fprintf('trial successful!\n\n');
                    
                    play(reward_sound{1});
                    success_trial  = true;
                    trial_end_time = trial_time;
                    send_pellets   = params.num_pellets(trial_type);
                    params.past_10_trials_succ = [true params.past_10_trials_succ(1:end-1)];
                    
                    % send digital pulses out
                    for i=1:3
                        moto.trigger_stim(1);
                    end
                    
                    %update stats
                    behav_stats.num_rewards_tt(trial_type)     = behav_stats.num_rewards_tt(trial_type)+1;
                    behav_stats.num_pellets(trial_type)     = behav_stats.num_pellets(trial_type)+params.num_pellets(trial_type);
                    behav_stats.num_rewards_int(intervale_type)     = behav_stats.num_rewards_int(intervale_type)+1;
                    
                    % update GUI stats
                    set(GUI_h.pellets_delivered_txt,'String', sprintf('%d (%.3f g)', ...
                        sum(behav_stats.num_pellets)+man_pellets, (sum(behav_stats.num_pellets)+man_pellets)*0.045));
                    eval( ['GUI_h.tt' num2str(trial_type) '_num_rew_txt.String =  behav_stats.num_rewards_tt(trial_type);']);
                    eval( ['GUI_h.int' num2str(intervale_type) '_num_rew_txt.String =  behav_stats.num_rewards_int(intervale_type);']);
                    
                    %force pause
                    post_trial_pause = true;
%                    pause_duration = max(params.mastication_time*[1 params.num_pellets(trial_type)]);
                     pause_duration = max(2,params.mastication_time*params.num_pellets(trial_type));
                    % pause is at least 1x mastication time, or more if more than 1 pellet
                    
                    %increase hold_time?
                    if params.adapt_hold_time && sum(params.past_10_trials_succ)>=5
                        % more than 60% success rate, increase hold time.
                        params.hold_time = min(params.hold_time_max, current_hold_time * 1.02);
                        %clear success flags to avoid multiple increases in a row ?
                        %->not now. Allowing multiple increase/decrease in a row.
                        % params.past_10_trials_succ = false(1,10);
                        % update hold time
                        set(GUI_h.hold_time_edit,'String',num2str(params.hold_time*1000));
                    end
                    
                    %increase distance?
                    if params.adapt_distance && sum(params.past_10_trials_succ)>=5
                        % more than 60% success rate, increase distance.
                        params.distance = min(params.distance_max, current_distance +0.5);
                        %clear success flags to avoid multiple increases in a row ?
                        %->not now. Allowing multiple increase/decrease in a row.
                        % params.past_10_trials_succ = false(1,10);
                        % update lever distance
                        set(GUI_h.lever_pos_edit,'String',num2str(params.distance));
                    end
                    
                    %increase force?
                    if params.adapt_force && sum(params.past_10_trials_succ)>=5
                        % more than 60% success rate, increase force.
                        params.force = min(params.force_max, current_force * 1.02);
                        %clear success flags to avoid multiple increases in a row ?
                        %->not now. Allowing multiple increase/decrease in a row.
                        % params.past_10_trials_succ = false(1,10);
                        % update force
                        set(GUI_h.force_level_edit,'String',num2str(params.force));
                    end
                end
            end
        end
        
        % give pellets when needed
        if send_pellets && time_now-last_pellet_time>params.pellets_pause
            moto.trigger_feeder(1);
            last_pellet_time = time_now;
            send_pellets = send_pellets-1;
        end
        
        % update force fig
        if ishandle(force_plot)
            set(force_plot,'XData', trial_force_buffer(:,1),...
                'YData',trial_force_buffer(:,2));
        end
            
        % update GUI
        set(GUI_h.time_elapsed_txt,'String',datestr(time_now/86400,'HH:MM:SS'));
        
        % check feed button
        if get(GUI_h.feed_button,'userdata')
            set(GUI_h.feed_button,'userdata',0);
            moto.trigger_feeder(1);
            man_pellets = man_pellets + 1;
            set(GUI_h.pellets_delivered_txt,'String', sprintf('%d (%.3f g)', ...
                sum(behav_stats.num_pellets)+man_pellets, (sum(behav_stats.num_pellets)+man_pellets)*0.045));
        end
        
%         % update params from GUI
        if ~isempty(get(GUI_h.start_button,'userdata'))
            params = GUI_h.start_button.UserData;
            set(GUI_h.start_button,'userdata',[]);
        end
            
        
        drawnow limitrate; %update GUI and force fig
        
    end
    
    %% end of session: display and save results
    
     % turn off trial LED
     moto.lights(1);
                
    disp('session ended');
    behav_stats.duration = time_now;
    fprintf('duration: %s\n\n',datestr(time_now/86400,'HH:MM:SS'));
    disp('result summary:');
    disp('type      trials  rewards  pellets');
    for i=1:length(params.trial_type)
        disp([params.trial_type{i} sprintf('\t\t%d',behav_stats.num_trials(i))...
            sprintf('\t\t%d(%.2f%%)',behav_stats.num_rewards(i),behav_stats.num_rewards(i)/behav_stats.num_trials(i)*100)...
            sprintf('\t\t%d',behav_stats.num_pellets(i))]);
    end
    fprintf('manual feeding: %d pellets\n', man_pellets);
    fprintf('total pellets: %d (%.2fg)\n',...
        sum(behav_stats.num_pellets)+man_pellets, (sum(behav_stats.num_pellets)+man_pellets)*0.045);
    fprintf('overall sucess rate: %.2f\n\n', sum(behav_stats.num_rewards)/sum(behav_stats.num_trials)*100);
    
    %save updated params & results
    save_params_and_results(GUI_h,params,behav_stats,experiment_start_time,0);
    
    % cleanup
    %fclose(moto.serialcon);
    if ishandle(force_fig)
        close(force_fig);
    end
    
catch ME
    %fclose(moto.serialcon);
    if ishandle(force_fig)
        close(force_fig);
    end
    GUI_h.start_button.UserData = [];
    GUI_h.start_button.String = 'START';
    save_params_and_results(GUI_h,params,behav_stats,experiment_start_time,1);
    rethrow(ME);
end

end

function save_params_and_results(GUI_h,params,behav_stats,experiment_start_time,crashed)

%reset the start button
GUI_h.start_button.UserData = [];
GUI_h.start_button.String = 'START';

if crashed
    SaveButton = questdlg(sprintf('mototrak_diff_reward_crashed!\n Save files?'), 'Shit Happens', 'Yes','No','Yes');
else
    SaveButton = questdlg(sprintf('End of behavioral session\nSave files?'), 'End of Seesion', 'Yes','No','Yes');
end
if strcmp(SaveButton,'Yes')
    if params.cno
        fname = [params.animal_name '_cno_' datestr(experiment_start_time,'yyyymmdd_HHMMSS')];
    else
        fname = [params.animal_name,'_',datestr(experiment_start_time,'yyyymmdd_HHMMSS')];
    end
    save(fullfile(params.save_dir,['params_' fname]),'-struct','params');
    save(fullfile(params.save_dir,['behav_stats_' fname]),'-struct','behav_stats');

    disp('behavior stats and parameters saved successfully');
else
    disp('behavior stats and parameters not saved');
end
end
