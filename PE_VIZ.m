function [] = PE_VIZ(par_maps, gof_maps)

% helper function to quickly visualize parameter and fit results

% display the parameter maps
if ~isempty(par_maps)
    [~, ~, z] = size(par_maps);
    for i = 1:z
        par_name = horzcat('Parameter: ', num2str(i));
        figure('Name', par_name)
        imagesc(par_maps(:,:,i)), colorbar;
    end
end

% display the goodness of fit data, spatially-oriented

if ~isempty(gof_maps)
    assert(size(gof_maps,3) == 5); %ensure we have a complete gof map

    %SSE
    figure('Name', 'SSE')
    imagesc(gof_maps(:,:,1)), colorbar;

    %R-squared
    figure('Name', 'R-Squared')
    imagesc(gof_maps(:,:,2), [-1 1]), colorbar;

    figure('Name', 'Degrees of Error')
    imagesc(gof_maps(:,:,3)), colorbar;

    figure('Name', 'Adjusted R-Squared')
    imagesc(gof_maps(:,:,4), [0 1]), colorbar;

    figure('Name', 'RMSE')
    imagesc(gof_maps(:,:,5)), colorbar;
end
