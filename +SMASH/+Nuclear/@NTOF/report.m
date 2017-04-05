%
% created January 21, 2016 by Patrick Knapp (Sandia National Laboratories)
%
function varargout=report(object,varargin)

Narg=numel(varargin) + 1;
assert(Narg>1,'Error: report takes at least 2 NTOF objects as input')

%% create figure with three subplots
figure('Units','Inches','Position',[4,6,14,6],'Color','w',...
    'PaperPositionMode','auto')

subplot('Position',[0.075, 0.15, 0.5, 0.8])
ax1 = gca;
hold on
xlabel('Time [s]')
ylabel('Signal')
ylim([-0.05 1.05])
xlim([3.35e-6 4.5e-6])

subplot('Position',[0.65, 0.57, 0.3, 0.38])
ax2 = gca;
hold on
set(gca,'Xtick',[1 2 3 4 5 6],'XTickLabel','','XLim',[0 7])
ylabel('Ion Temperature [keV]')

subplot('Position',[0.65, 0.15, 0.3, 0.38])
ax3 = gca;
hold on
set(gca,'Xtick',[1 2 3 4 5 6],'XLim',[0 7],...
    'XTickLabel',{'7 m','8 m(1)','8 m(2)','9 m','11 m','25 m'})
xlabel('Detector')
ylabel('Bang Time [ns]')

if Narg == 6
    Fsig = zeros(6,1);
    Fsig(1) = object.Settings.FitSignal;
    Tion = zeros(Narg,1);
    bangtime = zeros(Narg,1);
    
    % plot first object
    X = object.Settings.FinalSignal.Grid;
    Tion(1) = object.Settings.Fit.Parameter{1}(2);
    bangtime(1) = 1e9*object.Settings.Fit.Parameter{1}(1);
    
    line(X,object.Settings.FinalSignal.Data,'Color','b',...
        'LineWidth',1,'LineStyle','-',...
        'Parent',ax1)
    if ~isnan(Fsig(1))
        line(X,evaluate(object.Settings.Fit,X),'Color','r',...
            'LineWidth',1,'LineStyle','--',...
            'Parent',ax1)
    end
    % plot remaining objects
    
    for n=1:Narg-1
        Fsig(n+1) =  varargin{n}.Settings.FitSignal;
        
        if isnan(Fsig(n+1))
            X = NaN;
            Tion(n+1) = NaN;
            bangtime(n+1) = NaN;
            
        else
            X = varargin{n}.Settings.FinalSignal.Grid;
            Tion(n+1) = varargin{n}.Settings.Fit.Parameter{1}(2);
            bangtime(n+1) = 1e9*varargin{n}.Settings.Fit.Parameter{1}(1);
            line(X,varargin{n}.Settings.FinalSignal.Data,'Color','b',...
                'LineWidth',1,'LineStyle','-',...
                'Parent',ax1)
        end
        if ~isnan(Fsig(n+1))
            line(X,evaluate(varargin{n}.Settings.Fit,X),'Color','r',...
                'LineWidth',1,'LineStyle','--',...
                'Parent',ax1)
        end
    end
    mask = ~isnan(Fsig);
    
    Tstats = PlotMeanStd(Tion,ax2,mask);
    BTstats = PlotMeanStd(bangtime-3000,ax3,mask);
    
    text(3.66e-6, 0.8,sprintf('$T_i=%3.1f~+/- %3.1f$ keV',Tstats(1),Tstats(2)),...
        'Interpreter','latex','Parent',ax1,'FontSize',12)
    text(3.66e-6, 0.7,sprintf('$t_{bang}=%3.1f~+/- %3.1f$ ns',BTstats(1)+3000,BTstats(2)),...
        'Interpreter','latex','Parent',ax1,'FontSize',12)
    
end
if nargout == 2
    varargout{1} = Tstats;
    varargout{2} = BTstats + 3000;
else
    if nargout == 3
        varargout{1} = Tstats;
        varargout{2} = BTstats + [3000, 0];
        varargout{3} = [ax1, ax2, ax3];
        
    end
end
    function stats = PlotMeanStd(vals, ax, mask)
        detectors = [1, 2, 3, 4, 5, 6];
        meanval = mean(vals(mask));
        sigmaval = std(vals(mask));
        xvals = get(ax,'XLim');
        
        bar(ax,detectors(mask), vals(mask),'FaceColor','r')
        line(xvals,[meanval meanval],'Color','k','Parent',ax)
        line(xvals,[meanval+sigmaval meanval+sigmaval],'Color','k','LineStyle','--','Parent',ax)
        line(xvals,[meanval-sigmaval meanval-sigmaval],'Color','k','LineStyle','--','Parent',ax)
        
        stats = [meanval sigmaval];
    end
end