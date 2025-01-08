% Famous Faces Experiment 
% Screen setup
screenNumber = max(Screen('Screens'));
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% Open a window
[window, windowRect] = Screen('OpenWindow', screenNumber, grey);

% Screen size
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Fixation cross parameters
fixCrossDimPix = 20;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
lineWidthPix = 4;

% Load face images (ensure famous and non-famous images are in separate folders)
famousFolder = '/Users/raphaelsemiz/Desktop/Coding/Introduction/abgabe/famous '; 
nonFamousFolder = '/Users/raphaelsemiz/Desktop/Coding/Introduction/abgabe/non famous'; 
famousFiles = dir(fullfile(famousFolder, '*.jpg'));
nonFamousFiles = dir(fullfile(nonFamousFolder, '*.jpg'));

% Combine famous and non-famous faces
allFiles = [famousFiles; nonFamousFiles];
numTrials = length(allFiles);
isFamous = [ones(length(famousFiles), 1); zeros(length(nonFamousFiles), 1)];

% Randomize trial order
trialOrder = randperm(numTrials);
allFiles = allFiles(trialOrder);
isFamous = isFamous(trialOrder);

% Reaction time storage
reactionTimes = NaN(numTrials, 1);

% Start experiment
for trial = 1:numTrials
    % Fixation cross
    Screen('DrawLines', window, allCoords, lineWidthPix, black, [screenXpixels / 2, screenYpixels / 2]);
    Screen('Flip', window);
    WaitSecs(0.5); % Show fixation cross for 500ms

    % Jittered "noisy square"
    jitterTime = 0.3 + rand * 0.5; % Random time between 300-800ms
    noisySquare = rand(screenYpixels, screenXpixels) * 255; % Random noise
    noisyTexture = Screen('MakeTexture', window, noisySquare);
    Screen('DrawTexture', window, noisyTexture, [], []);
    Screen('Flip', window);
    WaitSecs(jitterTime);

    % Display face image
    img = imread(fullfile(allFiles(trial).folder, allFiles(trial).name));
    imgTexture = Screen('MakeTexture', window, img);
    Screen('DrawTexture', window, imgTexture, [], []);
    vbl = Screen('Flip', window); % Get the timestamp for reaction timing
    tStart = GetSecs;

    % Wait for response
    responded = false;
    while GetSecs - tStart < 1.0 % Show image for max 1 second
        [keyIsDown, keyTime, keyCode] = KbCheck;
        if keyIsDown && keyCode(KbName('space')) % If spacebar is pressed
            if isFamous(trial) == 1 % Correct response only for famous face
                reactionTimes(trial) = keyTime - vbl;
            end
            responded = true;
            break;
        end
    end

    % Clear screen after response or timeout
    Screen('Flip', window);
    WaitSecs(0.5); % Inter-trial interval (500ms)

    % Feedback 
    if responded && isFamous(trial) == 1
        disp(['Correct response on trial ' num2str(trial) ' with RT: ' num2str(reactionTimes(trial)) ' seconds']);
    elseif responded && isFamous(trial) == 0
        disp(['Incorrect response on trial ' num2str(trial)]);
    elseif ~responded && isFamous(trial) == 1
        disp(['Missed response on trial ' num2str(trial)]);
    end
end

% Close the screen
sca;

% Display results
disp('Reaction times for famous faces:');
disp(reactionTimes(~isnan(reactionTimes)));

% Calculate average reaction time
averageRT = mean(reactionTimes(~isnan(reactionTimes)));
disp(['Average reaction time: ' num2str(averageRT) ' seconds']);
