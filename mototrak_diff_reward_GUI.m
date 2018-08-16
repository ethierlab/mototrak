function varargout = mototrak_diff_reward_GUI(varargin)
% MOTOTRAK_DIFF_REWARD_GUI MATLAB code for mototrak_diff_reward_GUI.fig
%      MOTOTRAK_DIFF_REWARD_GUI, by itself, creates a new MOTOTRAK_DIFF_REWARD_GUI or raises the existing
%      singleton*.
%
%      H = MOTOTRAK_DIFF_REWARD_GUI returns the handle to a new MOTOTRAK_DIFF_REWARD_GUI or the handle to
%      the existing singleton*.
%
%      MOTOTRAK_DIFF_REWARD_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOTOTRAK_DIFF_REWARD_GUI.M with the given input arguments.
%
%      MOTOTRAK_DIFF_REWARD_GUI('Property','Value',...) creates a new MOTOTRAK_DIFF_REWARD_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mototrak_diff_reward_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mototrak_diff_reward_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mototrak_diff_reward_GUI

% Last Modified by GUIDE v2.5 17-Jul-2018 15:36:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mototrak_diff_reward_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mototrak_diff_reward_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before mototrak_diff_reward_GUI is made visible.
function mototrak_diff_reward_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mototrak_diff_reward_GUI (see VARARGIN)

% Choose default command line output for mototrak_diff_reward_GUI
handles.output = hObject;

handles.moto=Connect_MotoTrak;
if isempty(handles.moto)
    warning('No mototrak connection');
end

% update GUI with all_params:
handles = update_GUI_from_params(handles);

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = mototrak_diff_reward_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Buttons
function start_button_Callback(hObject, eventdata, handles)
% hObject    handle to start_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%update params with GUI data:
handles.params = update_params_from_GUI(handles,handles.params);

switch hObject.String
    case 'UPDATE'
        hObject.UserData = handles.params;
    case 'START'

        %increase params.session_number as we start a new one
        handles.params.session_number = handles.params.session_number+1;
        handles.session_number_txt.String = num2str(handles.params.session_number);
        % reset counters
        reset_gui_counters(handles);

        %shuffle pseudo-random number generator to avoid same order of trials from
        %one session to the next
        rng('shuffle','twister');
        
        %change text to 'update'
        hObject.String = 'UPDATE';
        hObject.UserData = [];
        %start experiment:
        mototrak_diff_reward(handles);
    otherwise
        disp('something is wrong with this button');
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in stop_button.
function stop_button_Callback(hObject, eventdata, handles)
% hObject    handle to stop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.start_button.String = 'START';
set(hObject,'userdata',1);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in feed_button.
function feed_button_Callback(hObject, eventdata, handles)
% hObject    handle to feed_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(gcbo,'userdata',1);

% --- Executes on button press in browse_button.
function browse_button_Callback(hObject, eventdata, handles)
% hObject    handle to browse_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

save_dir = uigetdir(handles.save_dir_edit.String, 'Select folder in which to save the behavioral results');
if ~isempty(save_dir)
    handles.save_dir_edit.String=save_dir;
end

% --- Executes on button press in load_button.
function load_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load params
[loadfile,loaddir] = uigetfile('D:\customized_behavioral_task_results\*.mat','Which param file?');

if loadfile
    params = load(fullfile(loaddir,loadfile));
    % update GUI from params
    handles = update_GUI_from_params(handles,params);
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% update params from GUI
params = update_params_from_GUI(handles);
savefile = fullfile(params.save_dir,['params_' params.animal_name '_' datestr(now,'yyyymmdd_HHMMSS')]);

% save params
[savefile,savedir] = uiputfile('*.mat','Where do you want to save the params?',savefile);
if savefile
    save(fullfile(savedir,savefile),'-struct','params');
    disp(['param file "' fullfile(savedir,savefile) '" saved successfully']);
else
    disp('save cancelled');
end

% --- Executes on button press in clear_button.
function clear_button_Callback(hObject, eventdata, handles)
params = mototrak_diff_reward_default_params;
handles = update_GUI_from_params(handles);
% Update handles structure
guidata(hObject, handles);


%% toggle trial lines visibility depending on the number of trial types wanted
function toggle_tt_visible(num_tt,handles)

tog_vis = {'on','off','off','off','off'};

for i = 2:num_tt
    tog_vis{i} = 'on';
end

for i = 2:5
    eval( [ 'set(handles.tt' num2str(i) '_label_edit,''Visible'',tog_vis{i})']);
    eval( [ 'set(handles.tt' num2str(i) '_init_tone_edit,''Visible'', tog_vis{i})']);
    eval( [ 'set(handles.tt' num2str(i) '_pct_trials_edit,''Visible'', tog_vis{i})']);
    eval( [ 'set(handles.tt' num2str(i) '_num_pellets_edit,''Visible'', tog_vis{i})']);
    eval( [ 'set(handles.tt' num2str(i) '_num_trials_txt,''Visible'', tog_vis{i})']);
    eval( [ 'set(handles.tt' num2str(i) '_num_rew_txt,''Visible'', tog_vis{i})']);
end



%% update all the gui using selected parameters
function handles = update_GUI_from_params(handles,varargin)

if nargin>1
    params = varargin{1};
else
    params = [];
end

% fill missing values with defaults:
params = mototrak_diff_reward_default_params(params);

% replace new parameters in handles
handles.params = params;

% all params :
% ... %modifiable params
% 'animal_name'       , 'jan-01-01',...
% 'trial_type'        , {{'jackpot', 'single', 'no_reward'}},...
% 'trial_type_pct'    , [25 50 25],...
% 'num_pellets'       , [5 1 0],...
% 'trial_type_sounds' , [13000 7000 10000],...
% 'hit_window'        , 5,...
% 'cno'               , false,...
% 'duration'          , 40*60,...
% 'force_target'      , 80,...
% 'hold_time'         , 0.8,...
% 'adapt_hold_time'     , true,...
% 'hold_time_max'     , 0.8,...
% 'lever_pos'         , 350, ...
% 'save_dir'          , 'D:\customized_behavioral_task_results\jan-01-01\', ...
% ... % fixed params
% 'trial_type_digout' , [2 1 7],... %number of digital pulses for each trial type
% 'reward_sound'      , 4000 ,...
% 'mastication_time'  , 5,...
% 'pellets_pause'     , 1.5,...
% 'init_thresh'       , 10,...
% 'task_level'        , 4,...
% 'fbuf_dur'          , 0.5 ...

set(handles.animal_name_edit,'String',params.animal_name);
num_tt = length(params.trial_type);
toggle_tt_visible(num_tt,handles);
set(handles.num_trial_type_pop,'Value',num_tt);
for i = 1:num_tt
    eval( [ 'set(handles.tt' num2str(i) '_label_edit,''String'', params.trial_type{i})']);
    eval( [ 'set(handles.tt' num2str(i) '_pct_trials_edit,''String'', params.trial_type_pct(i))']);
    eval( [ 'set(handles.tt' num2str(i) '_num_pellets_edit,''String'', params.num_pellets(i))']);
    eval( [ 'set(handles.tt' num2str(i) '_init_tone_edit,''String'', params.trial_type_sounds(i))']);
end
set(handles.hit_window_edit,'String',params.hit_window);
set(handles.cno_cbx,'Value',params.cno);
set(handles.save_dir_edit,'String',params.save_dir);
set(handles.duration_edit,'String',params.duration/60);
set(handles.force_level_edit,'String',params.force_target);
set(handles.hold_time_edit,'String',params.hold_time*1000);
set(handles.adapt_hold_time_cbx,'Value',params.adapt_hold_time);
set(handles.hold_time_max_edit,'String',params.hold_time_max*1000);
set(handles.lever_pos_edit,'String',params.lever_pos);
set(handles.save_dir_edit,'String',params.save_dir);
set(handles.session_number_txt,'String',num2str(params.session_number));

% reset all counters
reset_gui_counters(handles);

function params = update_params_from_GUI(handles,varargin)
if nargin>1
    params = varargin{1};
else
    params = [];
end

% ... %modifiable params
% 'animal_name'       , 'jan-01-01',...
% 'trial_type'        , {{'jackpot', 'single', 'no_reward'}},...
% 'trial_type_pct'    , [25 50 25],...
% 'num_pellets'       , [5 1 0],...
% 'trial_type_sounds' , [13000 7000 10000],...
% 'hit_window'        , 5,...
% 'cno'               , false,...
% 'duration'          , 40*60,...
% 'force_target'      , 80,...
% 'hold_time'         , 0.8,...
% 'adapt_hold_time'     , true,...
% 'hold_time_max'     , 0.8,...
% 'lever_pos'         , 350, ...
% 'save_dir'          , 'D:\customized_behavioral_task_results\jan-01-01\'

params.animal_name = handles.animal_name_edit.String;
num_tt = handles.num_trial_type_pop.Value;
params.trial_type        = cell(1,num_tt);
params.trial_type_pct    = nan(1,num_tt);
params.num_pellets       = nan(1,num_tt);
params.trial_type_sounds = nan(1,num_tt);
for i = 1:num_tt
    params.trial_type{i}        = eval( [ 'handles.tt' num2str(i) '_label_edit.String']);
    params.trial_type_pct(i)    = str2double( eval( [ 'handles.tt' num2str(i) '_pct_trials_edit.String']) );
    params.num_pellets(i)       = str2double( eval( [ 'handles.tt' num2str(i) '_num_pellets_edit.String']));
    params.trial_type_sounds(i) = str2double( eval( [ 'handles.tt' num2str(i) '_init_tone_edit.String'])  );
end
params.hit_window    = str2double(handles.hit_window_edit.String);
params.cno           = handles.cno_cbx.Value;
params.duration      = 60*str2double(handles.duration_edit.String);
params.force_target  = str2double(handles.force_level_edit.String);
params.hold_time     = 0.001*str2double(handles.hold_time_edit.String);
params.adapt_hold_time = handles.adapt_hold_time_cbx.Value;
params.lever_pos     = str2double(handles.lever_pos_edit.String);
params.hold_time_max = 0.001*str2double(handles.hold_time_max_edit.String);
params.save_dir      = handles.save_dir_edit.String;
params.session_number= str2double(handles.session_number_txt.String);

% fill missing values with defaults:
params = mototrak_diff_reward_default_params(params);

function animal_name_edit_Callback(hObject, eventdata, handles)
rat = hObject.String;
%load last params for that rat if a folder with his name is
% found in D:\customized_behavioral_task_results\
defdir = ['D:\customized_behavioral_task_results\' rat];
if isdir(defdir)
    fprintf('loading previous data for rat ''%s''\n',rat);
    d = dir([defdir '\params*.mat']);
    if isempty(d)
        fprintf('No ''params*.mat'' file found in "%s"\n',defdir);
    else
        [~,I] = sort(vertcat(d.datenum));
        latest_param_file = d(I(end)).name;
        params = load(fullfile(defdir,latest_param_file));
        % update GUI from params
        handles = update_GUI_from_params(handles,params);
        % Update handles structure
        guidata(hObject, handles);      
    end
else
    fprintf('No record of rat ''%s''\n',rat);
end

function animal_name_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cno_cbx_Callback(hObject, eventdata, handles)

function num_trial_type_pop_Callback(hObject, eventdata, handles)
num_tt = get(hObject,'Value');
toggle_tt_visible(num_tt,handles);

function num_trial_type_pop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function duration_edit_Callback(hObject, eventdata, handles)
function duration_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function force_level_edit_Callback(hObject, eventdata, handles)
function force_level_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hold_time_edit_Callback(hObject, eventdata, handles)
function hold_time_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function save_dir_edit_Callback(hObject, eventdata, handles)
function save_dir_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tt1_num_pellets_edit_Callback(hObject, eventdata, handles)
function tt2_num_pellets_edit_Callback(hObject, eventdata, handles)
function tt3_num_pellets_edit_Callback(hObject, eventdata, handles)
function tt4_num_pellets_edit_Callback(hObject, eventdata, handles)
function tt5_num_pellets_edit_Callback(hObject, eventdata, handles)

function tt1_num_pellets_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt2_num_pellets_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt3_num_pellets_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt4_num_pellets_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt5_num_pellets_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tt1_pct_trials_edit_Callback(hObject, eventdata, handles)
function tt1_pct_trials_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt2_pct_trials_edit_Callback(hObject, eventdata, handles)
function tt2_pct_trials_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt3_pct_trials_edit_Callback(hObject, eventdata, handles)
function tt3_pct_trials_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt4_pct_trials_edit_Callback(hObject, eventdata, handles)
function tt4_pct_trials_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt5_pct_trials_edit_Callback(hObject, eventdata, handles)
function tt5_pct_trials_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tt1_init_tone_edit_Callback(hObject, eventdata, handles)
function tt1_init_tone_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt2_init_tone_edit_Callback(hObject, eventdata, handles)
function tt2_init_tone_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt3_init_tone_edit_Callback(hObject, eventdata, handles)
function tt3_init_tone_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt4_init_tone_edit_Callback(hObject, eventdata, handles)
function tt4_init_tone_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt5_init_tone_edit_Callback(hObject, eventdata, handles)
function tt5_init_tone_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt1_label_edit_Callback(hObject, eventdata, handles)
function tt1_label_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt2_label_edit_Callback(hObject, eventdata, handles)
function tt2_label_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt3_label_edit_Callback(hObject, eventdata, handles)
function tt3_label_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt4_label_edit_Callback(hObject, eventdata, handles)
function tt4_label_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tt5_label_edit_Callback(hObject, eventdata, handles)
function tt5_label_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function adapt_hold_time_cbx_Callback(hObject, eventdata, handles)

function hit_window_edit_Callback(hObject, eventdata, handles)
function hit_window_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hold_time_max_edit_Callback(hObject, eventdata, handles)
function hold_time_max_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lever_pos_edit_Callback(hObject, eventdata, handles)
function lever_pos_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit7_Callback(hObject, eventdata, handles)
function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit8_Callback(hObject, eventdata, handles)
function edit8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit10_Callback(hObject, eventdata, handles)
function edit10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit11_Callback(hObject, eventdata, handles)
function edit11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
