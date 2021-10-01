%Noah Schnitzer 
%20180514 Initial script based on dm4movie2stack by SSH
%Modified to write single precision tiffstack directly by SSH
%Modified to more precisely navigate through directories

%source_directory: path to dm4 directory which contains Hour_00 (and all
%subfolders
%save_dir: path to output tiff file

%binFrame: number of frames (>=1) to average over-- 1 keeps all
%information

%binXY: scale for imresize-- 1 keeps dims binXY = 2 -> imresize( im, 0.5);

function writeDM4SeriesToTiff(source_dir, save_dir, dataname, binXY, binFrame )
    if ~isfolder( fullfile(source_dir,dataname) )
        error( 'No specified dataset in specified source path')
    end
    
    if ~isfolder(save_dir)
        mkdir(save_dir)
    end

    files = dir(fullfile(source_dir,dataname,'*','*','*','*.dm*'));
    numFiles = length(files);
    disp_counter = 10;
    finished = false;
    ind = 1;
    
    binScale = 1/binXY;
    delInd = [];
    % Read First Image to determine metadata
    while ind <= numFiles && ~finished
        if contains(files(ind).name, dataname) && files(ind).name(1) ~= '.'  % Checking for a proper file
            img = bfopen_im( fullfile(files(ind).folder,'/',files(ind).name) );
            [nr,nc] = size(imresize(img, binScale,'nearest'));            
            finished = true;
        else
            delInd = [delInd, ind];
        end
        ind = ind+1;
    end 
    files(delInd) = [];
    numFiles = length(files);
    
    fname = sprintf('%s_binXY%d_binFrame%d.tif',dataname, binXY,binFrame);
    
    tiffObj = Tiff( fullfile(save_dir, fname), 'w8'); %w8: tag for writing BigTIFF
    % Tiff Tags
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;    %0 is black
    tagstruct.Compression = Tiff.Compression.None;           %Lossless LZW Compression
    tagstruct.BitsPerSample = 32;                            %32bit
    tagstruct.SamplesPerPixel = 1;                          %BW image
    tagstruct.ImageWidth = nc;                              %Image size
    tagstruct.ImageLength = nr;                             %Image size
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;        %FLoating point
    
    numImage = floor(numFiles/binFrame);
    for indIm = 0:(numImage-1)% First pass to find global min max
        img_binFrame = zeros( nr,nc );
        for indFrame = 1:binFrame
            
            ind = indIm*binFrame +indFrame;
            
            if rem(ind,disp_counter) == 0
                fprintf('%d out of %d done\n',ind,numFiles)
            end
            img = bfopen_im( fullfile(files(ind).folder,'/',files(ind).name) );
            img_binXY = (imresize(img, binScale,'bilinear'));     
            
            img_binFrame = img_binFrame + img_binXY;
            
        end
        setTag(tiffObj,tagstruct)       %Set tag for each image
        write(tiffObj,img_binFrame); %Write image
        tiffObj.writeDirectory          %Move to next slice
    end 
    
    
   
    close(tiffObj);
end



