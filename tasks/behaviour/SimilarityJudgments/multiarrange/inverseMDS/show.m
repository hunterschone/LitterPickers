function show(mat,figSubplotSpec)

if ~exist('figSubplotSpec','var'), figSubplotSpec=0; end
selectPlot(figSubplotSpec);

if prod(size(mat))==length(mat) % if it's a vector
    subplot(2,1,1); plot(mat); title(['mean=',num2str(mean(mat)),', std=',num2str(std(mat))]);
    subplot(2,1,2); hist(mat);
else
    imagesc(real(mat));
    colorbar;
end
    