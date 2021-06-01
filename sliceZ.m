function sliceZ(data)

    [~,~,nz] = size(data);

    cmin = min(data(:));
    cmax = max(data(:));

    f = figure;
    im_h = imagesc(data(:,:,1),[cmin, cmax]);
    ax = gca;
    axis(ax,'image')
    %%% UIs
    % ui panels
    p1 = uipanel(f,'Position',[0,0,0.1,1]);

    % Add sliders
    slmin = uicontrol(p1,'style','slider',...
        'Units','Normalized','position',[0,0,0.25,1],...
        'min', cmin, 'max', cmax,'Value', cmin);
    slmax = uicontrol(p1,'style','slider',...
        'Units','Normalized','position',[0.25,0,0.25,1],...
        'min', cmin, 'max', cmax,'Value', cmax);
    slz = uicontrol(p1,'style','slider',...
        'Units','Normalized','position',[0.5,0,0.25,1]...
        ,'min', 1, 'max', nz,'Value', 1,'SliderStep',[1/nz 1/nz]);
    slav = uicontrol(p1,'style','slider',...
        'Units','Normalized','position',[0.75,0,0.25,1]...
        ,'min',1,'max', nz','Value',1,'sliderStep',[1/nz 1/nz]);

    
    % Listen to slider values and change B & C
    addlistener([slmin, slmax,slz], 'Value', 'PostSet',...
        @(hObject,eventdata) update(ax,im_h,data,nz,slmin,slmax,slz,slav));
    
    addlistener(slav,'Value','PostSet',...
        @(hObject,eventdata) updateAv(ax,im_h,data,nz,slmin,slmax,slz,slav));

    
    update(ax,im_h,data,nz,slmin,slmax,slz,slav)
end

function updateAv(ax,im_h,data,nz,slmin,slmax,slz,slav)
    zstep  = round(slav.Value);
    slzMax = nz-zstep+1;
    
    if slz.Value > slzMax
        slz.Value = slzMax;
    end
    
    
    slz.Max = nz-zstep+1;
    slz.SliderStep = [1/slzMax, 1/slzMax];
    update(ax,im_h,data,nz,slmin,slmax,slz,slav)
    
    if slz.Max == 1
        slz.Max = 1.1;
    end
end


function update(ax,im_h,data,nz,slmin,slmax,slz,slav)
    zslice = round(slz.Value);
    zstep  = round(slav.Value);
    slzMax = nz-zstep+1;
    cmin = slmin.Value;
    cmax = slmax.Value;
    
    
    if zslice>nz
        slz.Value = nz;
    elseif zslice <1
        slz.Value = 1;
    end
    
    setSlice(im_h,zslice,zstep,data)
    setContrast(ax,cmin, cmax)
    setTitle(ax,cmin,cmax,zslice,nz,zstep)
end
function setTitle(ax,cmin,cmax,zslice,nz,zstep)
    title(ax,sprintf('(%d-%d)/%d slice, averaging over %d slice(s)\n min = %f, max = %f', zslice,(zslice+zstep-1),nz,zstep, cmin, cmax));
end

function setSlice(im_h,zslice,zstep,data)
    % Select image from image stack  by slider values
    set(im_h,'CData', mean(data(:,:,zslice:zslice+zstep-1),3))
end

function setContrast(ax,cmin, cmax)
    % Set coloraxis limit determined by slider values
    if cmin < cmax
        caxis(ax,[cmin, cmax])
    end
end