function im_stack = readBigTiff(varargin)
    
    fname = varargin{1};
    im_info = imfinfo(fname);
    
    nc = im_info(1).Width;
    nr = im_info(1).Height;
    nz = length(im_info);
    
    if nargin == 1
        zs = 1:nz;
    elseif nargin == 2
        zs = varargin{2};
        nz = length(zs);
    else
        error( 'Invalid Arguments' )
    end
    
    tiffObj = Tiff(fname,'r');
    
    tiffObj.setDirectory(1);
    
    
    im_stack = zeros(nr,nc,nz,'single');
    
    for indZ = 1:nz
        fprintf('%d / %d\n', indZ, nz);
        tiffObj.setDirectory( zs(indZ))
        im_stack(:,:,indZ) = tiffObj.read;
    end
    close(tiffObj)
end
        
        
    
    