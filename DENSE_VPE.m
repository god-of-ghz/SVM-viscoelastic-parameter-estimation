function [par_maps, gof_maps] = DENSE_VPE(frames, masks, fr_start, fr_time, vpe_type)

% function to coordinate viscoelastic parameter estimation for DENSE frames
% Developed by Sameer Sajid 20180702


%% SAFETY CHECKS
assert(all(size(frames) == size(masks)), 'Number and size of frames must match those of masks');
assert(size(frames,1) == size(frames,2), 'Frame and mask size must be square');
assert(size(frames,1) == 128 || size(frames,1) == 256, 'Image size must be 128 or 256 pixels');

%% PREPARATION
[x, y, z] = size(frames);
%to_process = find(frames(:,:,1) .* masks(

% declare holder for parameter & goodness of fit maps
[num_pars, ~, ~] = PE_HELPER(vpe_type);
par_maps = zeros(x, y, num_pars);
gof_maps = zeros(x, y, 5);
% 1 = sse
% 2 = rsquare
% 3 = dfe
% 4 = adjrsquare
% 5 = rmse

%% DECLARE MATRICES
current_px = zeros(z, 1);
current_pars = zeros(num_pars, 1);
temp_gof = zeros(1, 5);
gof_data = [];

%% CONSTRUCT PARAMETER MAPS
for i = 1:x
    for j = 1:y
        %for debugging
        %disp(i)
        
        %check if this pixel is to be used
        if masks(i, j, 1) == 0
            continue;
        end
        
        %assemble the pixels to pass
        current_px(:) = frames(i, j, :);
        
        assignin('base', 'current_px', current_px);
        
        %obtain parameter estimation for these pixels
        [current_pars, gof] = VPE(current_px, vpe_type, fr_start, fr_time, 0);
        par_maps(i, j, :) = current_pars;
        temp_gof(1) = gof.sse;
        temp_gof(2) = gof.rsquare;
        temp_gof(3) = gof.dfe;
        temp_gof(4) = gof.adjrsquare;
        temp_gof(5) = gof.rmse;
        
        %compile data together
        gof_maps(i, j, :) = temp_gof(:);
        gof_data = [gof_data; temp_gof];
    end
end

assignin('base', 'par_maps', par_maps);
assignin('base', 'gof_maps', gof_maps);
assignin('base', 'gof_data', gof_data);

% for debugging, currently disabled
if (0)
    figure, imagesc(gof_maps(:,:,2), [-2 2]), colorbar;     %r squared
    figure, imagesc(gof_maps(:,:,4), [0 1]), colorbar;     %adj r square
end

%visualize data
PE_VIZ(par_maps, gof_maps);
