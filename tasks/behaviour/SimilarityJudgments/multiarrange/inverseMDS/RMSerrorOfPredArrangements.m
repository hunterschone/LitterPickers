function RMSerror=RMSerrorOfPredArrangements(estRDM_utv, partialRDMs_utv, partialRDM_nDims, MDScriterion, monitor)

% USAGE
%   RMSerror=RMSerrorOfPredArrangements(estRDM_utv, partialRDMs_utv[, partialRDM_nDims=2, MDScriterion='metricstress', monitor])
%
% FUNCTION
%   to characterize the badness of fit of an estimated representational
%   dissimilarity matrix (estRDM) to the distance matrices of several
%   subset arrangements in a lower dimensional space (partialRDMs). the
%   estimated RDM is used to predict the subset arrangments by MDS. the
%   total root mean square of the disparities between the predicted and
%   actual distances of all subset arrangements is used


%% preparations
if ~exist('partialRDM_nDims','var'), partialRDM_nDims=2; end
if ~exist('MDScriterion','var'), MDScriterion='metricstress'; end

% normalize the estimated RDM
estRDM_utv=normalizeRDMs(estRDM_utv);

partialRDMs_sq=squareRDMs(partialRDMs_utv);

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



%% compute root-mean-square (RMS) of errors of predicted arrangements
% (predict each subset arrangment's RDM from the RDM estimate)
errors=[];
for partialRDM_I=1:nPartialRDMs
    
    % use MDS to predict the distance matrix for this subset arrangment
    % (given the current RDM estimate)
    estRDM_utv_partial=reduceRDMs(estRDM_utv,subsetLOGs(partialRDM_I,:));
    RMSestRDM_forSubset=rms(estRDM_utv_partial);
    nDissims_cPartialRDM=sum(subsetLOGs(partialRDM_I,:));
    
    try
        predMDSdists=pdist(mdscale(estRDM_utv_partial, partialRDM_nDims, 'criterion', MDScriterion));
    catch
        predMDSdists=nan(size(estRDM_utv_partial));
    end
    predMDSdists_aligned2estRDM=predMDSdists/rms(predMDSdists)*RMSestRDM_forSubset;
    % compute disparities between the predicted and actual distance matrix
    cPartialRDM_utv=reduceRDMs(partialRDMs_utv(:,:,partialRDM_I),subsetLOGs(partialRDM_I,:)); % remove undefined part
    cPartialRDM_utv_aligned2estRDM=cPartialRDM_utv/rms(cPartialRDM_utv)*RMSestRDM_forSubset;
    cPartialDisparities=predMDSdists_aligned2estRDM-cPartialRDM_utv_aligned2estRDM;
    errors=[errors;cPartialDisparities(:)];
end
RMSerror=rms(errors);
if isnan(RMSerror), RMSerror=1e6; end % can't be inf for fminunc to work

%% show dissimilarity plots for partial RDMs
if exist('monitor','var')
        if isfield(monitor,'trueRDM')
            showPartialRDMsAlignment(partialRDMs_utv,estRDM_utv,monitor.trueRDM);
        else
            showPartialRDMsAlignment(partialRDMs_utv,estRDM_utv);
        end        
end


