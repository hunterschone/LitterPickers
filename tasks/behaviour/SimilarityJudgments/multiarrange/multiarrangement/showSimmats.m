function showSimmats(simmats,figI,rankTransform01,clims,showColorbar)

% displays a set of simmats for visual inspection.
% simmats can be passed in struct format or stacked as a single 3d array


%% define default behavior
if ~exist('figI','var'), figI=500; end
if ~exist('clims','var'), clims=[]; end
if ~exist('rankTransform01','var'), rankTransform01=true; clims=[0 1]; end
if ~exist('showColorbar','var'), showColorbar=true; end


%% convert from struct and/or ltv form
% old version: simmats_stacked_sq=squareAndStackSimmats(simmats);
simmats_stacked_sq=unwrapSimmats(squareSimmats(simmats));
[n,n,nSimmats]=size(simmats_stacked_sq);

if isempty(clims)
    allOffDiagValues=unwrapSimmats(vectorizeSimmats(simmats));
    clims=[min(allOffDiagValues(:)) max(allOffDiagValues(:))];
end


%% display similarity matrices
h=figure(figI(1)); set(h,'Color','w');

if numel(figI)<4
    [nVerPan nHorPan]=paneling(nSimmats+1,2/3);
    subplotOffset=0;
    clf;
else
    nVerPan=figI(2);
    nHorPan=figI(3);
    subplotOffset=figI(4)-1;
end
    
for simmatI=1:nSimmats
    subplot(nVerPan,nHorPan,simmatI+subplotOffset); cla;

    if rankTransform01
        image(scale01(rankTransform_equalsStayEqual(simmats_stacked_sq(:,:,simmatI),1)),'CDataMapping','scaled','AlphaData',~isnan(simmats_stacked_sq(:,:,simmatI)));
        %imagesc(scale01(squareSimmat(rankTransform_equalsStayEqual(vectorizeSimmat(simmats_stacked_sq(:,:,simmatI)),1))),clims);
        %imagesc(squareSimmat(rankTransform_randomOrderAmongEquals(vectorizeSimmat(simmats_stacked_sq(:,:,simmatI)),1)),clims);
        set(gca,'CLim',[0 1],'CLimMode','manual');
    else
        image(squareSimmat(simmats_stacked_sq(:,:,simmatI)),'CDataMapping','scaled','AlphaData',~isnan(simmats_stacked_sq(:,:,simmatI)));
        set(gca,'CLim',clims,'CLimMode','manual');
    end
    
    set(gca,'XTick',[],'YTick',[]);
    
    if isstruct(simmats), title(['\bf',deunderscore(simmats(simmatI).name)]); end;
    %colorbar;
    axis square;
end


%% add color bar
if showColorbar
    subplot(nVerPan,nHorPan,nSimmats+1+subplotOffset); cla;
    if rankTransform01
        imagesc(squareSimmat(rankTransform(vectorizeSimmat(simmats_stacked_sq(:,:,1)),1)),clims);  cla;
        ht=text(n/2,n/2,{['\bfeach similarity matrix (',num2str(n),'^2)'], 'separately rank-transformed', 'and scaled into [0,1]'},'HorizontalAlignment','Center','FontUnits','normalized');
    else
        imagesc(squareSimmat((simmats_stacked_sq(:,:,1))),clims);  cla;
        ht=text(n/2,n/2,{['\bfsimilarity matrices (',num2str(n),'^2)'],'not rank-tranformed'},'HorizontalAlignment','Center','FontUnits','normalized');
    end
    set(ht,'FontSize',.06);
    axis square off;
    colormapJet4Print;
    %colormap(summer);
    colorbar;
end
