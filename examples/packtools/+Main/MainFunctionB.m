function MainFunctionB()

disp('This is MainFunctionB, which calls MainFucntionA');

fprintf('\t');
packtools.call('MainFunctionA');

disp('See, I told you...');

end