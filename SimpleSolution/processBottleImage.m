function [Result, bottleImage, locations] = processBottleImage(inputImage)
%Function to process an image and say if it has cap or not, if label is there, etc
%Inputs:
%       inputImage: jpg image of three bottles
%Outputs:
%       Result: structure with different fields for each feature

%% First, set all parameters to false;
Result.bottlePresent = true;
Result.underfilled = false;
Result.overfilled = false;
Result.labelMissing = false;
Result.whiteLabel = false;
Result.labelNotStraight = false;
Result.missingCap = false;
Result.deformed = false;

locations.underfilled = [];
locations.overfilled = [];
locations.labelMissing = [];
locations.whiteLabel = [];
locations.labelNotStraight = [];
locations.missingCap = [];
locations.deformed = [];

%% Extract bottle in the middle and extract channels
[bottleImage, ~] = FindBottle(inputImage);
if(isnan(bottleImage))
   Result.bottlePresent = false;
   return;
end

% Get channels of the image
red = bottleImage(:,:,1);
green = bottleImage(:,:,2);
blue = bottleImage(:,:,3);

bottleBW = rgb2gray(bottleImage);

%% Now process every feature

%% Under-filled: 
[~, remainingBottle] = getTopAndRemaining(bottleBW);
liquidArea = remainingBottle(1:95,30:80);
if (length(liquidArea(liquidArea < 100)) < 800)
    Result.underfilled = true;
    locations.underfilled = locate(liquidArea, bottleBW, 'locateunderfill');
end
%% Over-filled:
if (length(liquidArea(liquidArea < 100)) > 1600) %1500
    Result.overfilled = true;
    locations.overfilled = locate(liquidArea, bottleBW, 'locateoverfill');
end

%% White label
[~, remBW] = getTopAndRemaining(bottleBW);
lowPart = remBW(floor(size(remBW,1)/2):end ,:);
if(length(lowPart(lowPart>200)) > 100*65)
    Result.whiteLabel = true;
    locations.whitelabel = locate(remBW, bottleBW, 'whitelabel');
end

%% Label Missing:
newImage = red - green - blue;
    [top, remaining] = getTopAndRemaining(newImage); %Divide bottle into two parts: top is 33.33% of the image and remaining is the remaining part
if(Result.whiteLabel == false) %If label is not white, check if it is red
    if(length(remaining(remaining>100)) < 50)
        Result.labelMissing = true;
        locations.labelMissing = locate(remBW, bottleBW, 'labelnotlocated');
    end
end

%% Label not straight
if (Result.labelMissing == false && Result.whiteLabel == false && Result.deformed == false)
    [Label,~] = redThreshhold(bottleImage);
    Label(230:end,:) = 1; 
    stats = regionprops(Label, 'Area');
    indexMax = 1;
    for i = 1:length(stats)
        if (stats(i).Area > stats(indexMax).Area)
            indexMax = i;
        end
    end
    cc = bwlabel(Label);
    Label = bwareaopen(cc,stats(indexMax).Area -10);
    se = strel('diamond',20); 
    Label = imdilate(Label,se);
    Label = imfill(Label,'holes');
    BW = edge(Label,'canny');

    [y, x] = find(BW);
    p = polyfit(x,y,1);
    x1 = 0:200;
    y1 = polyval(p,x1);
%     figure(2);    imshow(BW); hold on;
%     plot(x1,y1, 'LineWidth',2)
    atan(abs(p(1)))*180/pi
    if (atan(abs(p(1)))*180/pi > 5 )
        Result.labelNotStraight = true;
        locations.labelNotStraight = locate(BW, bottleBW, 'notstraight');
    end
end

%% Missing cap
if(length(top(top>100)) < 50)
    Result.missingCap = true;
    locations.missingCap = locate(top, bottleBW, 'missingCap');
end

%% Deformed bottle
if(~Result.whiteLabel && ~Result.labelMissing) %If label is not white (only deformed bottles with red label are recognized)
    %Create mask of the size of the bottle image
    mask = zeros(size(bottleBW));
    %Create some lines in the mask
    for i = 1:10:size(mask,2)
       mask(97:214,i) = ones(118,1); 
    end
    %ensure that there is a line at the end
    mask(97:214, size(mask,2)) =ones(118,1); 

    %Apply mask to red channel based image
    linesResult = mask.*double(newImage);

    %Analyze every line
    for i= 1:10:size(mask, 2)
        currLine = linesResult(97:214,i);
        currLineGray = bottleBW(97:214, i);
        if(length(currLine(currLine>100))<2 && length(currLineGray(currLineGray<80))<5)
            Result.deformed = true;
        end
    end
    %Analyze last line
    lastLine = linesResult(97:214, size(mask,2));
    lastLineGray = bottleBW(97:214, size(mask,2));
    if(length(lastLine(lastLine>100))<2 && length(lastLineGray(lastLineGray<80))<5)
        Result.deformed = true;
    end
    
    if(Result.deformed)
       locations.deformed = locate(linesResult, newImage, 'deformed');
    end
    
end

if(Result.deformed && Result.labelNotStraight)
    Result.labelNotStraight = false;
end




