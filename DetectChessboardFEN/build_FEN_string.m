function FEN = build_FEN_string(Cells) 
    %Cells must contain the 'pieceClass' and the 'pieceColor'
    
    %FEN encoding:
    %Whites KQRBNP
    %Blacks kqrbnp
    
    if size(Cells,2) ~= 64
        FEN = "";
    else
        FEN = '';
        cond = false; %TRUE if one row-string is not successful
        for r = 1:8
            row = Cells(r:8:64);
            str_row = build_FEN_row(row);
            if ~cond && ~isempty(str_row)
                FEN = strcat(FEN,str_row,'/');
            else
                cond = true;
            end
        end
        if ~cond
            FEN = FEN(1:length(FEN)-1); %remove last '/'
            FEN = strcat(FEN,' - 0 1');
            FEN = string(FEN);
        end
    end
end

function str_row = build_FEN_row(row)
    str_row = '';
    for c = 1:8
        str_cell = get_FEN_character(row(c));
        str_row = strcat(str_row,str_cell);
    end
    if size(find(str_row=='0'),2) > 0
        str_row = '';
    else
        count_empty = 0;
        index_empty_start = 0;
        index = 1;
        while index <= length(str_row)
            if str_row(index) == 'e'
                count_empty = count_empty + 1;
                if index_empty_start == 0
                    index_empty_start = index;
                end
            else
                if count_empty ~= 0
                    e_chars = add_e_chars(count_empty);
                    str = regexprep(str_row(1:index),e_chars, num2str(count_empty));
                    str_row = strcat(str, str_row(index+1:length(str_row)));
                    index = index - (count_empty - 1);
                end
                count_empty = 0;
                index_empty_start = 0;
            end
            index = index + 1;
        end
        if count_empty ~= 0
            e_chars = add_e_chars(count_empty);
            str = regexprep(str_row(1:length(str_row)),e_chars, num2str(count_empty));
            str_row = strcat(str, str_row(index+1:length(str_row)));
        end
    end
end

function FEN_char = get_FEN_character(cell)
    if isempty(cell.pieceClass)
        FEN_char = '0';
    else
        switch cell.pieceClass
            case 'Pawn'
                FEN_char = 'p';
            case 'King'
                FEN_char = 'k';
            case 'Queen'
                FEN_char = 'q';
            case 'Rook'
                FEN_char = 'r';
            case 'Bishop'
                FEN_char = 'b';
            case 'Knight'
                FEN_char = 'n';
            otherwise
                FEN_char = 'e'; %Empty
        end
        col = cell.pieceColor;
        if ~isempty(col) && col == 1 && FEN_char ~= 'e'
            FEN_char = upper(FEN_char);
        end
    end
end

function e_chars = add_e_chars(count)
    e_chars = '';
    if count > 0
        for k = 1:count
            e_chars = strcat(e_chars,'e');
        end
    end
end