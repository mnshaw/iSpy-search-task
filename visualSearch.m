function visualSearch() 
%     subID=num2str(subID);

    % Load experiment parameters
%     settingsVisualSearch


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
    % Pin 1: 119, 34; 173, 83
    % Pin 2: 624, 75; 668, 125
    % Pin 3: 491, 268; 538, 313
    % Pin 4: 1.5, 338; 63, 394
    % Pin 5: 335, 351; 382, 399
    % Pin 6: 856, 308; 893, 358
    
    pinBoxes = [pinCoords pinCoords(:,1)+(boxWidth) pinCoords(:,2)+(boxWidth)];
    
    %TODO: save results
    % Set up the output file
%     resultsFolder = 'results';
%     outputfile = fopen([resultsFolder '/VisualSearch_' num2str(subID) '_session' num2str(sessionNum) '.txt'],'a');
    %     fprintf(outputfile, 'subID\t imageTarget\t disFace1\t disFace2\t disFace3\t session\t targDir\t probeDir\t trial\t accuracy\t RT\n');

    
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
    
    [circleIm, ~, transparency] = imread(fullfile('Images/circle.png'));
    circleIm(:,:,4) = transparency;
    circleImTarg = Screen('MakeTexture', window1, circleIm);
    
    imageSize = size(ispyIm);
    
    posTarg = [0 0 W H];
    
    Screen(window1, 'FillRect', backgroundColor);
    Screen('DrawTexture', window1, ispyImTarg, [], posTarg);
    
    timeout = 10;
    clicks = 0;
    pinClicks = 0;
    distractorClicks = 0;
    SetMouse(W/2,H/2,window1);
    ShowCursor('CrossHair',window1);
    [mouse_x,mouse_y,buttons]=GetMouse(window1);
    
    timeoutTimer = timer;
    timeoutTimer.StartDelay = timeout;
    timeoutTimer.TimerFcn = @(~,~) endTest(window1, W, H);

    Screen('Flip', window1);
    while 1
        
        distractor = true;
        try
            [click,mouse_x,mouse_y,buttons]=GetClicks(window1,0);
        catch ME
            break;
        end
        
        if (click == 1)
            clicks = clicks + 1;
        end
        
        for i=1:length(pinCoords)
            if (mouse_x > pinCoords(i, 1) && mouse_y > pinCoords(i, 2) ...
                && mouse_x < pinCoords(i, 1) + boxWidth ...
                && mouse_y < pinCoords(i, 2) + boxWidth)
            
                if (i == 4)
                    display('started');
                    start(timeoutTimer);
                end
            
                pinClicks = pinClicks + 1;
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
     
    display([pinClicks, distractorClicks]); 


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Draw a fixation cross (overlapping horizontal and vertical bar)
function drawCross(window, W, H)
    barLength = 16; % in pixels
    barWidth = 2; % in pixels
    barColor = 255; % number from 0 (black) to 255 (white) 
    Screen('FillRect', window, barColor,[ (W-barLength)/2 (H-barWidth)/2 (W+barLength)/2 (H+barWidth)/2]);
    Screen('FillRect', window, barColor ,[ (W-barWidth)/2 (H-barLength)/2 (W+barWidth)/2 (H+barLength)/2]);
end

function endTest(window, W, H)
    Screen('TextSize',window,20);
    Screen('DrawText',window,'The test has ended', W/2 - W/4, H/4, 255);
    Screen('Flip',window);
    WaitSecs(2.00);
    Screen('CloseAll');
end