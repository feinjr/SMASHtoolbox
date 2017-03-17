% convert Convert frequency to velocity
%
%

function result=convert(object,varargin)



end

% % convert Convert frequency to velocity
% %
% % This method converts beat frequency to velocity.
% %
% %    object=convert(object,wavelength,offset);
% %
% %    object=convert(object,myfunc);
% %
% % See also PDV, analyze, characterize
% %
% 
% %
% % created February 23, 2015 by Daniel Dolan (Sandia National Laboratories)
% % revised March 17, 2016 by Daniel Dolan
% %    -removed custom map function feature (should be part of leapfrog class)
% %    -merged operations from the analyze method to clearly distinguish raw and processed results
% function object=convert(object,varargin)
% 
% % make sure analysis has been performed
% if isempty(object.Frequency)
%     error('ERROR: analyze must be called before conversion');
% end
% 
% % manage input
% Narg=numel(varargin);
% if (Narg==2) && (ischar(varargin{1}) || isa(varargin{1},'function_handle'))
%     % call user function
%     return
% end
% 
% if (Narg<1) || isempty(varargin{1})
%     wavelength=1550e-9; % meters
%     assert(isnumeric(wavelength) && all(wavelength ~= 0),...
%         'ERROR: invalid wavelength');
% else 
%     wavelength=varargin{1};
% end
% if isscalar(wavelength)
%     wavelength=repmat(wavelength,size(object.Frequency));
% end
% assert(all(wavelength ~= 0),'ERROR: invalid wavelength value');
% 
% if (Narg<2) || isempty(varargin{2})
%     offset=0; % Hz
%     assert(isnumeric(offset),'ERROR: invalid offset frequency');
% else
%     offset=varargin{2};
% end
% if isscalar(offset)
%     offset=repmat(offset,size(object.Frequency));
% end
% assert(numel(offset) == numel(object.Frequency),...
%     'ERROR: invalid number of offset frequencies')
% 
% % apply conversions
% object.Velocity=object.Frequency;
% for n=1:numel(object.Velocity)
%     scale=wavelength(n)/2;
%     table=object.Velocity{n}.Data;
%     table(:,1)=(table(:,1)-offset(n))*scale;
%     table(:,2)=table(:,2)*scale;
%     object.Velocity{n}=reset(object.Velocity{n},[],table);
% end
% 
% end
% 
% % case 'velocity'
% %         N=numel(object.Velocity);
% %         assert(N>0,'ERROR: velocity has not been calculated yet');
% %         SMASH.MUI.Figure;
% %         color=lines(N);        
% %         h=nan(N,2);
% %         label=cell(1,N);
% %         for n=1:N
% %             label{n}=object.Velocity{n}.Name;
% %             ha(1)=subplot(2,1,1);
% %             h(n,1)=view(object.Velocity{n},1,gca);           
% %             ha(2)=subplot(2,1,2);
% %             h(n,2)=view(object.Velocity{n},2,gca);
% %             set(h(n,:),'Color',color(n,:));
% %         end
% %         set(ha,'Box','on');
% %         ylabel(ha(1),'Velocity');
% %         xlabel(ha(2),'Time');
% %         ylabel(ha(2),'Uncertainty');
% %         legend(h(:,1),label,'Location','best');
% %         warning off; %#ok<WNOFF>
% %         title(ha(2),'');        
% %         linkaxes(ha,'x');
% %         warning on; %#ok<WNON>