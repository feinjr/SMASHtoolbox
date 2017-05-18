function varargout=Sub1FunctionB()

disp('This is Sub1FunctionB, which calls several things...');

fprintf('\t');
packtools.call('Sub1FunctionA');

fprintf('\t');
packtools.call('-.MainFunctionA');

fprintf('\t');
packtools.call('-.Sub2.Sub2FunctionA');

%ns=packtools.namespace('local','-.*');

ns=packtools.import('-.*');

if nargout > 0
    varargout{1}=ns;
end

end