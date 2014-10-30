% script to manipulate image.

%imread to read, imshow to show
H = imread('HouseSingHouse12.bmp');
F = imread('Bfemale27.jpg');

%convert to grayscale
I = rgb2gray(F);

%rescale image
I(:,641:end)=[];


%convert to RGB for alpha plan
I2 = SetImageAlpha(I, 0.5);
H2 = SetImageAlpha(H, 0.5);
%I2(1:480,1:640,1)=I;
%I2(1:480,1:640,2)=I;
%I2(1:480,1:640,3)=I;
%I2(1:480,1:640,4)=1;
%imshow(I2)

%H2(1:480,1:640,1)=H;
%H2(1:480,1:640,2)=H;
%H2(1:480,1:640,3)=H;
%H2(1:480,1:640,4)=1;
%imshow(H2)


%% testing psychtoolbox routines.
% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
inc = white - grey;


% Open an on screen window
%use Will's function
screenResolution=[800 600];
backgroundColor=256/2*[1 1 1];
[w, windowRect] = setupScreen(backgroundColor, screenResolution);


%%%%%%%%%or not use Will's setupScreen;
%KbName('UnifyKeyNames')

% Removes the blue screen flash and minimize extraneous warnings.
% http://psychtoolbox.org/FaqWarningPrefs
%Screen('Preference', 'Verbosity', 2); % remove cli startup message
%Screen('Preference', 'VisualDebugLevel', 3); % remove  visual logo

%[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
%Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%Screen('TextFont', w, '-misc-fixed-bold-r-normal--0-0-100-100-c-0-iso8859-16');

%Priority(MaxPriority(w));

%HideCursor;
%%%%%%%%%


% Query the frame duration
ifi = Screen('GetFlipInterval', w);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

imageTexture = Screen('MakeTexture', w, I);
Screen('DrawTexture', w, imageTexture, [], [],0, [],0.7);
imageTexture2 = Screen('MakeTexture', w, H);
Screen('DrawTexture', w, imageTexture2, [], [],0, [],0.2);
Screen('Flip', w);
