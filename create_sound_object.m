function sound_object = create_sound_object(frequency,duration,amplitude,indice_speaker) %Hz,seconds,0-1
fs = frequency*10;
t = 0:(1/fs):duration;
y = amplitude*sin(2*pi*frequency*t);
sound_object=audioplayer(y,fs,24,indice_speaker);
end