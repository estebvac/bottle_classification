function [label] = getLabel(Result)

    label = [];

    if Result.bottlePresent == 0
        label = 'No Bottle';
    else
        label = 'Yes Bottle';
    end

    if Result.underfilled == 1
        label = [label ' underfilled '];
    end

    if Result.overfilled == 1
        label = [label ' overfilled '];
    end

    if Result.labelMissing == 1
        label = [label ' labelMissing '];
    end

    if Result.whiteLabel == 1
        label = [label ' whiteLabel '];
    end

    if Result.labelNotStraight == 1
        label = [label ' labelNotStraight '];
    end

    if Result.missingCap == 1
        label = [label ' missingCap '];
    end

    if Result.deformed == 1
        label = [label ' deformed '];
    end
end

