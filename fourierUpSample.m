function im_up = fourierUpSample(fname, upSamp)

im = double(imread(fname,'tif'));

[nr,nc] = size(im);


figure
subplot(2,2,1)
imagesc(im)
colormap gray
axis equal off
title('original')


im_fft = fftshift(fft2(im));

subplot(2,2,2)
imagesc(log(1+abs(im_fft)))
colormap gray
axis equal off
title('FFT of original')

pad = 1;
im_fft_abs_edge = abs(im_fft);
im_fft_abs_edge(1+pad:nr-pad,1+pad:nc-pad) = NaN;
noiseLevel = mean(im_fft_abs_edge(:),'omitnan');

im_up_fft_abs = 2.3*noiseLevel*rand(nr*upSamp, nc*upSamp);
im_up_fft_pha = 2*pi*rand(nr*upSamp, nc*upSamp) -1;

im_up_fft_abs((upSamp/2-0.5)*nr+1:(upSamp/2+0.5)*nr, (upSamp/2-0.5)*nc+1:(upSamp/2+0.5)*nc) = abs(im_fft);
im_up_fft_pha((upSamp/2-0.5)*nr+1:(upSamp/2+0.5)*nr, (upSamp/2-0.5)*nc+1:(upSamp/2+0.5)*nc) = angle(im_fft);

im_up_fft = im_up_fft_abs.*exp(-1i*im_up_fft_pha);

subplot(2,2,3)
imagesc(log(1+abs(im_up_fft)))
colormap gray
axis equal off
title('FFT of up Sampled')


im_up = abs(ifft2(ifftshift(im_up_fft)));
subplot(2,2,4)
imagesc(im_up)
colormap gray
axis equal off
title('up Sampled')

im_up_scal = im_up - min(im_up(:));
im_up_scal = uint16(65535*im_up_scal/max(im_up_scal(:)));

imwrite(im_up_scal,sprintf([fname,'_upSampled_x%d.tif'],upSamp))