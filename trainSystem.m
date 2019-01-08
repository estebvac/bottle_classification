function [Mdl] = trainSystem(path)

%% READ FULL DIRECTORY

displayImages = 0;

list = dir(strcat(path, '/**/*.jpg'));
number_of_files = size(list);
labels = zeros(size(list));
k = 1;
CellSizeHOG = [16 8]; %[16 8];
%% OPEN EACH FILE
for i= 1: number_of_files(1,1)
    %% READING ALL THE IMAGES
    filename = [list(i).folder '\'   list(i).name];
    OriginalImage = imread(filename);
    %% FIND THE BOTTLES
    [CroppedImage,CutPoints] =FindBottle(OriginalImage);
    if (displayImages)
    %% PLOT THE RESULT
        subplot(1,2,1)

        imshow(OriginalImage,[]);
        title(list(i).name)
    end
    if(~isnan(CutPoints))
        [feature, visualize] = extractHOGFeatures(CroppedImage,'CellSize',CellSizeHOG);
        if (displayImages)
            line([CutPoints(1),CutPoints(1)],[CutPoints(3),CutPoints(4)]);
            line([CutPoints(2),CutPoints(2)],[CutPoints(3),CutPoints(4)]);
            subplot(1,2,2)
            imshow(CroppedImage,[]); hold on;
            plot(visualize);
        end
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
    end
end
%% Remove the non allocated features:
features = features(1:k-1,:);
Mdl = fitcecoc(features,trainLabels);

end

