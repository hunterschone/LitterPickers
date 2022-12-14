function RDMs_utv=vectorizeRDMs(RDMs)
% converts set of RDMs (stacked along the 3rd dimension)
% to upper-triangular form (set of row vectors)

if isstruct(RDMs)
    % wrapped
    RDMs_struct=RDMs;
    RDMs=unwrapRDMs(RDMs_struct);
    
    nRDMs=size(RDMs,3);
    RDMs_utv=[];
    for RDMI=1:nRDMs
        RDMs_utv=cat(3,RDMs_utv,vectorizeRDM(RDMs(:,:,RDMI)));
    end
    
    RDMs_utv=wrapRDMs(RDMs_utv,RDMs_struct);
else
    % bare
    nRDMs=size(RDMs,3);
    RDMs_utv=[];
    for RDMI=1:nRDMs
        RDMs_utv=cat(3,RDMs_utv,vectorizeRDM(RDMs(:,:,RDMI)));
    end
end