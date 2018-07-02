function [chessboard, corners] = segmentChessboard(Image)


    %Remove the noise and binarize the image
    blur = imgaussfilt(Image,2);
    T = adaptthresh(blur,0.6);
    bin = ~imbinarize(blur,T);
    bin2 = bwareaopen(bin,200);
    kernel = strel('square',3);
    bw = imdilate(bin2,kernel);
    
    %Find the biggest boundary with shape like a square, which should be
    %the black frame of the chessboard
    [B,~] = bwboundaries(bw,'noholes');
    [~,sortedIndexBoundaries] = sort(cellfun(@length,B),'descend');
    chessboardFound = false;
    while ~chessboardFound && size(B{sortedIndexBoundaries(1)},1) > 1000
        max_boundary_index = sortedIndexBoundaries(1);

        %Biggest boundary found
        boundary = B{max_boundary_index};

        %Create a binary mask which should be the square inside the black
        %frame
        poly = roipoly(bw,boundary(:,2),boundary(:,1));

        %Find the 4 corners of the mask from the mask's edges
        points = findCorners(poly);

        %If didn't found them it's because the lines couldn't form a
        %square, so that boundary was not of the black frame
        if isempty(points)

            %Delete the wrong boundary
            sortedIndexBoundaries(1) = [];
        else
            x = points(:,1);
            y = points(:,2);
            
            %Sort the points in clock-wise order
            [x,y] = sortPoints(x,y);
            
            corners = zeros(4,2);
            corners(:,1) = x;
            corners(:,2) = y;
            
            %Check from the corners if the formed square has actually the
            %properties of a square, and also that it has a minimum size.
            %If so the black frame of the chessboard has been found
            if isSquare(corners) 
                chessboardFound = true;            
            else
                %Otherwise the boundary is wrong
                sortedIndexBoundaries(1) = [];
            end
        end
    end
    
    %If the chessboard has been found multiply the mask for the image so
    %that all the background is set to zero
    if chessboardFound
        %Create a square-mask from the corners to avoid possible
        %imperfections in the boundary
        mask = poly2mask(x,y,size(bw,1),size(bw,2));
        chessboard = uint8(mask) .* Image;
    else
        chessboard = [];
        corners = [];
    end
end