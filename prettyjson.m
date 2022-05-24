function less_ugly = prettyjson(ugly)
% Makes JSON strings (relatively) pretty
% Probably inefficient

    MAX_ARRAY_WIDTH = 80;
    TAB = sprintf('    ');

    % Modification to leave the {}[] as is when inside ""
    % #####################################################################
    lines = splitlines(ugly);
    for i = 1:length(lines)
        line = lines{i};

        doubleQuotes = strfind(line, '"');
        doubleQuotes = [doubleQuotes(1:2:end-1)' doubleQuotes(2:2:end)'];
        doubleQuotes = doubleQuotes(diff(doubleQuotes') > 2, :);
        mem = cell(length(doubleQuotes), 1);
        for j = 1:length(doubleQuotes)
            idx = doubleQuotes(j,1)+1:doubleQuotes(j,2)-1;
            mem{j} = line(idx);
            line(idx) = ['$' repmat('_', 1, length(idx)-2) '$'];
        end
        lines{i} = line;
    end
    ugly = strjoin(lines, newline);
    kMem = 1;
    % #####################################################################

    ugly = strrep(ugly, '{', sprintf('{\n'));
    ugly = strrep(ugly, '}', sprintf('\n}'));
    ugly = strrep(ugly, ',"', sprintf(', \n"'));
    ugly = strrep(ugly, ',{', sprintf(', \n{'));

    indent = 0;
    lines = splitlines(ugly);

    for i = 1:length(lines)
        line = lines{i};
        next_indent = 0;

        % Count brackets
        open_brackets = length(strfind(line, '['));
        close_brackets = length(strfind(line, ']'));

        open_braces = length(strfind(line, '{'));
        close_braces = length(strfind(line, '}'));

        if close_brackets > open_brackets || close_braces > open_braces
            indent = indent - 1;
        end

        if open_brackets > close_brackets
            line = strrep(line, '[', sprintf('[\n'));
            next_indent = 1;
        elseif open_brackets < close_brackets
            line = strrep(line, ']', sprintf('\n]'));
            next_indent = -1;
        elseif open_brackets == close_brackets && length(line) > MAX_ARRAY_WIDTH
            first_close_bracket = strfind(line, ']');
            if first_close_bracket > MAX_ARRAY_WIDTH % Just a long array -> each element on a new line
                line = strrep(line, '[', sprintf('[\n%s', TAB));
                line = strrep(line, ']', sprintf('\n]'));
                line = strrep(line, ',', sprintf(', \n%s', TAB)); % Add indents!
            else % Nested array, probably 2d, first level is not too wide -> each sub-array on a new line
                line = strrep(line, '[[', sprintf('[\n%s[', TAB));
                line = strrep(line, '],', sprintf('], \n%s', TAB)); % Add indents!
                line = strrep(line, ']]', sprintf(']\n]'));
            end
        end

        sublines = splitlines(line);
        for j = 1:length(sublines)
            if j > 1   % todo: dumb to do this check at every line...
                sublines{j} = sprintf('%s%s', repmat(TAB, 1, indent+next_indent), sublines{j});
            else
                sublines{j} = sprintf('%s%s', repmat(TAB, 1, indent), sublines{j});
            end
        end

        if open_brackets > close_brackets || open_braces > close_braces
            indent = indent + 1;
        end
        indent = indent + next_indent;

        % Modification to leave the {}[] as is when inside ""
        % #################################################################
        for k = 1:length(sublines)
            dollar = strfind(sublines{k}, '$');
            dollar = [dollar(1:2:end-1)' dollar(2:2:end)'];
            for j = 1:size(dollar,1)
                sublines{k}(dollar(j,1):dollar(j,2)) = mem{kMem};
                kMem = kMem + 1;
            end
        end
        % #################################################################

        lines{i} = strjoin(sublines, newline);
    end

    less_ugly = strjoin(lines, newline);
end