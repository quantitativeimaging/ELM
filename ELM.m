function varargout = ELM(varargin)
% ELM MATLAB code for ELM.fig
%      ELM, by itself, creates a new ELM or raises the existing
%      singleton*.
%
%      H = ELM returns the handle to a new ELM or the handle to
%      the existing singleton*.
%
%      ELM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ELM.M with the given input arguments.
%
%      ELM('Property','Value',...) creates a new ELM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ELM_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ELM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ELM

% Last Modified by GUIDE v2.5 06-Apr-2016 16:12:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ELM_OpeningFcn, ...
                   'gui_OutputFcn',  @ELM_OutputFcn, ...
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


% --- Executes just before ELM is made visible.
function ELM_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ELM (see VARARGIN)

% Choose default command line output for ELM
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ELM wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ELM_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function input_dir_edit_Callback(hObject, eventdata, handles)
% hObject    handle to input_dir_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_dir_edit as text
%        str2double(get(hObject,'String')) returns contents of input_dir_edit as a double


% --- Executes during object creation, after setting all properties.
function input_dir_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_dir_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function output_dir_edit_Callback(hObject, eventdata, handles)
% hObject    handle to output_dir_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of output_dir_edit as text
%        str2double(get(hObject,'String')) returns contents of output_dir_edit as a double


% --- Executes during object creation, after setting all properties.
function output_dir_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_dir_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in input_dir_browse_btn.
function input_dir_browse_btn_Callback(hObject, eventdata, handles)
% hObject    handle to input_dir_browse_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input_dir = uigetdir;
set(handles.input_dir_edit, 'String', input_dir);


% --- Executes on button press in output_dir_browse_btn.
function output_dir_browse_btn_Callback(hObject, eventdata, handles)
% hObject    handle to output_dir_browse_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
output_dir = uigetdir;
set(handles.output_dir_edit, 'String', output_dir);


% --- Executes on button press in process_btn.
function process_btn_Callback(hObject, eventdata, handles)
% hObject    handle to process_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input_dir = get(handles.input_dir_edit, 'String');
output_dir = get(handles.output_dir_edit, 'String');
pixel_size = str2num(get(handles.pixel_size_edit, 'String'));
model_type = get(get(handles.model_type_group, 'SelectedObject'), 'Tag');
switch model_type
	case 'spherical_radiobtn'
		model_type = 'spherical';
	case 'ellipsoidal_radiobtn'
		model_type = 'ellipsoidal';
end

fsa.elm_analysis(input_dir, output_dir, pixel_size, model_type)


% --- Executes on button press in spherical_radiobtn.
function spherical_radiobtn_Callback(hObject, eventdata, handles)
% hObject    handle to spherical_radiobtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spherical_radiobtn


% --- Executes on button press in ellipsoidal_radiobtn.
function ellipsoidal_radiobtn_Callback(hObject, eventdata, handles)
% hObject    handle to ellipsoidal_radiobtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ellipsoidal_radiobtn



function pixel_size_edit_Callback(hObject, eventdata, handles)
% hObject    handle to pixel_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pixel_size_edit as text
%        str2double(get(hObject,'String')) returns contents of pixel_size_edit as a double


% --- Executes during object creation, after setting all properties.
function pixel_size_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixel_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in model_type_group.
function model_type_group_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in model_type_group
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function model_type_group_CreateFcn(hObject, eventdata, handles)
% hObject    handle to model_type_group (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
