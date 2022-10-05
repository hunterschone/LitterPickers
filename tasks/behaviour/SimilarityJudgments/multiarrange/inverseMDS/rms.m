function r=rms(x,dim)

% computes the root mean square of x along the first non-singleton
% dimension by default, or along dimension dim.

if ~exist('dim','var')
    dim=min(find(size(x)>1));
end

n=size(x,dim);
r=sqrt(sum(x.^2,dim)/n);

    
    
    
    