% view BayesCalibration object's MCMCResults

% This method displays the results of the Markov chain. 
%
%       >> [htop, hbottom] = view(object)
%
% generates a split axis plot with a histogram, KDE (blue curve), and
% Gaussian fit (red curve) on the top with the trace plot on the bottom. If
% requested, the axis handles are returned. 
%
% The variables to be viewed can be input as the first option:
%       >> [htop, hbottom] = view(object,'variables')
%
% where valid options are 'inferred' (default), 'cut', 'hyper', and 'all'
%
% A second option can be specified as 
%       >> [htop, hbottom] = view(object,'variables',vnums)
%
% where vnums is an array specifying which variables to view.
%
% A third option can be specified as 
%
%       >> h = view(object,'variables',[],'type')
%
% where valid types are 'histogram' (default) or 'covariance'. If
% 'covariance' is selected, an lower triangular plot showing the covariance
% of each variable is created. 
%
%
% See also Calibration, SMASH.MonteCarlo.Cloud
%

%
% created June 30, 2016 by Justin Brown (Sandia National Laboratories)

function varargout=view(object,variables,vnums,plottype)

    % manage input
    if nargin < 2 || isempty(variables)
        variables = 'allinferred';
    end
    
    if nargin < 3 
        vnums = [];
    end
    
    if nargin < 4
        plottype = 'histogram';
    end

    assert(ischar(variables),'ERROR: invalid variables specification. Choose from inferred, cut, hyper, or all');
    assert(ischar(variables),'ERROR: invalid options specification. Choose from histogram or covariance');
    
    
    %Parse variable selection
    if strcmpi(variables,'inferred')
        varnames = object.MCMCResults.InferredVariables;
        c  = object.MCMCResults.InferredChain;
    end

    if strcmpi(variables,'cut')
        varnames = object.MCMCResults.CutVariables;
        c  = object.MCMCResults.CutChain;
    end

    if strcmpi(variables,'hyper')
        c  = object.MCMCResults.HyperChain;
        [nr nc] = size(c);
        for ii = 1:nc
            varnames{ii} = sprintf('phi%i',ii);
        end
    end

    if strcmpi(variables,'allinferred')
        c  = object.MCMCResults.HyperChain;
        [nr nc] = size(c);
        for ii = 1:nc
            varnames{ii} = sprintf('phi%i',ii);
        end
        varnames = horzcat(object.MCMCResults.InferredVariables,varnames);
        c  = horzcat(object.MCMCResults.InferredChain,c);
    end


    if strcmpi(variables,'all')
        c  = object.MCMCResults.HyperChain;
        [nr nc] = size(c);
        for ii = 1:nc
            varnames{ii} = sprintf('phi%i',ii);
        end
        varnames = horzcat(object.MCMCResults.InferredVariables,varnames,object.MCMCResults.CutVariables);
        c  = horzcat(object.MCMCResults.InferredChain,c,object.MCMCResults.CutChain);
    end

    % Apply array selection
    if ~isempty(vnums)
        c=c(:,vnums);
        varnames = {varnames{vnums}};
    end

    [nr,nc] = size(c);

% Histograms for each chain value
if strcmpi(plottype,'histogram')
for i = 1:nc
        fh = SMASH.Graphics.AIPfigure(4,'11in');
           fh.Color = 'w';

        %Setup subplot layouts

        %Plot histogram
        sp1(i) = subplot('Position',[.125 .425 .8 .5]);
        hh(i) = histogram(c(:,i),'Normalization','pdf');
        set(gca,'FontName','times','FontAngle','normal','LineWidth',2.5,'FontSize',20);
        xlabel(varnames{i},'FontName','times','FontAngle','normal','FontSize',24);
        ylabel('Probability Density','FontName','times','FontAngle','normal','FontSize',24);
        box on; axis tight;

        %Plot KDE
        obj = SMASH.MonteCarlo.Cloud(c(:,i),'table');
        [dgrid,p] = density(obj);
        kdeh = line(dgrid,p); kdeh.LineWidth = 3; %kdeh.Color = [0.8 0.0 0.0];        
        
        %Plot normal distribution
        mu = mean(c(:,i));
        stdev = std(c(:,i));
        x=linspace(min(hh(i).BinEdges),max(hh(i).BinEdges),1000)';
        npdf = @(x) 1./(stdev.*sqrt(2*pi))*exp(-((x-mu).^2)./(2*stdev.^2));
        npd = npdf(dgrid);
        ndh = line(dgrid,npd); ndh.LineWidth = 3; ndh.Color = [0.8 0.0 0.0]; 
        

%         %Autocorrelation plot
%         sp2 = subplot('Position',[.125 .1 .8 .2])
%         lengthac = 100;
%         acf(c(:,i),lengthac,1);
%         %th(i) = line(1:lengthac,ac);
%         %th(i).LineWidth = 2;
%         set(gca,'FontName','times','FontAngle','normal','LineWidth',2.5,'FontSize',20);
%         xlabel('Lag Length','FontName','times','FontAngle','normal','FontSize',24);
%         ylabel('Autocorrelation','FontName','times','FontAngle','normal','FontSize',24);
%         box on; axis tight;
        
        %Trace plot
        sp3(i) = subplot('Position',[.125 .1 .8 .2]);
        th(i) = plot(c(:,i));
        th(i).LineWidth = 2;
        set(gca,'FontName','times','FontAngle','normal','LineWidth',2.5,'FontSize',20);
        xlabel('MC Number','FontName','times','FontAngle','normal','FontSize',24);
        ylabel(varnames{i},'FontName','times','FontAngle','normal','FontSize',24);
        box on; axis tight;
        
        if nargout>0
            varargout{1}=sp1;
            varargout{2}=sp3;
        end
end

elseif strcmpi(plottype,'covariance')
    
%     cobj = SMASH.MonteCarlo.Cloud(c,'table');
%     cobj = configure(cobj,'VariableName',varnames);
%     [varargout{1},varargout{2}]=view(cobj,'lower');
%     fh = gcf;
%     fh.Color = 'w';
    
%Plot cov
FS = 12;
FScov = FS;
tloc = 0.2;
stdcutoff=3;    
%fh = SMASH.Graphics.AIPfigure(6,'16in');
fh = SMASH.Graphics.AIPfigure(2);
%sfh = SMASH.MUI.Figure; fh = sfh.Handle; 
fh.Color = 'w';
    
    nvars = nc;
    hsub = [];
    fac = 0.9;
    subwidth = fac/nvars; 
    for j = 1:nvars
        for i = 1:j
            %Subplots first so diagonals go on top
            if i~=j
                pos = [fac*(mod(i-1,nvars))/nvars+(1-fac*1.025) fac*(1-1/nvars-(mod(j-1,nvars))/nvars)+(1-fac*1.025) subwidth subwidth];
                %hsub{i,j} = subplot(nvars,nvars,(j-1)*nvars+i,'Position',pos);
                hsub{i,j} = axes('Parent',fh,'Units','normalized','Position',pos);
                
                obj = SMASH.MonteCarlo.Cloud([c(:,i),c(:,j)],'table');
                obj=configure(obj,'GridPoints',1e2);
                [dgrid1,dgrid2,p]=density(obj);    
                [cdata,ch]=contour(dgrid1,dgrid2,p,obj.DensitySettings.NumberContours); 
                set(ch,'LineWidth',1,'ShowText','off');
                %colormap jet;
                %xlabel(sprintf('%i %i',i,j));
                %ylabel(sprintf('%i %i',i,j));
                if j==nvars 
                    xlabel(varnames{i});
                end
                if i==1
                    ylabel(varnames{j});
                end
                
                mu1 = mean(c(:,i));
                stdev1 = std(c(:,i));
                mu2 = mean(c(:,j));
                stdev2 = std(c(:,j));
                
                axis([mu1-stdcutoff*stdev1,mu1+stdcutoff*stdev1,mu2-stdcutoff*stdev2,mu2+stdcutoff*stdev2]);
                box on;
                set(gca,'LineWidth',1.0,'FontSize',FS);
                set(gca,'XTick',[],'YTick',[]);
                
                
                %subplot(nvars,nvars,(i-1)*nvars+j)
                pos = [fac*(mod(j-1,nvars))/nvars+(1-fac*1.025) fac*(1-1/nvars-(mod(i-1,nvars))/nvars)+(1-fac*1.025) subwidth subwidth];
                hsub{j,i} = axes('Parent',fh,'Units','normalized','Position',pos);
                [cdata,ch]=contour(dgrid2,dgrid1,p',obj.DensitySettings.NumberContours);
                set(ch,'LineWidth',1,'ShowText','off');
                axis([mu2-stdcutoff*stdev2,mu2+stdcutoff*stdev2,mu1-stdcutoff*stdev1,mu1+stdcutoff*stdev1]);
                %Correlation coefficient
                %cc = corrcoef([c(:,i),c(:,j)]);
                %text(tloc,0.5,sprintf('%3.3f',cc(2)),'FontSize',FScov);
                box on;
                %xlabel(varnames{j});
                %ylabel(varnames{i});
                set(gca,'XTick',[],'YTick',[]);
                set(gca,'LineWidth',1.0,'FontSize',FS);
            end
        end
    end
    
    for j = 1:nvars
        for i = 1:j    

            if i==j    
            pos = [fac*(mod(i-1,nvars))/nvars+(1-fac*1.025) fac*(1-1/nvars-(mod(j-1,nvars))/nvars)+(1-fac*1.025) subwidth subwidth];
            hsub{i,j} = axes('Parent',fh,'Units','normalized','Position',pos);
            hh = histogram(c(:,j),'Normalization','pdf');
            hh.EdgeColor='none';

            obj = SMASH.MonteCarlo.Cloud(c(:,i),'table');
            obj = configure(obj,'GridPoints',1e3);
            [dgrid,p] = density(obj);
            kdeh = line(dgrid,p); kdeh.LineWidth = 1; kdeh.Color = 'k';


            mu1 = mean(c(:,i));
            stdev1 = std(c(:,i));

            i1=find(dgrid>(mu1-stdev1),1,'first');
            i2=find(dgrid>(mu1+stdev1),1,'first');

            th=text(dgrid(i1),p(i1)*0,sprintf('%0.4g  ',dgrid(i1)));
            set(th,'HorizontalAlignment','center','VerticalAlignment','bottom');
            th=text(dgrid(i2),p(i2)*0,sprintf('  %0.4g ',dgrid(i2)));
            set(th,'HorizontalAlignment','center','VerticalAlignment','bottom');
            %h=line([dgrid(i1),dgrid(i1)],[0,max(p)]); 
            %set(h,'LineStyle','--','Color','k');
            %h=line([dgrid(i2),dgrid(i2)],[0,max(p)]); 
            %set(h,'LineStyle','--','Color','k');

            axis tight;
            set(gca,'XLim',[mu1-stdcutoff*stdev1,mu1+stdcutoff*stdev1]);
            box on;
            set(gca,'XTick',[dgrid(i1),dgrid(i2)],'YTick',[],'XTickLabel',[]);
            set(gca,'LineWidth',1.0,'FontSize',FS-2);

            if j==nvars
                xlabel(varnames{i});
            elseif i==1
                ylabel(varnames{j});
            end


%                 %Plot normal distribution
%                 mu = mean(c(:,i));
%                 stdev = std(c(:,i));
%                 npdf = @(x) 1./(stdev.*sqrt(2*pi))*exp(-((x-mu).^2)./(2*stdev.^2));
%                 npd = npdf(dgrid);
%                 ndh = line(dgrid,npd); ndh.LineWidth = 1; ndh.Color = [0.8 0.0 0.0];
%                 axis([mu-stdcutoff*stdev,mu+stdcutoff*stdev,0,max([max(npd),max(p)])]);
            end
        end
    end
    
    
    
    
    
    
    varargout{1} = hsub;
end


























% hdiagonal=[];
% hcross=[];
% N=object.NumberVariables;
% for m=1:N
%     % single variable plots (diagonal)
%     index=sub2ind([N N],m,m);
%     hdiagonal(end+1)=subplot(N,N,index); %#ok<AGROW>
%     [dgrid,value]=density(object,m);    
%     h=plot(dgrid,value,'k');
%     temp=sprintf('%s ',object.VariableName{m});
%     xlabel(temp); 
%     ylabel('Probability density');
%     % cross variable plots
%     for n=(m+1):N
%         switch orientation
%             case 'lower'
%                 index=sub2ind([N N],m,n); % lower triangle
%             case 'upper'
%                 index=sub2ind([N N],n,m); % upper triangle
%         end
%         hcross(end+1)=subplot(N,N,index); %#ok<AGROW>
%         [dgrid1,dgrid2,value]=density(object,[m n]);
%         contour(dgrid1,dgrid2,value,object.DensitySettings.NumberContours);
%         box on;               
%         temp=sprintf('%s ',object.VariableName{m});
%         xlabel(temp);
%         temp=sprintf('%s ',object.VariableName{n});
%         ylabel(temp);    
%     end
%     colormap jet
% end
% 
% % handle output
% if nargout>0
%     varargout{1}=hdiagonal;
%     varargout{2}=hcross;
% end

end