function PDVtiming(varargin)

% manage input

fig=figure('Menubar','none','Toolbar','none');

% experimentation
ht=uitable('Parent',fig);

ColumnName={' Probe '  ' PDV ' ' Digitizer ' ' Measurement '};
ColumnFormat={'numeric' 'numeric' 'numeric' 'char'};
Ncolumn=numel(ColumnName);
%ColumnFormat={'char','numeric','numeric','numeric'};
set(ht,'ColumnName',ColumnName,'ColumnFormat',ColumnFormat);



set(ht,'RowName',{});


data=cell(50,Ncolumn);
set(ht,'Data',data,'ColumnEditable',true(1,Ncolumn));
%ht=uitable('Parent',fig,...
%    'FontName','fixed',...
%    'Data',data,...
%    'ColumnName',ColumnName,...
%    'RowName',{},...
%    'ColumnEditable',true(1,Ncolumn),...
%    'ColumnFormat',ColumnFormat,...
%    'CellEditCallback',@forceInteger);

extent=get(ht,'Position');
position=get(ht,'Position');
position(3)=extent(3)*1.05;
set(ht,'Position',position);

%    function forceInteger(source,EventData)
%        value=sscanf(EventData.EditData,'%g',1);        
%        row=EventData.Indices(1);
%        column=EventData.Indices(2);
%        %source.Data{row,column}=sprintf('%.0f',value);
%        source.Data{row,column}=round(value);
%    end

end