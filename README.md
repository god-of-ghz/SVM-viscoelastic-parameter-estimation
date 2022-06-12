# SVM-viscoelastic-parameter-estimation
Simple parameter fitting for viscoelastic constants, intended to be used for pixel-wise fitting in non-invasive imaging

DENSE_VPE is the main function, used to read in images and estimate viscoelastic constants from a multi-frame image of stress relaxation
- intended to be used with cine DENSE MRI, but really can work with any cine-like, multi-frame acquisition from any imaging modality
- requires displacement data to compute stress relaxation and viscoelastic constants

test_dense_vpe is a test script used to check if your imaging modality/cine acquisition even has the requisite number of frames and SNR to even make this assessment.
- check the SNR from your imaging modality
- check number of the frames you intend to acquire
- implement your desired stress relaxation (or creep) model of choice in %% VARIABLE DECLARATION and %% STRESS DATA COMPUTATION
- (you may need to make more changes later in the code, but the foundation is there)

run test-dense-vpe to run a Monte Carlo simulation of the parameter estimation
