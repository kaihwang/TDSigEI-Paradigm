function [image_matrix, image_names] = superimpose(target_dir, distractor_dir, scram_var)
% function to manipulate target and distractor images, by making them
% transparent and impose on top of each other. Also has the option to phase
% scramble the underlay distractor image.
%
% Usage: [image_matrix, image_names] = superimpose(target_dir, distractor_dir, scram_var)
%   target_dir: directory that contains all the target images
%   distractor_dir:  distractor images directory
%   scram_var: whether or not to phase scramble the distractors, 1 = yes, 0 = no
%
% Outputs:
%   image_martrx: the output image matrix in 4 dimensions. first dimension
%   is the picture number.
%   image_names is a list of file names. 
%
% example: [C, F] = superimpose('Houses','Faces', 1);
%   here Houses is the directory where the target images are saved, they
%   will be make transparent and superimpose on top of phase scrambled
%   faces (scram_var is turned on)




target = dir(target_dir);
distractor = dir(distractor_dir);

%randomly select distractors
distractor_i = 4:length(distractor);
distractor_i = distractor_i(randperm(length(4:length(distractor))));

if scram_var == 0 % no scramble of distractor, just superimpose
    k = 0;
    for i=4:length(target)
        k = k+1;
        [C, curr_file_name] = impose(target(i).name, distractor(distractor_i(k)).name, target_dir, distractor_dir);
        
        image_matrix(k,:,:,:) = C;
        eval(sprintf('image_names(%s)={''%s''};',num2str(k),curr_file_name));
    end
    
elseif scram_var == 1 % scramble background distractor image
    k = 0;
    for i=4:length(target)
        k = k+1;
        [C, curr_file_name] = scramble(target(i).name, distractor(distractor_i(k)).name, target_dir, distractor_dir);
        
        image_matrix(k,:,:,:) = C;
        eval(sprintf('image_names(%s)={''%s''};',num2str(k),curr_file_name));
        %for j=4:length(distractor)
        %scramblehouseimpose(faces(i).name, houses(j).name);
        %scramblefaceimpose(faces(i).name, houses(j).name);
        %end
    end
end
end


function [C, curr_file_name] = impose( inputImg1, inputImg2, target_dir, distractor_dir)
A = imread(fullfile(target_dir,inputImg1));
B = imread(fullfile(distractor_dir,inputImg2));
[heightA, widthA, ~] = size(A); [heightB, widthB, ~] = size(B);
[~,y1] = size(inputImg1);
[~,y2] = size(inputImg2);

% crop images....
if heightB > heightA && widthB > widthA
    B = imcrop(B, [(widthB-widthA)/2 (heightB-heightA)/2 widthA heightA]);
end

if heightA > heightB && widthA > widthB
    A = imcrop(A, [(widthA-widthB)/2 (heightA-heightB)/2 widthB heightB]);
end

C = imfuse(A,B,'blend'); %make transparent and overlay
curr_file_name = strcat(inputImg1(1:y1-4), '_', inputImg2(1:y2-4)); %take out the 'jpeg' or 'bmp'
%imwrite(C, strcat('out/superimposed/',curr_file_name), 'JPEG');
%imshow(C);
% i = imshow(A); hold on;
% h = imshow(B);
% alpha(0.5);
% imwrite(h,'superimpose3.bmp');
% set(h, 'AlphaData', 0.5);
end

function  [C, curr_file_name] = scramble(inputImg1, inputImg2, target_dir, distractor_dir)
A = imread(fullfile(target_dir,inputImg1));
B = scrambleImage(fullfile(distractor_dir,inputImg2));
[heightA, widthA, ~] = size(A);
[heightB, widthB, ~] = size(B);
[~,y1] = size(inputImg1);
[~,y2] = size(inputImg2);

% crop images....
if heightB > heightA && widthB > widthA
    B = imcrop(B, [(widthB-widthA)/2 (heightB-heightA)/2 widthA heightA]);
end

if heightA > heightB && widthA > widthB
    A = imcrop(A, [(widthA-widthB)/2 (heightA-heightB)/2 widthB heightB]);
end

C = imfuse(A,B,'blend');
curr_file_name = strcat(inputImg1(1:y1-4), '_Scramble', inputImg2(1:y2-4));
%imwrite(C, strcat('out/housescramble/',outfile));
end



function scrambleImage = scrambleImage( filename )
Im = mat2gray(double(imread(filename)));
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
scrambleImage = real(ImScrambled); %get rid of imaginer part in image (due to rounding error)
%imwrite(ImScrambled,'faceScrambled.bmp','jpg');
%imshow(ImScrambled)
%scrambledhouse = ImScrambled;
end

