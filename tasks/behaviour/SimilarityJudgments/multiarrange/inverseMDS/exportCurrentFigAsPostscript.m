function exportCurrentFigAsPostscript(filespec,appendFlag)
% exports the current figures to the file [filespec,'.ps'] in postscript
% format. if appendFlag is 0 any existing file [filespec,'.ps'] is
% overwritten. if appendFlag is 1 the figure is appended to the existing
% postscript file [filespec,'.ps']. if appendFlag is 3 (default) the figure
% is appended to the existing postscript file [filespec,'.ps'] and exported
% to a separate file [filespec,'_',num2str(gcf),'.ps'].

if ~exist('filespec','var'), filespec='currentFigAsPostscript'; end
if isempty(filespec), return; end
if ~exist('appendFlag','var'), appendFlag=1; end

switch appendFlag
    case 0
        print('-dpsc2',filespec);
    case 1
        print('-dpsc2','-append',filespec);
    case 3
        print('-dpsc2',[filespec,'_',num2str(gcf)]);
        print('-dpsc2','-append',filespec);
    case 4
        print('-dpsc2',filespec);
        print('-dpsc2','-append','^ALL_POSTSCRIPTS_appendFlag4');
end