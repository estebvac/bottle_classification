function [faults, mostlikely, bottleImage, locations, hogvisualization] = analyseImage(Image, mdl)
addpath('SimpleSolution');
CellSizeHOG = [16 8];

[bottleImage,~] = FindBottle(Image);

[faults, ~, locations] = processBottleImage(Image);
if (faults.bottlePresent)
    [feature, hogvisualization] = ...
        extractHOGFeatures(bottleImage,'CellSize',CellSizeHOG);
    mostlikely = predict(mdl,feature);
    mostlikely = classifyMostLikely(mostlikely);
    
else
    mostlikely = '';
    hogvisualization = [];
end

end

function result = classifyMostLikely(mostLikely)

    switch mostLikely{1}
        case 'underfilled'
            result = 'Under-filled';
        case 'overfilled'
            result = 'Over-filled';
        case 'nolabel'
            result = 'Label missing';
        case 'nolabelprint'
            result = 'Printing failed';
        case 'labelnotstraight'
            result = 'Label not straight';
        case 'capmissing'
            result = 'Cap missing';
        case 'deformedbottle'
            result = 'Deformed';
        otherwise
            result = 'Normal';
    end
end

