function is_square = isSquare(corners)
    %Corners should be already sorted in clock-wise order and in the form
    %[X, Y]
    
    
    if size(corners,1) == 4 && size(corners,2) == 2
        TL = [corners(1,1), corners(1,2)];
        TR = [corners(2,1), corners(2,2)];
        BR = [corners(3,1), corners(3,2)];
        BL = [corners(4,1), corners(4,2)];
        
        %Check if the diagonals are congruent
        T_diagonals = 100;
        diagonalsEqual = false;
        diag1 = distance(TL,BR);
        diag2 = distance(TR,BL);
        if abs(diag1-diag2) <= T_diagonals
            diagonalsEqual = true;
        end
                

        edges = zeros(1,4);
        edges(1) = distance(TL,TR);
        edges(2) = distance(TR,BR);
        edges(3) = distance(BR,BL);
        edges(4) = distance(BL,TL);
        
        %Check if the edges have at least a minimum length in order to
        %avoid to consider as chessboard frames those squares with very
        %small dimensions
        T_edges = 300; 
        hasMinimumLength = true;
        i = 1;
        while hasMinimumLength && i <= 4
            if edges(i) < T_edges
                hasMinimumLength = false;
            end
            i = i + 1;
        end
        
        
        %Check if the edges between them are congruent
        %Threshold very high because the chessboards in perspective the
        %edges differ a lot
        T_diff = 350;
        avg_length = mean(edges);
        islengthequal = true;
        i = 1;
        while islengthequal && i <= 4
            if(abs(edges(i) - avg_length) > T_diff)
                islengthequal = false;
            end
            i = i + 1;
        end
        
        %If all the checks were verified then those corners form a square
        if diagonalsEqual && islengthequal && hasMinimumLength
            is_square = true;
        else
            is_square = false;
        end

    else
        is_square = false;
    end
end

function length = distance(corner1, corner2)
    %Euclidean distance from the two points
    x1 = corner1(1,1);
    y1 = corner1(1,2);
    x2 = corner2(1,1);
    y2 = corner2(1,2);
    length = abs(pdist([x1,y1;x2,y2],'euclidean'));
end