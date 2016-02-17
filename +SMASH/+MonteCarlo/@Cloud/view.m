% view Display cloud data
%
% UNDER CONSTRUCTION...

% This method graphical displays cloud data in a triangular array of plots.
% Plots showing variation within individual variables are on the diagonal,
% while off-diagonal plots show mutual variations betwen variable pairs.
% Standard use of this method:
%     view(object);
% generates 1D and 2D histograms. 


%
% Additional views can be created with the following settings.
%     view(object,DiagonalPlots,CrossPlots);
% Diagonal plots (1D) can be:
%   'histogram' : histogram plots 
%   'density'   : density estimate plots (Gaussian kernel)
% Cross plots (2D) can be:
%   'histogram' : histogram plots
%   'density'   : density countours
%   'points'    : cloud point plots
% Histograms and density plots are based on NumberBins property; increasing
% this number creates a finer scale representation.
%
% The default orientation of the plot array is upper triangular.  The
% fourth input can be used to change to a lower triangular array.
%     view(object,DiagonalPlots,CrossPlots,'upper'); % default
%     view(object,DiagonalPlots,CrossPlots,'lower');
%
% Graphic handles for the plots generated by this method are available as
% outputs.
%     [hdiagonal,hcross]=view(...); % return graphic handles 
%
% See also Cloud
%

%
% created August 5, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised July 6, 2015 by Daniel Dolan
%   -changed to a triangular plot array
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
    plot(dgrid{1},value);
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
        [dgrid,value]=density(object,[m n]);
        contour(dgrid{:},value);
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