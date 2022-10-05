function h=pageFigure(figI,paperSizeORheightToWidth,proportionOfScreenArea,horPos0123,landscapeFig)
% h=pageFigure([figI,paperSizeORheightToWidth,proportionOfScreenArea,horPos1234]);

if ~exist('figI','var'), figI=gcf; end
%if ~exist('paperSizeORheightToWidth'), paperSizeORheightToWidth='A4'; end
if ~exist('paperSizeORheightToWidth','var')||isempty(paperSizeORheightToWidth), paperSizeORheightToWidth='letter'; end
%if ~exist('proportionOfScreenArea')||isempty(proportionOfScreenArea), proportionOfScreenArea=0.23; end
if ~exist('proportionOfScreenArea','var')||isempty(proportionOfScreenArea), proportionOfScreenArea=.35; end
if ~exist('landscapeFig','var') || isempty(landscapeFig), landscapeFig=false; end

if ishandle(figI) && strcmp(get(figI,'type'),'figure')
    h=figure(figI(1));
else
    h=figure;
end

% if ~exist('horPos0123','var')||isempty(horPos0123), horPos0123=mod(mod(h,10),4); end

set(h,'Color','w');
%set(h,'WindowStyle','docked');

if ischar(paperSizeORheightToWidth)
    if strcmp(paperSizeORheightToWidth,'A4')
        heightToWidth=sqrt(2)/1;
    elseif strcmp(paperSizeORheightToWidth,'legal')
        heightToWidth=14/8.5;
    elseif strcmp(paperSizeORheightToWidth,'letter')
        heightToWidth=11/8.5;
    end
else
    heightToWidth=paperSizeORheightToWidth;
end

if landscapeFig
    heightToWidth=1/heightToWidth;
end

lbwh = get(0,'ScreenSize');
screenArea=lbwh(3)*lbwh(4);

figWidth=sqrt(screenArea*proportionOfScreenArea/heightToWidth);
figHeight=heightToWidth*figWidth;

%left=lbwh(3)/2*horPos0123;
left=(lbwh(3)-figWidth)/2;
bottom=(lbwh(4)-figHeight)/2;

set(h,'Position',[left bottom figWidth figHeight])
% [left, bottom, width, height]

set(h,'PaperPositionMode','auto'); % 'auto' here prevents resizing when the figure is printed.
