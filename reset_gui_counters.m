function reset_gui_counters(GUI_h)
% this function resets the pellets, time, num trials and num rewards
% counters on mototrak_diff_reward_GUI to zero

num_pellets  = 0;
time_elapsed = 0;
num_trials   = [0 0 0 0 0];
num_rewards  = [0 0 0 0 0];

GUI_h.pellets_delivered_txt.String = sprintf('%d (%.3f g)', num_pellets, num_pellets*0.045);
GUI_h.time_elapsed_txt.String      = datestr(time_elapsed,'HH:MM:SS');

for trial_type = 1:5
    eval( ['GUI_h.tt' num2str(trial_type) '_num_trials_txt.String =  num_trials(trial_type);']);
    eval( ['GUI_h.tt' num2str(trial_type) '_num_rew_txt.String =  num_rewards(trial_type);']);
end


end

