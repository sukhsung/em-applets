function vsliceZ(varargin)
% view tiff stack on a fly without loading the whole stack to memory
% useful for viewing large stack
% Arguments:
%     Mode 1: vsliceZ( )
%             Opens dialog to select tiff stack to open
%
%     Mode 2: vsliceZ( path_to_tiffstack )
%             Opens specified tiff stack
%
%     Mode 3: vsliceZ( function_handle )
%             Opens dialog to select tiff stack to open (same as Mode 1)
%               and apply a post processing function
%               e.g.  vsliceZ( @(x) log(1+abs(x)) )or
%               f = @(x) log(1+abs(x); vsliceZ( f )
%
%     Mode 4: vsliceZ( path_to_tiffstack, function_handle )
%             Opens specified tiff stack (same as Mode 2)
%               and apply a post processing function
%
% Written by Suk Hyun Sung (sukhsung@umich.edu) 
% Last Modified 2021/06/09

    if nargin == 0
        [fname,path] = uigetfile('*.tif');
        fname = fullfile(path,fname);
        applyfun = @(x) x;
    elseif nargin == 1
        if isa( varargin{1}, 'function_handle' )
            [fname,path] = uigetfile('*.tif');
            fname = fullfile(path,fname);
            applyfun = varargin{1};
        else
            fname = varargin{1};
            applyfun = @(x) x;
        end
    elseif nargin == 2
        fname = varargin{1};
        applyfun = varargin{2};
    else
        error( 'Unsupported Number of Arguments' );
    end
            
    im_info = imfinfo(fname);
    nz = length(im_info);
    tiffObj = Tiff(fname,'r');

    im = applyfun( tiffObj.read );
    cmin = min(im(:));
    cmax = max(im(:));

    if cmin == cmax
        cmax = 65536;
    end
    f = figure;
    im_h = imagesc( im ,[cmin, cmax]);
    ax = gca;
    axis(ax,'image')
    colormap(parula(65536));
    %%% UIs
    % ui panels
    p1 = uipanel(f,'Position',[0,0,0.1,1]);

    % Add sliders
    slmin = uicontrol(p1,'style','slider',...
        'Units','Normalized','position',[0,0,0.33,1],...
        'min', cmin, 'max', cmax,'Value', cmin);
    slmax = uicontrol(p1,'style','slider',...
        'Units','Normalized','position',[0.33,0,0.33,1],...
        'min', cmin, 'max', cmax,'Value', cmax);
    slz = uicontrol(p1,'style','slider',...
        'Units','Normalized','position',[0.66,0,0.33,1]...
        ,'min', 1, 'max', nz,'Value', 1,'SliderStep',[1/nz 1/nz]);
    
    % Listen to slider values and change B & C
    addlistener([slmin, slmax,slz], 'Value', 'PostSet',...
        @(hObject,eventdata) update(ax,im_h,tiffObj,nz,slmin,slmax,slz,applyfun));
    addlistener(f, 'ObjectBeingDestroyed', @(~,~) close(tiffObj));
    update(ax,im_h,tiffObj,nz,slmin,slmax,slz,applyfun)
end

function update(ax,im_h,tiffObj,nz,slmin,slmax,slz,applyfun)
    zslice = round(slz.Value);
    setSlice(im_h,zslice,tiffObj,slmax,slmin,applyfun)
    cmin = slmin.Value;
    cmax = slmax.Value;
    
    setContrast(ax,cmin, cmax)
    setTitle(ax,cmin,cmax,zslice,nz)
end

function setTitle(ax,cmin,cmax,zslice,nz)
    title(ax,sprintf('%d/%d slice, \n min = %f, max = %f', zslice,nz, cmin, cmax));
end

function setSlice(im_h,zslice,tiffObj,slmax,slmin,applyfun)
    tiffObj.setDirectory(zslice);
    % Select image from image stack  by slider values
    im_h.CData = applyfun( tiffObj.read );
end

function setContrast(ax,cmin, cmax)
    % Set coloraxis limit determined by slider values
    if cmin < cmax
        caxis(ax,[cmin, cmax])
    end
end

function dat_col = col(dat)
    dat_col = dat(:);
end