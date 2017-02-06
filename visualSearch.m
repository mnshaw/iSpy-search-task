function visualSearch(subID) 
    subID=num2str(subID);

    % Load experiment parameters
%     settingsVisualSearch


    uniqueEffScore=0; % out of 6 pins
    correctEffScore=0; % total clicks on pins
    distractorClicks=0; % total clicks on non-pins
    
    % Screen setup
    clear screen
    backgroundColor=0;
    textColor=255;
    whichScreen = max(Screen('Screens'));
    [window1, rect] = Screen('Openwindow',whichScreen,backgroundColor,[0 0 1000 663],[],2);
    slack = Screen('GetFlipInterval', window1)/2;
    W=rect(RectRight); % screen width
    H=rect(RectBottom); % screen height
    Screen(window1,'FillRect',backgroundColor);
    Screen('Flip', window1);
    Screen('Preference', 'ConserveVRAM', window1);
    
    boxWidth = W/15; % side length of the square around the pins
    pinCoords = [W/9 H/23; % top left corner of square around pins
        W/1.63 H/10;
        W/2.08 H/2.6;
        W/1000 H/1.98;
        W/3.05 H/1.95;
        W/1.185 H/2.22];
    pinClickMat = [0 0 0 0 0 0]; % if pin has been clicked, 1
    
    % Pin 1: 119, 34; 173, 83
    % Pin 2: 624, 75; 668, 125
    % Pin 3: 491, 268; 538, 313
    % Pin 4: 1.5, 338; 63, 394
    % Pin 5: 335, 351; 382, 399
    % Pin 6: 856, 308; 893, 358
    
    pinBoxes = [pinCoords pinCoords(:,1)+(boxWidth) pinCoords(:,2)+(boxWidth)];
    

    resultsFolder = 'results';
    outputfile = fopen([resultsFolder '/VisualSearch_sub' num2str(subID) '.txt'],'a');
    display(outputfile);
    fprintf(outputfile, 'subID\t Unique\t Corr.\t Distr.\t Correct Ratio\t\n');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Run the experiment
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Hide cursor to start the experiment
    HideCursor(window1);

    % Start screen
    Screen('TextSize',window1,20);
    Screen('DrawText',window1,'Welcome to iSpy Visual Search', W/2 - W/4, H/4, textColor);
    Screen('DrawText',window1,'<Press Space to start>',W/2 - W/4,H/2,textColor);
    Screen('Flip',window1)

    % Wait for subject to press spacebar
    while 1
        [keyIsDown,secs,keyCode] = KbCheck;
        if keyCode(KbName('space'))==1
            break
        end
    end
    
    % Screen priority
    Priority(MaxPriority(window1));
    Priority(2);
  
    Screen('BlendFunction', window1, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    ispyIm=imread(fullfile('Images/ispy1.jpg'));
    ispyImTarg = Screen('MakeTexture', window1, ispyIm);
    
    [circleIm, ~, transparency] = imread(fullfile('Images/greenCircle.png'));
    circleIm(:,:,4) = transparency;
    circleImTarg = Screen('MakeTexture', window1, circleIm);
    
    imageSize = size(ispyIm);
    
    posTarg = [0 0 W H];
    
    Screen(window1, 'FillRect', backgroundColor);
    Screen('DrawTexture', window1, ispyImTarg, [], posTarg);
    %Screen('DrawTexture', window1, circleImTarg, [], posCircle);
    
    clicks = 0;
    tic % Reset the clock
    SetMouse(W/2,H/2,window1);
    ShowCursor('CrossHair',window1);
    [mouse_x,mouse_y,buttons]=GetMouse(window1);

    Screen('Flip', window1);
    while clicks < 6;
        distractor = true;
        [click,mouse_x,mouse_y,buttons]=GetClicks(window1,0);
        if (click == 1)
            clicks = clicks + 1;
        end
        RT = toc;
        display([mouse_x, mouse_y, buttons, RT, clicks]);
        
        for i=1:length(pinCoords)
            if (mouse_x > pinCoords(i, 1) && mouse_y > pinCoords(i, 2) ...
                && mouse_x < pinCoords(i, 1) + boxWidth ...
                && mouse_y < pinCoords(i, 2) + boxWidth)
                if (pinClickMat(i) == 0)
                    uniqueEffScore = uniqueEffScore + 1;
                    pinClickMat(i) = 1;
                end
                correctEffScore = correctEffScore + 1;
                distractor = false;
                Screen(window1, 'FillRect', backgroundColor);
                Screen('DrawTexture', window1, ispyImTarg, [], posTarg);
                Screen('DrawTexture', window1, circleImTarg, [], pinBoxes(i,:));
                Screen('Flip', window1);
                display('Pin click');
                WaitSecs(1.00);
                Screen(window1, 'FillRect', backgroundColor);
                Screen('DrawTexture', window1, ispyImTarg, [], posTarg);
                Screen('Flip', window1);
            end
        end
        if distractor
            distractorClicks = distractorClicks + 1;
            display('Distractor click');
        end
    end  
     
    display(uniqueEffScore);
    display(correctEffScore);
    display(distractorClicks); 
    WaitSecs(2.00)
    
    correctEffRatio = correctEffScore/(distractorClicks + correctEffScore);
    display(correctEffRatio);  
    
    
    fprintf(outputfile, '%s\t %d\t %d\t %d\t %f\t\n', ...
        subID, uniqueEffScore, correctEffScore, distractorClicks, ...
        correctEffRatio);

    Screen('CloseAll')


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Draw a fixation cross (overlapping horizontal and vertical bar)
function drawCross(window,W,H)
    barLength = 16; % in pixels
    barWidth = 2; % in pixels
    barColor = 255; % number from 0 (black) to 255 (white) 
    Screen('FillRect', window, barColor,[ (W-barLength)/2 (H-barWidth)/2 (W+barLength)/2 (H+barWidth)/2]);
    Screen('FillRect', window, barColor ,[ (W-barWidth)/2 (H-barLength)/2 (W+barWidth)/2 (H+barLength)/2]);
end