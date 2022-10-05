function reducedRDMs=reduceRDMs(RDMs,validConditionsLOG)
% reduces a set of RDMs to those experimental conditions indicated in
% validConditionsLOG. the RDMs may be passed in square or upper
% triangular form and as array or struct with additional information. the
% reduced RDMs will have the same format as those passed.


%% convert from struct and/or utv form
% OLD version: RDMs_stacked_sq=squareAndStackRDMs(RDMs);
RDMs_stacked_sq=unwrapRDMs(squareRDMs(RDMs));
[n,n,nRDMs]=size(RDMs_stacked_sq);
validConditionsLOG=logical(validConditionsLOG);


%% reduce all RDMs to valid conditions set
RDMs_stacked_sq=RDMs_stacked_sq(validConditionsLOG,validConditionsLOG,:);


%% check if reduction left NaNs
nanLOG_RDM=any(isnan(RDMs_stacked_sq),3);
if any(isnan(nanLOG_RDM(:)))
    error('reduceRDMs: NaNs found after reduction.');
end


%% convert back to original format
if isstruct(RDMs)
    reducedRDMs=RDMs;
    
    for RDMI=1:nRDMs
        if length(RDMs(RDMI).RDM)==numel(RDMs(RDMI).RDM)
            % upper triangle form
            reducedRDMs(RDMI).RDM=vectorizeRDM(RDMs_stacked_sq(:,:,RDMI));
        else
            % square form
            reducedRDMs(RDMI).RDM=RDMs_stacked_sq(:,:,RDMI);
        end
    end
else
    if length(RDMs(:,:,1))==numel(RDMs(:,:,1))
        % upper triangular form
        reducedRDMs=vectorizeRDMs(RDMs_stacked_sq);
    else
        % square form
        reducedRDMs=RDMs_stacked_sq;
    end
end

