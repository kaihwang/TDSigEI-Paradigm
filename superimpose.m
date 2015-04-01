function superimpose()
  faces = dir('Faces'); houses = dir('Houses');
  for i=4:length(faces)
      for j=4:length(houses)        
          impose(faces(4).name, houses(4).name);
          scramblehouseimpose(faces(i).name, houses(j).name);
          scramblefaceimpose(faces(i).name, houses(j).name);
      end
  end
end

function scramblehouseimpose(inputImg1, inputImg2)
  A = imread(strcat('Faces/',inputImg1));
  B = scrambleHouse(inputImg2);
  [heightA, widthA, ~] = size(A); [heightB, widthB, ~] = size(B);
  [~,y1] = size(inputImg1); %[~,y2]=size(inputImg2);
  B = imcrop(B, [(widthB-widthA)/2 (heightB-heightA)/2 widthA heightA]);
  C = imfuse(A,B,'blend');
  outfile = strcat(inputImg1(1:y1-4), '_Scramble', inputImg2);
  imwrite(C, strcat('out/housescramble/',outfile));
end

function scramblefaceimpose(inputImg1, inputImg2)
  A = scrambleFace(inputImg1);
  B = imread(strcat('Houses/',inputImg2));
  [heightA, widthA, ~] = size(A); [heightB, widthB, ~] = size(B);
  [~,y1] = size(inputImg1); %[~,y2]=size(inputImg2);
  B = imcrop(B, [(widthB-widthA)/2 (heightB-heightA)/2 widthA heightA]);
  C = imfuse(A,B,'blend');
  outfile = strcat('Scramble',inputImg1(1:y1-4), '_', inputImg2);
  imwrite(C, strcat('out/facescramble/',outfile));
end

function impose( inputImg1, inputImg2 )
 A = imread(strcat('Faces/',inputImg1));
 B = imread(strcat('Houses/',inputImg2));
 [heightA, widthA, ~] = size(A); [heightB, widthB, ~] = size(B);
 [~,y1] = size(inputImg1); %[~,y2]=size(inputImg2);
 B = imcrop(B, [(widthB-widthA)/2 (heightB-heightA)/2 widthA heightA]);
 C = imfuse(A,B,'blend');
 outfile = strcat(inputImg1(1:y1-4), '_', inputImg2);
 imwrite(C, strcat('out/superimposed/',outfile));
 %imshow(C);
% i = imshow(A); hold on;
% h = imshow(B);
% alpha(0.5);
% imwrite(h,'superimpose3.bmp');
% set(h, 'AlphaData', 0.5);
end

function scrambledhouse = scrambleHouse( filename )
  Im = mat2gray(double(imread(strcat('Houses/', filename))));
  ImSize = size(Im);
  RandomPhase = angle(fft2(rand(ImSize(1), ImSize(2))));
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
  ImScrambled = real(ImScrambled); %get rid of imaginer part in image (due to rounding error)
  %imwrite(ImScrambled,'faceScrambled.bmp','jpg');
  %imshow(ImScrambled)
  scrambledhouse = ImScrambled;
end

function scrambledface = scrambleFace( filename)
Im = mat2gray(double(imread(strcat('Faces/',filename))));
ImSize = size(Im);
RandomPhase = angle(fft2(rand(ImSize(1), ImSize(2))));
%generate random phase structure
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
ImScrambled = real(ImScrambled); %get rid of imaginery part in image (due to rounding error)
%imwrite(ImScrambled,'BearScrambled.jpg','jpg');
imshow(ImScrambled)
scrambledface = ImScrambled;
end
