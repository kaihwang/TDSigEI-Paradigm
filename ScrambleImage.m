function scrambleImage = ScrambleImage(Images)
    for i = 1:size(Images,1)
        Im = squeeze(Images(i,:,:,:)); %mat2gray(double(imread(filename)));
        ImSize = size(Im);
        RandomPhase = angle(fft2(rand(ImSize(1), ImSize(2))));

        if length(ImSize) == 2
            ImFourier = fft2(Im(:,:));
            %Fast-Fourier transform
            Amp = abs(ImFourier(:,:));
            %amplitude spectrum
            Phase = angle(ImFourier(:,:));
            %phase spectrum
            Phase = Phase(:,:) + RandomPhase;
            %add random phase to original phase
            ImScrambled = ifft2(Amp(:,:).*exp(sqrt(-1)*(Phase(:,:))));
            
        elseif length(ImSize) == 3 %not sure why dimesion is not identical between faces and houses...
            
            for layer = 1:ImSize(3)
                ImFourier(:,:,layer) = fft2(Im(:,:,layer));
                %Fast-Fourier transform
                Amp(:,:,layer) = abs(ImFourier(:,:,layer));
                %amplitude spectrum
                Phase(:,:,layer) = angle(ImFourier(:,:,layer));
                %phase spectrum
                Phase(:,:,layer) = Phase(:,:,layer) + RandomPhase;
                %add random phase to original phase
                ImScrambled(:,:,layer) = ifft2(Amp(:,:,layer).*exp(sqrt(-1)*(Phase(:,:,layer))));
                %combine Amp and Phase then perform inverse Fourier
            end
        end
        %combine Amp and Phase then perform inverse Fourier
        scrambleImage(i,:,:,:) = real(ImScrambled); %get rid of imaginer part in image (due to rounding error)
        %imwrite(ImScrambled,'faceScrambled.bmp','jpg');
        %imshow(ImScrambled)
        %scrambledhouse = ImScrambled;
    end
end