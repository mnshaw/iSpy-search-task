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
    
    ispyIm=imread(fullfile('Images/ispy1.jpg'));
    ispyImTarg = Screen('MakeTexture', window1, ispyIm);
    
    circleIm = imread(fullfile('Images/greenCircle.png'));
    circleImTarg = Screen('MakeTexture', window1, circleIm);
    
    imageSize = size(ispyIm);
    
    posTarg = [0 0 W H];
    posCircle = [W/3 H/3 (W/3)+256 (H/3)+256];
    
    Screen(window1, 'FillRect', backgroundColor);
    Screen('DrawTexture', window1, ispyImTarg, [], posTarg);
    Screen('DrawTexture', window1, circleImTarg, [], posCircle);
    
    Screen('Flip', window1);
    
    WaitSecs(10.00)
        

    % Show fixation cross
    fixationDuration = 0.500; % Length of fixation in seconds
    drawCross(window1,W,H);
    tFixation = Screen('Flip', window1);

    % Blank screen
    Screen(window1, 'FillRect', backgroundColor);
    Screen('Flip', window1, tFixation + fixationDuration - slack,0);


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