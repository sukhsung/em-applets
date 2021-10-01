%% Dependency: Bioformat Matlab (aka bfmatlab) and bfopen_im.m, writeDM4SeriresToTiff

src_dir  = '/Volumes/SSH-BLUE/Data/20210930_TaS2_Heating/videos/';
dataname = '1830_200keV_SA_10_Spot_5_CL_840mm_alpha_n20p20_speed_1.5p_exp_0p2s';
save_dir = '/Volumes/SSH-BLUE/Data/20210930_TaS2_Heating/Processed/videos/';
binXY = 2;
binFrame = 1;
writeDM4SeriesToTiff(src_dir, save_dir, dataname, binXY, binFrame)