function liveFFT(im)
    % Live FFT within ROI
    % Input: Image Matrix (n x m)
    % Output: None
    % by Suk Hyun Sung @ hovdenlab
    % sukhsung@umich.edu
    [nr,nc] = size(im);
    
    im_fft = logFFT(im);

    f = figure;
    ax1 = subplot(1,2,1);
    imagesc(im);
    axis(ax1,'equal','off');
    colormap(parula(65536))
    ax2 = subplot(1,2,2);
    im_obj = imagesc(im_fft);
    axis(ax2,'equal','off');
    colormap(parula(65536))
    
    ax1.Position=[0.1 0  0.4 1];
    ax2.Position=[0.5  0 0.4 1];
    
    % Find default min, max
    cmin1 = min(im(:));
    cmax1 = max(im(:)); 
    cmin2 = min(im_fft(:));
    cmax2 = max(im_fft(:)); 

    
    p1 = uipanel(f,'Position',[0,0,0.1,1]);
    p2 = uipanel(f,'Position',[0.9,0,0.1,1]);
    
    sl1_min = uicontrol(p1,'style','slider',...
        'Units','normalized','position',[0,0,0.5,1],...
        'min', cmin1, 'max', cmax1,'Value', cmin1);
    sl1_max = uicontrol(p1,'style','slider',...
        'Units','normalized','position',[0.5,0,0.5,1],...
        'min', cmin1, 'max', cmax1,'Value', cmax1);
    sl2_min = uicontrol(p2,'style','slider',...
        'Units','normalized','position',[0,0,0.5,1],...
        'min', cmin2, 'max', cmax2,'Value', cmin2);
    sl2_max = uicontrol(p2,'style','slider',...
        'Units','normalized','position',[0.5,0,0.5,1],...
        'min', cmin2, 'max', cmax2,'Value', cmax2);
    
    addlistener([sl1_min,sl1_max], 'Value', 'PostSet',@(src,evnt) setContrast(ax1,sl1_min,sl1_max));
    addlistener([sl2_min,sl2_max], 'Value', 'PostSet',@(src,evnt) setContrast(ax2,sl2_min,sl2_max));
    
    h = drawrectangle(ax1,'Deletable',false,'Position',[1,1,nc-1,nr-1],'DrawingArea',[1,1,nc-1,nr-1]);
    addlistener(h,'MovingROI',@(src,evnt) updateRight(evnt,im,im_obj));
end

function setContrast(ax,sl_min,sl_max)
    caxis(ax,[sl_min.Value, sl_max.Value])
end
function updateRight(evnt,im,im_obj)
    cp = round(evnt.CurrentPosition);
    newIm = logFFT(im(cp(2):cp(2)+cp(4),cp(1):cp(1)+cp(3)));
    [nr,nc] = size(im);
    set(im_obj,'CData',newIm,'XData',1:nc,'YData',1:nr)
end

function im_fft_log = logFFT(im)
    im_fft_log = log(1+abs(fftshift(fft2(im))));
end