function estimatedRDM_utv=inverseMDS(partialRDMs, partialRDM_nDims, MDScriterion, monitor)

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
%       version: 1.0


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



%% initial estimate: average of aligned partial RDMs
avgAlgndEstRDM_utv=averageAlignedPartialRDMs(partialRDMs_utv);
cEstRDM_utv=avgAlgndEstRDM_utv;

% RMSerror_avgAlgndEstRDM=RMSerrorOfPredArrangements(avgAlgndEstRDM_utv, partialRDMs_utv, partialRDM_nDims, MDScriterion, monitor)



%% estimate RDM by iterative reduction of RMS error of MDS-predicted partial RDMs
RMSadjustment=inf;
minRMSerror=inf;

% visualize convergence
iterationI=1;
nIterations=1000;
RMSerrors=[];

% press0mouse1key=0;
% while press0mouse1key==0;
    
% tic
while RMSadjustment>1e-3 && iterationI<nIterations
    
    % normalize the estimated RDM
    cEstRDM_utv=normalizeRDMs(cEstRDM_utv);
    
    errors=[];
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
    
    RMSerror=rms(errors);
    RMSerrors(iterationI)=RMSerror;
    
    if RMSerror<minRMSerror
        estimatedRDM_utv=cEstRDM_utv;
        minRMSerror=RMSerror;
    end
    
    % adjust cEstRDM_utv
    adjustmentCount(adjustment==0)=1;
    adjustment=adjustment./adjustmentCount; % the adjustment applied is the mean of the adjustments suggested by the arrangements.
    RMSadjustment=rms(adjustment)
    
    cEstRDM_utv=cEstRDM_utv+.2*adjustment;
    cEstRDM_utv(cEstRDM_utv<0)=0; % limit to positive range (because adjustments are based on MDS arrangements, sub-zero pulls are not impossible.)
    
    % visualize convergence
    if exist('monitor','var')
        
        % show dissimilarity plots for partial RDMs
        if isfield(monitor,'trueRDM')
            showPartialRDMsAlignment(partialRDMs,cEstRDM_utv,monitor.trueRDM);
        else
            showPartialRDMsAlignment(partialRDMs,cEstRDM_utv);
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
            set(AX(1),'YColor',[0 .5 1]);        
            set(AX(2),'YColor','k');
            set(H1,'LineStyle','-','Color',[0 .5 1],'LineWidth',10);
            set(H2,'LineStyle','-','Color','k','LineWidth',4,'Marker','none','MarkerSize',1.5,'MarkerFaceColor','k');
        else
            plot(1:iterationI,RMSerrors,'-k');
            ylabel('RMS error of predicted arrangements');
        end
        xlabel('iteration');
        
        
        % show MDS of true, averaged aligned, current-iteration estimated RDMs
        if isfield(monitor,'trueRDM')
            monitoredRDMs=normalizeRDMs(cat(3,vectorizeRDMs(monitor.trueRDM),avgAlgndEstRDM_utv,cEstRDM_utv));
            DMofRDMs=pdist(permute(monitoredRDMs,[3 2 1]),'euclidean');
            options.figI_catCols=[1701 2 1 2];
            options.figI_textLabels=[1701 2 1 2];
            figure(1701); subplot(2,1,2); cla;
            options.contrasts=eye(3);
            options.categoryLabels={'trueRDM','avgAlgndEstRDM','current'};
            options.textLabels={'','',''};
            options.categoryColors=[1 0 0
                                    0 0 0
                                    0 1 0];
            
            showMDSarrangement(DMofRDMs,options);
        end
                
    end
    iterationI=iterationI+1;
end
% toc

% press0mouse1key = waitforbuttonpress;
% nIterations=nIterations+100;
% end


