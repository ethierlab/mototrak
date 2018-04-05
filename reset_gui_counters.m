function reset_gui_counters(GUI_h)

 set(GUI_h.pellets_delivered_txt,'String', '0 (0.000 g)');
 set(GUI_h.time_elapsed_txt,'String','00:00:00');
 drawnow;