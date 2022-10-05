function [RDMs,nRDMs]=unwrapRDMs(RDMs_struct)
% unwraps dissimiliarity matrices in a structured array with meta data by
% extracting the dissimilarity matrices (in square or upper triangle form)
% and lining them up along the third dimension. (if they are already in
% that format they are handed back unchanged.)

if strcmp(class(RDMs_struct),'struct')
    % in struct form
    nRDMs=size(RDMs_struct,2);
    if length(RDMs_struct(1).RDM)==numel(RDMs_struct(1).RDM)
        % in upper-triangular form
        RDMs=nan(1,length(RDMs_struct(1).RDM),nRDMs);
        for RDMI=1:nRDMs
            RDMs(1,:,RDMI)=vectorizeRDM(RDMs_struct(RDMI).RDM);
        end
    else
        % in square form
        RDMs=nan(size(RDMs_struct(1).RDM,1),size(RDMs_struct(1).RDM,2),nRDMs);
        for RDMI=1:nRDMs
            RDMs(:,:,RDMI)=squareRDMs(RDMs_struct(RDMI).RDM);
        end
    end
else
    % bare already
    RDMs=RDMs_struct;
    nRDMs=size(RDMs,3);
end
