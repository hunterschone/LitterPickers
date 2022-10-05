function showRDMs(RDMs,figI,rankTransform01,clims,showColorbar)

% displays a set of RDMs for visual inspection.
% RDMs can be passed in struct format or stacked as a single 3d array


%% define default behavior
if ~exist('figI','var'), figI=500; end
if ~exist('clims','var'), clims=[]; end
if ~exist('rankTransform01','var'), rankTransform01=true; clims=[0 1]; end
if ~exist('showColorbar','var'), showColorbar=true; end


%% convert from struct and/or utv form
% old version: RDMs_stacked_sq=squareAndStackRDMs(RDMs);
RDMs_stacked_sq=unwrapRDMs(squareRDMs(RDMs));
[n,n,nRDMs]=size(RDMs_stacked_sq);

if isempty(clims)
    allOffDiagValues=unwrapRDMs(vectorizeRDMs(RDMs));
    clims=[min(allOffDiagValues(:)) max(allOffDiagValues(:))];
end


%% display similarity matrices
h=figure(figI(1)); set(h,'Color','w');

if numel(figI)<4
    [nVerPan nHorPan]=paneling(nRDMs+1,2/3);
    subplotOffset=0;
    clf;
else
    nVerPan=figI(2);
    nHorPan=figI(3);
    subplotOffset=figI(4)-1;
end
    
for RDMI=1:nRDMs
    subplot(nVerPan,nHorPan,RDMI+subplotOffset); cla;

    if rankTransform01
        image(scale01(rankTransform_equalsStayEqual(RDMs_stacked_sq(:,:,RDMI),1)),'CDataMapping','scaled','AlphaData',~isnan(RDMs_stacked_sq(:,:,RDMI)));
        %imagesc(scale01(squareRDM(rankTransform_equalsStayEqual(vectorizeRDM(RDMs_stacked_sq(:,:,RDMI)),1))),clims);
        %imagesc(squareRDM(rankTransform_randomOrderAmongEquals(vectorizeRDM(RDMs_stacked_sq(:,:,RDMI)),1)),clims);
        set(gca,'CLim',[0 1],'CLimMode','manual');
    else
        image(squareRDMs(RDMs_stacked_sq(:,:,RDMI)),'CDataMapping','scaled','AlphaData',~isnan(RDMs_stacked_sq(:,:,RDMI)));
        try
            set(gca,'CLim',clims,'CLimMode','manual');
        catch
            disp(['Caught error: Cannot set CLim property to [',num2str(clims),'].']);
        end
    end
    
    set(gca,'XTick',[],'YTick',[]);
    
    if isstruct(RDMs), title(['\bf',deunderscore(RDMs(RDMI).name)]); end;
    %colorbar;
    axis square off;
end


%% add color bar
if showColorbar
    subplot(nVerPan,nHorPan,nRDMs+1+subplotOffset); cla;
    if rankTransform01
        imagesc(squareRDMs(rankTransform(vectorizeRDM(RDMs_stacked_sq(:,:,1)),1)),clims);  cla;
        ht=text(n/2,n/2,{['\bfeach similarity matrix (',num2str(n),'^2)'], 'separately rank-transformed', 'and scaled into [0,1]'},'HorizontalAlignment','Center','FontUnits','normalized');
    else
        try
            imagesc(squareRDMs((RDMs_stacked_sq(:,:,1))),clims);  cla;
        catch
            disp(['Caught error: Cannot set CLim property to [',num2str(clims),'].']);
        end            
        ht=text(n/2,n/2,{['\bfsimilarity matrices (',num2str(n),'^2)'],'not rank-tranformed'},'HorizontalAlignment','Center','FontUnits','normalized');
    end
    set(ht,'FontSize',.06);
    axis square off;
    colormapJet4Print;
    colorbar;
end
