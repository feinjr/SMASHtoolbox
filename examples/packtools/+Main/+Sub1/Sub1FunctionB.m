function Sub1FunctionB()

disp('This is Sub1FunctionB, which calls several things...');

fprintf('\t');
packtools.call('Sub1FunctionA');

fprintf('\t');
packtools.call('-.MainFunctionA');

fprintf('\t');
packtools.call('-.Sub2.Sub2FunctionA');

end