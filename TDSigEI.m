function TDSigEI(subjname)
% Psychtoolbox script for TDSigEI paradigm.

sca; 
clear all;


%% Old stuff for using the external USB response box. keepin for now
% HID=DaqFind;
% DaqDConfigPort(HID,0,0);
% DaqDOut(HID,0,0);  %Turn off

%% Setup parameters
block_num=2;

%setup number of trials within blocks and practice
trial_num_pbl=12;
%prac_trial_num=1;

%setup trial timing
stim_on_time=2.5; %time of stimulus on screen
delay_time=.25; %time of delay between stimulus and feedback
feedback_time=2.25; %time of feedback
ITIs=[1.5,1.75,2,2.25,2.5,2.75,3]; %randomized intervals between stimuli

%setup paths to load stimuli and write outputs

data_dir='data'; %output
face_dir='Faces'; %stimuli of faces
house_dir='Houses'; %stimuli of houses
curr_dir='..';
WD = pwd;

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
    screenYpixels * 0.75, [0 0 1]);
Screen(window, 'Flip');

%% stimulus preparation. Here is where we insert Akshay's function to load, overlay, and normalize the face/scenes images
% for now just load a couple images to test..
cd(WD);
cd(fullfile(WD,face_dir));
[face_images,face_names]=load_all_images_from_dir;

cd(WD);
cd(fullfile(WD,house_dir));
[house_images,house_names]=load_all_images_from_dir;

cd(WD);


% a key stroke will end the instruction page
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
DrawFormattedText(window, 'Get Ready@', 'center',...
    screenYpixels * 0.5, [0 0 1]);
Screen(window, 'Flip');
starttime2 = GetSecs;
while (GetSecs - starttime2 < 2)
end



%% experiment

data_str=[];

%m_adapt_morph_rand=randperm(size(morph_pics,1));
%f_adapt_morph_rand=randperm(size(morph_pics,1));


tr_num_cnt=0;

for j = 1:block_num
    
    %create sequence of 1-back match
    selected_pics = randperm(30,12);
    nback_matches = sort(randperm(11,3)+1);
    for i = 1:length(nback_matches)-1
        if nback_matches(i) == nback_matches(i+1)-1 
            nback_matches(i+1) = nback_matches(i+1)+1;
        end
        if nback_matches(i) == nback_matches(i+1)
            nback_matches(i+1) = nback_matches(i+1)+2;
        end
    end
    nback_matches(nback_matches>12) = [];

    % this is the sequence of pictures that will be presented 
    selected_pics(nback_matches) = selected_pics(nback_matches-1)

    
    cat1_cnt=0;
    cat2_cnt=0;
    
    %randomize the sequence of picture names for cat1 and cat2
    cat1_rnd=randperm(length(cat1_names));
    cat2_rnd=randperm(length(cat2_names));
    
    %randomize the sequence of picture names for cat1 and cat2 to ensure sufficent tirla number...?
    while length(cat1_rnd)<(trial_num_pbl/2)
        cat1_rnd=[cat1_rnd randperm(length(cat1_names))];
    end
    
    while length(cat2_rnd)<(trial_num_pbl/2)
        cat2_rnd=[cat2_rnd randperm(length(cat2_names))];
    end
    
    for i = 1:length(trial_rand)
        
        %pick picture for cat1
        if trial_rand(i)==1
            cat1_cnt=cat1_cnt+1;
            curr_pic=squeeze(cat1_images(cat1_rnd(cat1_cnt),:,:,:));
            curr_pic_name=cat1_names{cat1_rnd(cat1_cnt)};
            curr_picnum=cat1_rnd(cat1_cnt);
        end
        
        %pick picture for cat1
        if trial_rand(i)==2
            cat2_cnt=cat2_cnt+1;
            curr_pic=squeeze(cat2_images(cat2_rnd(cat2_cnt),:,:,:));
            curr_pic_name=cat2_names{cat2_rnd(cat2_cnt)};
            curr_picnum=cat2_rnd(cat2_cnt);
        end
        
        Screen(window,'FillRect',black);
        Screen(window,'PutImage',curr_pic,imageRect);
        Screen(window, 'Flip');
        DaqDOut(HID,0,1);  %Turn on
        
        % logging RTs and key strokes
        keepchecking = 1;
        RT=-1;
        resp=-1;
        
        trial_start_time=GetSecs;
%         while (keepchecking == 1)
%             [keyIsDown,secs,keyCode] = KbCheck; % In while-loop, rapidly and continuously check if the Z or / key is being pressed.
%             if find(keyCode==1)==29  % If key is being pressed...
%                 keepchecking = 0; % ... end while-loop.
%                 RT=GetSecs-trial_start_time;
%             end
%             if find(keyCode==1)==56  % If key is being pressed...
%                 keepchecking = 0; % ... end while-loop.
%                 RT=GetSecs-trial_start_time;
%             end
%             if ((GetSecs - trial_start_time) > stim_on_time)
%                 keepchecking=0;
%             end
%         end
        
        
        ButtonResponse=-1;
        while (keepchecking == 1)
           if Gamepad('GetButton',1,5)==1  % If key is being pressed...
                    ButtonResponse=5;
                    keepchecking = 0; % ... end while-loop.
                    RT=GetSecs-trial_start_time;
           end
           if Gamepad('GetButton',1,8)==1  % If key is being pressed...
                    ButtonResponse=8
                    keepchecking = 0; % ... end while-loop.
                    RT=GetSecs-trial_start_time;
           end
           if ((GetSecs - trial_start_time) > stim_on_time)
                keepchecking=0; %when reach the maximum stimulus presentation time, exit loop
            end
        end
        
        %determine key response mapping
        if ButtonResponse ==5
            resp=1;
        elseif ButtonResponse ==8
            resp=0;
        else
            resp = -1; %in the case of no keystroke or wrong key?
        end
        
%         if find(keyCode==1)==56
%             resp=1;
%         else
%             if find(keyCode==1)==29
%                 resp=0;
%             end
%         end
        while ((GetSecs - trial_start_time) < stim_on_time) % ensure sufficeint stimulus presentation time
        end
        DaqDOut(HID,0,0);  %Turn off
        %put up delay screen
        Screen(window,'FillRect',black);
        centertext(window,' ',20,centery-10,centerx,centery,black);
        Screen(window, 'Flip');
        starttime2=GetSecs;
        
        while (GetSecs - starttime2 < delay_time)
        end
        
        
        %determine correct or incorrect
        Screen(window,'FillRect',black);
        if resp == -1
            tr_corr = -1;
        elseif (resp+1)==trial_rand(i)
            tr_corr = 1;
        else
            tr_corr = 0;
        end
        
        % the following version will not give feedback on performance, but
        % the explicit membership
        %         if trial_rand(i)==1
        %             centertext(window,'SUNNY',60,centery-30,centerx,centery,orange);
        %             Screen(window, 'Flip');
        %         else
        %             centertext(window,'RAINY',60,centery-30,centerx,centery,grey);
        %             Screen(window, 'Flip');
        %         end
        
        if tr_corr == 1; %correct response
            centertext(window,'Correct!',60,centery-30,centerx,centery,orange);
            Screen(window, 'Flip');
        elseif tr_corr==0 && resp~=-1; %incorrect response
            centertext(window,'Incorrect!',60,centery-30,centerx,centery,grey);
            Screen(window, 'Flip');
        elseif tr_corr == -1; %no correct key stroke detected
            centertext(window,'Please respond faster!',60,centery-30,centerx,centery,white);
            Screen(window, 'Flip');
        end
        %DaqDOut(HID,0,1);  %Turn on
        starttime2=GetSecs;
        
        while (GetSecs - starttime2 < feedback_time)
        end
        %DaqDOut(HID,0,0);  %Turn off
        tr_num_cnt=tr_num_cnt+1;
        
        %%%%%% getting stuck here!!! using 0 as index!!!!!
        data_str = [data_str  '\t' num2str(trial_rand(i)) '\t' num2str(tr_corr) '\t' num2str(resp)  '\t' num2str(RT) '\t' num2str(curr_picnum) '\t' curr_pic_name '\n'];
        data_mat(tr_num_cnt).ttype=num2str(trial_rand(i));
        %        data_mat(i).tr_len=curr_tr_len;
        data_mat(tr_num_cnt).catpic=curr_picnum;
        data_mat(tr_num_cnt).resp=resp;
        data_mat(tr_num_cnt).RT=RT;
        data_mat(tr_num_cnt).cat_picname=curr_pic_name;
        data_mat(tr_num_cnt).corr=tr_corr;
        clear keyCode keyIsDown resp RT
        eval(sprintf('cd %s',data_dir));
        
        cmd = sprintf('fid = fopen(''Categorization_Data%s.txt'',''w'');',subjname);      %will call the data file datasubjname
        eval(cmd);
        fprintf(fid,data_str);
        fclose(fid);
        
        eval(sprintf('save ''Categorization_Data%s.mat'' data_mat;',subjname));
        
        eval(sprintf('cd %s',curr_dir));
        %while ((GetSecs - trial_start_time) < response_window)
        %end
        %display a randomized ITI
        Screen(window,'FillRect',black);
        centertext(window,'+',20,centery-10,centerx,centery,white);
        Screen(window, 'Flip');
        starttime2=GetSecs;
        
        while (GetSecs - starttime2 < ITIs(randi(7)))
        end
    end
    
    if j < block_num
        Screen(window,'FillRect',black);
        centertext(window,'You have completed a block of the experiment and may now take a one minute break.',20,centery-40,centerx,centery,white);
        centertext(window,'Remember to press the orange button for sunny and press the green button for rainy.',20,centery,centerx,centery,white);
        %        centertext(window,'and press the "spacebar" if any body picture is repeated.',20,centery+40,centerx,centery,white);
        Screen(window, 'Flip');
        starttime2 = GetSecs;
        while (GetSecs - starttime2 < 60)
        end
        
        
        Screen(window,'FillRect',black);
        centertext(window,'Press any button to begin the next block.',20,centery-40,centerx,centery,white);
        Screen(window, 'Flip');
        keepchecking = 1;
        while (keepchecking == 1)
            [keyIsDown,secs,keyCode] = KbCheck; % In while-loop, rapidly and continuously check if the return key being pressed.
            if(keyIsDown)  % If key is being pressed...
                keepchecking = 0; % ... end while-loop.
            end
        end
        
        
        Screen(window,'FillRect',black);
        centertext(window,'+',20,centery-10,centerx,centery,white);
        starttime2 = GetSecs;
        while (GetSecs - starttime2 < 2)
        end
    end
end

eval(sprintf('cd %s',data_dir));

cmd = sprintf('fid = fopen(''Categorization_Data%s.txt'',''w'');',subjname);      %will call the data file datasubjname
eval(cmd);
fprintf(fid,data_str);
fclose(fid);

eval(sprintf('save ''Categorization_Data%s.mat'' data_mat;',subjname));

eval(sprintf('cd %s',curr_dir));

screen('CloseAll')

