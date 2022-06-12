% script to test function and robustness of QLV implementation
% developed by Sameer Sajid 20180727
close all;

%% VARIABLE DECLARATION
%desired parameters- hardcoded for now
c = 0.123;          %par 1, stiffness, in MPA
tau1 = 0.175;     %par 2, time constant, usually less than 1s
tau2 = 27;      %par 3, time constant, usually 30-70s
par_names = {'c';'tau1';'tau2'};

%time points
t_start = 0.20;   %time to start first frame
n_frame = 1e6;     %number of frames
t_frame = 4.0/n_frame;   %time between frames
times = t_start:t_frame:(t_start + t_frame*(n_frame-1)); %compute times

%SNR runs
smin = 10;           %minimum SNR, in dBA (for noise)
sitr = 5;          %amount to iterate SNR by each time
smax = 20;         %maximum SNR, in dBA (for noise)
navg = 10;         %number of times run each SNR level
snr_dBA = [smin:sitr:smax]; %SNR values to use
snr_type = 'dB';
%snr_dBA = [0:0.0001:0.01];
%snr_type = 'std';
snr_num = size(snr_dBA, 2); %num of SNR values, for reference

%% STRESS DATA COMPUTATION
%compute 'perfect' stress data from a simple model - Fung's quasi-linear viscoelasticity
%implemented from https://cir.nii.ac.jp/crid/1572824499663687424
stress_data = 1 + c.*(expint(times./tau2) - expint(times./tau1)); % change this equation to be whatever you want to fit
stress_data = reshape(stress_data, [n_frame 1]);

%% MATRIX DECLARATION
gof_mean = zeros(snr_num, 5);
par_mean = zeros(snr_num, 3);
gof_med = zeros(snr_num, 5);
par_med = zeros(snr_num, 3);
gof_std = zeros(snr_num, 5);
par_std = zeros(snr_num, 3);
par_raw = zeros(snr_num, navg, 3);
gof_raw = zeros(snr_num, navg, 5);

%% PERFORM PARAMETER ESTIMATION
%add noise to stress data and perform parameter estimation
run_times = [];
for i = 1:snr_num
    tic
    st = ['Current noise level: ', num2str(snr_dBA(i)) ' ' snr_type];
    disp(st); %current snr level
    
    %temp matrices
    gof_tmp = [];
    par_tmp = zeros(navg, 3);
    
    %run each SNR level navg number of times
    parfor j = 1:navg
        %add noise, of varying SNR
        [pars, gof] = VPE(awgn2(stress_data, snr_dBA(i),snr_type), 'qlv', t_start, t_frame, 0);
        %[pars, gof] = VPE(awgn(stress_data, snr_dBA(i)), 'qlv', t_start, t_frame, 0);
        par_tmp(j, :) = pars;
        gof_tmp = [gof_tmp; gof]; %structs are annoying to combine
    end
    %store raw data
    %par_raw(i, :, :) = par_tmp(:, :);
    %gof_raw(i, :, :) = double(struct2dataset(gof_tmp));
    
    %save alllll that tasty data
    par_mean(i, :) = mean(par_tmp);
    %gof_mean(i, :) = mean(double(struct2dataset(gof_tmp)));
    par_med(i, :) = median(par_tmp);
    %gof_med(i, :) = median(double(struct2dataset(gof_tmp)));
    par_std(i, :) = std(par_tmp);
    %gof_std(i, :) = std(double(struct2dataset(gof_tmp)));
    [msg,run_times] = estimate_time(run_times,i,0,0,snr_num,1,1,[]);
    disp(msg);
end

%compute confidence intervals for estimation based on noise level
CI = zeros(2,snr_num,3);
for i = 1:snr_num
    for j = 1:3
        CI(1,i,j) = par_mean(i,j) + 1.96*par_std(i,j);
        CI(2,i,j) = par_mean(i,j) - 1.96*par_std(i,j);
    end
end

%% RESULTS
%show results- yes I hardcoded it like a scrub, stop complaining
figure, hold on
title('parameter 1'), xlabel('SNR'), ylabel('mean value')
CI_area = [CI(1,:,1), fliplr(CI(2,:,1))];
CI_x = [snr_dBA, fliplr(snr_dBA)];
fill(CI_x,CI_area,[200 200 200]/255);
plot(snr_dBA, ones(size(snr_dBA)).*c,'r','LineWidth',1.5), hold on
plot(snr_dBA, par_mean(:,1),'b','LineWidth',1.5), hold on
legend('CI range','actual value','mean estimated value');

figure, hold on
title('parameter 2'), xlabel('SNR'), ylabel('mean value')
CI_area = [CI(1,:,2), fliplr(CI(2,:,2))];
CI_x = [snr_dBA, fliplr(snr_dBA)];
fill(CI_x,CI_area,[200 200 200]/255);
plot(snr_dBA, ones(size(snr_dBA)).*tau2,'r','LineWidth',1.5), hold on
plot(snr_dBA, par_mean(:,2),'b','LineWidth',1.5), hold on
legend('CI range','actual value','mean estimated value');

figure, hold on
title('parameter 3'), xlabel('SNR'), ylabel('mean value')
CI_area = [CI(1,:,3), fliplr(CI(2,:,3))];
CI_x = [snr_dBA, fliplr(snr_dBA)];
fill(CI_x,CI_area,[200 200 200]/255);
plot(snr_dBA, ones(size(snr_dBA)).*tau1,'r','LineWidth',1.5), hold on
plot(snr_dBA, par_mean(:,3),'b','LineWidth',1.5), hold on
legend('CI range','actual value','mean estimated value');

% figure, plot(snr_dBA, ones(size(snr_dBA)).*c, snr_dBA, par_mean(:,1), snr_dBA, CI(:,1,1), snr_dBA, CI(:,2,1)), hold on
% title('parameter 1'), xlabel('SNR in dBA'), ylabel('estimated value')
% legend('actual value', 'estimated value');
% 
% figure, plot(snr_dBA, ones(size(snr_dBA)).*tau2, snr_dBA, par_mean(:,2))
% title('parameter 2'), xlabel('SNR in dBA'), ylabel('estimated value')
% legend('actual value', 'estimated value');
% 
% figure, plot(snr_dBA, ones(size(snr_dBA)).*tau1, snr_dBA, par_mean(:,3));
% title('parameter 3'), xlabel('SNR in dBA'), ylabel('estimated value')
% legend('actual value', 'estimated value');

%% SAVE DATA
filename = ['PE-' num2str(n_frame) '-' num2str(snr_num) '-' num2str(navg) '.mat'];
save(filename);

PE_SAVER(filename, [c tau2 tau1], par_names);