function Orientation = getPieceOrientation(ImageCell, Cell, Templates, FirstCellColor)
    
    %Values of Orientation:
    % 0 Template not found
    % 1 Straight
    % 2 Rotated to left(90°)
    % 3 Rotated to 180°
    % 4 Rotated to right(-90°)
    
    if size(ImageCell,3) > 1
        ImageCell = rgb2gray(ImageCell);
    end
    
    %Find the index inside the struct 'Templates' containing the
    %corrispondent template of the piece contained in the cell and of the
    %same color
    idx = templateIndex(Templates, Cell.pieceClass, Cell.pieceColor);
    
    if idx == 0 %Template not found
        Orientation = 0;
    else
        
        %Image of the template
        T = Templates(idx).Template;
        
        %If the first cell on the top left is white then the chessboard
        %could be already straight or rotated of 180°
        if FirstCellColor == 1
            T1 = imrotate(T,-180);
            c = normxcorr2(T, ImageCell);
            c1 = normxcorr2(T1, ImageCell);
            m = max(c(:));
            m1 = max(c1(:));
            if m > m1 %The image is straight
                Orientation = 1;
            else
                Orientation = 3;
            end
        else
            %The chessboard is rotated to the left or to the right
            T1 = imrotate(T,90);
            T2 = imrotate(T,-90);
            c = normxcorr2(T1,ImageCell);
            c1 = normxcorr2(T2,ImageCell);
            m = max(c(:));
            m1 = max(c1(:));
            if m > m1 %The image is rotated to the left
                Orientation = 2;
            else
                Orientation = 4;
            end
        end
    end
end

function index = templateIndex(templates, class, color)
    for k = 1:6
        if strcmp(templates(k).Class,class)
            index = k;
        end
    end
    if color == 1
        index = index + 6;
    end
    if index > 12
        index = 0;
    end
end