function [force_plot,force_fig,hit_line,hit_window_line]=create_lever_force_fig(force_target, hit_window)
x = 0;
y = 0;   
force_fig = figure;
force_plot = plot(x,y);
hit_line = line(x,y);
init_line = line(x,y);
hit_window_lines = line(x,y);
title('force exerted on the lever')
xlabel('trial time (s)')
ylabel('force (gr)')
xlim([-1 3])
ylim([-5 100])

set(hit_line,'XData',[-.5 10],'YData',[force_target force_target],'Color','red');
set(hit_window_lines,'XData',[0 0; hit_window hit_window],'YData',[-10 130; -10 130],'Color','grey');

% Feed_Button = uicontrol('Parent', force_fig, 'String', 'Feed','Units','normalized',...
%                             'Position', [.85 .85 .1 .1],'Callback',@Feed_Button_Callback,'Enable','on');

end

% si plus d'une figure, ajouter ax=axes... pour propriétés (title,
% xlabl... etc.)

%     set(force_plot,'XData',x,'YData',y);
%     set(threshold_line,'XData',xx,'YData',yy);
%     set(hit_window_line,'XData',xxx,'YData',yyy);