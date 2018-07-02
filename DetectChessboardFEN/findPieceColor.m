function Color = findPieceColor(chessboardImage, cell)

    %The piece's color is identified by looking in the central part of the
    %cell's image(45x45), because if the piece is contained in the cell it
    %is in the central part, and after the image is binarized, by looking
    %the majority of 1s and 0s pixels to decide the piece's color
    if size(chessboardImage,3) ~= 1
        chessboardImage = rgb2gray(chessboardImage);
    end
    
    TL = cell.TL;
    TR = cell.TR;
    BL = cell.BL;
    cellImage = chessboardImage(TL(2):BL(2),TL(1):TR(1));
    dim = im2double(cellImage);
    
    %The window's size containing the piece
    windowSize = 45;
    
    yc = round(size(cellImage,1)/2);
    xc = round(size(cellImage,2)/2);
    
    windowTL_X = round(xc-windowSize/2);
    windowTL_Y = round(yc-windowSize/2);
       
    med = medfilt2(dim,[5 5]);
    T = graythresh(med);
    gamma = imadjust(med,[T-0.05 T],[],0.4);
    bw = imbinarize(gamma);

    %Find the central window of the cell's image
    window = bw(windowTL_Y:(windowTL_Y+windowSize), windowTL_X:(windowTL_X+windowSize));

    %If the black pixels's ratio is greater than white pixels' ration then
    %the piece is black, otherwise is white

    blackPixels = sum(sum(window==0));
    whitePixels = sum(sum(window==1));
    ratio1 = blackPixels / (windowSize*windowSize);
    ratio2 = whitePixels / (windowSize*windowSize);
    if ratio1 > ratio2
        Color = 0;
    else
        Color = 1;
    end
end