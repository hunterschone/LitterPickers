function [objectPositions,distanceMat_ltv]=letSubjectArrangeObjects_circularArena(varargin)
% USAGE
%       [objectPositions,distanceMat_ltv]=letSubjectArrangeObjects_circularArena(imageData[,instructionString,options])
%
% FUNCTION
%       This function allows the user to arrange a number of objects in a
%       circular "arena" by dragging and dropping with the mouse. Sets
%       of objects can be selected by right-clicking single objects or
%       right-dragging to draw a selection box. The objects are initially
%       placed outside the arena in a "seating" area. The imageData
%       structure array contains the images that represent the objects.
%
% ARGUMENTS
% imageData 
%       Structure array with as many entries as there are objects to be
%       arranged. The only required field is "image", which must contain
%       the image arrays (to be processed by matlab's image function).
%       Optionally a field "alpha" can be added to control the alpha
%       channel, i.e. to define transparent regions (for details see help
%       on matlab's image function).
%
% [instructionString]
%       Optional string containing the instruction for the subject, such as
%       "Please arrange the objects according to their visual similarity?".


%% define GUI and handle the case of a GUI callback 
if nargin
    % initialization code
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       'letSubjectArrangeObjects_circularArena', ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @letSubjectArrangeObjects_circularArena_OpeningFcn, ...
        'gui_OutputFcn',  @letSubjectArrangeObjects_circularArena_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);

    if ischar(varargin{1}) % it's a callback from the GUI
        gui_State.gui_Callback = str2func(varargin{1});
        gui_mainfcn(gui_State, varargin{:});
        return;
    end
end

% control passes here only on initial user call

%% define options
if nargin>2
    ud.options=varargin{3};
else
    ud.options.axisUnits='normalized';
end


%% open GUI and store information in GUI userdata (ud)
% open GUI
[hf,ha,hpb1,hpb2] = gui_mainfcn(gui_State, varargin{:}); % opens the GUI window and returns GUI info

% position the window
lbwh = get(0,'MonitorPositions');
lbwh = lbwh(ud.options.screen,:);
set(hf,'Units','pixels'); 
windowReductionFactor=.85;
lbwh_fig=round([lbwh(3:4)*((1-windowReductionFactor)/2)+lbwh(1:2) lbwh(3:4)*windowReductionFactor]);
set(hf,'Position',lbwh_fig);
drawnow;

% handle arguments
ud.imageData=varargin{1};
if numel(ud.imageData)<2
    error('letSubjectArrangeObjects_circularArena: pass at least two images to represent the objects to be arranged.');
end

if nargin>1
    ud.instructionString=varargin{2};
else
    ud.instructionString='[subject instruction string here]'; 
end

ha2 = axes('Position',[0.7 0.65 0.35 0.35]); axis off; % HACKED BY MH
ud.ha2 = ha2;
axes(ha)

% arena size
ud.nObjects=numel(ud.imageData);
[ud.imHeight,ud.imWidth,ignore]=size(ud.imageData(1).image); % all images assumed to be of the same size
ud.squareObjWidth=max(ud.imHeight,ud.imWidth); % the axes unit is pixel (in image bmp, not on the screen)
nObjectsThatWouldFillTheArena=ud.nObjects*3;

if strcmp(ud.options.axisUnits,'Pixels')  % ud.options.axisUnits=='Pixels'
    % CONSTANT FIGURE AND IMAGE SIZE
    % the objects have constant size: they appear at the screen resolution
    % (one screen pixel equals one imageData pixel).
    % in this mode the window is not resizable.
    set(hf,'Resize','off');

    ud.arenaMargin=ud.squareObjWidth*0.15;
    ud.squareAxisWidth=min(lbwh_fig(3:4));
    ud.arenaRadius=ud.squareAxisWidth/2-ud.arenaMargin-ud.squareObjWidth;
    
else
    % FIGURE RESIZABLE, ARENA AND IMAGES RESIZED IN PROPORTION
    set(hf,'Resize','on');
    
    % r^2*pi=n*ow^2 => r=sqrt(n*ow^2/pi)
    %(r: arena radius, n: number of objects filling the arena, ow: object width)
    ud.arenaRadius=sqrt(nObjectsThatWouldFillTheArena*ud.squareObjWidth^2/pi);

    ud.arenaMargin=ud.squareObjWidth*0.15;
    ud.squareAxisWidth=2*(ud.arenaRadius+ud.arenaMargin+ud.squareObjWidth);
end

set(ha,'Position',[0 0 1 1]); % ADDED BY MH


ud.ha=ha; % handle of axis
ud.hpb1=hpb1; % handle of push button 1
ud.hpb2=hpb2; % handle of push button 2

set(hf,'UserData',ud);


%% adjust GUI properties
%opengl software; 
set(hpb1,'TooltipString','Press here to clear the arena and start over.');
set(hpb2,'TooltipString','Press here to indicate that you are finished.');
set(hpb2,'Enable','off');
%set(hf,'Renderer','Painters'); 
%set(hf,'Renderer','ZBuffer'); 
set(hf,'Renderer','OpenGL'); % OpenGL appears to be the default anyway, so this line is redundant

% Note: 
% There's a bug in Matlab (version 2009a) that causes text to flip when you 
% use the 'OpenGL' rendering option. 
% See <http://www.mathworks.com/matlabcentral/answers/210> for more 
% information. The text flipping issue can be resolved by typing 
% <opengl software>, but this will result in other display problems.
% The other rendering options don't give these problems, but they do not 
% use the alpha channel.

set(hf,'KeyPressFcn','keypress_Callback');


%% create "arrangement arena"
initializeArena(hf);
ud=get(hf,'UserData');


%% wait for the subject to arrange the objects 
tic % start stopwatch to time the subject
button='No, I''ll adjust the arrangement.';
while ~strcmp(button,'Yes, I am done.')
    ud.donePressed=false; set(hf,'UserData',ud);
    while ~ud.donePressed
        if allInsideArena(hf)
            set(hpb2,'Enable','on'); % enable "done" button
        else
            set(hpb2,'Enable','off'); % disable "done" button
        end
        pause(0.1); % wait 0.1 s
        ud=get(hf,'UserData');
    end
    
    % subject has pressed done
    scr = ud.options.screen;
    if scr == 1
        button = questdlg('Are you sure you are done arranging the objects?','','Yes, I am done.','No, I''ll adjust the arrangement.','No, I''ll adjust the arrangement.');
    else 
        button = mfquestdlg([0.55+scr-1 0.4],'Are you sure you are done arranging the objects?','','Yes, I am done.','No, I''ll adjust the arrangement.','No, I''ll adjust the arrangement.');
    end
end
trialTimeDuration=toc;
% the subject has indicated again that the arrangement is final.


%% return the final arrangement
objectPositions=nan(ud.nObjects,2);
for objectI=1:ud.nObjects
    xdata=get(ud.h_image(objectI),'XData');
    ydata=get(ud.h_image(objectI),'YData');
    x=xdata(1)+ud.imWidth/2-ud.ctrXY;
    y=ydata(1)+ud.imHeight/2-ud.ctrXY;
    objectPositions(ud.seatingOrder(objectI),:)=[x,y];
end

objectPositions=objectPositions./(ud.arenaRadius*2);
% scale such that the arena's diameter corresponds to 1

distanceMat_ltv=pdist(objectPositions,'euclidean');


%% save the results to ensure that it is never lost
% trialIDstring=datestr(clock,30);
% save(['objectPositions_circularArena_',trialIDstring,'.txt'],'objectPositions','-ascii');
% save(['distanceMat_ltv_circularArena_',trialIDstring,'.txt'],'distanceMat_ltv','-ascii');
% save(['objectPositions_distanceMat_ltv_circularArena_',trialIDstring,'.mat'],'objectPositions','distanceMat_ltv','trialTimeDuration');

close(hf);

% function returns control



%% --------------------------------------------------------------------------
function initializeArena(hf)
moveImages('reset');

ud=get(hf,'UserData');

cla(ud.ha);
axis(ud.ha,'equal','off');
set(ud.ha,'Units',ud.options.axisUnits);


title(ud.ha,ud.instructionString,'FontUnits','normalized','FontSize',.03,'FontWeight','bold');
set(hf,'Color',[.9 .9 .9]);
axis(ud.ha,[0 ud.squareAxisWidth 0 ud.squareAxisWidth]);
set(ud.ha,'YDir','reverse'); % y axis points down (for image display)

% draw circular arena
ud.h_arena=rectangle('Position',[ud.squareObjWidth+ud.arenaMargin ud.squareObjWidth+ud.arenaMargin 2*ud.arenaRadius 2*ud.arenaRadius],'Curvature',[1 1],'EdgeColor','none','FaceColor',[1 1 1]);

% group selection of objects: add callbacks to axes object
set(ud.h_arena,'ButtonDownFcn','moveImages(''buttonDown'',''ellipse'')');

% arrange images in random sequence in peripheral circle
ud.seatingOrder=randperm(ud.nObjects);
initArrangementRad=ud.arenaRadius+ud.arenaMargin+ud.squareObjWidth/2;
ud.ctrXY=ud.squareAxisWidth/2;
angles_rad = 2*pi*(rand + (0:ud.nObjects-1)/ud.nObjects);
x = cos(angles_rad)*initArrangementRad;
y = sin(angles_rad)*initArrangementRad;
ud.h_image=nan(ud.nObjects,1);

for objectI=1:ud.nObjects
    ud.h_image(objectI)=image('XData',ud.ctrXY+x(objectI)-ud.imWidth/2,...
        'YData',ud.ctrXY+y(objectI)-ud.imHeight/2,...
        'CData',ud.imageData(ud.seatingOrder(objectI)).image,...
        'ButtonDownFcn','moveImages(''buttonDown'',''ellipse'')');

    % use imageData field 'alpha' to define transparency (if alpha exists and is not empty)
    if isfield(ud.imageData(ud.seatingOrder(objectI)),'alpha') && ~isempty(ud.imageData(ud.seatingOrder(objectI)).alpha)
        set(ud.h_image(objectI),'AlphaData',ud.imageData(ud.seatingOrder(objectI)).alpha);
    end
end

set(hf,'UserData',ud);


%% --------------------------------------------------------------------------
function answer=allInsideArena(hf)
ud=get(hf,'UserData');

insideArena=false(ud.nObjects,1);
for objectI=1:ud.nObjects
    xdata=get(ud.h_image(objectI),'XData');
    ydata=get(ud.h_image(objectI),'YData');
    x=xdata(1)+ud.imWidth/2-ud.ctrXY;
    y=ydata(1)+ud.imHeight/2-ud.ctrXY;
    insideArena(objectI)=sqrt(x^2+y^2)<ud.arenaRadius;
end
answer=all(insideArena);



%% --------------------------------------------------------------------------
% --- Executes just before letSubjectArrangeObjects_circularArena is made visible.
function letSubjectArrangeObjects_circularArena_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to letSubjectArrangeObjects_circularArena (see VARARGIN)

% Choose default command line output for letSubjectArrangeObjects_circularArena
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes letSubjectArrangeObjects_circularArena wait for user response (see UIRESUME)
% uiwait(handles.figure1);


%% --------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = letSubjectArrangeObjects_circularArena_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.axes1;
varargout{3} = handles.pushbutton1;
varargout{4} = handles.pushbutton2;


%% --------------------------------------------------------------------------
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

initializeArena(handles.figure1);


%% --------------------------------------------------------------------------
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ud=get(handles.figure1,'UserData');
ud.donePressed=true;
set(handles.figure1,'UserData',ud);


%% --------------------------------------------------------------------------
% --- Executes on any key press ocurring while GUI has the focus
function keypress_Callback
% disp('keypress_Callback');

scaleFactor=1.02;

moveImages('reset');

hf=gcbf;
ud=get(hf,'UserData');

lastKey=get(hf,'CurrentCharacter');

if any(lastKey=='aAzZ')
    % determine object positions (relative to center of arena)
    objectPositions=nan(ud.nObjects,2);
    for objectI=1:ud.nObjects
        xdata=get(ud.h_image(objectI),'XData');
        ydata=get(ud.h_image(objectI),'YData');
        x=xdata(1)+ud.imWidth/2-ud.ctrXY;
        y=ydata(1)+ud.imHeight/2-ud.ctrXY;
        objectPositions(ud.seatingOrder(objectI),:)=[x,y];
    end
    
    % apply the scale factor to the arrangement
    if any(lastKey=='aA')
        objectPositions=objectPositions*scaleFactor;
    elseif any(lastKey=='zZ')
        objectPositions=objectPositions/scaleFactor;
    end
    
    xy_new=(objectPositions+ud.ctrXY)-repmat([ud.imWidth/2,ud.imHeight/2],[ud.nObjects 1]);
    
    xlim=get(ud.ha,'XLim');
    ylim=get(ud.ha,'YLim');
    
    if all(xlim(1)<xy_new(:,1)) && all(xy_new(:,1)<xlim(2)) &&...
       all(ylim(1)<xy_new(:,2)) && all(xy_new(:,2)<ylim(2)),
        % all objects are still entirely within the axes limits: move all (otherwise: move none.)
        for objectI=1:ud.nObjects
            set(ud.h_image(objectI),'XData',xy_new(ud.seatingOrder(objectI),1));
            set(ud.h_image(objectI),'YData',xy_new(ud.seatingOrder(objectI),2));
        end
    end % object within axes limits
end % any(lastKey=='aAzZ')

set(hf,'UserData',ud);

