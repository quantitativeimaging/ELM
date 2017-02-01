function varargout = advanced_settings(varargin)
% ADVANCED_SETTINGS MATLAB code for advanced_settings.fig
%      ADVANCED_SETTINGS, by itself, creates a new ADVANCED_SETTINGS or raises the existing
%      singleton*.
%
%      H = ADVANCED_SETTINGS returns the handle to a new ADVANCED_SETTINGS or the handle to
%      the existing singleton*.
%
%      ADVANCED_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADVANCED_SETTINGS.M with the given input arguments.
%
%      ADVANCED_SETTINGS('Property','Value',...) creates a new ADVANCED_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before advanced_settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to advanced_settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help advanced_settings

% Last Modified by GUIDE v2.5 01-Dec-2016 11:57:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @advanced_settings_OpeningFcn, ...
                   'gui_OutputFcn',  @advanced_settings_OutputFcn, ...
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


% --- Executes just before advanced_settings is made visible.
function advanced_settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to advanced_settings (see VARARGIN)

% Choose default command line output for advanced_settings
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes advanced_settings wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Set string values in gui from appdata, not the gui figure:
set(handles.radius_low_edit, 'String', getappdata(0, 'radius_low'));
set(handles.radius_high_edit, 'String', getappdata(0, 'radius_high'));
set(handles.segmentation_edit, 'String', getappdata(0, 'segmentation'));
set(handles.border_edit, 'String', getappdata(0, 'border'));
set(handles.seed_edit, 'String', getappdata(0, 'seed'));
set(handles.fluorophores_edit, 'String', getappdata(0, 'fluorophores'));
set(handles.hough_sensitivity_edit, 'String', getappdata(0, 'hough_sensitivity'));

% --- Outputs from this function are returned to the command line.
function varargout = advanced_settings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function radius_low_edit_Callback(hObject, eventdata, handles)
% hObject    handle to radius_low_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of radius_low_edit as text
%        str2double(get(hObject,'String')) returns contents of radius_low_edit as a double


% --- Executes during object creation, after setting all properties.
function radius_low_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radius_low_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function radius_high_edit_Callback(hObject, eventdata, handles)
% hObject    handle to radius_high_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of radius_high_edit as text
%        str2double(get(hObject,'String')) returns contents of radius_high_edit as a double


% --- Executes during object creation, after setting all properties.
function radius_high_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radius_high_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function segmentation_edit_Callback(hObject, eventdata, handles)
% hObject    handle to segmentation_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of segmentation_edit as text
%        str2double(get(hObject,'String')) returns contents of segmentation_edit as a double


% --- Executes during object creation, after setting all properties.
function segmentation_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to segmentation_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function border_edit_Callback(hObject, eventdata, handles)
% hObject    handle to border_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of border_edit as text
%        str2double(get(hObject,'String')) returns contents of border_edit as a double


% --- Executes during object creation, after setting all properties.
function border_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to border_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function seed_edit_Callback(hObject, eventdata, handles)
% hObject    handle to seed_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of seed_edit as text
%        str2double(get(hObject,'String')) returns contents of seed_edit as a double


% --- Executes during object creation, after setting all properties.
function seed_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to seed_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fluorophores_edit_Callback(hObject, eventdata, handles)
% hObject    handle to fluorophores_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fluorophores_edit as text
%        str2double(get(hObject,'String')) returns contents of fluorophores_edit as a double


% --- Executes during object creation, after setting all properties.
function fluorophores_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fluorophores_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in apply_btn.
function apply_btn_Callback(hObject, eventdata, handles)
% hObject    handle to apply_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(0, 'radius_low', get(handles.radius_low_edit, 'String'));
setappdata(0, 'radius_high', get(handles.radius_high_edit, 'String'));
setappdata(0, 'segmentation', get(handles.segmentation_edit, 'String'));
setappdata(0, 'border', get(handles.border_edit, 'String'));
setappdata(0, 'seed', get(handles.seed_edit, 'String'));
setappdata(0, 'fluorophores', get(handles.fluorophores_edit, 'String'));
setappdata(0, 'hough_sensitivity', get(handles.hough_sensitivity_edit, 'String'));
figure1_CloseRequestFcn(handles.figure1, eventdata, handles);


% --- Executes on button press in cancel_btn.
function cancel_btn_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure1_CloseRequestFcn(handles.figure1, eventdata, handles);


% --- Executes on button press in defaults_btn.
function defaults_btn_Callback(hObject, eventdata, handles)
% hObject    handle to defaults_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.radius_low_edit, 'String', '5');
set(handles.radius_high_edit, 'String', '15');
set(handles.segmentation_edit, 'String', '13');
set(handles.border_edit, 'String', '7');
set(handles.seed_edit, 'String', '7');
set(handles.fluorophores_edit, 'String', '3000');
set(handles.hough_sensitivity_edit, 'String', '0.85');



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);



function hough_sensitivity_edit_Callback(hObject, eventdata, handles)
% hObject    handle to hough_sensitivity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hough_sensitivity_edit as text
%        str2double(get(hObject,'String')) returns contents of hough_sensitivity_edit as a double


% --- Executes during object creation, after setting all properties.
function hough_sensitivity_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hough_sensitivity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
