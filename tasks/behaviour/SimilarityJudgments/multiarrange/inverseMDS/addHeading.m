% local FUNCTION: addHeadingAndPrint(heading)
function th=addHeading(heading,figI,x,y)


% replace underscores
if iscell(heading)
    for lineI=1:numel(heading)
        line=heading{lineI};
        line(line==95)='-';
        heading{lineI}=line;
    end
else
    heading(heading==95)='-';
end    

if ~exist('figI','var'), figI=gcf; end
pageFigure(figI);

if ~exist('x','var'), x=1.11; end
if ~exist('y','var'), y=1.08; end

h=axes('Parent',gcf); hold on;
set(h,'Visible','off');
axis([0 1 0 1]);

% add heading(s)
th=text(x,y,heading,'HorizontalAlignment','Right','VerticalAlignment','Top','FontSize',12,'FontWeight','bold','Color','k');
