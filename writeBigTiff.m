function writeBigTiff(varargin)
% BigTiff Writer with Single Precision.
% Input : argument 1: Image Matrix or Image Stack Matrix
%         argument 2: Path to file
%         argument 3: Overwrite function

%         Input Image matrix is automatically converted to Single
%         If 3rd argument is 'overwrite', than the destination file is
%         automatically overwitten. Otherwise, command prompt will ask
% Output: None
% Last Modified 2020/02/15 by Suk Hyun Sung @ Hovden Lab

    if nargin < 2
        error('Check your input')
    elseif nargin == 2
        ovwrte = 'x';
    else
        ovwrte = varargin{3};
    end
    im_stack = varargin{1};
    fname = varargin{2};
    
    % Check if the file already exists
    if exist(fname,'file') == 2 
        if strcmp(ovwrte,'overwrite')
            cont = true;
        else
            cont = input('File Already Exists, delete and continue? (true/false)/n');
        end
        if cont
            delete(fname)
        else
            return
        end
    end
    
    % Get im_stack size
    im_stack = single(im_stack);
    [nr, nc, nz] = size(im_stack);
    b = whos('im_stack');
    filesize = b.bytes*10^-9;
    if filesize>3.9
        writetag = 'w8'; %w8: tag for writing BigTIFF
    else
        writetag = 'w';
    end
    
    % Initiate tiff File
    tiffObj = Tiff(fname,writetag); 
    
    % Tiff Tags
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;    %0 is black
    tagstruct.Compression = Tiff.Compression.None;          %No Compression
    tagstruct.BitsPerSample = 32;                           %Uint16
    tagstruct.SamplesPerPixel = 1;                          %BW image
    tagstruct.ImageWidth = nc;                              %Image size
    tagstruct.ImageLength = nr;                             %Image size
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;      %Single Precision Floating Pt
    
    % Iterate through stack
    for z = 1:nz
        fprintf('Writing %d / %d\n',z,nz)
        setTag(tiffObj,tagstruct)       %Set tag for each image
        write(tiffObj,im_stack(:,:,z)); %Write image
        tiffObj.writeDirectory          %Move to next slice
    end
    
    close(tiffObj)
end

        
        
    
    