%%
main=packtools.namespace('Main.*');
main.MainFunctionA();

%%
sub=packtools.namespace('Main.Sub1.*');
sub.Sub1FunctionA();
sub.Sub1FunctionB();

%%
sub=packtools.namespace('Main.Sub1.*B*');

sub.Sub1FunctionA();
sub.Sub1FunctionB();

%%
ns=Main.Sub1.Sub1FunctionB();