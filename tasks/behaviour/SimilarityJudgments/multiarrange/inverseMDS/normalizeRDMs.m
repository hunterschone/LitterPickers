function RDMs=normalizeRDMs(RDMs)
% normalizes a set of RDMs (stacked along the 3rd dimension) by
% independently scaling the dissimilarities of each matrix to a root mean
% square of 1. 

%% unwrap and vectorize the RDMs
RDMs_orig=RDMs;

% unwrap
if isstruct(RDMs)
    % wrapped
    RDMs_struct=RDMs;
    RDMs=unwrapRDMs(RDMs_struct);
end

%vectorize
RDMs_utv=vectorizeRDMs(RDMs);


%% normalize by scaling, such that the root mean square == 1
% for each RDM...
ssqds=nansum(RDMs_utv.^2,2); % sum of squared dissimilarities
nnonnands=sum(~isnan(RDMs_utv),2); % number of non-NaN dissimilarities

RDMs_utv=RDMs_utv./repmat(sqrt(ssqds./nnonnands),[1 numel(RDMs_utv(:,:,1)) 1]);


%% rewrap and resqaure to match output to input format
% resquare
if size(RDMs_orig(:,:,1),1)<size(RDMs_orig(:,:,1),2)
    RDMs=RDMs_utv;
else
    RDMs=squareRDMs(RDMs_utv);
end
    
% rewrap
if isstruct(RDMs_orig)
    RDMs=wrapRDMs(RDMs,RDMs_orig);
end

