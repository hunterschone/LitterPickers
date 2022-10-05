function estimatedRDM_utv=averageAlignedPartialRDMs_invSetsizeWeights(partialRDMs, weightExponent, monitor)

% USAGE
%   estimatedRDM_utv=averageAlignedPartialRDMs_invSetsizeWeights(partialRDMs[, weightExponent=1, monitor])


%% preparations
if ~exist('weightExponent', 'var')
    weightExponent=1;
end
if ~exist('monitor', 'var')
    monitor=false;
end

global partialRDMs_utv;
partialRDMs_utv=vectorizeSimmats(partialRDMs);
nPairs=size(partialRDMs_utv,2); % number of dissimilarities = number of item pairs
nPartialRDMs=size(partialRDMs_utv,3);
nItems=(1+sqrt(1+8*nPairs))/2;

subsetLOGs=false(nPartialRDMs,nItems);
partialRDMs_sq=squareRDMs(partialRDMs);
setSize=nan(nPartialRDMs,1);
col=nan(nPartialRDMs,3);
jet_colormap=colormap(jet);
for partialRDM_I=1:nPartialRDMs
    
    % item sets of the partial RDMs
    subsetLOGs(partialRDM_I,:)=sum(isnan(partialRDMs_sq(:,:,partialRDM_I)))<nItems-1;
    
    % color coding for the partial RDM index
    col(partialRDM_I,:)=jet_colormap(ceil(partialRDM_I/nPartialRDMs*64),:);
    %     col(partialRDM_I,:)=randomColor;
end
setSizes=sum(subsetLOGs,2);

%% initial estimate: mean
initialEstimate=nanmean(partialRDMs_utv,3);
initialEstimate=initialEstimate/sqrt(sum(initialEstimate.^2));


%% estimate dissimilarity by iterative alignment to mean
cEstimate=initialEstimate;
iterationChangeSSQ=inf;

% visualize convergence
% figw(900); clf; % for visualization of convergence
% iterationI=1;

% tic
while iterationChangeSSQ>1e-8
    cPartialRDM_utv_normalized=nan(size(partialRDMs_utv));
    % align each partial dissimilarity matrix to the current estimate
    for partialRDMI=1:nPartialRDMs
        cPartialRDM_utv=partialRDMs_utv(1,:,partialRDMI);
        nonNaN_LOG=~isnan(cPartialRDM_utv);
        targetSSQ=sum(cEstimate(nonNaN_LOG).^2);

        partialRDMs_utv_normalized(1,:,partialRDMI)=cPartialRDM_utv/sqrt(sum(cPartialRDM_utv(nonNaN_LOG).^2))*sqrt(targetSSQ);
    end
    
    % average the aligned partial dissimilarity matrices to obtain the new estimate
    pEstimate=cEstimate;
    
    % unweighted-mean estimate
    %     cEstimate=nanmean(partialRDMs_utv_normalized,3);
    
    % weighted-mean estimate
    weights=repmat(reshape(1./setSizes,[1 1 nPartialRDMs]),[1 nPairs 1]);
    weights=weights.^weightExponent;
    weights(isnan(partialRDMs_utv))=nan;
    cEstimate=nansum(partialRDMs_utv_normalized.*weights,3)./nansum(weights,3);
    
    cEstimate=cEstimate/sqrt(sum(cEstimate.^2));
    
    iterationChangeSSQ=sum((cEstimate-pEstimate).^2);
    
end
estimatedRDM_utv=normalizeRDMs(cEstimate); % normalize by scaling the dissimilarity RMS to 1
% toc

if monitor
    showPartialRDMsAlignment(partialRDMs,estimatedRDM_utv);
end

%% estimate dissimilarity matrix by optimization
% tic
% estimatedRDM_utv = fminsearch(@(RDMEstimate) deviationBetweenRDMAndStackOfPartials(RDMEstimate),initialEstimate)
% toc

% tic
% estimatedRDM_utv = fminsearch(@(RDMEstimate) deviationBetweenRDMAndStackOfPartials(RDMEstimate),estimatedRDM_utv)
% toc

