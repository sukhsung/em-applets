function varargout = imageBC(im)
    % Brightness & Contrast enabled imagesc
    % Input: Image Matrix (n x m)
    % Output: varargout{1}: figure . handle
    %                  {2}: axis    handle
    %                  {3}: imagesc handle
    % by Suk Hyun Sung @ hovdenlab
    % sukhsung@umich.edu
    
    
    % Create new figure and perform imagesc,
    f = figure;
    im_h = imagesc(im);
    ax = gca;
    
    % Return figure, axis, imagesc handles
    if nargout >0 
        varargout{1} = f;
        varargout{2} = ax;
        varargout{3} = im_h;
    end
    
    % 16 bit gray colormap as default
    colormap(gray(65536))
    % Find default min, max
    cmin = min(im(:));
    cmax = max(im(:)); 
    
    %%% UIs
    % ui panels
    p1 = uipanel(f,'Position',[0,0,0.1,1]);
    p2 = uipanel(f,'Position',[0.1,0,0.3,0.05]);
    % Add sliders
    slmin = uicontrol(p1,'style','slider',...
        'Units','Normalized','position',[0,0,0.5,1],...
        'min', cmin, 'max', cmax,'Value', cmin);
    slmax = uicontrol(p1,'style','slider',...
        'Units','Normalized','position',[0.5,0,0.5,1],...
        'min', cmin, 'max', cmax,'Value', cmax);
    
    % filename box
    txtbox = uicontrol(p2,'style','edit',...
        'Units','Normalized','position',[0.3 0 0.5, 1],...
        'String','File Name');
    % Add button
    uicontrol(p2,'style','pushbutton',...
        'Units','Normalized','position',[0 0 0.2, 1],...
        'String','Apply','CallBack',...
        @(hObject,eventdata) appliedIm(im,slmin,slmax));
    uicontrol(p2,'style','pushbutton',...
        'Units','Normalized','position',[0.8 0 0.2, 1],...
        'String','Save','CallBack',...
        @(hObject,eventdata) saveIm(im,slmin,slmax,txtbox));
    
    
    % Listen to slider values and change B & C
    addlistener([slmin, slmax], 'Value', 'PostSet',...
        @(hObject,eventdata) setContrast(ax,slmin,slmax));

    
end

function appliedIm(im,slmin,slmax)
    % Apply Contrast and create normal figure with imagesc
    % contrast applied image is assigned to variable im_thr in workspace
    cmin = slmin.Value;
    cmax = slmax.Value;
    
    figure
    imagesc(im,[cmin, cmax])
    im_thr = im;
    im_thr( im_thr > cmax ) = cmax;
    im_thr( im_thr < cmin ) = cmin;
    assignin('base','im_thr',im_thr)
    disp('Thresholded image assigned to im_thr')
end

function saveIm(im,slmin,slmax,txtbox)
    % Save 16 bit unsigned integer Tiff as shown in the figure window
    % data normalized to 16 bit (0 - 65535)
    cmin = slmin.Value;
    cmax = slmax.Value;
    
    if cmin < cmax
        disp('Applying Contrast Bounds');
        im( im<cmin ) = cmin;
        im( im>cmax ) = cmax;
        
        disp('Normalizing to 16 bit integer (0 - 65535)');
        im = im - cmin;
        im = uint16(65535 * im / max(im(:)));
        
        savestr = [txtbox.String,'.tif'];
        disp(['Saving to ', savestr]);
        imwrite(im, [txtbox.String,'.tif'])
    else
        error('Contrast is out of Bound')
    end
end

function setContrast(ax,slmin,slmax)
    % Set coloraxis limit determined by slider values
    cmin = slmin.Value;
    cmax = slmax.Value;
    if cmin < cmax
        caxis(ax,[cmin, cmax])
        title(sprintf('min = %f, max = %f', cmin, cmax));
    end
end