% Power spectrum tracking: 
%     >> result=track(object);
%     >> result=track(object,'power',[method],[threshold]);
% Only the first defined boundary (if present) is used; all other
% boundaries are ignored.
%  
%     >> result=track(object,'complex');

function result=track(object,mode,varargin)

% manage input
if (nargin<2) || isempty(mode)
    mode='power';
end
assert(ischar(mode),'ERROR: invalid mode');

mode=lower(mode);
switch mode
    case 'power'
        if nargin<3
           varargin{1}='';
        end
        method='';
        if numel(varargin)>=1
            method=varargin{1};
        end
        threshold=[];
        if numel(varargin)>=2
            threshold=varargin{2};
        end                    
    case 'complex'
        % under construction
    otherwise
        error('ERROR: %s is not a valid track mode',mode);
end

% mange boundarie(s)
boundary=object.Boundary.Children;
if isempty(boundary)
    table=nan(2,2);
    table(1,:)=[object.Grid(1) inf];
    table(2,:)=[object.Grid(end) inf];
    boundary=SMASH.ROI.BoundingCurve('horizontal',table);
    boundary.Children{1}.Label='Default boundary';
end

% perform tracking
if strcmp(mode,'power')
    N=numel(object.Boundary.Children);
    result=cell(1,N);    
    for n=1:N       
        define(object.Boundary,boundary{n});
        result{n}=analyze(object,...
            @(x,y) singlePeak(x,y,method,threshold));
        remove(object.Boundary,1);
    end
    define(object.Boundary,boundary);
elseif strcmp(mode,'complex')
    % under construction
end

end

% pre_process=[]; 
% post_process=[]; 
% Narg=numel(varargin);
% switch choice
%     case 'spectra'
%         % do nothing
%     case {'history','both'}
%         if Narg>=1
%             options=varargin{1};
%         else
%             options=[];
%         end
%         post_process=@(x,y) findpeak(x,y,options);    
%     case 'custom'       
%         assert(Narg>=1,'ERROR: insufficient number of inputs');
%         if Narg>=1
%             if isa(varargin{1},'function_handle')
%                 post_process=varargin{1};
%             else
%                 error('ERROR: invalid post-process function');
%             end        
%         end
%         if Narg>=2
%             if isa(varargin{2},'function_handle')
%                 pre_process=varargin{1};
%             else
%                 error('ERROR: invalid pre-process function');
%             end        
%         end    
%     case 'manual'
%         assert(Narg>=1,'ERROR: insufficient number of inputs');
%         if isa(varargin{1},'function_handle')
%             pre_process=varargin{1};
%         else
%             error('ERROR: invalid process function');
%         end
%     otherwise
%         error('ERROR: invalid analysis choice');
% end
% 
% % prepare for dynamic restriction
% %if strcmp(object.RestrictionType,'dynamic')
% %    left=object.RestrictionData(1,1);
% %    right=object.RestrictionData(end,1);
% %    object=limit(object,[left right]);    
% %else
% %    
% %end
% 
% % perform analysis
% Nhistory=[];
% frequency=[];
%     function output=local_function(time,signal)
%         % initital preparations
%         persistent local
%         if isempty(local)
%             local=SMASH.SignalAnalysis.Signal(time,signal);
%         else
%             local.Grid=time;
%             local.Data=signal;
%         end
%         FFToptions={'WindowName',object.WindowName,...
%             'WindowParameter',object.WindowParameter,...
%             'NumberFrequencies',object.NumberFrequencies,...
%             'RemoveDC',object.RemoveDC};% power versus transform?        
%         % pre-processing
%         if isempty(pre_process)
%             % do nothing
%         elseif strcmp(choice,'manual')
%             output=feval(pre_process,time,signal,FFToptions{:});
%             return
%         else
%             local.Data=feval(pre_process,time,signal);        
%         end         
%         % FFT calculation
%         [frequency,output1]=fft(local,FFToptions{:}); 
%         % post processing
%         if isempty(post_process)
%            output2=output1;
%         else
%             t=(time(end)+time(1))/2;
%             fb=restrict(object,t);
%             keep=(frequency>=fb(1)) & (frequency<=fb(2));
%             output2=feval(post_process,frequency(keep),output1(keep));
%         end
%         switch choice           
%             case 'both'
%                 output=[output1(:); output2(:)];
%                 if isempty(Nhistory)
%                     Nhistory=numel(output2);
%                 end
%             otherwise
%                 output=output2;                
%         end
%     end
% result=analyze@SMASH.SignalAnalysis.ShortTime(object,@local_function);
% 
% % handle output
% switch choice
%     case 'spectra'
%         varargout{1}=SMASH.ImageAnalysis.Image(...
%             transpose(result.Grid),frequency,transpose(result.Data));
%         varargout{1}.YDir='normal';
%         varargout{1}.DataScale='dB';
%         varargout{1}.Grid1Label='Time';
%         varargout{1}.Grid2Label='Frequency';
%         temp=max(varargout{1}.Data(:));                       
%         switch object.Normalization
%             case 'none'
%                 % dBm?
%             otherwise
%                 varargout{1}.DataLim=[-60 0];
%                 varargout{1}.Data=varargout{1}.Data/max(temp(:));
%         end
%         % customize results...
%     case 'history'
%         varargout{1}=result;
%         varargout{1}.GridLabel='Time';
%         varargout{2}=frequency;    
%     case 'both'
%         % spectra
%         temp=result.Data(:,1:end-Nhistory);
%         varargout{1}=SMASH.ImageAnalysis.Image(...
%             transpose(result.Grid),frequency,transpose(temp));
%         varargout{1}.YDir='normal';
%         varargout{1}.DataScale='dB';
%         varargout{1}.Grid1Label='Time';
%         varargout{1}.Grid2Label='Frequency';
%         %switch object.Normalization
%         %    case 'none'
%         %        % dBm?
%         %    otherwise
%         %        varargout{1}.DataLim=[-60 0];
%         %end        
%         % history
%         varargout{2}=SMASH.SignalAnalysis.SignalGroup(...
%             result.Grid,result.Data(:,end-Nhistory+1:end));
%         %result.Data=result.Data(:,end-Nhistory+1:end);
%         varargout{2}.GridLabel='Time';
%         varargout{3}=frequency';
%     case {'custom','manual'}
%         varargout{1}=result;
%         varargout{1}.GridLabel='Time';
%         varargout{2}=frequency;
% end