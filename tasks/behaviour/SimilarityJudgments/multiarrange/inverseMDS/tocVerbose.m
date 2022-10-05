function [days,hours,minutes,seconds,secondfraction]=tocVerbose(display)

% FUNCTION
%       returns and optionally outputs the matlab stopwatch time toc.
%       command-window output occurs if display is nonzero.
%
% USAGE
%       [days,hours,minutes,seconds,secondfraction]=tocVerbose(display)

t=toc;
seconds=floor(t);
secondfraction=t-seconds;

minutes=floor(seconds/60);
seconds=seconds-minutes*60;

hours=floor(minutes/60);
minutes=minutes-hours*60;

days=floor(hours/24);
hours=hours-days*24;

if display
    disp([num2str(days),' days, ',num2str(hours),' hours, ',num2str(minutes),' minutes, ',num2str(seconds),' seconds']);
end
