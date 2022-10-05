function RMSdisp=RMSdisparityOfNormRDMs(RDM1,RDM2)

%% vectorize RDMs
RDM1=vectorizeRDMs(RDM1);
RDM2=vectorizeRDMs(RDM2);

%% normalize RDMs
RDM1=normalizeRDMs(RDM1);
RDM2=normalizeRDMs(RDM2);

%% compute root-mean-square disparity
RMSdisp=rms(RDM1-RDM2);

