function data_mat = ERTTD(subjname, sessions, motor_mapping)
% Psychtoolbox script for the event related version of TDSigEI paradigm.
% Usage TTDSig(subjname, sessions, motor_mapping)
%
% for subjname, please input subject ID and the session number, such as 1001_session1 would be subject number 1001 session 1
%
% sessions would be an array of integers ranging from 1 to 7 indicating the conditions to run, they represent:
%   1:Fo = face as target on top of scramble houses
%   2:Ho = House as target on top of scramble faces
%   3:FH = Face as target on top of house distractors
%   4:HF = House as target on top of face distractors
%   5:B = attend both conditions, semi-transparent house/faces impose on top of each other
%   6:Fp = passivly viewing faces
%   7:Hp = passively viewing houses
% so if session input is [ 1 2 3], that means condtion Fo, Ho, FH will be
% given to the subject sequentially. Within each condition session, several
% blocks of trials will be given. Now the default is 4 task blcoks each
% consisting of 12 trials.
%
%
% motor_mapping: either 1 or 2. Represent the motor mapping for each condition that will be tested 
% in the session vector
%  1:M1 Face - respond with right index finger; House - respond with left index finger
%  2:M2 Face - respond with left index finger; House - respond with right index finger
% the number of elements in motor mapping must match number of elements in the session vector.
%
% Example usage. Block sequence use these two vectors:
% [7 1 4 6 2 3], [6 2 3 7 1 4]
% then cross with the following two motor mapping vectors
% [1 1 1 1 1 1], [2 2 2 2 2 2]
% The order should be counterbalanced across subjects. 
%

%% sanity check
if any(sessions > 7) || any (sessions< 1)
    error('entered wrong session vector!!');

end

if any(motor_mapping > 2) || any (motor_mapping< 1)
    error('entered wrong motor mapping!!');
end

if length(sessions) ~= length(motor_mapping)
    error('number of session does not match number of motor mapping given!!');
end

%% Setup parameters
sca;


%setup paths to load stimuli and write outputs
WD = pwd;
addpath(WD);
data_dir = fullfile(WD, 'data'); %output
face_dir = fullfile(WD, 'Faces'); %stimuli of faces
house_dir = fullfile(WD, 'Houses'); %stimuli of houses
curr_dir = WD;

%setup number of blocks, number of trials within blocks
block_num = 3;
trial_num_pbl = 13;
%prac_trial_num=1;

%setup trial timing
instruction_on_screen_time = 1;
inter_block_interval = 30;
initial_wait_time = 2;
block_start_cue_time = 2;
%stim_on_time = 1; %time of stimulus on screen, %speed up when testing script
%delay_time = .5; %time of delay between stimulus
stim_on_time = .25; %time of stimulus on screen
delay_times = [1.5 1.5 1.5 3 3 3 4.5 4.5 4.5 4.5 6 6 7.5]; %time of delay between stimulus (ITI)
delay_times = delay_times(randperm(trial_num_pbl));

%setup keyboard responses (if at scanner this will likely have to be different)
KbName('UnifyKeyNames');
%subjects will be asked to respond with either their right or left index if they detect a target.
% they will be asked to place their right index finger on key "k", left
% index finger on key "d"\
% this mapping will be different at the scanner....
RightIndex = KbName('4$');
LeftIndex = KbName('1!');
TTL = KbName('5%');

%setup display options
%Screen('Preference', 'SkipSyncTests', 1); %some timing stuff...
screens = Screen('Screens');
screenNumber = max(screens); %get external display if available
%if want to hide mouse corsor, use Screen('HideCursorHelper',window);
Priority(MaxPriority(screenNumber));

%setup colors
white=WhiteIndex(screenNumber); % pixel value for white
black=BlackIndex(screenNumber); % pixel value for black
green=[0 250 0];
red=[250 0 0];
orange=[250 125 0];
grey=[127 127 127];

%set transparency for each stimulus category
face_alpha = 0.55;
house_alpha = 0.45;

%open an window
Screen('Preference', 'SkipSyncTests', 1); 
[window, windowRect] = Screen('OpenWindow', screenNumber, grey);

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%get size of the screen
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);

% the size of stimuli on screen
imageRect = [xCenter-212 yCenter-212 xCenter+212 yCenter+212];


%% start session sequence
m = 0;
data_str=[]; %output structure
tr_num_cnt = 0; %count number of trials


for block_conditions = sessions
    
    %% initialize instruction screen
    Screen(window,'FillRect',grey);
    Screen(window, 'Flip');
    Screen('TextFont', window ,'Arial'); %set font
    Screen('TextSize', window, 26); %set fontsize
    
    % general instruction
    general_instruction = '\n\n For this experiment, you will be seeing pictures of faces and buildings. \n These pictures will be presented sequentially. \n You will be asked to respond to the pictures presented. \n\n Please press the right or the left botton to continue.';  

    %motor mapping instructions
    %1: M1, use right hand to respond to faces, use left hand respond to houses
    %2: M2 use left hand to respond to faces, use right hand to respond to houses
    m = m+1;
    if motor_mapping(m) == 1
        response_mode = 1;
        motor_instruction = '\n\n Please respond to picture of faces by pressing your "RIGHT INDEX FINGER", \n and respond to picture of buildings by pressing your "LEFT INDEX FINGER". \n Please keep both hands on the response box at all times. \n\n Please press the right or the left botton to continue.';
    elseif motor_mapping(m) == 2
        response_mode = 2;
        motor_instruction = '\n\n Please respond to picture of faces by pressing your "LEFT INDEX FINGER", \n and respond to picture of buildings by pressing your "RIGHT INDEX FINGER". \n Please keep both hands on the response box at all times. \n\n Please press the right or the left botton to continue.';
    end

    % task instruction
    switch(block_conditions)
        case 1 %Fo
            task_instruction = '\n\n Please pay attention to the faces presented in each picture, \n and make a button press \n if the face you see matches the face presented in the previous picture. \n\n Please press the right or the left botton to continue.';
            
        case 2 %Ho
            task_instruction = '\n\n Please pay attention to the building presented in each picture, \n and make a button press \n if the building you see matches the building presented in the previous picture. \n\n Please press the right or the left botton to continue.';
            
        case 3 %FH
            task_instruction = '\n\n Please pay attention to the faces presented in each picture, \n and make a button press \n if the face you see matches the face presented in the previous picture. \n\n Please press the right or the left botton to continue.';
        
        case 4 %HF
            task_instruction = '\n\n Please pay attention to the building presented in each picture,, \n and make a button press \n if the building you see matches the building presented in the previous picture. \n\n Please press the right or the left botton to continue.';
            
        case 5 %B
            task_instruction = '\n\n Please pay attention to both the face \n and the building presented in each picture, \n and make a button press \n if either the building or the face you see \n matches the building or the face presented in the previous picture. \n\n Please press the right or the left botton to continue.';
            
        case 6 %Fp
            task_instruction = '\n\n Please respond everytime you see a face. \n You do NOT have to match the face to the previously presented face, \njust respond with a button press you see a face. \n\n Please press the right or left botton to continue.';
            
        case 7 %Hp
            task_instruction = '\n\n Please respond everytime you see a building. \n You do NOT have to match the building to the previously presented building, \njust respond with a botton press everytime you see a building.  \n\n Please press the right or left botton to continue.';
    end
    final_reminder = ' \n\n Please remember to respond with the correct hand, \n and look at the center of the screen throughout the experiement. ';
    rest_reminder = '\n\n After completing a chunk of trials you will a see a green dot in the screen, \n please relax but stay still and focus on the green dot. \n You will be prompt to start the experiment again when you see "Get Ready!" \n\n Please press the right or the left botton to continue.';
        
    DrawFormattedText(window, [general_instruction], 'center',...
                screenYpixels * 0.35, [0 0 1]);
    Screen(window, 'Flip');
    WaitSecs(.5);
    check_keypress(RightIndex,LeftIndex);

    DrawFormattedText(window, [motor_instruction], 'center',...
                screenYpixels * 0.35, [0 0 1]);
    Screen(window, 'Flip');
    WaitSecs(.5);
    check_keypress(RightIndex,LeftIndex);

    DrawFormattedText(window, [task_instruction], 'center',...
                screenYpixels * 0.25, black);
    Screen(window, 'Flip');
    WaitSecs(.5);
    check_keypress(RightIndex,LeftIndex);

    DrawFormattedText(window, [final_reminder, rest_reminder], 'center',...
                screenYpixels * 0.25, [0 0 1]);
    Screen(window, 'Flip');
    WaitSecs(.1);
    check_keypress(RightIndex,LeftIndex);

    % instruction should at least be on the scren for 10 sec
    %starttime2 = GetSecs;
    %while (GetSecs - starttime2 < instruction_on_screen_time)
    %end
    %WaitSecs(instruction_on_screen_time);
    
    %% Stimulus preparation based on task conditions
    Conditions = {'Fo', 'Ho', 'FH', 'HF', 'B', 'Fp', 'Hp'};
    %1:Fo = face as target on top of scramble houses
    %2:Ho = House as target on top of scramble faces
    %3:FH = Face as target on top of house distractors
    %4:HF = House as target on top of face distractors
    %5:B = attend both conditions, semi-transparent house/faces impose on top of each other
    %6:Fp = passivly viewing faces
    %7:Hp = passively viewing houses
        
    % stimulus loading and preparation
    %[Face_Images,Face_Names]=load_all_images_from_dir(face_dir);
    %[House_Images,House_Names]=load_all_images_from_dir(house_dir);
    %Face_ScrambleImages = ScrambleImage(Face_Images);
    %House_ScrambleImages = ScrambleImage(House_Images);
    % here is a presaved image set
    load Images_Set_Shine.mat;
    
    % extract stimuli set depending on the condition.
    switch(block_conditions)
        case 1
            target_images = Face_Images * face_alpha;
            target_names = Face_Names;
            distractor_images = House_ScrambleImages * house_alpha;
            distractor_names = House_Names;
            %mask_images = Face_ScrambleImages;
        case 2
            target_images = House_Images * house_alpha;
            target_names = House_Names;
            distractor_images = Face_ScrambleImages * face_alpha;
            distractor_names = Face_Names;
            %mask_images = House_ScrambleImages;
        case 3
            target_images = Face_Images * face_alpha;
            target_names = Face_Names;
            distractor_images = House_Images * house_alpha;
            distractor_names = House_Names;
            %mask_images = Face_ScrambleImages;
        case 4
            target_images = House_Images * house_alpha;
            target_names = House_Names;
            distractor_images = Face_Images * face_alpha;
            distractor_names = Face_Names;
            %mask_images = House_ScrambleImages;
        case 6
            target_images = Face_Images * face_alpha;
            target_names = Face_Names;
            distractor_images = House_ScrambleImages * house_alpha;
            distractor_names = House_Names;
            %mask_images = Face_ScrambleImages;
        case 7
            target_images = House_Images * house_alpha;
            target_names = House_Names;
            distractor_images = Face_ScrambleImages * face_alpha;
            distractor_names = Face_Names;
            %mask_images = House_ScrambleImages;
    end
    
    
    % a key stroke will end the instruction page, or if at the scanner, wait for ttl pulse to start the task blocks
    Screen(window,'FillRect',grey);
    Screen(window, 'Flip');
    Screen('TextFont', window ,'Arial'); %set font
    Screen('TextSize', window, 30); %set fontsize
    DrawFormattedText(window, 'Wait for scanner to start', 'center',...
        screenYpixels * 0.5, [0 0 1]);
    Screen(window, 'Flip');
 
    %TTL initiation
    keepchecking = 1;
    while (keepchecking == 1)
      [keyIsDown,secs,keyCode] = KbCheck(-1); % In while-loop, rapidly and continuously check if the return key being pressed.
      if(keyIsDown)  % If key is being pressed...
        if keyCode(TTL)
          keepchecking = 0;
          break % ... end while-loop.
        end
      end
    end
    experiment_start_time = GetSecs;
    
    
    %% Insert a 2 seconds delay after instruction 
    Screen(window,'FillRect',grey);
    Screen(window, 'Flip');
    Screen('TextSize', window, 30);
    DrawFormattedText(window, 'Get Ready!', 'center',...
        screenYpixels * 0.5, [0 0 1]);
    Screen(window, 'Flip'); 
    WaitSecs(initial_wait_time);
    %starttime2 = GetSecs;
    %while (GetSecs - starttime2 < initial_wait_time)
    %end
    
    accum_accu = [];
    %% block sequence
    for j = 1:block_num
        
        %create ITI sequence
        ITIs = delay_times(randperm(trial_num_pbl))
        %ITIs(trial_num_pbl) = 1.5

        %%create sequence of 1-back match
        switch(block_conditions)
            case num2cell([1 2 3 4])
                %selected_pics = randperm(60, trial_num_pbl); %the total set is 60 pictures per category
                % create nback match sequence for targets.
                [selected_pics, nback_matches] = make_nback(randperm(60, trial_num_pbl), trial_num_pbl);
                
                % create responses
                targets = zeros(1,trial_num_pbl);
                targets(nback_matches) = 1;
                
                % create nback match seqeunce for distractors, so that
                % distractors also can be repeated luring false responses
                [distractor_sequence,~] = make_nback(randperm(60, trial_num_pbl), trial_num_pbl);
                
            case 5 % create two streams of n-back matches
                B_selected_pics = [];
                B_targets = [];
                for streams = 1:2
                    % both category as targets, so creating two streams of
                    % nback mathces
                    [B_selected_pics(streams,:), nback_matches] = make_nback(randperm(60, trial_num_pbl), trial_num_pbl);
                    
                    % create responses
                    targets = zeros(1,trial_num_pbl);
                    targets(nback_matches) = 1;
                    B_targets(streams,:) = targets;
                    targets = any(B_targets);
                end
                
            case num2cell([6 7]) % for passive viewing conditions, no n-back matches
                selected_pics = randperm(60, trial_num_pbl);
                distractor_sequence = randperm(60, trial_num_pbl);
                targets = ones(1,trial_num_pbl);
        end
        
        %pic_num = 0; %count picture number
        %% trial sequence
        for i = 1:trial_num_pbl
            
            %pic_num = pic_num+1;
            %extract to be presented stimuli
            switch(block_conditions)
                case num2cell([1 2 3 4 6 7])
                    
                    curr_pic =  (squeeze(target_images(selected_pics(i),:,:,:)) + squeeze(distractor_images(distractor_sequence(i),:,:,:)));
                    curr_pic_name = strcat(target_names{selected_pics(i)}, '___', distractor_names{distractor_sequence(i)} );
                    %mask_pic = squeeze(mask_images(selected_pics(i),:,:,:));
                    
                case 5
                    curr_pic =  (squeeze(Face_Images(B_selected_pics(1,i),:,:,:))*face_alpha + squeeze(House_Images(B_selected_pics(2,i),:,:,:))*house_alpha);
                    curr_pic_name = strcat(Face_Names{B_selected_pics(1,i)}, '___', House_Names{B_selected_pics(2,i)} );
                    
            end
            
            %present the stimuli
            Screen(window,'FillRect',grey);
            imageTexture = Screen('MakeTexture', window, curr_pic,[], [], 1);
            Screen('DrawTexture', window, imageTexture, [], imageRect, [], [], 1);
            %Screen(window,'PutImage',curr_pic,imageRect);
            Screen(window, 'Flip');
            stim_onset_time = GetSecs - experiment_start_time;
                    
            % logging RTs and key strokes
            RT=-1;
            RightHand_resp = 0;
            LeftHand_resp = 0;
            
            % trial time book keeping plus logging responses
            trial_start_time = GetSecs;
            while (GetSecs - trial_start_time < stim_on_time)
                [keyIsDown,secs,keyCode] = KbCheck(-1); % In while-loop, rapidly and continuously check if the k or d key is being pressed.
                if keyCode(RightIndex)  % If k key is being pressed...
                    RT = GetSecs-trial_start_time;
                    RightHand_resp = 1;
                elseif keyCode(LeftIndex)   % If d key is being pressed...
                    RT = GetSecs-trial_start_time;
                    LeftHand_resp = 1;
                end
            end
            
            
%             %present mask stimuli
%             Screen(window,'FillRect',grey);
%             imageTexture = Screen('MakeTexture', window, mask_pic,[], [], 1);
%             Screen('DrawTexture', window, imageTexture, [], imageRect, [], [], 1);
%             %Screen(window,'PutImage',curr_pic,imageRect);
%             Screen(window, 'Flip');
%             
%             mask_start_time = GetSecs;
%             while (GetSecs - mask_start_time < mask_on_time)
%                 [keyIsDown,secs,keyCode] = KbCheck(-1); % In while-loop, rapidly and continuously check if the k or d key is being pressed.
%                 if keyCode(RightIndex)  % If k key is being pressed...
%                     RT = GetSecs-trial_start_time;
%                     RightHand_resp = 1;
%                 elseif keyCode(LeftIndex)   % If d key is being pressed...
%                     RT = GetSecs-trial_start_time;
%                     LeftHand_resp = 1;
%                 end
%             end
%             
            
            %put up delay screen for ITI (fixation cross)
            ITI_start_time = GetSecs;
            Screen(window,'FillRect',grey);
            Screen('TextSize', window, 80);
            DrawFormattedText(window, '+', 'center',...
                'center', [0 0 1]);
            Screen(window, 'Flip');
            while (GetSecs - ITI_start_time < ITIs(i))
                [keyIsDown,secs,keyCode] = KbCheck(-1); % In while-loop, rapidly and continuously check if the k or d key is being pressed.
                if keyCode(RightIndex)  % If k key is being pressed...
                    RT = GetSecs-trial_start_time;
                    RightHand_resp = 1;
                elseif keyCode(LeftIndex)   % If d key is being pressed...
                    RT = GetSecs-trial_start_time;
                    LeftHand_resp = 1;
                end
            end

            %WaitSecs(delay_time);
            %starttime2 = GetSecs;
            %while (GetSecs - starttime2 < delay_time)
            %end
            
            %% determine accuracy of responses
            tr_corr = 0; %tr_corr = 1 is correct, 2 is false alarm, 0 is incorrect
            false_alarm = 0;
            %determine correct or incorrect
            %mode 1 , face with right, house with left
            %mode 2,  face with left, house with right
            if response_mode == 1 && (block_conditions == 1 || block_conditions ==3 ) %face as target, M1
                if any(LeftHand_resp)
                    false_alarm = 2;
                elseif targets(i) == RightHand_resp
                    tr_corr = 1;
                end
            elseif response_mode == 1 && (block_conditions == 2 || block_conditions ==4 ) %house as target, M1
                if any(RightHand_resp)
                    false_alarm =2;
                elseif targets(i) == LeftHand_resp
                    tr_corr = 1;
                end
            elseif response_mode == 2 && (block_conditions == 1 || block_conditions ==3 ) %face as target, M2
                if any(RightHand_resp)
                    false_alarm = 2;
                elseif targets(i) == LeftHand_resp
                    tr_corr = 1;
                end
            elseif response_mode == 2 && (block_conditions == 2 || block_conditions ==4 ) %house as target, M2
                if any(LeftHand_resp)
                    false_alarm = 2;
                elseif targets(i) == RightHand_resp
                    tr_corr = 1;
                end
            elseif response_mode == 1 && (block_conditions == 5 ) %both as targets, face in stream1, house in stream2, M1
                if B_targets(1,i) == RightHand_resp && B_targets(2,i) == LeftHand_resp
                    tr_corr = 1;
                end
            elseif response_mode == 2 && (block_conditions == 5 ) %both as targets, face in stream1, house in stream2, M2
                if B_targets(1,i) == LeftHand_resp && B_targets(2,i) == RightHand_resp
                    tr_corr = 1;
                end
            elseif response_mode == 1 && (block_conditions == 6) % passive view of face, M1
                if any(RightHand_resp)
                    tr_corr = 1;
                end
            elseif response_mode == 1 && (block_conditions == 7) % passive view of houses, M1
                if any(LeftHand_resp)
                    tr_corr = 1;
                end
            elseif response_mode == 2 && (block_conditions == 6) % passive view of faces, M2
                if any(LeftHand_resp)
                    tr_corr = 1;
                end
            elseif response_mode == 2 && (block_conditions == 7) % passive view of houses, M2
                if any(RightHand_resp)
                    tr_corr = 1;
                end
            end
            accum_accu = [accum_accu, tr_corr];
            
            tr_num_cnt = tr_num_cnt+1;
            %% organize data logs
            data_str = [data_str  subjname(1:4) '\t' ...
                cell2mat(Conditions(block_conditions)) '\t' ...
                num2str(response_mode) '\t' ...
                num2str(targets(i)) '\t' ...
                num2str(tr_corr) '\t' ...
                num2str(false_alarm) '\t' ...
                num2str(RightHand_resp) '\t' ...
                num2str(LeftHand_resp) '\t' ...
                num2str(RT) '\t' ...
                num2str(stim_onset_time) '\t' ...
                curr_pic_name '\n'];
            
            data_mat(tr_num_cnt).subj = subjname(1:4);
            data_mat(tr_num_cnt).condition = Conditions(block_conditions);
            data_mat(tr_num_cnt).response_mode = num2str(response_mode);
            data_mat(tr_num_cnt).nback_match = num2str(targets(i));
            data_mat(tr_num_cnt).Accu = tr_corr;
            data_mat(tr_num_cnt).false_alarm = false_alarm;
            data_mat(tr_num_cnt).RT = RT;
            data_mat(tr_num_cnt).cat_picname = curr_pic_name;
            data_mat(tr_num_cnt).RightHand_resp = RightHand_resp;
            data_mat(tr_num_cnt).LefttHand_resp = LeftHand_resp;
            data_mat(tr_num_cnt).stim_onset_time = stim_onset_time;
            clear keyCode keyIsDown resp RT
            
            
        end
        
        %% fixation rest block
        if j < block_num
            Screen(window,'FillRect',grey);
            Screen('DrawDots', window, [xCenter yCenter], 35, green, [], 2); %green dot in the center
            Screen(window, 'Flip');
            WaitSecs(inter_block_interval);
            %starttime2 = GetSecs;
            %while (GetSecs - starttime2 < inter_block_interval)
            %end
            
            
            % Screen(window,'FillRect',grey);
            % Screen('TextSize', window, 80);
            % DrawFormattedText(window, 'Press any key to continue', 'center',...
            %     screenYpixels * 0.5, [0 0 1]);
            % Screen(window, 'Flip');
            %keepchecking = 1;
            %while (keepchecking == 1)
            %    [keyIsDown,secs,keyCode] = KbCheck; % In while-loop, rapidly and continuously check if the return key being pressed.
            %    if(keyIsDown)  % If key is being pressed...
            %        keepchecking = 0; % ... end while-loop.
            %    end
            %end
            
            % the get ready screen to move back to the start of the block
            Screen(window,'FillRect',grey);
            Screen('TextSize', window, 30);
            Screen(window, 'Flip');
            DrawFormattedText(window, 'Get Ready!', 'center',...
                screenYpixels * 0.5, [0 0 1]);
            Screen(window, 'Flip');
            WaitSecs(block_start_cue_time);
            %starttime2 = GetSecs;
            %while (GetSecs - starttime2 < block_start_cue_time)
            %end
        end
        

        if j == block_num
            %% final rest

            Screen(window,'FillRect',grey);
            Screen('TextSize', window, 80);
            DrawFormattedText(window, '+', 'center',...
                'center', [0 0 1]);
            Screen(window, 'Flip');

            %Screen(window,'FillRect',grey);
            %Screen('DrawDots', window, [xCenter yCenter], 35, green, [], 2); %green dot in the center
            %Screen(window, 'Flip');
            WaitSecs(3); %final rest

            experiment_end_time = GetSecs - experiment_start_time

            Screen(window,'FillRect',grey);
            Screen('TextSize', window, 26);
            Screen(window, 'Flip');
            accum_accu;
            feedback_message = ['Good Job! \n You got ', num2str(mean(accum_accu)*100) '% of the trials right \n' 'Wait for the next run please.'];
            DrawFormattedText(window, feedback_message, 'center',...
                screenYpixels * 0.5, [0 0 1]);
            Screen(window, 'Flip');
            WaitSecs(5);    
        end
    end

    %% write data
    eval(sprintf('cd %s',data_dir));
    timestamp = strcat(datestr(clock,'yyyy-mm-dd-HHMM'),'m',datestr(clock,'ss'),'s');
    cmd = sprintf('fid = fopen(''fMRI_Data_%s_%s.txt'',''w'');',subjname, timestamp);      %will call the data file datasubjname
    eval(cmd);
    fprintf(fid,data_str);
    fclose(fid);
end


%% write data
eval(sprintf('cd %s',data_dir));
timestamp = strcat(datestr(clock,'yyyy-mm-dd-HHMM'),'m',datestr(clock,'ss'),'s');
cmd = sprintf('fid = fopen(''fMRI_Data_%s_%s.txt'',''w'');',subjname, timestamp);      %will call the data file datasubjname
eval(cmd);
fprintf(fid,data_str);
fclose(fid);

eval(sprintf('save ''fMRI_Data_%s_%s.mat'' data_mat;',subjname, timestamp));

eval(sprintf('cd %s',curr_dir));

Screen('CloseAll')
end

%a function to generate nback
function [stim_sequence, nback_matches] = make_nback(input_pics, trial_num_pbl)
% function to generate nback match sequence. input will be a vector of picture index (input_pics)
% and the number of trials (trial_num_pbl) in each block,
% output will be the stimulus sequence index (stim_sequence), and the binary position vector where there is a match (nback_matches)
nback_matches = sort(randperm(trial_num_pbl-1,4)+1);
for i = 1:length(nback_matches)-1
    if nback_matches(i) == nback_matches(i+1)-1
        nback_matches(i+1) = nback_matches(i+1)+1;
    end
    if nback_matches(i) == nback_matches(i+1)
        nback_matches(i+1) = nback_matches(i+1)+2;
    end
end
%nback_matches
nback_matches(nback_matches > trial_num_pbl) = [];
selected_pics = input_pics;
selected_pics(nback_matches) = input_pics(nback_matches-1);
stim_sequence = selected_pics;
end


function check_keypress(RightIndex,LeftIndex)
keepchecking = 1;
clear keyCode keyIsDown
while (keepchecking == 1)
    [keyIsDown,secs,keyCode] = KbCheck(-1); % In while-loop, rapidly and continuously check if the return key being pressed.
    if(keyIsDown)  % If key is being pressed...
        if keyCode(RightIndex) || keyCode(LeftIndex) 
            keepchecking = 0;
            break % ... end while-loop.
        end    
    end
end
end
