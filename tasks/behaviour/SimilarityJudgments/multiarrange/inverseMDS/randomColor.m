function rgb01=randomColor(nCols)
% returns a pseudorandom RGB triple chosen from a select population of
% bright and perky colors

if ~exist('nCols','var'), nCols=1; end

rgb01=rand(nCols,3);

mn=min(rgb01,[],2);
mx=max(rgb01,[],2);

rgb01=(rgb01-repmat(mn,[1 3]))./repmat(mx-mn,[1 3]);


