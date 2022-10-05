function showPartialRDMsAlignment(partialRDMs,estRDM,trueRDM)

%% prepare and vectorize RDMs
partialRDMs_utv=vectorizeRDMs(partialRDMs);

estRDM_avgAlgndPartls_utv=averageAlignedPartialRDMs(partialRDMs);

if ~exist('estRDM','var')
    estRDM_utv=estRDM_avgAlgndPartls;
else
    estRDM_utv=vectorizeRDMs(estRDM);
end

if exist('trueRDM','var')
    trueRDM_utv=vectorizeRDMs(trueRDM);
end
    
    
%% sort according to true of estimated RDM
if exist('trueRDM','var')
    [trueRDM_utv_sorted,i]=sort(trueRDM_utv(1,:));
    sortingDescription='sorted by dissimilarity in true RDM';
    estRDM1_utv_sorted=estRDM_utv(:,i,1);
else
    [estRDM1_utv_sorted,i]=sort(estRDM_utv(1,:,1));
    sortingDescription='sorted by dissimilarity in estimated RDM';
end
if size(estRDM_utv,3)>1
    estRDM2_utv_sorted=estRDM_utv(:,i,2);
end

partialRDMs_utv_sorted=partialRDMs_utv(:,i,:);
estRDM_avgAlgndPartls_utv_sorted=estRDM_avgAlgndPartls_utv(:,i,:);

%% determine numbers of items across arrangements and prepare colors
nPairs=size(partialRDMs_utv,2); % number of dissimilarities = number of item pairs
nPartialRDMs=size(partialRDMs_utv,3);
nItems=(1+sqrt(1+8*nPairs))/2;

col=nan(nPartialRDMs,3);
jet_colormap=colormap(jet);
nsItemsAcrossArrangements_string=[];
partialRDMs_sq=squareRDMs(partialRDMs);

for partialRDM_I=1:nPartialRDMs
    
    % item sets of the partial RDMs
    subsetLOGs(partialRDM_I,:)=sum(isnan(partialRDMs_sq(:,:,partialRDM_I)))<nItems-1;
    nsItemsAcrossArrangements(partialRDM_I)=sum(subsetLOGs(partialRDM_I,:));
    nsItemsAcrossArrangements_string=[nsItemsAcrossArrangements_string,num2str(nsItemsAcrossArrangements(partialRDM_I)),' '];

    col(partialRDM_I,:)=jet_colormap(ceil(partialRDM_I/nPartialRDMs*64),:);
end


%% show raw dissimilarity values of partial RDMs
figw(1600); clf;
subplot(2,1,1);
%plot(estRDM_utv_sorted,'o-','Color','k','MarkerFaceColor','k','MarkerEdgeColor','none','LineWidth',3); hold on;
for partialRDM_I=1:nPartialRDMs
    cPartialRDM_utv=partialRDMs_utv_sorted(1,:,partialRDM_I);
    nonNaN_pairIs=find(~isnan(cPartialRDM_utv));
    plot(nonNaN_pairIs,cPartialRDM_utv(nonNaN_pairIs),'o-','Color',col(partialRDM_I,:),'MarkerFaceColor',col(partialRDM_I,:),'MarkerEdgeColor','none'); hold on;
    %plot(cPartialRDM_utv,'o-','Color',col(partialRDM_I,:),'MarkerFaceColor',col(partialRDM_I,:),'MarkerEdgeColor','none'); hold on;
end
%plot(estRDM_utv_sorted,'-','Color','k','MarkerFaceColor','none','MarkerEdgeColor','none','LineWidth',1); hold on;
xlabel({'\bfitem-pair index',['\rm(',sortingDescription,')']});
ylabel({'\bfdissimilarity','\rm(black: estimate,','each color: dissimilarities from one arrangement)'});
axis([1 nPairs 0 nanmax(partialRDMs_utv_sorted(:))*1.01]);


%% show aligned dissimilarity values of partial RDMs
subplot(2,1,2);
if exist('trueRDM','var')
    plot(normalizeRDMs(trueRDM_utv_sorted),'o-','Color',[0 .5 1],'MarkerFaceColor','none','MarkerEdgeColor','none','LineWidth',10); hold on;
end
plot(estRDM_avgAlgndPartls_utv_sorted,'o-','Color',[.7 .7 .7],'MarkerFaceColor','none','MarkerEdgeColor','none','LineWidth',6); hold on;
plot(estRDM1_utv_sorted(:,:),'o-','Color','k','MarkerFaceColor','none','MarkerEdgeColor','none','LineWidth',3); hold on;
mx=0;
for partialRDM_I=1:nPartialRDMs
    cPartialRDM_utv_sorted=partialRDMs_utv_sorted(1,:,partialRDM_I);
    nonNaN_LOG=~isnan(cPartialRDM_utv_sorted);
    targetSSQ=sum(estRDM1_utv_sorted(nonNaN_LOG).^2);
    cPartialRDM_utv_sorted_normalized=cPartialRDM_utv_sorted/sqrt(sum(cPartialRDM_utv_sorted(nonNaN_LOG).^2))*sqrt(targetSSQ);
    plot(cPartialRDM_utv_sorted_normalized,'o','Color',col(partialRDM_I,:),'MarkerFaceColor',col(partialRDM_I,:),'MarkerEdgeColor',col(partialRDM_I,:),'MarkerSize',1); hold on;
    mx=max(mx,nanmax(cPartialRDM_utv_sorted_normalized));
end
plot(estRDM1_utv_sorted,'-','Color','k','MarkerFaceColor','none','MarkerEdgeColor','none','LineWidth',1); hold on;
if size(estRDM_utv,3)>1
    plot(estRDM2_utv_sorted,'-','Color','r','MarkerFaceColor','none','MarkerEdgeColor','none','LineWidth',1); hold on;
end
xlabel({'\bfitem-pair index',['\rm(',sortingDescription,')']});
ylabel({'\bfdissimilarity','\rm(black: estimate,','each color: \itscaled-to-fit\rm dissimilarities from one arrangement)'});
axis([1 nPairs 0 mx*1.01]);


%% add title and export
pageFigure();
addHeading({any2str('\fontsize{10}Multiple arrangements: # items = ',nItems,', # pairs = ',nPairs,', # arrangements = ',nPartialRDMs),'item numbers across arrangements: ',nsItemsAcrossArrangements_string});
%exportCurrentFigAsPostscript('figures',true);