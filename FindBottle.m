function [CroppedImage,CutPoints] = FindBottle(OriginalImage)

    BottleImage = rgb2gray(OriginalImage);
    %% TAKE THE TAPS OF THE BOTTLES AND THRESHOLD
    CheckTOP = BottleImage(1:40,:);
    CheckTOP = CheckTOP<180;
    %% DILATE THE IMAGE AND FILL HOLES 
    se = strel('disk',15);
    CheckTOP = imdilate(CheckTOP,se);
    CheckTOP = imfill(CheckTOP,'holes');
    %CheckTOP = imerode(CheckTOP,se);
    %% TAKE THE MEDIUM POINT AS REFERENCE
    midPoint = size(CheckTOP)/2;
    rightPoint = midPoint(2);
    leftPoint = midPoint(2);    
    %% MOVE UNTIL FIND A CHANGE RIGHT AND LEFT
    while( CheckTOP(midPoint(1),rightPoint) == CheckTOP(midPoint(1),midPoint(2) ) )
        rightPoint=rightPoint+1;
    end
    while( CheckTOP(midPoint(1),leftPoint) == CheckTOP(midPoint(1),midPoint(2) ) )
        leftPoint=leftPoint-1;
    end
    %% CHECK IF THE DISTANCE BELONGS TO A BOTTLE OR A GAP
    bottleSize=120;
    if((rightPoint-leftPoint)> bottleSize*.70 && CheckTOP(midPoint(1),midPoint(2) ) == 0)
        CroppedImage= nan;
        CutPoints = nan;
    else
        bottleCenter = round((rightPoint + leftPoint)/2);
        CroppedImage = imcrop(OriginalImage,[bottleCenter-bottleSize/2,0,bottleSize,288]);
        CutPoints = [bottleCenter-bottleSize/2,bottleCenter+bottleSize/2,...
                     0,288];
    end
end
