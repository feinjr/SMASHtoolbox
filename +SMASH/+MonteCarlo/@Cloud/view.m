% view Display cloud data
% This method graphical displays cloud data in a triangular array of plots.
%    view(object); % upper triangular array
%    view(object,'upper'); % same as as above
%    view(object,'lower'); % lower triangular array
% Plots on the diagonal show variation within each variable, while
% off-diagonal plots show mutual variations betwen variable pairs.
%
% Graphic handles for the plots generated by this method are available as
% outputs.
%     [hdiagonal,hcross]=view(...);
%
% See also Cloud
%

%
% created August 5, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised July 6, 2015 by Daniel Dolan
%   -changed to a triangular plot array
% revised Feburary 16, 2016 by Daniel Dolan
%   -converted all plots to density, cropping histogram and point display
function varargout=view(object,orientation)

% manage input
if (nargin<2) || isempty(orientation)
    orientation='upper';
end
assert(strcmpi(orientation,'lower') || strcmpi(orientation,'upper'),...
    'ERROR: invalid orientation');
orientation=lower(orientation);

% create plots
figure;

hdiagonal=[];
hcross=[];
N=object.NumberVariables;
for m=1:N
    % single variable plots (diagonal)
    index=sub2ind([N N],m,m);
    hdiagonal(end+1)=subplot(N,N,index); %#ok<AGROW>
    [dgrid,value]=density(object,m);    
    plot(dgrid,value);
    temp=sprintf('%s ',object.VariableName{m});
    xlabel(temp); 
    ylabel('Probability density');
    % cross variable plots
    for n=(m+1):N
        switch orientation
            case 'lower'
                index=sub2ind([N N],m,n); % lower triangle
            case 'upper'
                index=sub2ind([N N],n,m); % upper triangle
        end
        hcross(end+1)=subplot(N,N,index); %#ok<AGROW>
        [dgrid1,dgrid2,value]=density(object,[m n]);
        contour(dgrid1,dgrid2,value,object.NumberContours);
        box on;               
        temp=sprintf('%s ',object.VariableName{m});
        xlabel(temp);
        temp=sprintf('%s ',object.VariableName{n});
        ylabel(temp);    
    end
end

% handle output
if nargout>0
    varargout{1}=hdiagonal;
    varargout{2}=hcross;
end

end