function TDSigEI(subjname)
% Psychtoolbox script for TDSigEI paradigm.

sca; 
%clear all;


%% Old stuff for using the external USB response box. keepin for now
% HID=DaqFind;
% DaqDConfigPort(HID,0,0);
% DaqDOut(HID,0,0);  %Turn off

%% Setup parameters
block_num = 2;

%setup number of trials within blocks and practice
trial_num_pbl = 12;
%prac_trial_num=1;

%setup trial timing
stim_on_time = 1; %time of stimulus on screen
delay_time = .5; %time of delay between stimulus 
%feedback_time = 2.25; %time of feedback, not using for now
%ITIs=[1.5,1.75,2,2.25,2.5,2.75,3]; %randomized intervals between stimuli, not using for now

%setup paths to load stimuli and write outputs

data_dir = 'data'; %output
face_dir = 'Faces'; %stimuli of faces
house_dir = 'Houses'; %stimuli of houses
curr_dir = '..';
WD = pwd;

%setup keyboard responses (if at scanner this will likely have to be different)
KbName('UnifyKeyNames')

%subjects will be asked to respond with either their right or left index if they detect a target.
% they will be asked to place their right index finger on key "k", left index finger on key "d"
RightIndex = KbName('k');  
LeftIndex = KbName('d');


%setup display options
screens = Screen('Screens');
screenNumber = max(screens); %get external display if available
whichScreen=screenNumber;

%set colors
white=WhiteIndex(screenNumber); % pixel value for white
black=BlackIndex(screenNumber); % pixel value for black
green=[0 250 0];
red=[250 0 0];
orange=[250 125 0];
grey=[127 127 127];

%[window window_rect]=Screen(whichScreen,'OpenWindow');
%Screen(window); % if want to hide mouse corsor, use Screen('HideCursorHelper',window);

%open an window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%get size of the screen
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);

% the size of stimuli on screen
imageRect=[xCenter-212 yCenter-212 xCenter+212 yCenter+212];



%% initialize instruction screen
Screen(window,'FillRect',grey);
Screen(window, 'Flip');
Screen('TextFont', window ,'Arial'); %set font
Screen('TextSize', window, 26); %set fontsize
%display instructions
DrawFormattedText(window, 'Instruction of the task... blah blah blah', 'center',...
    screenYpixels * 0.35, [0 0 1]);
Screen(window, 'Flip');

% instruction should at least be on the scren for 10 sec
starttime2 = GetSecs;
while (GetSecs - starttime2 < 10)
end

%% stimulus preparation. Here is where we insert Akshay's function to load, overlay, and normalize the face/scenes images
% for now just load a couple images to test..
cd(WD);
cd(fullfile(WD,face_dir));
[face_images,face_names]=load_all_images_from_dir;

cd(WD);
cd(fullfile(WD,house_dir));
[house_images,house_names]=load_all_images_from_dir;

cd(WD);


%% organize block order
Conditions = {'Fo', 'Ho', 'FH', 'HF'};
%1:Fo = face as target on top of scramble houses
%2:Ho = House as target on top of scramble faces
%3:FH = Face as target on top of house distractors
%4:HF = House as target on top of face distractors

% randomize the order of blocks (might want to pseudorandomize this later)
block_conditions = randperm(4);

% randomize response mode (with right or left hand)
%1: use right hand
%2: use left hand
response_mode = [1 2 1 2];

% a key stroke will end the instruction page
Screen(window,'FillRect',grey);
Screen(window, 'Flip');
Screen('TextFont', window ,'Arial'); %set font
Screen('TextSize', window, 26); %set fontsize
%display instructions
DrawFormattedText(window, 'Press any key to continue', 'center',...
    screenYpixels * 0.35, [0 0 1]);
Screen(window, 'Flip');


keepchecking = 1;
while (keepchecking == 1)
    [keyIsDown,secs,keyCode] = KbCheck; % In while-loop, rapidly and continuously check if the return key being pressed.
    if(keyIsDown)  % If key is being pressed...
        keepchecking = 0; % ... end while-loop.
    end
end


%% practice blocks
% here insert pratice block code. omit for now.


% Insert a 2 second delay between instruction/practice and actual experiment. 
Screen(window,'FillRect',grey);
Screen(window, 'Flip');
Screen('TextSize', window, 80);
DrawFormattedText(window, 'Get Ready!', 'center',...
    screenYpixels * 0.5, [0 0 1]);
Screen(window, 'Flip');
experiment_start_time = GetSecs;

starttime2 = GetSecs;
while (GetSecs - starttime2 < 2)
end



%% experiment

data_str=[];

%m_adapt_morph_rand=randperm(size(morph_pics,1));
%f_adapt_morph_rand=randperm(size(morph_pics,1));


tr_num_cnt = 0;

for j = 1:block_num
    
    % extract stimuli set depending on the condition. Right now only presenting
    % single pic with no scramble underlay or distractors... will have to fix this
    % when those are done
    if (block_conditions(j) == 1 | block_conditions(j) == 3)
        target_images = face_images;
        target_names = face_names;
    elseif (block_conditions(j) == 2 | block_conditions(j) == 4)
        target_images = house_images;
        target_names = house_names;
    end
        

    %create sequence of 1-back match
    selected_pics = randperm(30,trial_num_pbl);
    nback_matches = sort(randperm(trial_num_pbl-1,3)+1);
    for i = 1:length(nback_matches)-1
        if nback_matches(i) == nback_matches(i+1)-1 
            nback_matches(i+1) = nback_matches(i+1)+1;
        end
        if nback_matches(i) == nback_matches(i+1)
            nback_matches(i+1) = nback_matches(i+1)+2;
        end
    end
    nback_matches(nback_matches>trial_num_pbl) = [];

    % create responses
    targets = zeros(1,trial_num_pbl);
    targets(nback_matches) = 1;

    % this is the sequence of pictures that will be presented 
    selected_pics(nback_matches) = selected_pics(nback_matches-1);

    pic_num = 0;
    for i = 1:length(selected_pics)
        
        %extract to be presented stimuli
        pic_num = pic_num+1;
        curr_pic = squeeze(target_images(selected_pics(pic_num),:,:,:));
        curr_pic_name = target_names{selected_pics(pic_num)};
        curr_picnum = selected_pics(pic_num);

        %present the stimuli
        Screen(window,'FillRect',grey);
        Screen(window,'PutImage',curr_pic,imageRect);
        Screen(window, 'Flip');
        stim_onset_time = GetSecs - experiment_start_time;
        
        % logging RTs and key strokes
        RT=-1;
        RightHand_resp = 0;
        LeftHand_resp = 0;

        % trial time book keeping plus logging responses
        trial_start_time = GetSecs;
        while (GetSecs - trial_start_time < stim_on_time)
            [keyIsDown,secs,keyCode] = KbCheck; % In while-loop, rapidly and continuously check if the k or d key is being pressed.
            if keyCode(RightIndex)  % If k key is being pressed...
                RT = GetSecs-trial_start_time;
                RightHand_resp=1;
            elseif keyCode(LeftIndex)   % If d key is being pressed...
                RT = GetSecs-trial_start_time;
                LeftHand_resp=1;
            end
        end
        

        %while ((GetSecs - trial_start_time) < stim_on_time) % ensure sufficeint stimulus presentation time
        %end

        %put up delay screen for ITI (fixation cross)
        Screen(window,'FillRect',grey);
        Screen('TextSize', window, 80);
        DrawFormattedText(window, '+', 'center',...
            'center', [0 0 1]);
        Screen(window, 'Flip');
        starttime2 = GetSecs; 
        while (GetSecs - starttime2 < delay_time)
        end
        
        
        tr_corr = 0; %tr_corr = 1 is correct, 2 is false alarm, 0 is incorrect 
        %determine correct or incorrect
        if response_mode(j) == 1
            if any(LeftHand_resp) 
                tr_corr = 2;
            elseif targets(i) == RightHand_resp
                tr_corr = 1;
            end
        elseif response_mode(j) == 2
            if any(RightHand_resp) 
                tr_corr = 2;
            elseif targets(i) == LeftHand_resp
                tr_corr = 1;
            end
        end
        
        
        tr_num_cnt = tr_num_cnt+1;
        
        %% writing out logs
        data_str = [data_str  '\t' ...
            num2str(block_conditions(j)) '\t' ...
            num2str(response_mode(j)) '\t' ...
            num2str(targets(i)) '\t' ...
            num2str(tr_corr) '\t' ...
            num2str(RightHand_resp) '\t' ...
            num2str(LeftHand_resp) '\t' ...
            num2str(RT) '\t' ...
            num2str(curr_picnum) '\t' ...
            num2str(stim_onset_time) '\t' ...
            curr_pic_name '\n'];

        data_mat(tr_num_cnt).condition = num2str(block_conditions(j));
        data_mat(tr_num_cnt).response_mode = num2str(response_mode(j));
        data_mat(tr_num_cnt).nback_match = num2str(targets(i));
        data_mat(tr_num_cnt).pic = curr_picnum;
        data_mat(tr_num_cnt).Accu = tr_corr;
        data_mat(tr_num_cnt).RT = RT;
        data_mat(tr_num_cnt).cat_picname = curr_pic_name;
        data_mat(tr_num_cnt).RightHand_resp = RightHand_resp;
        data_mat(tr_num_cnt).LefttHand_resp = LeftHand_resp;
        data_mat(tr_num_cnt).stim_onset_time = stim_onset_time;
        clear keyCode keyIsDown resp RT
        
        % conisder save on the go
        % eval(sprintf('cd %s',data_dir));
        % cmd = sprintf('fid = fopen(''Behav_Data_%s.txt'',''w'');',subjname);      %will call the data file datasubjname
        % eval(cmd);
        % fprintf(fid,data_str);
        % fclose(fid);
        
        % eval(sprintf('save ''Behav_Data_%s.mat'' data_mat;',subjname));
        
        % eval(sprintf('cd %s',curr_dir));
 
    end
    
    if j < block_num
        Screen(window,'FillRect',grey);
        Screen('TextSize', window, 80);
        DrawFormattedText(window, 'You finished one block, \n take a 10 sec break, \n\n and press any key to continue', ...
            'center',...
            screenYpixels * 0.3, black);  
        Screen(window, 'Flip');
        starttime2 = GetSecs;
        while (GetSecs - starttime2 < 10)
        end
        
        
        % Screen(window,'FillRect',grey);
        % Screen('TextSize', window, 80);
        % DrawFormattedText(window, 'Press any key to continue', 'center',...
        %     screenYpixels * 0.5, [0 0 1]); 
        % Screen(window, 'Flip');
        keepchecking = 1;
        while (keepchecking == 1)
            [keyIsDown,secs,keyCode] = KbCheck; % In while-loop, rapidly and continuously check if the return key being pressed.
            if(keyIsDown)  % If key is being pressed...
                keepchecking = 0; % ... end while-loop.
            end
        end
        
        % the get ready screen to move back to the start of the block
        Screen(window,'FillRect',grey);
        Screen('TextSize', window, 80);
        Screen(window, 'Flip');
        DrawFormattedText(window, 'Get Ready!', 'center',...
            screenYpixels * 0.5, [0 0 1]);
        Screen(window, 'Flip');
        starttime2 = GetSecs;
        while (GetSecs - starttime2 < 2)
        end
    end
end

eval(sprintf('cd %s',data_dir));

cmd = sprintf('fid = fopen(''Behav_Data_%s.txt'',''w'');',subjname);      %will call the data file datasubjname
eval(cmd);
fprintf(fid,data_str);
fclose(fid);

eval(sprintf('save ''Behav_Data__%s.mat'' data_mat;',subjname));

eval(sprintf('cd %s',curr_dir));

Screen('CloseAll')

