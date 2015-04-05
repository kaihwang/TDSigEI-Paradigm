function TDSigEI(subjname, block_conditions, motor_mapping)
% Psychtoolbox script for TDSigEI paradigm.
% Usage TDSigEI(subjname, block_condition, motor_mapping)
%
% for subjname, please input subject ID and the session number, such as 1001_1 would be subject number 1001 session 1
%
% block_condition would be an integer, see:
%   1:Fo = face as target on top of scramble houses
%   2:Ho = House as target on top of scramble faces
%   3:FH = Face as target on top of house distractors
%   4:HF = House as target on top of face distractors
%   5:B = attend both conditions, semi-transparent house/faces impose on top of each other
%   6:Fp = passivly viewing faces
%   7:Hp = passively viewing houses
%
% motor_mapping: either 'M1' or 'M2'
%  M1: Face - respond with right index finger; House - respond with left index finger
%  M2: Face - respond with left index finger; House - respond with right index finger
    sca; 
    %clear all;

    WD = pwd;
    addpath(WD);

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
    instruction_on_screen_time = 1;
    inter_block_interval = 5;
    %stim_on_time = 1; %time of stimulus on screen
    %delay_time = .5; %time of delay between stimulus
    %speed up when testing script
    stim_on_time = 1; %time of stimulus on screen
    delay_time = .5; %time of delay between stimulus

    %feedback_time = 2.25; %time of feedback, not using for now
    %ITIs=[1.5,1.75,2,2.25,2.5,2.75,3]; %randomized intervals between stimuli, not using for now

    %setup paths to load stimuli and write outputs
    data_dir = 'data'; %output
    face_dir = 'Faces'; %stimuli of faces
    house_dir = 'Houses'; %stimuli of houses
    curr_dir = '..';


    %setup keyboard responses (if at scanner this will likely have to be different)
    KbName('UnifyKeyNames');

    %subjects will be asked to respond with either their right or left index if they detect a target.
    % they will be asked to place their right index finger on key "k", left index finger on key "d"
    RightIndex = KbName('k');  
    LeftIndex = KbName('d');


    %setup display options
    Screen('Preference', 'SkipSyncTests', 1);
    screens = Screen('Screens');
    screenNumber = max(screens); %get external display if available
    whichScreen = screenNumber;

    %setup colors
    white=WhiteIndex(screenNumber); % pixel value for white
    black=BlackIndex(screenNumber); % pixel value for black
    green=[0 250 0];
    red=[250 0 0];
    orange=[250 125 0];
    grey=[127 127 127];

    %transparency
    face_alpha = 0.7;
    house_alpha = 0.3;

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
    while (GetSecs - starttime2 < instruction_on_screen_time)
    end


    %% Stimulus preparation based on list of conditions and its order
    % organize block order
    Conditions = {'Fo', 'Ho', 'FH', 'HF', 'B', 'Fp', 'Hp'};
    %1:Fo = face as target on top of scramble houses
    %2:Ho = House as target on top of scramble faces
    %3:FH = Face as target on top of house distractors
    %4:HF = House as target on top of face distractors
    %5:B = attend both conditions, semi-transparent house/faces impose on top of each other
    %6:Fp = passivly viewing faces
    %7:Hp = passively viewing houses

    % the order of blocks, it is fixed for now. we will have 4 different 
    %block_conditions = [5, 1, 4, 6, 2, 3, 7];

    % randomize response mode (with right or left hand)
    %1: use right hand to respond to faces, use left hand respond to houses
    %2: use left hand to respond to faces, use right hand to respond to houses
    %response_mode = [2, 2, 2, 2, 1, 1, 1] or [1, 1, 1, 1, 2, 2, 2]
    if strcmp(motor_mapping, 'M1')
        response_mode = 1;
    elseif strcmp(motor_mapping, 'M2')
        response_mode = 2;
    end


    % stimulus loading and preparation 
    [Face_Images,Face_Names]=load_all_images_from_dir(face_dir);
    [House_Images,House_Names]=load_all_images_from_dir(house_dir);
    Face_ScrambleImages = ScrambleImage(Face_Images);
    House_ScrambleImages = ScrambleImage(House_Images);

    % extract stimuli set depending on the condition. 
    switch(block_conditions)
        case 1
            target_images = Face_Images * face_alpha; 
            target_names = Face_Names;
            distractor_images = House_ScrambleImages * house_alpha; 
            distractor_names = House_Names;
        case 2
            target_images = House_Images * house_alpha; 
            target_names = House_Names;
            distractor_images = Face_ScrambleImages * face_alpha; 
            distractor_names = Face_Names;
        case 3
            target_images = Face_Images * face_alpha; 
            target_names = Face_Names;
            distractor_images = House_Images * house_alpha; 
            distractor_names = House_Names;
        case 4
            target_images = House_Images * house_alpha; 
            target_names = House_Names;
            distractor_images = Face_Images * face_alpha; 
            distractor_names = Face_Names;
        case 6
            target_images = Face_Images * face_alpha; 
            target_names = Face_Names;
            distractor_images = House_ScrambleImages * house_alpha; 
            distractor_names = House_Names;
        case 7
            target_images = House_Images * house_alpha; 
            target_names = House_Names;
            distractor_images = Face_ScrambleImages * face_alpha; 
            distractor_names = Face_Names;  
    end


    %% a key stroke will end the instruction page
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


    %% Insert a 2 second delay between instruction/practice and actual experiment. 
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

    %% block sequence
    for j = 1:block_num

        %%create sequence of 1-back match
        switch(block_conditions)
            case num2cell([1 2 3 4])
                %selected_pics = randperm(60, trial_num_pbl); %the total set is 60 pictures per category
                [selected_pics, nback_matches] = make_nback(randperm(60, trial_num_pbl), trial_num_pbl);
                
                % create responses
                targets = zeros(1,trial_num_pbl);
                targets(nback_matches) = 1;

                [distractor_sequence,~] = make_nback(randperm(60, trial_num_pbl), trial_num_pbl);

            case 5 % create two streams of n-back matches
                B_selected_pics = [];
                B_targets = [];
                for streams = 1:2
                    [B_selected_pics(streams,:), nback_matches] = make_nback(randperm(60, trial_num_pbl), trial_num_pbl);
                    
                    % create responses
                    targets = zeros(1,trial_num_pbl);
                    targets(nback_matches) = 1;
                    B_targets(streams,:) = targets;
                    targets = any(B_targets);
                end

            case num2cell([6 7])
                selected_pics = randperm(60, trial_num_pbl);
                targets = ones(1,trial_num_pbl);
        end

        pic_num = 0;

        %% trial sequence
        for i = 1:trial_num_pbl
            
            pic_num = pic_num+1;
            
            %extract to be presented stimuli
            switch(block_conditions)
                case num2cell([1 2 3 4 6 7])
                    
                    curr_pic =  (squeeze(target_images(selected_pics(pic_num),:,:,:)) + squeeze(distractor_images(distractor_sequence(pic_num),:,:,:)));
                    curr_pic_name = strcat(target_names{selected_pics(pic_num)}, '___', distractor_names{selected_pics(pic_num)} );

                case 5
                    curr_pic =  (squeeze(Face_Images(B_selected_pics(1,pic_num),:,:,:))*face_alpha + squeeze(House_Images(B_selected_pics(2,pic_num),:,:,:))*house_alpha);
                    curr_pic_name = strcat(Face_Names{B_selected_pics(1,pic_num)}, '___', House_Names{B_selected_pics(2,pic_num)} );

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
                [keyIsDown,secs,keyCode] = KbCheck; % In while-loop, rapidly and continuously check if the k or d key is being pressed.
                if keyCode(RightIndex)  % If k key is being pressed...
                    RT = GetSecs-trial_start_time;
                    RightHand_resp = 1;
                elseif keyCode(LeftIndex)   % If d key is being pressed...
                    RT = GetSecs-trial_start_time;
                    LeftHand_resp = 1;
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
            %mode 1 , face with right, house with left
            %mode 2,  face with left, house with right
            if response_mode == 1 && (block_conditions == 1 || block_conditions ==3 ) %face as target
                if any(LeftHand_resp) 
                    tr_corr = 2;
                elseif targets(i) == RightHand_resp
                    tr_corr = 1;
                end
            elseif response_mode == 1 && (block_conditions == 2 || block_conditions ==4 ) %house as target
                if any(RightHand_resp) 
                    tr_corr = 2;
                elseif targets(i) == LeftHand_resp
                    tr_corr = 1;
                end
            elseif response_mode == 2 && (block_conditions == 1 || block_conditions ==3 ) %face as target
                if any(RightHand_resp) 
                    tr_corr = 2;
                elseif targets(i) == LeftHand_resp
                    tr_corr = 1;
                end
            elseif response_mode == 2 && (block_conditions == 2 || block_conditions ==4 ) %house as target
                if any(LeftHand_resp) 
                    tr_corr = 2;
                elseif targets(i) == RightHand_resp
                    tr_corr = 1;
                end
            elseif response_mode == 1 && (block_conditions == 5 ) %both as targets, face in stream1, house in stream2
                if B_targets(1,i) == RightHand_resp && B_targets(2,i) == LeftHand_resp
                    tr_corr = 1;
                end
            elseif response_mode == 2 && (block_conditions == 5 )
                if B_targets(1,i) == LeftHand_resp && B_targets(2,i) == RightHand_resp
                    tr_corr = 1;
                end
            elseif response_mode == 1 && (block_conditions == 6)
                if any(RightHand_resp)
                    tr_corr = 1;
                end
            elseif response_mode == 1 && (block_conditions == 7)
                if any(LeftHand_resp)
                    tr_corr = 1;
                end
            elseif response_mode == 2 && (block_conditions == 6)
                if any(LeftHand_resp)
                    tr_corr = 1;
                end
            elseif response_mode == 2 && (block_conditions == 7)
                if any(RightHand_resp)
                    tr_corr = 1;
                end    
            end
            
            
            tr_num_cnt = tr_num_cnt+1;
            
            %% writing out logs
            data_str = [data_str  '\t' ...
                cell2mat(Conditions(block_conditions)) '\t' ...
                num2str(response_mode) '\t' ...
                num2str(targets(i)) '\t' ...
                num2str(tr_corr) '\t' ...
                num2str(RightHand_resp) '\t' ...
                num2str(LeftHand_resp) '\t' ...
                num2str(RT) '\t' ...
                num2str(stim_onset_time) '\t' ...
                curr_pic_name '\n'];

            data_mat(tr_num_cnt).condition = Conditions(block_conditions);
            data_mat(tr_num_cnt).response_mode = num2str(response_mode);
            data_mat(tr_num_cnt).nback_match = num2str(targets(i));
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
        
        %% fixation rest block
        if j < block_num
            Screen(window,'FillRect',grey);
            %Screen('TextSize', window, 80);
            %DrawFormattedText(window, 'You finished one block, \n take a 10 sec break, \n\n and press any key to continue', ...
            %    'center',...
            %    screenYpixels * 0.3, black);  
            
            Screen('DrawDots', window, [xCenter yCenter], 35, green, [], 2); %green dot in the center
            Screen(window, 'Flip');
            starttime2 = GetSecs;
            while (GetSecs - starttime2 < inter_block_interval)
            end
            
            
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

    cmd = sprintf('fid = fopen(''Behav_Data_%s_%s_%s.txt'',''w'');',subjname, cell2mat(Conditions(block_conditions)), motor_mapping);      %will call the data file datasubjname
    eval(cmd);
    fprintf(fid,data_str);
    fclose(fid);

    eval(sprintf('save ''Behav_Data_%s_%s_%s.mat'' data_mat;',subjname, cell2mat(Conditions(block_conditions)), motor_mapping));

    eval(sprintf('cd %s',curr_dir));

    Screen('CloseAll')
end

%a function to generate nback
function [stim_sequence, nback_matches] = make_nback(selected_pics, trial_num_pbl)
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
    selected_pics(nback_matches) = selected_pics(nback_matches-1);
    stim_sequence = selected_pics;
end