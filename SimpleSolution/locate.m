function [location] = locate(image,orig, characteristic)

    switch characteristic
        case 'whitelabel'
            location = locateWhiteLabel(image, orig);
        case 'notstraight'
            location = locateNotStraight(image, orig);
        case 'labelnotlocated'
            location = labelNotLocated(orig);
        case 'locateunderfill'
            [~, remaining] = getTopAndRemaining(orig);
            location = locateFill(image, remaining, orig);
        case 'locateoverfill'
            [~, remaining] = getTopAndRemaining(orig);
            location = locateFill(image, remaining, orig);
        case 'missingCap'
            location = missingCap(image, orig);
    end
end

function square = locateWhiteLabel(image, orig)
    binarized = imbinarize(image, 200.0/250);

    %scan to locate the whole area.
    rows = size(binarized, 1);
    cols = size(binarized, 2);
    half = round(rows/2.0);
    bottom = 0;
    x = 2;
    w = cols - 3;
    h = 1;
    for i = half : rows
        level = sum(binarized(i, :));
        if level < (cols/2)
           break; 
        end
        bottom = i;
        h = h + 1;
    end

    for i = half : -1 : 0
        level = sum(binarized(i, :));
        if level < (cols/2)
           break; 
        end
        h = h + 1;
    end
    y = size(orig, 1) - (rows - bottom);
    y = y - h;
    
    square = [x y w h];
end

function square = locateNotStraight(image, orig)

    rowsOrig = size(orig, 1);
    rowsDest = size(image, 1);
    st = regionprops(image, 'BoundingBox', 'Area' );
    square = st.BoundingBox;
    square(2) = square(2) + 20;
end

function square = labelNotLocated(orig)
    colsOrig = size(orig, 2);
    square = [2 round(colsOrig/2.0)+100 colsOrig-3 100]
end

function square = locateFill(image, rest ,orig)
    cols = size(orig, 1);
    bottom = 1;
    binarized = imbinarize(image, 100.0/255.0);
    for bottom = 1 : size(image, 1)
        level = sum(binarized(bottom, :));
        if level < (size(image, 2)/2)
           break; 
        end
    end
    diff = size(orig,1) - size(rest, 1);
    if (bottom < size(image, 1))
        square = [2 diff+bottom-10 size(orig, 2)-3 20];
    else
        square = [2 diff size(orig, 2)-3 90];
    end
end

function square = missingCap(image, orig)
    square = [12 2 size(orig, 2)-24 size(image,1)];
end
