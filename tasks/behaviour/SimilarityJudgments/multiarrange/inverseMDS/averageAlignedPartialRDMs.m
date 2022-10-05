function estimatedRDM_utv=averageAlignedPartialRDMs(partialRDMs, monitor)



%% preparations
if ~exist('monitor', 'var')
    monitor=false;
end

global partialRDMs_utv;
partialRDMs_utv=vectorizeRDMs(partialRDMs);
nPairs=size(partialRDMs_utv,2); % number of dissimilarities = number of item pairs
nPartialRDMs=size(partialRDMs_utv,3);
nObjects=(1+sqrt(1+8*nPairs))/2;

col=nan(nPartialRDMs,3);
jet_colormap=colormap(jet);
for partialRDMI=1:nPartialRDMs
    %     col(partialRDMI,:)=randomColor;
    col(partialRDMI,:)=jet_colormap(ceil(partialRDMI/nPartialRDMs*64),:);
end


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
    cEstimate=nanmean(partialRDMs_utv_normalized,3);
    
    % weighted-mean estimate
    %     weights=partialRDMs_utv.^2; % SNR=1 -> weight=1, SNR=.5 -> weight=.25
    %     cEstimate=nansum(partialRDMs_utv_normalized.*weights,3)./nansum(weights,3);
    
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

