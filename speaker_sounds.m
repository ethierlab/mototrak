function sounds = speaker_sounds(freqs,duration,amplitude)
% This function returns a cell array of 'sounds' objects, with as many sounds as
% there are frequencies, in Hz, in the input vector 'freqs' vector, assigned to 
% the computer speaker audio device.
% 'duration' and 'amplitude' are scalars (same value for all sounds) or vectors
% with the same length as 'freqs' (to specify different values for each
% sound). 'duration' is in seconds, 'amplitude' is between 0 and 10
%
%   e.g. my_sounds = speaker_sounds([1000 5000 10000],[0.3 0.6 0.3],10);
%       

num_sounds = length(freqs);

if isscalar(duration)
    % only one duration provided, we assume it applies to all sounds
    duration = repmat(duration,num_sounds,1);
end

if isscalar(amplitude)
    % only one amplitude provided, we assume it applies to all sounds
    amplitude = repmat(amplitude,num_sounds,1);
end

%find speaker device
sound_devs=audiodevinfo;
speak_dev_idx = find(strncmpi({sound_devs.output.Name},'speakers',8),1,'first');
sound_dev_id = sound_devs.output(speak_dev_idx).ID;

sounds = cell(num_sounds,1);

for f = 1:num_sounds
    sounds{f}     =  create_sound_object(freqs(f),duration(f),amplitude(f),sound_dev_id);
end

