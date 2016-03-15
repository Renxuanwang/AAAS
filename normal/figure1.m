function varargout = figure1(varargin)
% FIGURE1 MATLAB code for figure1.fig
%      FIGURE1, by itself, creates a new FIGURE1 or raises the existing
%      singleton*.
%
%      H = FIGURE1 returns the handle to a new FIGURE1 or the handle to
%      the existing singleton*.
%
%      FIGURE1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGURE1.M with the given input arguments.
%
%      FIGURE1('Property','Value',...) creates a new FIGURE1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before figure1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to figure1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help figure1

% Last Modified by GUIDE v2.5 13-Jan-2016 23:10:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @figure1_OpeningFcn, ...
                   'gui_OutputFcn',  @figure1_OutputFcn, ...
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


% --- Executes just before figure1 is made visible.
function figure1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to figure1 (see VARARGIN)
global H;
global h1;
global h2;
global h3;
global h4;
global vCnt;
global sCnt;
global iCnt;
global option;
global range;
global text2handle;
global text3handle;
text2handle=handles.text2;
text3handle=handles.text3;
range=1;
vCnt = 0;
sCnt = 0;
iCnt = 0;
H=uicontextmenu;
set(gcf,'uicontextmenu',H);

option=1;
h1=uimenu(H,'label','SAT','tag','adipose','Callback',@adipose);
h2=uimenu(H,'label','VAT','tag','visceral','Callback',@visceral);
h3=uimenu(H,'label','OUT','tag','outside','Callback',@outside);
h4=uimenu(H,'label','NAT','tag','inside','Callback',@inside);
set(h1,'Checked','on');
% Choose default command line output for figure1
handles.output = hObject;
set(handles.slider1,'visible','off');
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes figure1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = figure1_OutputFcn(hObject,eventdata,handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
%function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%M = dicomread('D:/pic');
%imshow(M);
%axis tight;

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDAT

global filename;
global pathname;
global filename1;
global pathname1;

[filename1, pathname1] = uigetfile({'*.*'},'File Selector');

%M = dicomread([pathname,filename]);
if(~isequal(filename1,0))
filename=filename1;
pathname=pathname1;
img = dicomread([pathname filename]);

axes(handles.axes1);
%imagesc(M);
img = double(img);
imgg = img/max(img(:));
imgg = single(imgg);
imagehandle=imshow(imgg);
set(handles.pushbutton7,'enable','on');
axis off;
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%system('D:/VolumeRendering.exe');
global sCnt;
global vCnt;
global iCnt;
sCnt = 0;
vCnt = 0;
iCnt = 0;
[filename, pathname, index] = uigetfile({'*.dat'},'File Selector(Please select .dat files)','MultiSelect','on');

dat = [];
if(iscell(filename))
    for i = 1: length(filename)
        tmp = char(filename(i));
        M = load([pathname tmp]);
        sCnt = sCnt + length(find(M == 1));
        vCnt = vCnt + length(find(M == 2));
        iCnt = iCnt + length(find(M == 3));
        for j = 1:8
        dat = [dat; M];
        end
    end
else
    M = load([pathname filename]);
    sCnt = sCnt + length(find(M == 1));
    vCnt = vCnt + length(find(M == 2));
    iCnt = iCnt + length(find(M == 3));
    for j = 1:8
        dat = [dat; M];
    end
end

str = ['Percentage VAT: ', num2str(roundn(vCnt / (vCnt + sCnt + iCnt), -4)*100), '% SAT: ', num2str(roundn(sCnt / (vCnt + sCnt + iCnt), -4)*100), '%'];
dlmwrite('name.txt', str, '');
dlmwrite('render.dat', dat, '\t');
system('VolumeRendering_cp1.exe');
%delete('render.dat');
delete('name.txt');

function ImageClickCallback2 ( objectHandle, eventData)

function ImageClickCallback ( objectHandle, eventData)
global segmat;
global option;
global range;
global H;
global preSeg;
global storeNum;
global vCnt;
global sCnt;
global iCnt;
global text2handle;
global text3handle;
axesHandle  = get(objectHandle,'Parent');
handle = get(axesHandle, 'Parent');
handles = get(handle, 'Parent');
coordinates = get(axesHandle,'CurrentPoint'); 
coordinates = coordinates(1,1:2);
pos = round(coordinates);
preSeg = [preSeg; segmat];
storeNum = storeNum + 1;
if strcmp(get(gcf,'SelectionType'),'normal')
if option == 1
    for i = -range:range
        for j = -range:range
            segmat(pos(2)+i,pos(1)+j) = 1;
        end
    end
elseif option == 2
    for i = -range:range
        for j = -range:range
            segmat(pos(2)+i,pos(1)+j) = 2;
        end
    end
elseif option == 4
    for i = -range:range
        for j = -range:range
            segmat(pos(2)+i,pos(1)+j) = 3;
        end
    end
else option == 3
    for i = -range:range
        for j = -range:range
            segmat(pos(2)+i,pos(1)+j) = 4;
        end
    end
end
sCnt = length(find(segmat == 1));
vCnt = length(find(segmat == 2));
iCnt = length(find(segmat == 3));
axes(axesHandle);
%str = 'aaa';
%set(handles.text2,'string',str);
imageHandle = imagesc(segmat);
if (iCnt == 0 || vCnt == 0 || sCnt == 0)
    set(text2handle, 'string', '');
    set(text3handle, 'string', '');
else sum = iCnt + vCnt + sCnt;
    v1 = vCnt/sum;
    s1 = sCnt/sum;
    str1 = ['VAT: ', num2str(v1*100), '%'];
    str2 = ['SAT: ', num2str(s1*100), '%'];
    set(text2handle, 'string', str1);
    set(text3handle, 'string', str2);
end
axis off;
set(imageHandle,'ButtonDownFcn',@ImageClickCallback);
set(imageHandle,'uicontextmenu',H);
end





% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pathname;
global filename;
global segmat;
global option;
global storeNum;
global preSeg;
global iCnt;
global vCnt;
global sCnt;
global text2handle;
global text3handle;
iCnt = 0;
vCnt = 0;
sCnt = 0;
preSeg = [];
storeNum = 0;
option = 1;
axes(handles.axes2);
set(handles.pushbutton2,'enable','off');
set(handles.pushbutton3,'enable','on');
h = waitbar(0,'Preprocessing','CreateCancelBtn','delete(gcbf)');
segmat = AAT_SEG(filename, pathname,h,1,1);
delete(h);
clear h;
sCnt = length(find(segmat == 1));
vCnt = length(find(segmat == 2));
iCnt = length(find(segmat == 3));
imageHandle = imagesc(segmat);
if (iCnt == 0 || vCnt == 0 || sCnt == 0)
    set(text2handle, 'string', '');
    set(text3handle, 'string', '');
else sum = iCnt + vCnt + sCnt;
    v1 = vCnt/sum;
    s1 = sCnt/sum;
    str1 = ['VAT: ', num2str(v1*100), '%'];
    str2 = ['SAT: ', num2str(s1*100), '%'];
    set(text2handle, 'string', str1);
    set(text3handle, 'string', str2);
end
set(handles.change,'visible','on');
set(handles.change,'enable','on');
set(handles.pushbutton2,'enable','on');
set(handles.pushbutton3,'enable','on');
set(handles.pushbutton7,'enable','on');
axis off;


%tmp = load(['ori' filename ]);
%imagesc(tmp);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton2.
function pushbutton2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radiobutton1.
function adipose(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
global option;
global h1;
global h2;
global h3;
global h4;
option = 1;
set(h1,'Checked','on');
set(h2,'Checked','off');
set(h3,'Checked','off');
set(h4,'Checked','off');


% --- Executes on button press in radiobutton2.
function visceral(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
global option;
global h1;
global h2;
global h3;
global h4;
option = 2;
set(h1,'Checked','off');
set(h2,'Checked','on');
set(h3,'Checked','off');
set(h4,'Checked','off');


% --- Executes on button press in radiobutton3.
function outside(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
global option;
global h1;
global h2;
global h3;
global h4;
option = 3;
set(h1,'Checked','off');
set(h2,'Checked','off');
set(h3,'Checked','on');
set(h4,'Checked','off');


% --- Executes on button press in radiobutton4.
function inside(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4
global option;
global h1;
global h2;
global h3;
global h4;
option = 4;
set(h1,'Checked','off');
set(h2,'Checked','off');
set(h3,'Checked','off');
set(h4,'Checked','on');


% --------------------------------------------------------------------


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global range;
range = round(get(hObject, 'Value'));


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function change_OnCallback(hObject, eventdata, handles)
global segmat;
global H;
set(handles.slider1,'visible','on');
set(handles.slider1,'enable','on');
imageHandle = imagesc(segmat);
set(imageHandle,'ButtonDownFcn',@ImageClickCallback);
set(imageHandle,'uicontextmenu',H);
axis off;
% hObject    handle to change (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function change_OffCallback(hObject, eventdata, handles)
global segmat;
set(handles.slider1,'enable','off');
set(handles.slider1,'visible','off');
imageHandle = imagesc(segmat);
set(imageHandle,'ButtonDownFcn',@ImageClickCallback2);
axis off;
% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function pushbutton9_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global preSeg;
global segmat;
global storeNum;
global vCnt;
global sCnt;
global iCnt;
global text2handle;
global text3handle;
%{
segmat = preSeg(length(preSeg)-511:length(preSeg), 1:512);
preSeg(length(preSeg)-511:length(preSeg), 1:512) = [];
%}
%axesHandle  = get(hObject,'Parent');
storeNum = storeNum-1;
segmat = preSeg(storeNum*512+1:(storeNum+1)*512, 1:512);
preSeg = preSeg(1:storeNum*512, 1:512);
sCnt = length(find(segmat == 1));
vCnt = length(find(segmat == 2));
iCnt = length(find(segmat == 3));
axes(handles.axes2);
imageHandle = imagesc(segmat);
axis off;
if (iCnt == 0 || vCnt == 0 || sCnt == 0)
    set(text2handle, 'string', '');
    set(text3handle, 'string', '');
else sum = iCnt + vCnt + sCnt;
    v1 = vCnt/sum;
    s1 = sCnt/sum;
    str1 = ['VAT: ', num2str(v1*100), '%'];
    str2 = ['SAT: ', num2str(s1*100), '%'];
    set(text2handle, 'string', str1);
    set(text3handle, 'string', str2);
end
if strcmp(get(handles.change,'State'),'on')
set(imageHandle,'ButtonDownFcn',@ImageClickCallback);
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sCnt;
global vCnt;
global iCnt;
pos=get(handles.figure1,'currentpoint');
pos=pos(1,1:2);
x=round(pos(1)/100*512);
y=round(512-pos(2)/38.28*512);
if(x<512)
str=['X = ',' ',num2str(x),'   ','Y = ',' ',num2str(y)];
set(handles.text1,'string',str);
set(handles.figure1, 'Pointer','crosshair');
end
if(x>512)
    str=['X = ',' ',num2str(x-512),'   ','Y = ',' ',num2str(y)];
    set(handles.text1,'string',str);
    set(handles.figure1, 'Pointer','crosshair');
end
if(x>1024 || y<0)
 set(handles.text1,'string','');
set(handles.figure1, 'Pointer','arrow');
end

function uipushtool3_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global segmat;
global filename;
out = uint8(segmat);
dlmwrite(['dat/' filename '.dat'], out, '\t');
    %set(handles.text2, 'string', str1);
    %set(handles.text3, 'string', str2);
axis off;


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filename;
global pathname;
global segmat;
global vCnt;
global sCnt;
global iCnt;
vCnt = 0;
sCnt = 0;
iCnt = 0;
seg = [];
[filename, pathname, index] = uigetfile({'*.*'},'File Selector(Please select dicom raw data files)','MultiSelect','on');
if(~isequal(filename,0))
if(iscell(filename))
    h = waitbar(0,'Preprocessing','CreateCancelBtn','delete(gcbf)');
    for i = 1: length(filename)
        segmat = AAT_SEG(char(filename(i)), pathname,h, length(filename), i);
        sCnt = sCnt + length(find(segmat == 1));
        vCnt = vCnt + length(find(segmat == 2));
        iCnt = iCnt + length(find(segmat == 3));
        for j = 1:8
        seg = [seg; segmat];
        end
    end
    delete(h);
    clear h;
else
    h = waitbar(0,'Preprocessing','CreateCancelBtn','delete(gcbf)');
    segmat = AAT_SEG(filename, pathname, h, 1, 1);
    sCnt = sCnt + length(find(segmat == 1));
    vCnt = vCnt + length(find(segmat == 2));
    iCnt = iCnt + length(find(segmat == 3));
    for j = 1:8
        seg = [seg; segmat];
    end
    delete(h);
    clear h;
end
str = ['Percentage VAT: ', num2str(roundn(vCnt / (vCnt + sCnt + iCnt), -4)*100), '% SAT: ', num2str(roundn(sCnt / (vCnt + sCnt + iCnt), -4)*100), '%'];
dlmwrite('name.txt', str, '');
dlmwrite('render.dat', seg, '\t');
system('VolumeRendering_cp1.exe');
%delete('render.dat');
delete('name.txt');
end