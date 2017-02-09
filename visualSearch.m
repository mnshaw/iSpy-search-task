function visualSearch(subID, timeout) 
    subID=num2str(subID);
    
    % Default timeout is 3 minutes
    if nargin < 2
        timeout = 180;
    end

    uniqueEffScore=0; % out of 6 pins
    correctEffScore=0; % total clicks on pins
    distractorClicks=0; % total clicks on non-pins
    
    % Screen setup
    clear screen
    backgroundColor=0;
    textColor=255;
    whichScreen = max(Screen('Screens'));
    [window1, rect] = Screen('Openwindow',whichScreen,backgroundColor,[0 0 1000 663],[],2);
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
    
    finalTime = timeout;

    pinBoxes = [pinCoords pinCoords(:,1)+(boxWidth) pinCoords(:,2)+(boxWidth)];

    % Make output file
    resultsFolder = 'results';
    outputfile = fopen([resultsFolder '/VisualSearch_sub' subID '.txt'],'a');
    display(outputfile);
    fprintf(outputfile, 'subID\t Time\t Unique\t Corr.\t Distr.\t Correct Ratio\t\n');
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
    
    % Display iSpy image
    ispyIm=imread(fullfile('Images/ispy1.jpg'));
    ispyImTarg = Screen('MakeTexture', window1, ispyIm);
    
    [circleIm, ~, transparency] = imread(fullfile('Images/circle.png'));
    circleIm(:,:,4) = transparency;
    circleImTarg = Screen('MakeTexture', window1, circleIm);
        
    posTarg = [0 0 W H];
    
    Screen(window1, 'FillRect', backgroundColor);
    Screen('DrawTexture', window1, ispyImTarg, [], posTarg);
    
    clicks = 0;
    pinClicks = 0;
    distractorClicks = 0;

    tic % Reset the clock

    SetMouse(W/2,H/2,window1);
    ShowCursor('CrossHair',window1);
    [mouse_x,mouse_y,buttons] = GetMouse(window1);
    
    started = false;
    
    timeoutTimer = timer;
    timeoutTimer.StartDelay = timeout;
    timeoutTimer.TimerFcn = @(~,~) endTest(window1, W, H);

    Screen('Flip', window1);

    while 1
        distractor = true;
        try
            [click, mouse_x, mouse_y, ~] = GetClicks(window1, 0);
        catch ME
            break;
        end
        
        if (click == 1)
            clicks = clicks + 1;
        end
        
        % Check if clicked in each of the pins
        for i=1:length(pinCoords)
            if (mouse_x > pinCoords(i, 1) && mouse_y > pinCoords(i, 2) ...
                && mouse_x < pinCoords(i, 1) + boxWidth ...
                && mouse_y < pinCoords(i, 2) + boxWidth)

                % Begin the timer when pin 4, the 'start' pin, is clicked
                if (i == 4) && (~started)
                    started = true;
                    start(timeoutTimer);
                    tic;
                    t = tic;
                end
            
                % If the pin has not been clicked already, increase unique
                % efficiency score
                if (pinClickMat(i) == 0)
                    uniqueEffScore = uniqueEffScore + 1;
                    pinClickMat(i) = 1;
                end
                
                % A click on a pin increases the correct efficiency score
                correctEffScore = correctEffScore + 1;
                
                % Show this was a click on a pin, not a distractor
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

                % All pins have been clicked
                if sum(pinClickMat) == 6
                    delete(timeoutTimer);
                    finalTime = toc;
                    endTest(window1, W, H);
                    break;
                end
                
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
    WaitSecs(1.00)
    
    correctEffRatio = correctEffScore/(distractorClicks + correctEffScore);
    display(correctEffRatio);  
    
    % print values to the output file
    fprintf(outputfile, '%s\t %0.2f\t %d\t %d\t %d\t %f\t\n', ...
        subID, finalTime, uniqueEffScore, correctEffScore, ...
        distractorClicks, correctEffRatio);


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