function str=tocString

[days,hours,minutes,seconds,secondfraction]=tocVerbose(0);

str=[];
if days>0
    str=[str,any2str(days,' days, ')];
end
if hours>0
    str=[str,any2str(hours,' hours, ')];
end
if minutes>0
    str=[str,any2str(minutes,' min., ')];
end
str=[str,any2str(seconds,' s')];
