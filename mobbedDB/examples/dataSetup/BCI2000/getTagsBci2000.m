function tags = getBCI2000Tags(run)
%% Return a cell array of tags corresponding to a specified run

    switch run
        case 1
            tags = {'BCI2000', 'eyes open', 'no movement'};
        case 2
            tags = {'BCI2000', 'eyes closed', 'no movement'};
        case {3, 7, 11}
            tags = {'BCI2000', 'fist', 'real movement', 'left-right', 'open-close'};
        case {4, 8, 12}
            tags = {'BCI2000', 'fist', 'imagined movement', 'left-right', 'open-close'};
        case {5, 9, 13}
            tags = {'BCI2000', 'fist', 'foot', 'real movement', 'open-close'};
        case {6, 10, 14}
            tags = {'BCI2000', 'fist', 'foot', 'real movement', 'open-close'}; 
        otherwise
            tags = {'BCI2000'};
    end
end

