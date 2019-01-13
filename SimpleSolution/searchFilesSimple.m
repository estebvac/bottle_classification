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
testBottles=zeros(288,119,3,number_of_files(1,1)*2);
k = 1;

measures.liquidArea = zeros(1,  number_of_files(1,1));
measures.brightAreaLabel = zeros(1,  number_of_files(1,1));
measures.darkAreaLabel = zeros(1,  number_of_files(1,1));
measures.labelStraightness  = zeros(1,  number_of_files(1,1));
measures.capArea = zeros(1,  number_of_files(1,1));
measures.deformedMaskRed = zeros(1,  number_of_files(1,1));
measures.deformedMaskGray = zeros(1,  number_of_files(1,1));

%% OPEN EACH FILE
for i= 1: number_of_files(1,1)
    %% READING ALL THE IMAGES
    filename = [list(i).folder '\'   list(i).name];
    OriginalImage = imread(filename);
    %% FIND THE BOTTLES
    [Result, bottleImage, locations, obtainedMeasures] = processBottleImage(OriginalImage);

    measures.liquidArea(i) = obtainedMeasures.liquidArea;
    measures.brightAreaLabel(i) = obtainedMeasures.brightAreaLabel;
    measures.darkAreaLabel(i) = obtainedMeasures.darkAreaLabel;
    measures.labelStraightness(i)  = obtainedMeasures.labelStraightness;
    measures.capArea(i) = obtainedMeasures.capArea;
    measures.deformedMaskRed(i) = obtainedMeasures.deformedMaskRed;
    measures.deformedMaskGray(i) = obtainedMeasures.deformedMaskGray;

    %figure(1);imshow(OriginalImage);
    %bottleLabel = getLabel(Result);
    %title(bottleLabel);
    %pause(2);
end

