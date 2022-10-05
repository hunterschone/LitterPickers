% TEST_inverseMDS

clear; close all hidden;

%% true RDM (3 dimensional)
% tetrahedron
trueRDM=[0 1 1 1
         1 0 1 1
         1 1 0 1
         1 1 1 0];

% sprinkle negligible noise for MDS uniqueness
%trueRDM=squareRDMs(vectorizeRDMs(trueRDM)+randn(size(vectorizeRDMs(trueRDM)))*0.00001);

%% define partial RDMs
partialRDM1_itemIs=[1 2 3 4];
partialRDM2_itemIs=[1 2 3];

arrangement1=mdscale(trueRDM(partialRDM1_itemIs,partialRDM1_itemIs),2,'criterion','metricstress');
arrangement2=mdscale(trueRDM(partialRDM2_itemIs,partialRDM2_itemIs),2,'criterion','metricstress');

figure(1); clf;
subplot(2,1,1); rubberbandGraphPlot(arrangement1,trueRDM(partialRDM1_itemIs,partialRDM1_itemIs)); title('first arrangement provided by the subject (simulated by MDS)');
subplot(2,1,2); rubberbandGraphPlot(arrangement2,trueRDM(partialRDM2_itemIs,partialRDM2_itemIs)); title('second arrangement provided by the subject (simulated by MDS)');
% subplot(2,1,1); plot(arrangement1(:,1),arrangement1(:,2));
% subplot(2,1,2); plot(arrangement2);

partialRDM1_collapsed=pdist(arrangement1);
partialRDM2_collapsed=pdist(arrangement2);

partialRDM1=nan(size(trueRDM));
partialRDM2=nan(size(trueRDM));

partialRDM1(partialRDM1_itemIs,partialRDM1_itemIs)=squareform(partialRDM1_collapsed);
partialRDM2(partialRDM2_itemIs,partialRDM2_itemIs)=squareform(partialRDM2_collapsed);

partialRDMs=cat(3,partialRDM1,partialRDM2);
showRDMs(partialRDMs,2,false,[0 1.3]);



%% aligned-average RDM estimate
% (averageAlignedPartialRDMs)

estRDM_utv_alignedAvg=averageAlignedPartialRDMs(partialRDMs);

%showRDMs(cat(3,trueRDM,partialRDM1,partialRDM2,squareform(estRDM_utv_alignedAvg)),2,false,[0 1.3]);


arrangement3d=mdscale(estRDM_utv_alignedAvg,3,'criterion','metricstress');

figure(30);
plot3(arrangement3d(:,1),arrangement3d(:,2),arrangement3d(:,3),'o');
axis equal;


%% inverse MDS
partialRDM_nDims=2;
MDScriterion='metricstress';
monitor.trueRDM=trueRDM;
[estRDM_utv_invMDS,matlabGradDescEstRDM]=inverseMDS(partialRDMs, partialRDM_nDims, MDScriterion, monitor);

RDMs=cat(3,trueRDM,partialRDM1,partialRDM2,squareform(estRDM_utv_alignedAvg),squareform(estRDM_utv_invMDS));
RDMs=vectorizeRDMs(RDMs);
RDMs=normalizeRDMs(RDMs);
showRDMs(RDMs,2,false,[0 1.3]);


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




