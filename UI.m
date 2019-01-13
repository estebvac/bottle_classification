function varargout = UI(varargin)
% UI MATLAB code for UI.fig
%      UI, by itself, creates a new UI or raises the existing
%      singleton*.
%
%      H = UI returns the handle to a new UI or the handle to
%      the existing singleton*.
%
%      UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UI.M with the given input arguments.
%
%      UI('Property','Value',...) creates a new UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UI

% Last Modified by GUIDE v2.5 07-Jan-2019 12:58:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UI_OpeningFcn, ...
                   'gui_OutputFcn',  @UI_OutputFcn, ...
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


% --- Executes just before UI is made visible.
function UI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UI (see VARARGIN)

% Choose default command line output for UI
handles.output = hObject;
handles.train = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes UI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = UI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function openimg_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to openimg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path,indx] = uigetfile({'*.png;*.jpg','Images (*.png,*.jpg)}'}, 'Select Image');

if file ~= 0 
    white = [1, 1, 1];

    handles.normal.BackgroundColor = white;
    handles.underfilled.BackgroundColor = white;
    handles.overfilled.BackgroundColor = white;
    handles.labelmissing.BackgroundColor = white;
    handles.printing.BackgroundColor = white;
    handles.straight.BackgroundColor = white;
    handles.cap.BackgroundColor = white;
    handles.deformed.BackgroundColor = white;

    set(get(handles.segmentedImg,'children'),'visible','off')
    set(get(handles.hogImg,'children'),'visible','off')

    image = imread(strcat(path, file));
    axes(handles.originalImg);
    imshow(image);
    handles.img = image;
    handles.identify.Enable = 'On';
    guidata(hObject, handles);
end

% --------------------------------------------------------------------
function identify_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to identify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[faults, mostlikely, bottleImage, locations, hogvisualization] = analyseImage(handles.img, handles.train);
axes(handles.segmentedImg);
imshow(bottleImage);

if (faults.bottlePresent)
    axes(handles.hogImg),
    imshow(bottleImage),
    hold on,
    plot(hogvisualization);
    markFaults(faults, locations, handles);
    handles.like.String = mostlikely;
else
    msgbox('The bottle is not present', 'Information', 'help');
end

% --------------------------------------------------------------------
function view_all_ClickedCallback(hObject,eventdata,handles)
   % hObject    handle to identify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setpath = uigetdir;
if setpath ~= 0 
    list = dir(strcat(setpath, '/*.jpg'));
    number_of_files = size(list);
    mostlikelyLabels = {};
    for i= 1: number_of_files(1,1)    
        filename = [list(i).folder '\'   list(i).name];
        OriginalImage = imread(filename);
        axes(handles.originalImg);
        imshow(OriginalImage);
        handles.img = OriginalImage;
        [faults, mostlikely, bottleImage, locations, hogvisualization] = analyseImage(handles.img, handles.train);
        axes(handles.segmentedImg);
        imshow(bottleImage);

        trlabel = strsplit(list(i).name,'-');
        trainLabels(i) = trlabel(1);
        mostlikelyLabels(i) = {mostlikely};

        if (faults.bottlePresent)
            axes(handles.hogImg),
            imshow(bottleImage),
            hold on,
            plot(hogvisualization);
            markFaults(faults, locations, handles);
            handles.like.String = mostlikely; 
        end
    %     pause(1);
    end
    save('statistics1.mat', 'trainLabels','mostlikelyLabels');
end

function markFaults(faults, locations, handles)
    
green = [0, 1, 0];
red = [1, 0, 0];

handles.normal.BackgroundColor = green;
handles.underfilled.BackgroundColor = green;
handles.overfilled.BackgroundColor = green;
handles.labelmissing.BackgroundColor = green;
handles.printing.BackgroundColor = green;
handles.straight.BackgroundColor = green;
handles.cap.BackgroundColor = green;
handles.deformed.BackgroundColor = green;

if (faults.underfilled)
   handles.underfilled.BackgroundColor = red;
   handles.normal.BackgroundColor = red;
   axes(handles.segmentedImg),
    hold on,
   rectangle('Position', locations.underfilled,'EdgeColor','w','LineWidth',2);
end
if (faults.overfilled)
   handles.overfilled.BackgroundColor = red;
   handles.normal.BackgroundColor = red;
   axes(handles.segmentedImg),
    hold on,
   rectangle('Position', locations.overfilled,'EdgeColor','w','LineWidth',2);
end
if (faults.labelMissing)
   handles.labelmissing.BackgroundColor = red;
   handles.normal.BackgroundColor = red;
   axes(handles.segmentedImg),
    hold on,
   rectangle('Position', locations.labelMissing,'EdgeColor','g','LineWidth',2)
end
if (faults.whiteLabel)
   handles.printing.BackgroundColor = red;
   handles.normal.BackgroundColor = red;
   axes(handles.segmentedImg),
    hold on,
   rectangle('Position', locations.whitelabel,'EdgeColor','g','LineWidth',2);
end
if (faults.labelNotStraight)
   handles.straight.BackgroundColor = red;
   handles.normal.BackgroundColor = red;
   axes(handles.segmentedImg),
    hold on,
   rectangle('Position', locations.labelNotStraight,'EdgeColor','g','LineWidth',2);
end
if (faults.missingCap)
   handles.cap.BackgroundColor = red;
   handles.normal.BackgroundColor = red;
   axes(handles.segmentedImg),
    hold on,
   rectangle('Position', locations.missingCap,'EdgeColor','r','LineWidth',2);
end
if (faults.deformed)
   handles.deformed.BackgroundColor = red;
   handles.normal.BackgroundColor = red;
   axes(handles.segmentedImg),
   hold on,
   rectangle('Position', locations.deformed,'EdgeColor','r','LineWidth',2);
end


% --------------------------------------------------------------------
function train_Callback(hObject, eventdata, handles)
% hObject    handle to train (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selpath = uigetdir('.', 'Open Training dataset');

if (selpath ~= 0)
    handles.train = trainSystem(selpath);
    handles.openimg.Enable = 'On';
    handles.view_all.Enable = 'On';
    guidata(hObject, handles);
end
