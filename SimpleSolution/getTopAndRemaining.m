function [top, remaining] = getTopAndRemaining(currImage)

m = size(currImage, 1); %number of rows

%Separate the image into three subimages:
limits = linspace(1,m,5);
top = currImage(limits(1):floor(limits(2)), :, :);
remaining = currImage(floor(limits(2))+1:m, :, :);