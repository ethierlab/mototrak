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

% Last Modified by GUIDE v2.5 03-Apr-2018 17:29:08

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
handles.params = mototrak_diff_reward_default_params;

% Update handles structure
guidata(hObject, handles);

set(handles.animal_name_edit,'String', handles.params.animal_name);

% UIWAIT makes mototrak_diff_reward_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mototrak_diff_reward_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function animal_name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to animal_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of animal_name_edit as text
%        str2double(get(hObject,'String')) returns contents of animal_name_edit as a double


% --- Executes during object creation, after setting all properties.
function animal_name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to animal_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cno_cbx.
function cno_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to cno_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cno_cbx


% --- Executes on selection change in num_trial_type_pop.
function num_trial_type_pop_Callback(hObject, eventdata, handles)
% hObject    handle to num_trial_type_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns num_trial_type_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from num_trial_type_pop


% --- Executes during object creation, after setting all properties.
function num_trial_type_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_trial_type_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_prev_cbx.
function load_prev_cbx_Callback(hObject, eventdata, handles)
% hObject    handle to load_prev_cbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of load_prev_cbx



function duration_edit_Callback(hObject, eventdata, handles)
% hObject    handle to duration_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of duration_edit as text
%        str2double(get(hObject,'String')) returns contents of duration_edit as a double


% --- Executes during object creation, after setting all properties.
function duration_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to duration_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function force_level_edit_Callback(hObject, eventdata, handles)
% hObject    handle to force_level_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of force_level_edit as text
%        str2double(get(hObject,'String')) returns contents of force_level_edit as a double


% --- Executes during object creation, after setting all properties.
function force_level_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to force_level_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in start_button.
function start_button_Callback(hObject, eventdata, handles)
% hObject    handle to start_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mototrak_diff_reward(handles);



% --- Executes on button press in stop_button.
function stop_button_Callback(hObject, eventdata, handles)
% hObject    handle to stop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(gcbo,'userdata',1);


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
sd = get(handles.save_dir_edit,'String');
save_dir = uigetdir(sd, 'Select folder in which to save the behavioral results');
if isdir(save_dir)
    set(handles.save_dir_edit,'String',save_dir);
end

function save_dir_edit_Callback(hObject, eventdata, handles)
% hObject    handle to save_dir_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_dir_edit as text
%        str2double(get(hObject,'String')) returns contents of save_dir_edit as a double


% --- Executes during object creation, after setting all properties.
function save_dir_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_dir_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
