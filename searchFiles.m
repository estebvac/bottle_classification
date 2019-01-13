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
list = dir('../TrainingData/**/*.jpg');
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
        imshow(CroppedImage,[]); hold on;
        [feature, visualize] = extractHOGFeatures(CroppedImage,'CellSize',CellSizeHOG);
        plot(visualize);
        %% Getting the labels of the images
        trlabel = strsplit(list(i).name,'-');
        if k==1
            features = feature;
            trainLabels = trlabel(1);
        else
            features = [features ; feature];
            trainLabels = [trainLabels trlabel(1)];
        end
        k = k+1;
        
        %% CREATE A TEST DATA SET:
        testBottles(: , 1  : CutPoints(1) , : ,2*k-1) = ...
                                        OriginalImage(: , 1  : CutPoints(1)  , :);
        testBottles(: , 1  : 352 - CutPoints(2)+1 , : ,2*k) =...
                                        OriginalImage(: , CutPoints(2):352  , :);
    end
    %pause(0.1);  
end
%% Remove the non allocated features:
features = features(1:k-1,:);
Mdl = fitcecoc(features,trainLabels);
testBottles=testBottles(1:288,1:119,:,:);
clf;
for i=1:k*2
    TestImage = uint8(testBottles(:,:,:,i));
    [feature, visualize] = extractHOGFeatures(TestImage,'CellSize',CellSizeHOG);
    label = predict(Mdl,feature);
    imshow(TestImage,[]); hold on;
    plot(visualize);
    title(label);
    pause(1);  
end

