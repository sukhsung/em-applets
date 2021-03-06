%% Dependency: Bioformat Matlab (aka bfmatlab) and bfopen_im.m, writeDM4SeriresToTiff

src_dir  = '/Volumes/SSH-BLUE/Data/20210930_TaS2_Heating/videos/';
dataname = '2023_200keV_SA_40_Spot_3_CL_840mm_alpha_n10p12_speed_1.5p_exp_0p5s3';
save_dir = '/Volumes/SSH-BLUE/Data/20210930_TaS2_Heating/Processed/videos/';
binXY = 2;
binFrame = 1;
writeDM4SeriesToTiff(src_dir, save_dir, dataname, binXY, binFrame)