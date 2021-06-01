function liveFilter(im)
    % Live Filter within ROI
    % Input: Image Matrix (n x m)
    % Output: None
    % by Suk Hyun Sung @ hovdenlab
    % sukhsung@umich.edu
    im = normalize(im);
    
    [nr,nc] = size(im);
    im_cp = round( [nr,nc]/2);
    [xx,yy] = meshgrid(1:nc,1:nr);
   % rr = sqrt((xx-im_cp(1)).^2+(yy-im_cp(2)).^2);
   % tt = atan2(yy-im_cp(2)),(xx-im_cp(1));
    
    im_fft= fftshift(fft2(im));
    im_fft_log = normalize(log(1+abs(im_fft)));
    
    f= figure;
    ax1 = subplot(2,2,1);
    im1_obj = imagesc(im_fft_log);
    axis(ax1,'equal','off');
    ax2 = subplot(2,2,3);
    im2_obj = imagesc(im_fft_log);
    axis(ax2,'equal','off');
    ax3 = subplot(2,2,[2 4]);
    im3_obj = imagesc(im);
    axis(ax3,'equal','off');
    colormap(ax1,gray(65536));
    colormap(ax2,gray(65536));
    colormap(ax3,gray(65536));
    
    im_objs = [im1_obj,im2_obj,im3_obj];
    

    ax1.Position=[0.05 0.5  0.45 0.45];
    ax2.Position=[0.05 0.03 0.45 0.45];
    
    ax3.Position=[0.5 0 0.4 1];
    
    p1 = uipanel(f,'Position',[0,0,0.1,1]);
    p2 = uipanel(f,'Position',[0.9,0,0.1,1]);
    p3 = uipanel(f,'Position',[0.2,0.95,0.2,0.05]);
    
    sl1_min = uicontrol(p1,'style','slider',...
        'Units','normalized','position',[0,0,0.5,1],...
        'min', 0, 'max', 1,'Value', 0);
    sl1_max = uicontrol(p1,'style','slider',...
        'Units','normalized','position',[0.5,0,0.5,1],...
        'min', 0, 'max', 1,'Value', 1);
    sl2_min = uicontrol(p2,'style','slider',...
        'Units','normalized','position',[0,0,0.5,1],...
        'min', 0, 'max', 1,'Value', 0);
    sl2_max = uicontrol(p2,'style','slider',...
        'Units','normalized','position',[0.5,0,0.5,1],...
        'min', 0, 'max', 1,'Value', 1);
    
    filt_select = uicontrol(p3, 'style', 'popupmenu',...
        'String',{'Gaussian','von Hann','Hard','None'},...
        'Units','normalized','Position',[0,0,0.5,0.5],...
        'Value',1);
    mode_select = uicontrol(p3, 'style', 'popupmenu',...
        'String',{'Amplitdue','Phase','Phase (Centered)'},...
        'Units','normalized','Position',[0,0.5,0.5,0.5],...
        'Value',1);
    
    linkR_check = uicontrol(p3, 'style','checkbox',...
        'String','Link Radius',...
        'Units','normalized','Position',[0.5,0,0.3,0.3]);
    linkP_check = uicontrol(p3, 'style','checkbox',...
        'String','Link Position',...
        'Units','normalized','Position',[0.5,0.3,0.3,0.3]);
    enable_check = uicontrol(p3, 'style','checkbox',...
        'String','Enable Red',...
        'Units','normalized','Position',[0.5,0.6,0.3,0.3]);
        
    com_button = uicontrol(p3, 'style','pushbutton',...
        'String','Find Max',...
        'Units','normalized','Position',[0.8,0,0.2,1]);
    update_button = uicontrol(p3, 'style','pushbutton',...
        'String','Update',...
        'Units','normalized','Position',[0.6,0,0.2,1],...
        'Visible','off');
    
    circr = drawcircle(ax1,'Center',[nc/2+1,nr/2+1],'Radius',nr/8,...
        'Deletable',false,'DrawingArea',[1,1,nc-1,nr-1],...
        'Color','R','Visible','off');
    circb = drawcircle(ax1,'Center',[nc/2+1,nr/2+1],'Radius',nr/8,...
        'Deletable',false,'DrawingArea',[1,1,nc-1,nr-1],...
        'Color','B');
    
    circs = [circb, circr];
   
    labcmap = labColormap();
    
    addlistener(mode_select,'Value','PostSet', @(src,evnt) changeMode(labcmap,mode_select.Value,ax3,update_button));
    addlistener(filt_select,'Value','PostSet', @(src,evnt) changeFilt(update_button));
    addlistener([sl1_min,sl1_max], 'Value', 'PostSet',@(src,evnt) setContrast(ax1,sl1_min,sl1_max));
    addlistener([sl1_min,sl1_max], 'Value', 'PostSet',@(src,evnt) setContrast(ax2,sl1_min,sl1_max));
    addlistener([sl2_min,sl2_max], 'Value', 'PostSet',@(src,evnt) setContrast(ax3,sl2_min,sl2_max));
    
    addlistener(enable_check,'Value','PostSet', @(src,evnt) enableRed(enable_check.Value,circr,update_button));
    
    addlistener(circs,'MovingROI',@(src,evnt) runUpdate(update_button));
    addlistener(circb,'MovingROI',@(src,evnt) linkedMove(circb,circr,im_cp,linkP_check.Value,linkR_check.Value));
    addlistener(circr,'MovingROI',@(src,evnt) linkedMove(circr,circb,im_cp,linkP_check.Value,linkR_check.Value));
    
    addlistener(com_button, 'Value', 'PostSet', @(src,evnt) move2Max(circs,im_fft,xx,yy,update_button));
    
    
    addlistener(update_button, 'Value', 'PostSet', @(src,evnt) updateRecp(circs,im_fft,im_objs,xx,yy,filt_select.Value,mode_select.Value,im_cp,enable_check.Value));
end

function enableRed(enabled,circr,update_button)
    if enabled == 1
        circr.Visible = 'on';
    elseif enabled == 0
        circr.Visible = 'off';
    end
    runUpdate(update_button)
end

function linkedMove(circ_p,circ_c,im_cp,linkedP,linkedR)
    if linkedR
        circ_c.Radius = circ_p.Radius;
    end
    if linkedP
        circ_c.Center = 2*im_cp - circ_p.Center;
    end
end

function runUpdate(update_button)
    update_button.Value = 1;
    update_button.Value = 0;
end

function changeFilt(update_button)
    runUpdate(update_button)
end

function changeMode(labcmap,mode, ax3,update_button)
    if mode == 2 || mode == 3
        colormap(ax3,labcmap)
    else
        colormap(ax3,'gray')
    end
    runUpdate(update_button)
end

function setContrast(ax,sl_min,sl_max)
    caxis(ax,[sl_min.Value, sl_max.Value])
end

function move2Max(circs,im,xx,yy,update_button)
    for ind = 1:2
        [xc,yc] = findMax(circs(ind),im,xx,yy);
        moveCirc(circs(ind),xc,yc);
    end
    runUpdate(update_button)
end

function moveCirc(circ,x0,y0)
    circ.Center = [x0,y0];
end

function [xc,yc] = findMax(circ,im,xx,yy)
    x0 = circ.Center(1);
    y0 = circ.Center(2);
    r0 = circ.Radius;
    rr2 = (xx-x0).^2 + (yy-y0).^2;
    im_filtered = im.*makeHardDisk(rr2,r0);
    
   
    xc = xx( (im_filtered==max(im_filtered(:))) );
    yc = yy( (im_filtered==max(im_filtered(:))) );
    
end

function updateRecp(circs,im_fft,im_objs,xx,yy,filt_type,mode,im_cp,enabledR)
    if enabledR == 1
        cp1 = circs(1).Center;
        cp2 = circs(2).Center;
        filter1 = makeFilter(xx,yy,cp1(1),cp1(2),circs(1).Radius,filt_type);
        filter2 = makeFilter(xx,yy,cp2(1),cp2(2),circs(2).Radius,filt_type);

        if mode ==1 || mode ==2
            fft_filtered = im_fft.*((filter1+filter2)/2);
            ifft_filtered = iFFT(fft_filtered,mode,cp1,im_cp);
            
            set(im_objs(2),'CData',normalize(log(1+abs(fft_filtered))))
            set(im_objs(3),'CData',normalize(abs(ifft_filtered)))
        elseif mode == 3

            fft_filtered1 = ( im_fft.*filter1 );
            fft_filtered2 = ( im_fft.*filter2 );

            ifft_filtered1 = (iFFT(fft_filtered1,mode,cp1,im_cp));
            ifft_filtered2 = (iFFT(fft_filtered2,mode,cp2,im_cp));


            set(im_objs(2),'CData',normalize(log(1+abs(fft_filtered1 + fft_filtered2))))
            set(im_objs(3),'CData',normalize(abs(ifft_filtered1 + ifft_filtered2)))
        end
    elseif enabledR == 0
        cp1 = circs(1).Center;
        cp2 = 2*im_cp - cp1;
        filter1 = makeFilter(xx,yy,cp1(1),cp1(2),circs(1).Radius,filt_type);
        filter2 = makeFilter(xx,yy,cp2(1),cp2(2),circs(1).Radius,filt_type);
        
        fft_filtered1 = im_fft.*(filter1+filter2);
        ifft_filtered1 = iFFT(fft_filtered1,mode,cp1,im_cp);
        
        set(im_objs(2),'CData',normalize(log(1+abs(fft_filtered1))))
        set(im_objs(3),'CData',normalize(abs(ifft_filtered1)))

        %fft_filtered1 = ( im_fft.*filter1 );

        %ifft_filtered1 = (iFFT(fft_filtered1,mode,cp1,im_cp));

        %set(im_objs(2),'CData',normalize(log(1+abs(fft_filtered1))))
        %set(im_objs(3),'CData',normalize(ifft_filtered1))
    end
end


function im_ifft = iFFT(im_fft,mode,cp,im_cp)
    if mode == 1
        im_ifft = (ifft2(ifftshift(im_fft)));
    elseif mode == 2
        im_ifft = angle(ifft2(ifftshift(im_fft)));
    elseif mode == 3
        im_fft_shifted = shiftCenter(im_fft,cp,im_cp);
        im_ifft = angle(ifft2(ifftshift(im_fft_shifted)));
    end
end
function im_fft_shifted = shiftCenter(im_fft,cp,im_cp)
    dr= round(im_cp-cp);
    im_fft_shifted= circshift(im_fft,dr(1),2);
    im_fft_shifted = circshift(im_fft_shifted,dr(2),1);

end




function im_filter = makeFilter(xx,yy,x0,y0,r0,filt_type)
    rr2 = (xx-x0).^2 + (yy-y0).^2;
    if filt_type == 1
        im_filter = makeGaussianFilter(rr2,r0);
    elseif filt_type == 2
        im_filter = makeVonHannFilter(rr2,r0);
    elseif filt_type == 3
        im_filter = makeHardDisk(rr2,r0);
    elseif filt_type == 4
        im_filter = ones(size(rr2));
    end
end
function im_filter = makeGaussianFilter(rr2,sg)
    im_filter = exp( -rr2/(2*sg^2) );
end
function im_filter = makeHardDisk(rr2,r0)
    im_filter = rr2 <= r0^2;
end
function im_filter = makeHighPass(rr2,r0)
    im_filter = 1- makeGaussianFilter(rr2,r0*3);
end
function im_filter = makeVonHannFilter(rr2,r0)
    rr = sqrt(rr2);
    im_filter = (cos( pi*rr/(2*r0) ).^2) .* (rr<=r0);
end


function im_norm = normalize(im)
    im_norm = im- min(im(:));
    im_norm = im_norm/max(im_norm(:));
end

function cmap = labColormap()
    n = 65536;
    phi = linspace(0,2*pi,n);
    l = 70 * ones(n,1);
    a = 65 * cos(phi');
    b = 65 * sin(phi');
    lab = [l,a,b];
    cmap = double(lab2rgb(lab,'OutputType','uint16'))/65535;
end
