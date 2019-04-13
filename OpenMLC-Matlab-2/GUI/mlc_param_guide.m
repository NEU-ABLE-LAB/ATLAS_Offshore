function varargout = mlc_param_guide(varargin)
% MLC_PARAM_GUIDE MATLAB code for mlc_param_guide.fig
%      MLC_PARAM_GUIDE, by itself, creates a new MLC_PARAM_GUIDE or raises the existing
%      singleton*.
%
%      H = MLC_PARAM_GUIDE returns the handle to a new MLC_PARAM_GUIDE or the handle to
%      the existing singleton*.
%
%      MLC_PARAM_GUIDE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MLC_PARAM_GUIDE.M with the given input arguments.
%
%      MLC_PARAM_GUIDE('Property','Value',...) creates a new MLC_PARAM_GUIDE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mlc_param_guide_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mlc_param_guide_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mlc_param_guide

% Last Modified by GUIDE v2.5 31-Mar-2015 12:34:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mlc_param_guide_OpeningFcn, ...
                   'gui_OutputFcn',  @mlc_param_guide_OutputFcn, ...
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


% --- Executes just before mlc_param_guide is made visible.
function mlc_param_guide_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mlc_param_guide (see VARARGIN)

handles.mlcparam=MLCparameters;
handles.mlcparam.opset=opset(1:10);
opname=cell(1,length(handles.mlcparam.opset));
for i=1:length(handles.mlcparam.opset)
    opname{i}=handles.mlcparam.opset(i).op;
end
handles.opselected=[];



%guidata(hObject, handles);
set(handles.list_op_avaialable,'String',opname,...
	'Value',1)


% Choose default command line output for mlc_param_guide
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mlc_param_guide wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mlc_param_guide_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.mlcparam;
delete(handles.figure1);



% --------------------------------------------------------------------
function Pb_def_men_Callback(hObject, eventdata, handles)
% hObject    handle to Pb_def_men (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function pop_size_edt_Callback(hObject, eventdata, handles)
% hObject    handle to pop_size_edt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pop_size_edt as text
%        str2double(get(hObject,'String')) returns contents of pop_size_edt as a double


% --- Executes during object creation, after setting all properties.
function pop_size_edt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_size_edt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sens_nb_edt_Callback(hObject, eventdata, handles)
% hObject    handle to sens_nb_edt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sens_nb_edt as text
%        str2double(get(hObject,'String')) returns contents of sens_nb_edt as a double


% --- Executes during object creation, after setting all properties.
function sens_nb_edt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sens_nb_edt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end










% --- Executes on selection change in list_op_avaialable.
function list_op_avaialable_Callback(hObject, eventdata, handles)
% hObject    handle to list_op_avaialable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
get(handles.figure1,'SelectionType');
% If double click
if strcmp(get(handles.figure1,'SelectionType'),'open')
    n=get(handles.list_op_avaialable,'value');

    handles.opselected=unique([handles.opselected n]);
for i=1:length(handles.opselected)
    opname{i}=handles.mlcparam.opset(handles.opselected(i)).op;
end





set(handles.list_op_selected,'String',opname,...
	'Value',1)
guidata(hObject, handles);    
end

% Hints: contents = cellstr(get(hObject,'String')) returns list_op_avaialable contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_op_avaialable


% --- Executes during object creation, after setting all properties.
function list_op_avaialable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_op_avaialable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in list_op_selected.
function list_op_selected_Callback(hObject, eventdata, handles)
% hObject    handle to list_op_selected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
get(handles.figure1,'SelectionType');
% If double click
if strcmp(get(handles.figure1,'SelectionType'),'open')
    n=get(handles.list_op_selected,'value')
    a=1:length(handles.opselected);
    idx=a(a~=n)
    handles.opselected=handles.opselected(idx);
    opname{1}='No operation';
for i=1:length(handles.opselected)
    opname{i}=handles.mlcparam.opset(handles.opselected(i)).op;
end
set(handles.list_op_selected,'String',opname,...
	'Value',1)
guidata(hObject, handles);    
% Hints: contents = cellstr(get(hObject,'String')) returns list_op_selected contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_op_selected
end

% --- Executes during object creation, after setting all properties.
function list_op_selected_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_op_selected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in pushcreate.
function pushcreate_Callback(hObject, eventdata, handles)
% hObject    handle to pushcreate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
% The GUI is still in UIWAIT, us UIRESUME
uiresume(hObject);
else
% The GUI is no longer waiting, just close it
delete(hObject);
end










