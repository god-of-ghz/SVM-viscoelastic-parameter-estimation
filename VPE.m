function [pars, gof] = VPE(points, vpe_type, fr_start, fr_time, to_plot)

% function to fit a series of pixels to some desired model
% Developed by Sameer Sajid 20180703

%% PREPARATION

%determine model type and starting points
[~, fit_model, f_o] = PE_HELPER(vpe_type);

%ensure the points are a vertical column of data
[x, y] = size(points);
if x == 1 && y > 1      %if its a horizontal array, fix that
    points = reshape(points, [y x]);
elseif x > 1 && y > 1   %its a 2D matrix, then just grab the first column (for now, will change later)
    points = points(:, 1);
end

%initialize x data, the time of each frame
[x, ~] = size(points);
x_data = zeros(x, 1);
for i = 1:x
    x_data(i) = fr_start + (fr_time * (i-1));   %start at TM, then add time per frame
end



%% CURVE FITTING
[pe_fit, gof] = fit(x_data, points, fit_model, f_o);
pars = coeffvalues(pe_fit);

if to_plot
    figure('Name', horzcat(vpe_type, ' fit'))
    plot(pe_fit, x_data, points)
    title([vpe_type ' fit']), xlabel('time (s)'), ylabel('stress (MPa)')
end


% for debugging
% assignin('base', 'x_data', x_data);
% assignin('base', 'pe_fit', pe_fit);
