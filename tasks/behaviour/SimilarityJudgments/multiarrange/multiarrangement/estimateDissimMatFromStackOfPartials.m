function [estimate_dissimMat_ltv,evidenceWeight_ltv]=estimateDissimMatFromStackOfPartials(stackOfPartialDissimMats,monitor)


%% preparations
global stackOfPartialDissimMats_ltv;
stackOfPartialDissimMats_ltv=vectorizeSimmats(stackOfPartialDissimMats);
nPairs=size(stackOfPartialDissimMats_ltv,2); % number of dissimilarities = number of item pairs
nDissimPartialMats=size(stackOfPartialDissimMats_ltv,3);
nObjects=(1+sqrt(1+8*nPairs))/2;

weights=evidenceWeights(stackOfPartialDissimMats_ltv); % SNR=1 -> weight=1, SNR=.5 -> weight=.25
 
evidenceWeight_ltv=nansum(weights,3);

if ~exist('monitor','var');
    monitor=false;
end


%% initial estimate: mean
initialEstimate=nanmean(stackOfPartialDissimMats_ltv,3);
initialEstimate=initialEstimate/sqrt(sum(initialEstimate.^2));


%% estimate dissimilarity by iterative alignment to mean
cEstimate=initialEstimate;
iterationChangeSSQ=99999;

% visualize convergence
% figw(900); clf; % for visualization of convergence
% iterationI=1;

tic
while iterationChangeSSQ>1e-8
    cPartialDissimMat_ltv_normalized=nan(size(stackOfPartialDissimMats_ltv));
    % align each partial dissimilarity matrix to the current estimate
    for partialDissimMatI=1:nDissimPartialMats
        cPartialDissimMat_ltv=stackOfPartialDissimMats_ltv(1,:,partialDissimMatI);
        nonNaN_LOG=~isnan(cPartialDissimMat_ltv);
        targetSSQ=sum(cEstimate(nonNaN_LOG).^2);

        stackOfPartialDissimMats_ltv_normalized(1,:,partialDissimMatI)=cPartialDissimMat_ltv/sqrt(sum(cPartialDissimMat_ltv(nonNaN_LOG).^2))*sqrt(targetSSQ);
    end
    
    % average the aligned partial dissimilarity matrices to obtain the new estimate
    pEstimate=cEstimate;
    
    % unweighted-mean estimate
    %       cEstimate=nanmean(stackOfPartialDissimMats_ltv_normalized,3);
    
    % weighted-mean estimate
    cEstimate=nansum(stackOfPartialDissimMats_ltv_normalized.*weights,3)./nansum(weights,3);
    
    cEstimate=cEstimate/sqrt(sum(cEstimate.^2));
    
    iterationChangeSSQ=sum((cEstimate-pEstimate).^2);
    
    % visualize convergence
    %     if iterationI<=10
    %         subplot(5,2,iterationI);
    %         % sort
    %         [cEstimate_ltv_sorted,i]=sort(cEstimate(1,:));
    %         stackOfPartialDissimMats_ltv_normalized_sorted=stackOfPartialDissimMats_ltv_normalized(:,i,:);
    %
    %         % draw
    %         plot(cEstimate_ltv_sorted,'o-','Color','k','MarkerFaceColor','k','MarkerEdgeColor','none','LineWidth',3); hold on;
    %         for partialDissimMatI=1:nDissimPartialMats
    %             cPartialDissimMat_ltv=stackOfPartialDissimMats_ltv_normalized_sorted(1,:,partialDissimMatI);
    %             nonNaN_pairIs=find(~isnan(cPartialDissimMat_ltv));
    %             plot(nonNaN_pairIs,cPartialDissimMat_ltv(nonNaN_pairIs),'o-','Color',col(partialDissimMatI,:),'MarkerFaceColor',col(partialDissimMatI,:),'MarkerEdgeColor','none'); hold on;
    %             %plot(cPartialDissimMat_ltv,'o-','Color',col(partialDissimMatI,:),'MarkerFaceColor',col(partialDissimMatI,:),'MarkerEdgeColor','none'); hold on;
    %         end
    %         plot(cEstimate_ltv_sorted,'-','Color','k','MarkerFaceColor','none','MarkerEdgeColor','none','LineWidth',1); hold on;
    %         xlabel({'\bfobject-pair index','\rm(sorted by dissimilarity according to final estimate)'});
    %         ylabel({'\bfdissimilarity','\rm(black: final estimate,','each color: dissimilarities from one arrangement)'});
    %     end
    %     iterationI=iterationI+1;
end
estimate_dissimMat_ltv=cEstimate;
toc


%% estimate dissimilarity matrix by optimization
% tic
% estimate_dissimMat_ltv = fminsearch(@(dissimMatEstimate) deviationBetweenDissimMatAndStackOfPartials(dissimMatEstimate),initialEstimate)
% toc

% tic
% estimate_dissimMat_ltv = fminsearch(@(dissimMatEstimate) deviationBetweenDissimMatAndStackOfPartials(dissimMatEstimate),estimate_dissimMat_ltv)
% toc


%% visualization
if ~monitor, return; end

col=nan(nDissimPartialMats,3);
jet_colormap=colormap(jet);
for partialDissimMatI=1:nDissimPartialMats
    %     col(partialDissimMatI,:)=randomColor;
    col(partialDissimMatI,:)=jet_colormap(ceil(partialDissimMatI/nDissimPartialMats*64),:);
end

% sort according to final estimate of dissimMat
[estimate_dissimMat_ltv_sorted,i]=sort(estimate_dissimMat_ltv(1,:));
stackOfPartialDissimMats_ltv_sorted=stackOfPartialDissimMats_ltv(:,i,:);

figw(1600); clf;
subplot(2,1,1);
plot(estimate_dissimMat_ltv_sorted,'o-','Color','k','MarkerFaceColor','k','MarkerEdgeColor','none','LineWidth',3); hold on;
for partialDissimMatI=1:nDissimPartialMats
    cPartialDissimMat_ltv=stackOfPartialDissimMats_ltv_sorted(1,:,partialDissimMatI);
    nonNaN_pairIs=find(~isnan(cPartialDissimMat_ltv));
    plot(nonNaN_pairIs,cPartialDissimMat_ltv(nonNaN_pairIs),'o-','Color',col(partialDissimMatI,:),'MarkerFaceColor',col(partialDissimMatI,:),'MarkerEdgeColor','none'); hold on;
    %plot(cPartialDissimMat_ltv,'o-','Color',col(partialDissimMatI,:),'MarkerFaceColor',col(partialDissimMatI,:),'MarkerEdgeColor','none'); hold on;
end
plot(estimate_dissimMat_ltv_sorted,'-','Color','k','MarkerFaceColor','none','MarkerEdgeColor','none','LineWidth',1); hold on;
xlabel({'\bfobject-pair index','\rm(sorted by dissimilarity according to final estimate)'});
ylabel({'\bfdissimilarity','\rm(black: final estimate,','each color: dissimilarities from one arrangement)'});
axis([1 nPairs 0 nanmax(stackOfPartialDissimMats_ltv_sorted(:))*1.01]);
    
subplot(2,1,2);
plot(estimate_dissimMat_ltv_sorted,'o-','Color','k','MarkerFaceColor','k','MarkerEdgeColor','none','LineWidth',4); hold on;
mx=0;
for partialDissimMatI=1:nDissimPartialMats
    cPartialDissimMat_ltv_sorted=stackOfPartialDissimMats_ltv_sorted(1,:,partialDissimMatI);
    nonNaN_LOG=~isnan(cPartialDissimMat_ltv_sorted);
    targetSSQ=sum(estimate_dissimMat_ltv_sorted(nonNaN_LOG).^2);
    cPartialDissimMat_ltv_sorted_normalized=cPartialDissimMat_ltv_sorted/sqrt(sum(cPartialDissimMat_ltv_sorted(nonNaN_LOG).^2))*sqrt(targetSSQ);
    plot(cPartialDissimMat_ltv_sorted_normalized,'.','Color',col(partialDissimMatI,:),'MarkerFaceColor',col(partialDissimMatI,:),'MarkerEdgeColor',col(partialDissimMatI,:),'MarkerSize',5); hold on;
    mx=max(mx,nanmax(cPartialDissimMat_ltv_sorted_normalized));
end
plot(estimate_dissimMat_ltv_sorted,'-','Color','k','MarkerFaceColor','none','MarkerEdgeColor','none','LineWidth',1); hold on;
xlabel({'\bfobject-pair index','\rm(sorted by dissimilarity according to final estimate)'});
ylabel({'\bfdissimilarity','\rm(black: final estimate,','each color: \itscaled-to-fit\rm dissimilarities from one arrangement)'});
axis([1 nPairs 0 mx*1.01]);

pageFigure();
addHeadingAndPrint({'MULTI-ARRANGEMENT (random sets, exponentially decreasing set sizes)',any2str('\fontsize{12}number of objects = ',nObjects,', number of pairs = ',nPairs)},'figures');



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dev=deviationBetweenDissimMatAndStackOfPartials(cEstimate_dissimMat_ltv)

%% preparations
global stackOfPartialDissimMats_ltv;
nPartialDissimMats=size(stackOfPartialDissimMats_ltv,3);
nPairs=size(stackOfPartialDissimMats_ltv,2);

nData=sum(~isnan(stackOfPartialDissimMats_ltv(:)));

% for visualization: sort according to reference dissimMat
% [cEstimate_dissimMat_ltv_sorted,i]=sort(cEstimate_dissimMat_ltv(1,:,1));
% stackOfPartialDissimMats_ltv_sorted=stackOfPartialDissimMats_ltv(:,i,:);
% figure(1600); clf;


%% compute correlations
dev=nData;
for partialDissimMatI=1:nPartialDissimMats
    cPartialDissimMat_dissims=stackOfPartialDissimMats_ltv(1,:,partialDissimMatI);
    nonNaN_LOG=~isnan(cPartialDissimMat_dissims);
    nNonNaN=sum(nonNaN_LOG);
    nData=nData+nNonNaN;

    r_0fix=correlation_0fixed(cEstimate_dissimMat_ltv(nonNaN_LOG),cPartialDissimMat_dissims(nonNaN_LOG));

    % visualize
    %     subplot(ceil(nPartialDissimMats/2),2,partialDissimMatI);
    %     plot(cEstimate_dissimMat_ltv_sorted,'o-','Color','k','MarkerFaceColor','k','MarkerEdgeColor','none'); hold on;
    %     plot(stackOfPartialDissimMats_ltv_sorted(1,:,partialDissimMatI),'o','MarkerFaceColor','r','MarkerEdgeColor','none'); hold on;
    %     title(['r_0fix=',num2str(r_0fix)]);
    
    dev=dev-r_0fix*nNonNaN;
end

dev=dev/nData;


