function im_stack = readBigTiff(fname)
    

    tiffObj = Tiff(fname,'r');
    im_info = imfinfo(fname);
    
    nc = im_info(1).Width;
    nr = im_info(1).Height;
    nz = length(im_info);
   
    
    tiffObj.setDirectory(1);
    
    
    im_stack = zeros(nr,nc,nz,'single');
    fprintf('Reading Tiff Stack \n\t%s\n',fname);
    for z = 1:nz
        lineLength = fprintf('%d / %d\n', z, nz);
        im_stack(:,:,z) = tiffObj.read;
        if ~tiffObj.lastDirectory
            tiffObj.nextDirectory
        end
        fprintf(repmat('\b',1,lineLength));
    end
    fprintf('Finished Reading \n\t%s\n',fname);
    close(tiffObj)
end
        
        
    
    