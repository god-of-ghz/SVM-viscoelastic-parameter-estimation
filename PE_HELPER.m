function [num_pars, fit_model, f_o] = PE_HELPER(vpe_type)

% helper function to decide the model type & number of parameters
% developed by Sameer Sajid 20180704

%declaration of important constants
e_m = 0.57721;
f_o = [];

%return the right equation and fit options based on desired model
%usually used for QLV, but can be used for other stuff too
if strcmp(vpe_type, 'qlv') || strcmp(vpe_type, 'QLV')
    [fit_model] = fittype('1 + c.*(expint(x./t1) - expint(x./t2))');
    start_pts = [1 50 0.5];
    f_o = fitoptions('exp2', 'Lower', [0.05 5 0.05], 'Upper', [20 100 1], 'StartPoint', start_pts);
    f_o.robust = 'on';
    %start_pts = [1 1 1];
    num_pars = 3;
elseif strcmp(vpe_type, 'lin')
    [fit_model] = fittype('a*x + b');
    start_pts = [0 0];
    f_o = fitoptions('linearinterp','StartPoint', start_pts);
    num_pars = 2;
elseif strcmp(vpe_type, 'q_lin')
    [fit_model] = fittype('a*x + b');
    start_pts = [0 0];
    f_o = fitoptions('StartPoint', start_pts);
    num_pars = 2;
elseif strcmp(vpe_type, 'quad')
    [fit_model] = fittype('a*x^2 + b*x + c');
    start_pts = [0 0 0];
    f_o = fitoptions('StartPoint', start_pts);
    num_pars = 3;
elseif strcmp(vpe_type, 'log')
    [fit_model] = fittype('a*log(x) + b');
    start_pts = [0 0];
    f_o = fitoptions('StartPoint', start_pts);
    num_pars = 2;
elseif strcmp(vpe_type, 'test')
    [fit_model] = fittype('a*x + b');
    start_pts = [0 0];
    f_o = fitoptions('StartPoint', start_pts);
    num_pars = 2;
elseif strcmp(vpe_type, 'T1')
    [fit_model] = fittype('a*x + b');
    start_pts = [0 0];
    f_o = fitoptions('StartPoint', start_pts);
    num_pars = 2;
elseif strcmp(vpe_type, 'T2')
    [fit_model] = fittype('a*x + b');
    start_pts = [0 0];
    f_o = fitoptions('StartPoint', start_pts);
    num_pars = 2;
else
    disp('Not a supported fit type')
    fit_model = [];
    start_pts = [];
    num_pars = [];
end

%
