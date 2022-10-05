function [estimatedRDM_utv,matlabGradDescEstRDM]=inverseMDS(partialRDMs, partialRDM_nDims, MDScriterion, monitor)

% USAGE
%       estimatedRDM_utv=inverseMDS(partialRDMs, [partialRDM_nDims=2, MDScriterion='metricstress', monitor=undef])
%
% FUNCTION
%       to estimate a representational dissimilarity matrix (RDM) on the
%       basis of the distance matrices of several subset arrangements in a
%       lower dimensional space (partial RDM estimates).
%
%       the function implements inverse MDS in that it estimates an RDM (the
%       input to MDS) from multiple low-dimensional arrangements (outputs of
%       MDS). computing the distance matrix for an arrangement could be
%       conceptualized as inverting MDS. however, the solution is not unique,
%       because many other matrices may produce the same MDS solution (as the
%       global minimum of the chosen MDS cost function). this is to say that a
%       single MDS solution is not uniquely invertible. to constrain the problem
%       and obtain a unique estimate, we base the inversion on multiple partial
%       distance matrices from arrangements of subsetLOGs of the items.
%
%       version: 1.5


%% preparations
if ~exist('partialRDM_nDims','var'), partialRDM_nDims=2; end
if ~exist('MDScriterion','var'), MDScriterion='metricstress'; end

% global partialRDMs_utv; % >>> needed?
partialRDMs_utv=vectorizeRDMs(partialRDMs);
partialRDMs_sq=squareRDMs(partialRDMs);

nPairs=size(partialRDMs_utv,2); % number of dissimilarities = number of item pairs
nPartialRDMs=size(partialRDMs_utv,3);
nItems=(1+sqrt(1+8*nPairs))/2;

subsetLOGs=false(nPartialRDMs,nItems);
col=nan(nPartialRDMs,3);
jet_colormap=colormap(jet);
for partialRDM_I=1:nPartialRDMs
    
    % item sets of the partial RDMs
    subsetLOGs(partialRDM_I,:)=sum(isnan(partialRDMs_sq(:,:,partialRDM_I)))<nItems-1;
    
    % color coding for the partial RDM index
    col(partialRDM_I,:)=jet_colormap(ceil(partialRDM_I/nPartialRDMs*64),:);
    %     col(partialRDM_I,:)=randomColor;
end


%% search control variables
cAdjustmentStep=.2;
maxAdjustmentStep=1;
minAdjustmentStep=1/2/256;
shrinkBackProportion=.5; % 0: stay with current estimate, 1: shrink all the way back to the average-of-alinged initial estimate
randomizationRMS=.001; %0.1;

% intitialize
RMSerror=inf;
adjustment=zeros(1,nPairs); 
initRMSerror=nan;

%% initial estimate: average of aligned partial RDMs
avgAlgndEstRDM_utv=averageAlignedPartialRDMs(partialRDMs_utv);
avgAlgndEstRDMd2_utv=averageAlignedPartialRDMs_d2weights(partialRDMs_utv)
cEstRDM_utv=avgAlgndEstRDM_utv;

% partialRDMs_utv_max1=partialRDMs_utv./repmat(max(partialRDMs_utv,[],2),[1 nPairs 1]);
% avgAlgndEstRDMd2max1_utv=averageAlignedPartialRDMs_d2weights(partialRDMs_utv_max1)
% 
% weightExponent=.1;
% avgAlgndEstRDMinvSS1_utv=averageAlignedPartialRDMs_invSetsizeWeights(partialRDMs_utv, weightExponent);
% weightExponent=.5;
% avgAlgndEstRDMinvSS2_utv=averageAlignedPartialRDMs_invSetsizeWeights(partialRDMs_utv, weightExponent);
% weightExponent=1;
% avgAlgndEstRDMinvSS5_utv=averageAlignedPartialRDMs_invSetsizeWeights(partialRDMs_utv, weightExponent);
% weightExponent=10;
% avgAlgndEstRDMinvSS10_utv=averageAlignedPartialRDMs_invSetsizeWeights(partialRDMs_utv, weightExponent);
% 
% 
% 
% initEstRDMs_utv=cat(3,avgAlgndEstRDM_utv,avgAlgndEstRDMd2_utv,avgAlgndEstRDMd2max1_utv,avgAlgndEstRDMinvSS1_utv,avgAlgndEstRDMinvSS2_utv,avgAlgndEstRDMinvSS5_utv,avgAlgndEstRDMinvSS10_utv);
% initEstRDMs_utv=cat(3,initEstRDMs_utv,mean(initEstRDMs_utv,3));
% 
% % for initEstRDM_I=1:size(initEstRDMs_utv,3)
% %     RMSerrorOfPredArrangements(initEstRDMs_utv(:,:,initEstRDM_I), partialRDMs_utv, partialRDM_nDims, MDScriterion, monitor);
%     
% % show MDS of true RDM and its initial estimates
% if isfield(monitor,'trueRDM')
%     pageFigure(4);
%     monitoredRDMs=normalizeRDMs(cat(3,vectorizeRDMs(monitor.trueRDM),initEstRDMs_utv));
%     DMofRDMs=pdist(permute(monitoredRDMs,[3 2 1]),'euclidean');
%     DMofRDMs_sq=squareRDMs(DMofRDMs);
%     subplot(2,1,1); h=plot(1:9,DMofRDMs_sq(1,:),'o'); set(gca,'XTickLabel',{'true','avg','avgD2','avgD2max1','avgInvSS','avgInvSS2','avgInvSS5','avgInvSS10','\bfAVGAVG'});
%     options.figI_textLabels=[4 2 1 2];
%     figure(1701); subplot(2,1,2); cla;
%     options.textLabels={'true','avg','avgD2','avgD2max1','avgInvSS','avgInvSS2','avgInvSS5','avgInvSS10','\bfAVGAVG'};
%     options.categoryColors=[0 .5 1
%         0.5 0.5 0.5
%         0 0 0
%         0 0 0
%         .6 .6 .6
%         .4 .4 .4
%         .2 .2 .2
%         0 0 0
%         1 0 0];
% 
%     try
%         showMDSarrangement(DMofRDMs,options);
%     catch
%         disp('MDS visualization of initial RDM estimates failed.');
%     end
% end


% RMSerror_avgAlgndEstRDM=RMSerrorOfPredArrangements(avgAlgndEstRDM_utv, partialRDMs_utv, partialRDM_nDims, MDScriterion, monitor)



%% use matlab gradient descent function
% tic
% [matlabGradDescEstRDM,RMSerrorOfPredArr_matlabGradDescEstRDM] = fminunc(@(estRDM_utv) RMSerrorOfPredArrangements(estRDM_utv, partialRDMs_utv, partialRDM_nDims, MDScriterion),avgAlgndEstRDM_utv);
% disp(['fminunc took ',tocString,'.'])
matlabGradDescEstRDM=nan;


%% estimate RDM by iterative reduction of RMS error of MDS-predicted partial RDMs
RMSadjustment=inf;
minRMSerror=inf;

% visualize convergence
iterationI=1;
nIterations=1000;
RMSerrors=[];
reinitIterationIs=[1];
slowdownIterationIs=[];
shrinkbackIterationIs=[];

% press0mouse1key=0;
% while press0mouse1key==0;
    
tic
while RMSadjustment>1e-5 && iterationI<nIterations
    
    % normalize the estimated RDM
    cEstRDM_utv=normalizeRDMs(cEstRDM_utv);
    
    errors=[];
    prevAdjustment=adjustment;
    adjustment=zeros(size(cEstRDM_utv)); 
    adjustmentCount=zeros(size(cEstRDM_utv));
    
    
    % predict each subset arrangment's RDM from the current RDM estimate
    for partialRDM_I=1:nPartialRDMs
        
        % use MDS to predict the distance matrix for this subset arrangment
        % (given the current RDM estimate)
        cEstRDM_utv_partial=reduceRDMs(cEstRDM_utv,subsetLOGs(partialRDM_I,:));
        RMSestRDM_forSubset=rms(cEstRDM_utv_partial);
        nDissims_cPartialRDM=sum(subsetLOGs(partialRDM_I,:));
        
        %         try
        predMDSdists=pdist(mdscale(cEstRDM_utv_partial, partialRDM_nDims, 'criterion', MDScriterion));
        %         catch
        %             a=1;
        %         end
        predMDSdists_aligned2estRDM=predMDSdists/rms(predMDSdists)*RMSestRDM_forSubset;
        
        % compute disparities between the predicted and actual distance matrix
        cPartialRDM_utv=reduceRDMs(partialRDMs_utv(:,:,partialRDM_I),subsetLOGs(partialRDM_I,:)); % remove undefined part
        cPartialRDM_utv_aligned2estRDM=cPartialRDM_utv/rms(cPartialRDM_utv)*RMSestRDM_forSubset;
        cPartialDisparities=predMDSdists_aligned2estRDM-cPartialRDM_utv_aligned2estRDM;
        errors=[errors;cPartialDisparities(:)];
        
        % adjust current RDM estimate so as to reduce disparities
        cPartialDisparities_sq=zeros(nItems,nItems);
        cPartialDisparities_sq(subsetLOGs(partialRDM_I,:),subsetLOGs(partialRDM_I,:))=squareRDMs(cPartialDisparities);
        adjustment=adjustment-vectorizeRDMs(cPartialDisparities_sq);
        adjustmentCount=adjustmentCount+(vectorizeRDMs(cPartialDisparities_sq)~=0);
    end
    
    prevRMSerror=RMSerror;
    RMSerror=rms(errors);
    if isnan(initRMSerror), initRMSerror=RMSerror; end % this is the RMSerror for the initial RDM estimate: not to be exceeded
    RMSerrors(iterationI)=RMSerror;
    
    if RMSerror<minRMSerror
        estimatedRDM_utv=cEstRDM_utv;
        minRMSerror=RMSerror;
        bestEstIterationI=iterationI;
    end
    
    % adjust cEstRDM_utv
    if RMSerror>1.1*initRMSerror
        % initial estimate was better than current: reinitialize with added noise
        %         cEstRDM_utv=avgAlgndEstRDM_utv+randomizationRMS*randn(1,nPairs);
        cEstRDM_utv=estimatedRDM_utv+randomizationRMS*randn(1,nPairs);
        cEstRDM_utv(cEstRDM_utv<0)=0; % limit to positive range
        
        cAdjustmentStep=.2; % reset step size
        %RMSerror=inf;
        adjustment=zeros(1,nPairs);
        reinitIterationIs=[reinitIterationIs,iterationI];
        
    else
        if RMSerror>prevRMSerror
        
            % RMSerror increased: take half a step back and slow to half speed
            cEstRDM_utv=cEstRDM_utv-0.5*prevAdjustment;
            adjustment=0.5*prevAdjustment;
            cEstRDM_utv(cEstRDM_utv<0)=0; % limit to positive range (because adjustments are based on MDS arrangements, sub-zero pulls are not impossible.)

            cAdjustmentStep=cAdjustmentStep/2;

            if cAdjustmentStep<minAdjustmentStep
                % shrink back toward average-of-aligned-partial-RDMs estimate
%                 cEstRDM_utv=(1-shrinkBackProportion)*cEstRDM_utv+shrinkBackProportion*avgAlgndEstRDM_utv;
%                 cAdjustmentStep=0.3;
%                 adjustment=zeros(1,nPairs);
%                 shrinkbackIterationIs=[shrinkbackIterationIs,iterationI];
                
                % random step
                cEstRDM_utv=cEstRDM_utv+randomizationRMS*randn(1,nPairs);
                cEstRDM_utv(cEstRDM_utv<0)=0; % limit to positive range

                cAdjustmentStep=.2; % reset step size
                RMSerror=inf;
                adjustment=zeros(1,nPairs);
                shrinkbackIterationIs=[shrinkbackIterationIs,iterationI];
                
                
                
            else
                slowdownIterationIs=[slowdownIterationIs,iterationI];
            end
        else
            % RMSerror decreased (or didn't change): take a step forward
            adjustmentCount(adjustment==0)=1;
            adjustment=adjustment./adjustmentCount; % the adjustment applied is the mean of the adjustments suggested by the arrangements.
            RMSadjustment=rms(adjustment);
            adjustment=cAdjustmentStep*adjustment;
            
            % adjust only half the entries (randomly chosen)
            %adjustment(rand(1,nPairs)>.5)=0;

            cEstRDM_utv=cEstRDM_utv+adjustment;
            cEstRDM_utv(cEstRDM_utv<0)=0; % limit to positive range (because adjustments are based on MDS arrangements, sub-zero pulls are not impossible.)
            cAdjustmentStep=cAdjustmentStep*1.2;
            if cAdjustmentStep>maxAdjustmentStep, cAdjustmentStep=maxAdjustmentStep; end
        end
    end
    cAdjustmentStep
    
    % visualize convergence
    if exist('monitor','var')
        
        % show dissimilarity plots for partial RDMs
        if isfield(monitor,'trueRDM')
            showPartialRDMsAlignment(partialRDMs,cat(3,cEstRDM_utv,estimatedRDM_utv),monitor.trueRDM);
        else
            showPartialRDMsAlignment(partialRDMs,cat(3,cEstRDM_utv,estimatedRDM_utv));
        end
        
        % show RMS error and correlation to true RDM across iterations
        figure(1701); subplot(2,1,1); cla;
        if isfield(monitor,'trueRDM')
            % plot RMS error of predicted arrangements and RMS disparity of estimated and true RDMs
            %RMSdisp_true2avgAlgndRDM=RMSdisparityOfNormRDMs(monitor.trueRDM,avgAlgndEstRDM_utv);
            RMSdisp_true2currentRDM(iterationI)=RMSdisparityOfNormRDMs(monitor.trueRDM,cEstRDM_utv);
            [AX,H1,H2] = plotyy(1:iterationI,RMSdisp_true2currentRDM,1:iterationI,RMSerrors);
            set(get(AX(1),'Ylabel'),'String','RMS disparity of estimated and true RDMs (both normalized)');
            set(get(AX(2),'Ylabel'),'String','RMS error of predicted arrangements');
            set(AX(1),'YColor',[0 .5 1],'YLim',[0 max(RMSdisp_true2currentRDM)],'YLimMode','manual');        
            set(AX(2),'YColor','k','YLim',[0 max(RMSerrors)],'YLimMode','manual');
            set(H1,'LineStyle','-','Color',[0 .5 1],'LineWidth',5);
            set(H2,'LineStyle','-','Color','k','LineWidth',2,'Marker','none','MarkerSize',1.5,'MarkerFaceColor','k');

            hold on;
            plot(AX(1),reinitIterationIs,RMSdisp_true2currentRDM(reinitIterationIs),'LineStyle','none','Marker','o','MarkerSize',10,'MarkerFaceColor','r','MarkerEdgeColor','r');
            plot(AX(1),slowdownIterationIs,RMSdisp_true2currentRDM(slowdownIterationIs),'LineStyle','none','Marker','<','MarkerSize',5,'MarkerFaceColor','none','MarkerEdgeColor','k');
            plot(AX(1),shrinkbackIterationIs,RMSdisp_true2currentRDM(shrinkbackIterationIs),'LineStyle','none','Marker','*','MarkerSize',5,'MarkerFaceColor','r','MarkerEdgeColor','r');
            plot(AX(1),bestEstIterationI,RMSdisp_true2currentRDM(bestEstIterationI),'LineStyle','none','Marker','o','MarkerSize',20,'MarkerFaceColor','none','MarkerEdgeColor','r');

%             RMSerrorAX=AX(2);
        else
            plot(1:iterationI,RMSerrors,'-k');
            ylabel('RMS error of predicted arrangements');
%             RMSerrorAX=gca;
        end
        hold on;
        xlabel('iteration');
        
        if isfield(monitor,'trueRDM')
            RMSdisp_true2avg=RMSdisparityOfNormRDMs(monitor.trueRDM,avgAlgndEstRDM_utv);
            RMSdisp_true2cEst=RMSdisparityOfNormRDMs(monitor.trueRDM,cEstRDM_utv);
            RMSdisp_true2best=RMSdisparityOfNormRDMs(monitor.trueRDM,estimatedRDM_utv);
            title({['\fontsize{8}RMSdisp(trueRDM,avgAlgndRDM)=',num2str(RMSdisp_true2avg),', RMSdisp(trueRDM,cEstRDM_utv)=',num2str(RMSdisp_true2cEst)],...
                ['RMSdisp(trueRDM,bestEstRDM_utv)=',num2str(RMSdisp_true2best),', \bfiterative RDM-estimate error reduction ',num2str((1-RMSdisp_true2best/RMSdisp_true2avg)*100),'%'],...
                ['iterative arrangement-prediction error reduction: ',num2str((1-minRMSerror/initRMSerror)*100),'%']});
        else
            title({['iterative arrangement-prediction error reduction: ',num2str((1-minRMSerror/initRMSerror)*100),'%'],...
                '( (1-minRMSerror/initRMSerror)*100 )'});
            
        end        
        
        % show MDS of true, averaged aligned, current-iteration and best estimated RDMs
        if isfield(monitor,'trueRDM')
            shrinkbackEstRDMfourth=.25*avgAlgndEstRDM_utv+.75*cEstRDM_utv;
            shrinkbackEstRDMhalf=0.5*avgAlgndEstRDM_utv+0.5*cEstRDM_utv;
            
            monitoredRDMs=normalizeRDMs(cat(3,vectorizeRDMs(monitor.trueRDM),avgAlgndEstRDM_utv,cEstRDM_utv,estimatedRDM_utv,shrinkbackEstRDMfourth,shrinkbackEstRDMhalf));
            DMofRDMs=pdist(permute(monitoredRDMs,[3 2 1]),'euclidean');
            %options.figI_catCols=[1701 2 1 2];
            options.figI_textLabels=[1701 2 1 2];
            figure(1701); subplot(2,1,2); cla;
            %options.contrasts=eye(4);
            %options.categoryLabels={'true','avgAlgndEst','currentEst','bestEst'};
            options.textLabels={'true','avgAlgnd','current','best','shrinkbackFourth','shrinkbackHalf'};
            options.categoryColors=[0 .5 1
                                    0.5 0.5 0.5
                                    0 0 0
                                    1 0 0
                                    0 0 0
                                    0 0 0];
            
            try
                showMDSarrangement(DMofRDMs,options);
            catch
                disp('MDS visualization of convergence failed.');
            end
        end
                
    end
    iterationI=iterationI+1;
end
disp(['slidedown took ',tocString,'.'])


% press0mouse1key = waitforbuttonpress;
% nIterations=nIterations+100;
% end


