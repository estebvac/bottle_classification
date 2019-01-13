function [Result, bottleImage, locations, measures] = processBottleImage(inputImage)
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

measures.liquidArea = 0;
measures.brightAreaLabel = 0;
measures.darkAreaLabel = 0;
measures.labelStraightness  = 0;
measures.capArea = 0;
measures.deformedMaskRed = 0;
measures.deformedMaskGray = 0;

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
sizeLiquidArea = length(liquidArea(liquidArea < 100));
measures.liquidArea = sizeLiquidArea;

if (sizeLiquidArea < 800)
    Result.underfilled = true;
    locations.underfilled = locate(liquidArea, bottleBW, 'locateunderfill');
end
%% Over-filled:
if (sizeLiquidArea > 1600)
    Result.overfilled = true;
    locations.overfilled = locate(liquidArea, bottleBW, 'locateoverfill');
end

%% White label
[~, remBW] = getTopAndRemaining(bottleBW);
lowPart = remBW(floor(size(remBW,1)/2):end ,:);
sizeOfBrightArea = length(lowPart(lowPart>200));
measures.brightAreaLabel = sizeOfBrightArea;
if(sizeOfBrightArea > 100*65)
    Result.whiteLabel = true;
    locations.whitelabel = locate(remBW, bottleBW, 'whitelabel');
end

%% Label Missing:
newImage = red - green - blue;
    [top, remaining] = getTopAndRemaining(newImage); %Divide bottle into two parts: top is 33.33% of the image and remaining is the remaining part

darkAreaLevel = length(remaining(remaining>100));
measures.darkAreaLabel = darkAreaLevel;

if(Result.whiteLabel == false) %If label is not white, check if it is red
    if(darkAreaLevel < 50)
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
    alpha = atan(abs(p(1)))*180/pi;
    
    measures.labelStraightness  = alpha;
    if (alpha > 8)
        Result.labelNotStraight = true;
        locations.labelNotStraight = locate(BW, bottleBW, 'notstraight');
    end
end

%% Missing cap
capArea = length(top(top>100));
measures.capArea = capArea;
if(capArea < 50)
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

    
    measures.deformedMaskRed = 0;
    measures.deformedMaskGray = 0;
    
    lines = 0;
    %Analyze every line
    for i= 1:10:size(mask, 2)
        currLine = linesResult(97:214,i);
        currLineGray = bottleBW(97:214, i);
        lengthCurrLine = length(currLine(currLine>100));
        lengthGrayLine = length(currLineGray(currLineGray<80));
        
        measures.deformedMaskRed = measures.deformedMaskRed + lengthCurrLine;
        measures.deformedMaskGray = measures.deformedMaskGray + lengthGrayLine;
        if(lengthCurrLine<2 && lengthGrayLine<5)
            Result.deformed = true;
        end
        lines = lines + 1;
    end
    %Analyze last line
    lastLine = linesResult(97:214, size(mask,2));
    lastLineGray = bottleBW(97:214, size(mask,2));

    lengthCurrLine = length(lastLine(lastLine>100));
    lengthGrayLine = length(lastLineGray(lastLineGray<80));

    measures.deformedMaskRed = measures.deformedMaskRed + lengthCurrLine;
    measures.deformedMaskGray = measures.deformedMaskGray + lengthGrayLine;

    if(lengthCurrLine <2 && lengthGrayLine <5)
        Result.deformed = true;
    end
    
    if(Result.deformed)
       locations.deformed = locate(linesResult, newImage, 'deformed');
    end
    
    measures.deformedMaskRed = measures.deformedMaskRed / (lines + 1);
    measures.deformedMaskGray = measures.deformedMaskGray / (lines + 1);
    
end

if(Result.deformed && Result.labelNotStraight)
    Result.labelNotStraight = false;
end




