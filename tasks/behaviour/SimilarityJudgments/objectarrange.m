clear; close all hidden;
addpath(genpath('multiarrange'))

rng('shuffle');

base_dir = 'right_effectors';

options.sessionI = 1; 
options.axisUnits = 'normalized'; % images resized
options.maxSessionLength_min = 20; % maximum 40 minutes

options.analysisFigs = false;

options.subjectInitials=inputdlg('Subject initials:');
options.subjectInitials=options.subjectInitials{1};

options.screen = 1; % do we use a secondary screen?

%% load stimuli

disp('Loading stimuli...')
try
    load(fullfile(base_dir,'stimuli.mat'))
catch
    base_dir = pwd;
    load(fullfile(base_dir,'stimuli.mat'))
end
disp('done.')

%% administer session
options.dateAndTime_start=clock;

% MULTI-ARRANGEMENT (MA)
[estimate_dissimMat_ltv_MA,simulationResults_ignore,story_MA]=simJudgmentByMultiArrangement_circArena_liftTheWeakest(stimuli,'Please arrange these objects according to their similarity',options);

%% save experimental data from the current subject
if ~isdir(fullfile(base_dir,'results')), mkdir(base_dir,'results'), end
save(fullfile(base_dir,'results',sprintf('%s_session%i_%s_workspace.mat',options.subjectInitials,options.sessionI,dateAndTimeStringNoSec_nk)));

%% display representational dissimilarity matrix (RDM)
showSimmats(estimate_dissimMat_ltv_MA);
addHeadingAndPrint('multiple-trial RDM','figures');

%% plot stimuli in multidimensional-scaling (MDS) arrangement
criterion='metricstress';
[pats_mds_2D,stress,disparities]=mdscale(estimate_dissimMat_ltv_MA,2,'criterion',criterion);

pageFigure(400); subplot(2,1,2); 
drawImageArrangement(stimuli,pats_mds_2D,1,[1 1 1]);
title({'\fontsize{14}stimulus images in MDS arrangement\fontsize{11}',[' (',criterion,')']});
shepardPlot(estimate_dissimMat_ltv_MA,disparities,pdist(pats_mds_2D),[400 2 1 2],['\fontsize{14}shepard plot\fontsize{11}',' (',criterion,')']);
addHeadingAndPrint('multiple-trial MDS plot','figures');
