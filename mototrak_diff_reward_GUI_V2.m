function varargout = mototrak_diff_reward_GUI_V2(varargin)
% MOTOTRAK_DIFF_REWARD_GUI_V2 MATLAB code for mototrak_diff_reward_GUI_V2.fig
%      MOTOTRAK_DIFF_REWARD_GUI_V2, by itself, creates a new MOTOTRAK_DIFF_REWARD_GUI_V2 or raises the existing
%      singleton*.
%
%      H = MOTOTRAK_DIFF_REWARD_GUI_V2 returns the handle to a new MOTOTRAK_DIFF_REWARD_GUI_V2 or the handle to
%      the existing singleton*.
%
%      MOTOTRAK_DIFF_REWARD_GUI_V2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOTOTRAK_DIFF_REWARD_GUI_V2.M with the given input arguments.
%
%      MOTOTRAK_DIFF_REWARD_GUI_V2('Property','Value',...) creates a new MOTOTRAK_DIFF_REWARD_GUI_V2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mototrak_diff_reward_GUI_V2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mototrak_diff_reward_GUI_V2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mototrak_diff_reward_GUI_V2

% Last Modified by GUIDE v2.5 03-Jul-2019 11:03:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mototrak_diff_reward_GUI_V2_OpeningFcn, ...
                   'gui_OutputFcn',  @mototrak_diff_reward_GUI_V2_OutputFcn, ...
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


% --- Executes just before mototrak_diff_reward_GUI_V2 is made visible.
function mototrak_diff_reward_GUI_V2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mototrak_diff_reward_GUI_V2 (see VARARGIN)

% Choose default command line output for mototrak_diff_reward_GUI_V2
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
function varargout = mototrak_diff_reward_GUI_V2_OutputFcn(hObject, eventdata, handles) 
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
        mototrak_diff_reward_V2(handles);
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
params = mototrak_diff_reward_default_params_V2;
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

%% toggle intervale lines visibility depending on the number of intervale types wanted
function toggle_int_visible(num_int,handles)

tog_vis = {'on','off','off','off','off'};

for i = 2:num_int
    tog_vis{i} = 'on';
end

for i = 2:5
    eval( [ 'set(handles.int' num2str(i) '_label_edit,''Visible'',tog_vis{i})']);
    eval( [ 'set(handles.int' num2str(i) '_min_edit,''Visible'', tog_vis{i})']);
    eval( [ 'set(handles.int' num2str(i) '_pct_edit,''Visible'', tog_vis{i})']);
    eval( [ 'set(handles.int' num2str(i) '_max_edit,''Visible'', tog_vis{i})']);
    eval( [ 'set(handles.int' num2str(i) '_num_trials_txt,''Visible'', tog_vis{i})']);
    eval( [ 'set(handles.int' num2str(i) '_num_rew_txt,''Visible'', tog_vis{i})']);
end

%% update all the gui using selected parameters
function handles = update_GUI_from_params(handles,varargin)

if nargin>1
    params = varargin{1};
else
    params = [];
end

% fill missing values with defaults:
params = mototrak_diff_reward_default_params_V2(params);

% replace new parameters in handles
handles.params = params;

% all params :
%         ... %modifiable params
%         'animal_name'        , 'jan-01-01',...
%         'trial_type'         , {{'jackpot', 'single', 'no_reward'}},...
%         'trial_type_pct'     , [25 50 25],...
%         'num_pellets'        , [5 1 0],...
%         'trial_type_sounds'  , [7000 10000 13000],...
%         'trial_type_digout'  , [2 1 7],... %number of digital pulses for each trial type
%         'intervale_type'     , {{'intervale_1'}},...
%         'min_intervale'      , [15 ],...
%         'max_intervale'      , [200],...
%         'intervale_type_pct' , [100],...
%         'hit_window'         , 5,...
%         'cno'                , false,...
%         'duration'           , 30*60,...
%         'force_target'       , 80,...
%         'hold_time'          , 0.8,...
%         'adapt_hold_time'    , false,...
%         'hold_time_max'      , 0.8,...        
%         'adapt_force'        , false,...
%         'force_max'          , 80,...
%         'adapt_distance'     , false,...
%         'distance_max'       , 0.75,...
%         'lever_pos'          , 0.75,...  
%         'min_int'            , 1,...
%         'sound'              , true,...
%         'synchronisation'    , false,...
%         ... % fixed params
%         'session_number'     , 0,...
%         'past_10_trials_succ', false(1,10),...
%         'reward_sound'       , 4000 ,...
%         'mastication_time'   , 7,...
%         'pellets_pause'      , 1.5,...
%         'init_thresh'        , 10,...
%         'task_level'         , 4,...
%         'save_dir'           , 'D:\customized_behavioral_task_results\jan-01-01\', ...
%         'fbuf_dur'           , 0.5 ...

set(handles.animal_name_edit,'String',params.animal_name);
num_tt = length(params.trial_type);
num_int = length(params.intervale_type);
toggle_tt_visible(num_tt,handles);
toggle_int_visible(num_int,handles);
set(handles.num_trial_type_pop,'Value',num_tt);
set(handles.num_intervale_type_pop,'Value',num_int);
for i = 1:num_int
    eval( [ 'set(handles.int' num2str(i) '_label_edit,''String'', params.intervale_type{i})']);
    eval( [ 'set(handles.int' num2str(i) '_pct_edit,''String'', params.intervale_type_pct(i))']);
    eval( [ 'set(handles.int' num2str(i) '_min_edit,''String'', params.min_intervale(i))']);
    eval( [ 'set(handles.int' num2str(i) '_max_edit,''String'', params.max_intervale(i))']);
end
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
set(handles.adapt_force_cbx,'Value',params.adapt_force);
set(handles.force_max_edit,'String',params.force_max);
set(handles.hold_time_edit,'String',params.hold_time*1000);
set(handles.adapt_hold_time_cbx,'Value',params.adapt_hold_time);
set(handles.hold_time_max_edit,'String',params.hold_time_max*1000);
set(handles.lever_pos_edit,'String',params.lever_pos);
set(handles.adapt_distance_cbx,'Value',params.adapt_distance);
set(handles.distance_max_edit,'String',params.distance_max);
set(handles.save_dir_edit,'String',params.save_dir);
set(handles.session_number_txt,'String',num2str(params.session_number));
set(handles.sound_cbx,'Value',params.adapt_force);
set(handles.synchronisation_cbx,'Value',params.adapt_force);

minforceradio_fnc (params.min_int,handles);

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
% 'intervale_type'     , {{'intervale_1', 'intervale_2'}},...
% 'min_intervale'      , [15 0],...
% 'max_intervale'      , [200 0],...
% 'intervale_type_pct' , [100 0 ],...
% 'hit_window'        , 5,...
% 'cno'               , false,...
% 'duration'          , 40*60,...
% 'force_target'      , 80,...
% 'adapt_hold_time'   , false,...
% 'hold_time_max'     , 80,...
% 'hold_time'         , 0.8,...
% 'adapt_hold_time'   , false,...
% 'hold_time_max'     , 0.8,...
% 'lever_pos'         , 350, ...
% 'adapt_distance'    , false,...
% 'distance_max'      , 350,...
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
num_int = handles.num_intervale_type_pop.Value;
params.intervale_type        = cell(1,num_int);
params.intervale_type_pct    = nan(1,num_int);
params.min_intervale         = nan(1,num_int);
params.max_intervale         = nan(1,num_int);
for i = 1:num_tt
    params.intervale_type{i}        = eval( [ 'handles.int' num2str(i) '_label_edit.String']);
    params.intervale_type_pct(i)    = str2double( eval( [ 'handles.int' num2str(i) '_pct_edit.String']) );
    params.min_intervale(i)         = str2double( eval( [ 'handles.int' num2str(i) '_min_edit.String']));
    params.max_intervale(i)         = str2double( eval( [ 'handles.int' num2str(i) '_max_edit.String'])  );
end
params.hit_window    = str2double(handles.hit_window_edit.String);
params.cno           = handles.cno_cbx.Value;
params.duration      = 60*str2double(handles.duration_edit.String);
params.force_target  = str2double(handles.force_level_edit.String);
params.adapt_force = handles.adapt_force_cbx.Value;
params.force_max = str2double(handles.force_max_edit.String);
params.hold_time     = 0.001*str2double(handles.hold_time_edit.String);
params.adapt_hold_time = handles.adapt_hold_time_cbx.Value;
params.hold_time_max = 0.001*str2double(handles.hold_time_max_edit.String);
params.lever_pos     = str2double(handles.lever_pos_edit.String);
params.adapt_distance = handles.adapt_distance_cbx.Value;
params.distance_max = str2double(handles.distance_max_edit.String);
params.min_int = handles.intervaleforceradio.Value;
params.sound = handles.sound_cbx.Value;
params.synchronisation = handles.synchronisation_cbx.Value;



params.save_dir      = handles.save_dir_edit.String;
params.session_number= str2double(handles.session_number_txt.String);

% fill missing values with defaults:
params = mototrak_diff_reward_default_params_V2(params);

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


function distance_max_edit_Callback(hObject, eventdata, handles)

function distance_max_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function force_max_edit_Callback(hObject, eventdata, handles)

function force_max_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function adapt_force_cbx_Callback(hObject, eventdata, handles)

function adapt_distance_cbx_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function minforceradio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minforceradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function intervaleforceradio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intervaleforceradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in minforceradio.
function minforceradio_Callback(hObject, eventdata, handles)
value= handles.minforceradio.Value;
minforceradio_fnc (value,handles);



function minforceradio_fnc(value,handles)

if value == 1
    state= '''on''';
    astate= '''off''';
else
    state= '''off''';
    astate= '''on''';
end

 eval( ['set(handles.force_level_edit,' '''Enable''' ',' state ')']);
 eval( [' set(handles.force_max_edit,' '''Enable''' ',' state ')']);
 eval( ['set(handles.num_intervale_type_pop,' '''Enable''' ',' astate ')']);
 eval( ['set(handles.synchronisation_cbx,' '''Enable''' ',' astate ')']);
 for i = 1:handles.num_intervale_type_pop.Value
    eval( ['set(handles.int' num2str(i) '_label_edit,' '''Enable''' ',' astate ')']);
    eval( ['set(handles.int' num2str(i) '_pct_edit,' '''Enable''' ',' astate ')']);
    eval( ['set(handles.int' num2str(i) '_min_edit,' '''Enable''' ',' astate ')']);
    eval( ['set(handles.int' num2str(i) '_max_edit,' '''Enable''' ',' astate ')']);

 end

% hObject    handle to minforceradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of minforceradio


% --- Executes on button press in intervaleforceradio.
function intervaleforceradio_Callback(hObject, eventdata, handles)
value= handles.minforceradio.Value;
 minforceradio_fnc (value,handles);
% hObject    handle to intervaleforceradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of intervaleforceradio



function int5_label_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int5_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int5_label_edit as text
%        str2double(get(hObject,'String')) returns contents of int5_label_edit as a double


% --- Executes during object creation, after setting all properties.
function int5_label_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int5_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int4_label_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int4_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int4_label_edit as text
%        str2double(get(hObject,'String')) returns contents of int4_label_edit as a double


% --- Executes during object creation, after setting all properties.
function int4_label_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int4_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int1_label_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int1_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int1_label_edit as text
%        str2double(get(hObject,'String')) returns contents of int1_label_edit as a double


% --- Executes during object creation, after setting all properties.
function int1_label_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int1_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int3_label_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int3_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int3_label_edit as text
%        str2double(get(hObject,'String')) returns contents of int3_label_edit as a double


% --- Executes during object creation, after setting all properties.
function int3_label_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int3_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int2_label_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int2_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int2_label_edit as text
%        str2double(get(hObject,'String')) returns contents of int2_label_edit as a double


% --- Executes during object creation, after setting all properties.
function int2_label_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int2_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int5_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int5_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int5_min_edit as text
%        str2double(get(hObject,'String')) returns contents of int5_min_edit as a double


% --- Executes during object creation, after setting all properties.
function int5_min_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int5_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int4_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int4_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int4_min_edit as text
%        str2double(get(hObject,'String')) returns contents of int4_min_edit as a double


% --- Executes during object creation, after setting all properties.
function int4_min_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int4_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int1_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int1_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int1_min_edit as text
%        str2double(get(hObject,'String')) returns contents of int1_min_edit as a double


% --- Executes during object creation, after setting all properties.
function int1_min_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int1_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int3_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int3_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int3_min_edit as text
%        str2double(get(hObject,'String')) returns contents of int3_min_edit as a double


% --- Executes during object creation, after setting all properties.
function int3_min_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int3_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int2_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int2_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int2_min_edit as text
%        str2double(get(hObject,'String')) returns contents of int2_min_edit as a double


% --- Executes during object creation, after setting all properties.
function int2_min_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int2_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int5_pct_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int5_pct_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int5_pct_edit as text
%        str2double(get(hObject,'String')) returns contents of int5_pct_edit as a double


% --- Executes during object creation, after setting all properties.
function int5_pct_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int5_pct_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int4_pct_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int4_pct_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int4_pct_edit as text
%        str2double(get(hObject,'String')) returns contents of int4_pct_edit as a double


% --- Executes during object creation, after setting all properties.
function int4_pct_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int4_pct_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int1_pct_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int1_pct_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int1_pct_edit as text
%        str2double(get(hObject,'String')) returns contents of int1_pct_edit as a double


% --- Executes during object creation, after setting all properties.
function int1_pct_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int1_pct_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int3_pct_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int3_pct_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int3_pct_edit as text
%        str2double(get(hObject,'String')) returns contents of int3_pct_edit as a double


% --- Executes during object creation, after setting all properties.
function int3_pct_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int3_pct_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int2_pct_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int2_pct_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int2_pct_edit as text
%        str2double(get(hObject,'String')) returns contents of int2_pct_edit as a double


% --- Executes during object creation, after setting all properties.
function int2_pct_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int2_pct_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in num_intervale_type_pop.
function num_intervale_type_pop_Callback(hObject, eventdata, handles)
num_int = get(hObject,'Value');
toggle_int_visible(num_int,handles);


% --- Executes during object creation, after setting all properties.
function num_intervale_type_pop_CreateFcn(hObject, eventdata, handles)
num_int = get(hObject,'Value');
toggle_int_visible(num_int,handles);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int2_max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int2_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int2_max_edit as text
%        str2double(get(hObject,'String')) returns contents of int2_max_edit as a double


% --- Executes during object creation, after setting all properties.
function int2_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int2_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int3_max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int3_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int3_max_edit as text
%        str2double(get(hObject,'String')) returns contents of int3_max_edit as a double


% --- Executes during object creation, after setting all properties.
function int3_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int3_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int1_max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int1_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int1_max_edit as text
%        str2double(get(hObject,'String')) returns contents of int1_max_edit as a double


% --- Executes during object creation, after setting all properties.
function int1_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int1_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int4_max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int4_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int4_max_edit as text
%        str2double(get(hObject,'String')) returns contents of int4_max_edit as a double


% --- Executes during object creation, after setting all properties.
function int4_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int4_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int5_max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to int5_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of int5_max_edit as text
%        str2double(get(hObject,'String')) returns contents of int5_max_edit as a double


% --- Executes during object creation, after setting all properties.
function int5_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int5_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sound_cbx.
function sound_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to sound_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sound_cbx


% --- Executes on button press in synchronisation_cbx.
function synchronisation_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to synchronisation_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of synchronisation_cbx

value= handles.synchronisation_cbx.Value;

if value == 1
    astate= '''off''';
    num_int = handles.num_trial_type_pop.Value;
    set(handles.num_intervale_type_pop,'Value', num_int);
    toggle_int_visible(num_int,handles)
     for i = 1:num_int

        eval( ['set(handles.int' num2str(i) '_pct_edit,' '''Enable''' ',' astate ')']);
        pct_value =  eval( ['handles.tt' num2str(i) '_pct_trials_edit.String']);
        eval( ['set(handles.int' num2str(i) '_pct_edit,' '''String''' ',' pct_value ')']);
    
     end

else
    
    astate= '''on''';
    num_int = handles.num_trial_type_pop.Value;
     for i = 1:num_int

        eval( ['set(handles.int' num2str(i) '_pct_edit,' '''Enable''' ',' astate ')']);
    
    end
end


