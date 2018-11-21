%% IMAGE PROCESSING PROJECT BEGINNING
%% Labels that will be used for the bottles
% 1. Underfilled
% 2. Overfilled
% 3. No Label
% 4. No Label Print
% 5. Label Not Straight
% 6. Cap Missing
% 7. Defformed Bottle

clc;
clear all;
close all;
%% READ FULL DIRECTORY
list = dir('**/*.jpg');
number_of_files = size(list);
labels = zeros(size(list));
 
%% OPEN EACH FILE
for i= 1: number_of_files(1,1)
    %% READING ALL THE IMAGES
    filename = [list(i).folder '\'   list(i).name];
    OriginalImage = imread(filename);
    BottleImage = rgb2gray(OriginalImage);
    %% FIND THE BOTTLES
    [CroppedImage,CutPoints] =FindBottle(OriginalImage);
    %% PLOT THE RESULT
    clf
    subplot(1,2,1)
    imshow(OriginalImage,[]);
    title(list(i).name)
    if(~isnan(CutPoints))
        line([CutPoints(1),CutPoints(1)],[CutPoints(3),CutPoints(4)]);
        line([CutPoints(2),CutPoints(2)],[CutPoints(3),CutPoints(4)]);
        subplot(1,2,2)
        imshow(CroppedImage,[]);
    end
    pause(0.1);  
    
end