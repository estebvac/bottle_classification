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
CellSizeHOG = [16 8]; %[16 8];
%% OPEN EACH FILE
for i= 1: number_of_files(1,1)
    %% READING ALL THE IMAGES
    filename = [list(i).folder '\'   list(i).name];
    OriginalImage = imread(filename);
    BottleImage = rgb2gray(OriginalImage);
    %% FIND THE BOTTLES
    Result = processBottleImage(OriginalImage);
    figure(1);imshow(OriginalImage);
    bottleLabel = getLabel(Result);
    title(bottleLabel);
    pause(2);
end

