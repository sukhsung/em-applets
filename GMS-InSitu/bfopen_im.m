function [im] = bfopen_im(fname)
    % Simplified version of bfopen
    % Assumes one image stored in file
    % NO ERROR CHECKING 
    % (Make sure that original bfopen from bio-format works)
    % 2018-04-04 Suk Hyun Sung
    r = bfGetReader(fname, 0);
    r.setSeries(0);
    im = bfGetPlane(r, 1);
    r.close();
end