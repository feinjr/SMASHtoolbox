% findmax Find maximum probability density
%
% This method finds the maximum probability density on a series of line
% segments in original/scaled coordinates.
%   value=findmax(object,'original',[x y]);
%   value=findmax(object,'scaled',[u v]);
% Maximum density is determined along the line segments defined by the
% two-column table passed to this method.  NaN values in this table
% indicate line breaks where density is *not* tested.
%
% See also Density2D, lookup

%
% created March 3, 2016 by Daniel Dolan  (Sandia National Laboratories)
%
function [value,location]=findmax(object,mode,table,isnormal)

% manage input
assert(nargin>=3,'ERROR: insufficient input');

assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);
switch mode
    case {'original' 'scaled'}
        % valid modes
    otherwise
        error('ERROR: invalid mode');
end

assert(isnumeric(table) && ismatrix(table),...
    'ERROR: invalid coordinate table');
[~,cols]=size(table);
assert(cols==2,'ERROR: invalid coordinate table');

if (nargin<4) || isempty(isnormal) || strcmpi(isnormal,'general')
    isnormal=false;
elseif strcmpi(isnormal,'normal')
    isnormal=true;
end
assert(islogical(isnormal),'ERROR: invalid normal flag');

% transform coordinates as necessary
switch mode
    case 'original'
        table=bsxfun(@minus,table,object.Original.Mean);
        table=table*object.Matrix.Forward;
end

% prepare for calculations
uc=0; % normal assumption centered at the origin
vc=0;
ustd=object.Scaled.Std(1);
vstd=object.Scaled.Std(2);
uvar=object.Scaled.Var(1);
vvar=object.Scaled.Var(2);

Nincrement=nan(1,2);

% determine maximum density
value=-inf;
location=nan(1,2);
Nsegment=size(table,1)-1;
for n=1:Nsegment
    segment=table(n:n+1,:);
    % skip breaks
    if any(isnan(segment(:)))
        continue
    elseif isnormal
        u0=segment(1,1);
        v0=segment(1,2);
        Lu=segment(2,1)-segment(1,1);
        Lv=segment(2,2)-segment(1,2);
        eta=(u0-uc)*Lu/uvar+(v0-vc)*Lv/vvar;
        eta=-eta/(Lu^2/uvar+Lv^2/vvar);
        if (eta>0) && (eta<1)
            eta=[0; eta(1); 1];
        else
            eta=[0; 1];
        end
        u=u0+eta*Lu;
        v=v0+eta*Lv;
        temp=1/(2*pi*ustd*vstd)*...
            exp(-(u-uc).^2/(2*uvar)-(v-vc).^2/(2*vvar));
        [current,index]=max(temp);
        ucurrent=u(index);
        vcurrent=v(index);
    else
        segment=trimSegment(segment,...
            object.Scaled.ubound,object.Scaled.vbound);
        if any(isnan(segment))
            continue
        end
        u0=segment(1,1);
        v0=segment(1,2);
        Lu=segment(2,1)-segment(1,1);
        Lv=segment(2,2)-segment(1,2);
        Nincrement(1)=abs(Lu/object.Scaled.uinc);
        Nincrement(2)=abs(Lv/object.Scaled.vinc);
        Nincrement=2*ceil(Nincrement);
        eta=linspace(0,1,max(Nincrement));
        u=u0+eta*Lu;
        v=v0+eta*Lv;
        temp=object.Scaled.Lookup(u',v');
        [current,index]=max(temp);
        if isnan(current)
            current=object.Scaled.MinDensity;
        end
        ucurrent=u(index);
        vcurrent=v(index);
    end                              
    if current > value
        value=current;
        location=[ucurrent vcurrent];
    end
end

if value<=0
    value=object.Scaled.MinDensity;
end

% scale results as needed
switch mode
    case 'original'
        value=value*object.Matrix.Jacobian;
        location=location*object.Matrix.Reverse;
        location=location+object.Original.Mean;
end

end

% function [u0,v0,Lu,Lv]=reduce(table,ubound,vbound)
% 
% valid=true;
% for m=1:2
%     u=table(m,1);
%     v=table(m,2);
%     if (u >= ubound(1)) && (u <= ubound(2)) ...
%             && (v >= vbound(1)) && (v <= vbound(2))
%         continue % point is already inside bounds
%     end
%     Lu=table(2,1)-table(1,1);
%     Lv=table(2,2)-table(1,2);
%     %
%     eta=(ubound(1)-u)/Lu;
%     new=v+eta*Lv;
%     if (new >= vbound(1)) && (new <= vbound(2))
%         table(m,2)=new;
%         table(m,1)=u+eta*Lu;
%         continue
%     end
%     eta=(ubound(2)-u)/Lu;
%     new=v+eta*Lv;
%     if (new >= vbound(1)) && (new <= vbound(2))
%         table(m,2)=new;
%         table(m,1)=u+eta*Lu;
%         continue
%     end
%     %
%     eta=(vbound(1)-v)/Lv;
%     new=u+eta*Lu;
%     if (new >= ubound(1)) && (new <= ubound(2))
%         table(m,1)=new;
%         table(m,2)=v+eta*Lv;
%         continue
%     end
%     eta=(vbound(2)-v)/Lv;
%     new=u+eta*Lu;
%     if (new >= ubound(1)) && (new <= ubound(2))
%         table(m,1)=new;
%         table(m,2)=v+eta*Lv;
%         continue
%     end
%     %
%     valid=false;
%     break
% end
% 
% if valid
%     u0=table(1,1);
%     v0=table(1,2);
%     Lu=table(2,1)-table(1,1);
%     Lv=table(2,2)-table(1,2);
% else
%     [u0,v0,Lu,Lv]=deal(nan(1));
% end
% 
% % % reduce table to bounded region
% % for m=1:2
% %     u0=table(m,1);
% %     v0=table(m,2);
% %     if (u0 >= ubound(1)) && (u0 <= ubound(2)) ...
% %             && (v0 >= vbound(1)) && (v0 <= vbound(2))
% %         continue % point is already inside bounds
% %     end
% %     if m==1
% %         Lu=table(2,1)-table(1,1);
% %         Lv=table(2,2)-table(1,2);
% %     else
% %         Lu=table(1,1)-table(2,1);
% %         Lv=table(1,2)-table(2,2);
% %     end
% %     % check horizontal bounds
% %     gamma=inf;
% %     for n=1:2
% %         new=(ubound(n)-u0)/Lu;
% %         if  (new < 0) || (new > 1) || isnan(new)
% %             continue
% %         elseif (new < gamma)
% %             v0p=v0+new*Lv;
% %             if (v0p >= vbound(1)) && (v0p<=vbound(2));
% %                 gamma=new;
% %             end
% %         end
% %     end    
% %     % check vertical bounds
% %     for n=1:2
% %         new=(vbound(n)-v0)/Lv;
% %         if (new < 0) || (new > 1) || isnan(new)
% %             continue
% %         elseif (new < gamma) 
% %             u0p=u0+new*Lu;
% %             if (u0p >= ubound(1)) && (u0p<=vbound(2));
% %                 gamma=new;
% %             end
% %         end
% %     end    
% %     % update when possible
% %     if gamma < inf
% %         table(m,1)=u0+gamma*Lu;
% %         table(m,2)=v0+gamma*Lv;
% %     end
% % end
% % 
% % % return reduced segment parameters
% % u0=table(1,1);
% % v0=table(1,2);
% % Lu=table(2,1)-table(1,1);
% % Lv=table(2,2)-table(1,2); 
% 
% end