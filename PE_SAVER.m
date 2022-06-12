function [] = PE_SAVER(filename, par_list, par_names)

%% PREPARATION
%cleanup & loading
load(filename);

%safety checks
assert(logical(exist('par_raw','var')));     %make sure at least raw data is there
[snr_num, navg, n_pars] = size(par_raw);          %grab size of data
assert(size(par_list, 2) == n_pars);     %ensure we have the right # of parameters

%prepare folder
folder = filename(1:end-4);
folder = horzcat(folder, '/');
if ~exist(folder, 'dir')
    mkdir(folder)
end

%make figures invisible temporarily
set(0,'DefaultFigureVisible','off');

%% METRIC RECONSTRUCTION
%reconstruct missing mean, CI, & std info for the older datasets
if ~exist('par_mean', 'var')
    disp('Reconstructing mean data...')
    par_mean = zeros(snr_num, n_pars);
    for i = 1:snr_num
        par_mean(i,:) = mean(par_raw(i,:,:));
    end
end
if ~exist('par_std', 'var')
    disp('Reconstructing standard deviation data...')
    par_std = zeros(snr_num, n_pars);
    for i = 1:snr_num
        par_std(i,:) = std(par_raw(i,:,:));
    end
end
if ~exist('CI','var')
    disp('Rebuilding 95% confidence interval...')
    CI = zeros(2,snr_num,3);
    for i = 1:snr_num
        for j = 1:3
            CI(1,i,j) = par_mean(i,j) + 1.96*par_std(i,j);
            CI(2,i,j) = par_mean(i,j) - 1.96*par_std(i,j);
        end
    end
end

%% FIGURE SAVING
disp('Saving mean figures...')    % mean
for i = 1:n_pars
    figure, hold on
    set(gca,'Fontname','Arial');
    ftitle = ['Parameter Estimation for ' par_names{i} ' - ' num2str(navg) ' iterations'];
    title(ftitle,'Fontname','Arial')
    xlabel('SNR (dBA)','Fontname','Arial');
    ylabel('Mean Value','Fontname','Arial');
    CI_area = [CI(1,:,i),fliplr(CI(2,:,i))];
    CI_x = [snr_dBA, fliplr(snr_dBA)];
    fill(CI_x,CI_area,[200 200 200]/255);
    plot(snr_dBA, ones(size(snr_dBA)).*par_list(i),'r--','LineWidth',1.5), hold on
    plot(snr_dBA, par_mean(:,i),'b','LineWidth',1.5), hold on
    legend('CI range','actual value','mean estimated value');
    
    savename = [folder filename(1:end-4) '-mean-par-' par_names{i}];
    saveas(gcf, savename, 'png');
    saveas(gcf, savename, 'svg');
%     figure, plot(snr_dBA, ones(size(snr_dBA)).*par_list(i), snr_dBA, par_mean(:,i))
%     title(horzcat('parameter ', num2str(i))), xlabel('SNR in dBA'), ylabel(['mean value of ' num2str(n_avg) ' iterations'])
%     legend('actual value', 'estimated value');
%     savename = [folder filename(1:end-4) '-med-par' num2str(i)];
%     saveas(gcf, savename, 'svg');
%     close;
end
disp('Saving standard deviation figures...') %std
for i = 1:n_pars   
    figure, plot(snr_dBA, ones(size(snr_dBA)).*par_list(i), snr_dBA, par_std(:,i))
    title(horzcat('parameter ', num2str(i))), xlabel('SNR in dBA'), ylabel(['std value of ' num2str(navg) ' iterations'])
    legend('actual value', 'std of estimated value');
    savename = [folder filename(1:end-4) '-std-par' num2str(i)];
    saveas(gcf, savename, 'svg');
    close;
end


%make figures visible again
set(0,'DefaultFigureVisible','on');