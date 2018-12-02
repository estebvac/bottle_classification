function Result = processBottleImage(inputImage)
%Function to process an image and say if it has cap or not, if label is there, etc
%Inputs:
%       inputImage: jpg image of three bottles
%Outputs:
%       Result: structure with different fields for each feature

%% Extract bottle in the middle and extract channels
[bottleImage, ~] = FindBottle(inputImage);
if(isnan(bottleImage))
   Result.bottlePresent = false;
   return;
end

%In case are useful later
red = bottleImage(:,:,1);
green = bottleImage(:,:,2);
blue = bottleImage(:,:,3);

bottleBW = rgb2gray(bottleImage);


%% First, set all parameters to false;
Result.bottlePresent = true;
Result.underfilled = false;
Result.overfilled = false;
Result.labelMissing = false; %Done
Result.whiteLabel = false; %Done
Result.labelNotStraight = false;
Result.missingCap = false;   %Done
Result.deformed = false;

%% Now process every feature

%Under-filled: 

%Over-filled:

%White label
[~, remBW] = getTopAndRemaining(bottleBW);
lowPart = remBW(floor(size(remBW,1)/2):end ,:);
if(length(lowPart(lowPart>200)) > 100*65)
    Result.whiteLabel = true;
end

%Label Missing:
newImage = red - green - blue;
    [top, remaining] = getTopAndRemaining(newImage); %Divide bottle into two parts: top is 33.33% of the image and remaining is the remaining part
if(Result.whiteLabel == false) %If label is not white, check if it is red
    if(length(remaining(remaining>100)) < 50)
        Result.labelMissing = true;
    end
end

%Label not straight


%Missing cap
if(length(top(top>100)) < 50)
    Result.missingCap = true;
end

%Deformed bottle



