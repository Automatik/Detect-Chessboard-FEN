function rectifiedChessboard = rectifyChessboard(chessboard, corners, outputSize)
    %Check if the two are empty, if so then the chessboard didn't get
    %segmented correctly
    if ~isempty(chessboard) && ~isempty(corners)
        
        %Contain the 4 corners of the object found in clock-wise order
        movingPoints = corners; 
        
        size = outputSize;
        
        %Position that the chessboard must take
        fixedPoints = [0 0; size 0; size size; 0 size];
        
        %Calculate the transformation matrix in prospective
        tform = fitgeotrans(movingPoints,fixedPoints,'projective');

        %Final dimensions of the image rectified
        resultReference = imref2d([size size]) ;

        %Doing the rectification of the chessboard's image
        rectifiedChessboard = imwarp(chessboard,tform,'OutputView',resultReference);
    else
        rectifiedChessboard = [];
    end
end