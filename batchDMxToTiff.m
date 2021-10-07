function indError = batchDMxToTiff(directory)
    

    dirs = dir(fullfile(directory,'*.dm*'));
    mkdir( fullfile( directory, 'tiffs' ) )
    numFile = length(dirs);
    indError = [];
    for ind = 1:numFile
        fname = dirs(ind).name;
        if fname(1) ~= '.'
            disp(fname)
            try
                DMtotiff( directory, fname  );
            catch
                indError = [indError, ind];
            end
        end
    end
    
end

function DMtotiff( directory, fname )
    im_stack = DMReader( fullfile( directory,fname) );
    writeBigTiff( im_stack, fullfile( directory, 'tiffs', [fname(1:end-4),'.tif']),'overwrite' );
end

function im_stack = DMReader(fname)

    bfObject = bfopen(fname);
    numIm = size(bfObject{1,1},1);
    [nr,nc] = size(bfObject{1,1}{1,1});
    im_stack = zeros(nr,nc,numIm);
    
    for ind = 1:numIm
        im_stack(:,:,ind) = bfObject{1,1}{ind,1};
    end
    
end
