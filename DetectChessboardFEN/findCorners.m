function corners = findCorners(chessboardMask)
    %Find the extern lines of the chessboard's mask
    bw = edge(chessboardMask,'canny');
    [H, Theta, Rho] = hough(bw,'RhoResolution',5); 
    P = houghpeaks(H,4,'Threshold',0.3*max(H(:)));
    %700 of 'FillGap' because the chessboards very zoomed the lines on the
    %same chessboard's segment are very distant
    Lines = houghlines(bw,Theta,Rho,P,'FillGap',700);
    
    
    n = length(Lines);
    %Because it should be a square if it didn't find 4 lines it's because
    %the mask is not of the correct shape, so it's not the chessboard
    if  n ~= 4 
        corners = [];
    else
        %Check if the lines are two to two parallel and perpendicular
        p1 = are_parallel(Lines(1),Lines(2));
        p2 = are_parallel(Lines(1),Lines(3));
        p3 = are_parallel(Lines(1),Lines(4));
        if (p1 && ~p2 && ~p3) || (~p1 && p2 && ~p3) || (~p1 && ~p2 && p3)
            %If they are, find then the corners from the lines
            %intersections
            corners = get_corners(Lines);
        else
            corners = [];
        end
    end
end

function corners = get_corners(lines)
    %Find the corners from the perpendicular lines intersections
    corners = zeros(4,2);
    index = 1;
    for i = 1:length(lines)
        for j = 1:length(lines)
            if i ~= j && not(are_parallel(lines(i),lines(j)))
                point = linesIntersection([lines(i).point1; lines(i).point2; lines(j).point1; lines(j).point2]);
                %Check if the point is finite and if it not was already
                %found
                if(and(isfinite(point), not(point_ismember(point,corners))))
                    corners(index,1) = point(1);
                    corners(index,2) = point(2);
                    index = index + 1;
                end
            end
        end
    end
end

function result = point_ismember(point, matrix)
    %matrix of corners(:,2)
    %no input check
    result = false;
    for k = 1:size(matrix,1)
        if(and(point(1)==matrix(k,1), point(2)==matrix(k,2)))
            result = true;
        end
    end
end