% here is the code I found online for phase scrambling

Im = mat2gray(double(imread('Faces/f_001.bmp')));
%read and rescale (0-1) image

ImSize = size(Im)

RandomPhase = angle(fft2(rand(ImSize(1), ImSize(2))));
%generate random phase structure

% for layer = 1:ImSize(3)
    %ImFourier(:,:) = fft2(Im(:,:));
    ImFourier = fft2(Im(:,:));
%Fast-Fourier transform
    Amp = abs(ImFourier(:,:));       
%amplitude spectrum
    Phase = angle(ImFourier(:,:));   
%phase spectrum
    Phase = Phase(:,:) + RandomPhase;
%add random phase to original phase
    ImScrambled = ifft2(Amp(:,:).*exp(sqrt(-1)*(Phase(:,:))));   
%combine Amp and Phase then perform inverse Fourier
%end

ImScrambled = real(ImScrambled); %get rid of imaginer part in image (due to rounding error)
%imwrite(ImScrambled,'faceScrambled.bmp','jpg');

imshow(ImScrambled)
