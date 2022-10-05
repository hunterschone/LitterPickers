% TEST2_inverseMDS_complexRandomRDMs

clear; close all hidden;

%% control variables
nItems=96;
nTrials=nItems;
nDim_internal=nItems;
% randomPartialRDMs_nsItems=[10 8 8 8 5 5 5 5 3 3 3 3 3 3]; %nItems:-1:3;
randomPartialRDMs_nsItems=round(logspace(log10(nItems),log10(3),nTrials/1.15));

% nItems=8;
% nTrials=nItems;
% nDim_internal=nItems;
% randomPartialRDMs_nsItems=round(logspace(log10(nItems),log10(3),nTrials));
% 
% nItems=16;
% nTrials=nItems;
% nDim_internal=nItems;
% randomPartialRDMs_nsItems=round(logspace(log10(nItems),log10(3),nTrials))
% randomPartialRDMs_nsItems=[16 10 10 8 8 8 4 4 4 3 3 3 3 3 3];

sum(randomPartialRDMs_nsItems)/(nItems*(nItems-1)/2)


%% true RDM (complex, random)
patterns=randn(nItems,nDim_internal);
trueRDM=squareRDMs(pdist(patterns));


%% define partial RDMs
partialRDMs=[];
for randomPartialRDM_nItems=randomPartialRDMs_nsItems
    randPermOfItemIs=randperm(nItems);
    cPartialRDM_itemIs=randPermOfItemIs(1:randomPartialRDM_nItems);
    
    arrangement=mdscale(trueRDM(cPartialRDM_itemIs,cPartialRDM_itemIs),2,'criterion','metricstress');

    %     figure(1); clf;
    %     rubberbandGraphPlot(arrangement,trueRDM(partialRDM1_itemIs,partialRDM1_itemIs));

    cPartialRDM_collapsed=pdist(arrangement);
    
    cPartialRDM=nan(size(trueRDM));

    cPartialRDM(cPartialRDM_itemIs,cPartialRDM_itemIs)=squareform(cPartialRDM_collapsed);

    
    partialRDMs=cat(3,partialRDMs,cPartialRDM);
end

showRDMs(partialRDMs,2);


%% aligned-average RDM estimate
% (estimateDissimMatFromStackOfPartials)

estRDM_utv_alignedAvg=averageAlignedPartialRDMs(partialRDMs);
%estRDM_utv_alignedAvg=estimateDissimMatFromStackOfPartials(partialRDMs); % identical

showRDMs(cat(3,trueRDM,partialRDMs,squareform(estRDM_utv_alignedAvg)),2);

% 
% arrangement3d=mdscale(estRDM_utv_alignedAvg,3,'criterion','metricstress');
% 
% figure(30);
% plot3(arrangement3d(:,1),arrangement3d(:,2),arrangement3d(:,3),'o');
% axis equal;


%% inverse MDS
partialRDM_nDims=2;
MDScriterion='metricstress';
monitor.trueRDM=trueRDM;
%estRDM_utv_invMDS=inverseMDS_v1(partialRDMs, partialRDM_nDims, MDScriterion, monitor)
[estRDM_utv_invMDS,matlabGradDescEstRDM]=inverseMDS(partialRDMs, partialRDM_nDims, MDScriterion, monitor)

RDMs=cat(3,trueRDM,partialRDMs,squareform(estRDM_utv_alignedAvg),squareform(estRDM_utv_invMDS));
RDMs=vectorizeRDMs(RDMs);
RDMs=normalizeRDMs(RDMs);
showRDMs(RDMs,2);



%% export figures as ps
% RDMs
figure(2);
exportCurrentFigAsPostscript([dateAndTimeString_nk,'_RDMs'],false);

% dissimilarity plots
figure(1600);
% subplot(2,1,1); text(1,5,['item sizes for trials: ',num2str(randomPartialRDMs_nsItems)]);
exportCurrentFigAsPostscript([dateAndTimeString_nk,'_dissimPlots'],false);

% iterative convergence
figure(1701);
% addHeading({any2str('\fontsize{9}corr(trueRDM,1stPartialRDM)=',corr(vectorizeRDMs(trueRDM)',vectorizeRDMs(partialRDMs(:,:,1))')),...
%             any2str('\fontsize{9}corr(trueRDM,estRDM_alignedAvg)=',corr(vectorizeRDMs(trueRDM)',estRDM_utv_alignedAvg')),...
%             any2str('\fontsize{9}corr(trueRDM,estRDM_invMDS)=',corr(vectorizeRDMs(trueRDM)',estRDM_utv_invMDS'))},1701,.8,1.08);
exportCurrentFigAsPostscript([dateAndTimeString_nk,'_convergence'],false);


