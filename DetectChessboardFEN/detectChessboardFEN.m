function FEN = detectChessboardFEN(Image, PieceClassifier, Templates)
    
    if size(Image,3) ~= 1
        Image = rgb2gray(Image);
    end
    
    %Find the chessboard looking for the black frame and its corners
    [chessboard, corners] = segmentChessboard(Image);
    
    %Image's size of the chessboard after being rectified
    outputSize = 1008;
    
    %Doing projective transformation of the chessboard so that the image is
    %in plane-view
    rectifiedChessboard = rectifyChessboard(chessboard, corners, outputSize);
    
    if ~isempty(rectifiedChessboard)
        %The chessboard has been found and segmented correctly
        
        %Find the lines which separate the chessboard's cells
        Lines = getCellsLines(rectifiedChessboard);
        
        %Find the cells' corners to crop them after
        cells = getCells(Lines);

        %Find the cells' color to understand later the chessboard's
        %orientation
        Cells = getCellsColor(rectifiedChessboard, cells);
        
        %If the cells were segmentented right there should be 64
        if length(Cells) == 64
            
            %The color of the cell on the top left 
            firstCellColor = Cells(1).color;
            
            %Find the info about every cell(empty, containing a piece, and
            %if so which piece, what color and which orientation)
            [Cells, piecesOrientations] = detectCellsFeatures(rectifiedChessboard, Cells, ...
                PieceClassifier, true, Templates);
                        
            %Find chessboard's global orientation
            piecesOrientations(piecesOrientations==0) = []; %Remove zeros
            isRotated = false;
            if firstCellColor == 1 %Chessboard is straight or 180° rotated
                or1 = sum(piecesOrientations==1);
                or2 = sum(piecesOrientations==3);
                if or2 > or1 %Chessboard is 180° rotated
                    isRotated = true;
                    rectifiedChessboard = imrotate(rectifiedChessboard,-180);
                end
            else
                %Chessboard is rotated on the left or on the
                %right(-90°,90°)
                or1 = sum(piecesOrientations==2);
                or2 = sum(piecesOrientations==4);
                isRotated = true;
                if or1 >= or2 %Is rotated on the left                  
                    rectifiedChessboard = imrotate(rectifiedChessboard,-90);
                else %Is rotated on the right
                    rectifiedChessboard = imrotate(rectifiedChessboard,90);
                end
            end
            
            %If the chessboard were rotated make again an analysis more 
            %accurate of the cells' features
            %(This time without finding pieces' orientation, we already know)
            if isRotated
                Lines = getCellsLines(rectifiedChessboard);
                cells = getCells(Lines);
                Cells = getCellsColor(rectifiedChessboard, cells);
                [Cells, ~] = detectCellsFeatures(rectifiedChessboard, Cells, ...
                    PieceClassifier, false);
            end
            
            %Find the FEN encoding of the chessboard
            FEN = build_FEN_string(Cells);
        else
            FEN = "";
        end
    else
        FEN = "";
    end
end

function [Cells, piecesOrientations] = detectCellsFeatures(rectifiedChessboard, ...
    Cells, PieceClassifier, doFindPiecesOrientation, Templates)
    
    %If we are interested in finding also the piece's orientation
    if doFindPiecesOrientation
        piecesOrientations = zeros(64,1);
    else
        piecesOrientations = [];
    end
    
    %Parameters to calculate HOG on every cell to classify it
    ImageCellSize = [125 125];
    CellSize = [16 16];
    BlockSize = [4 4];
    FirstCellColor = Cells(1).color;
    
    for c = 1:64
                
        %Crop the cell's image from its corners
        TL = Cells(c).TL;
        TR = Cells(c).TR;
        BL = Cells(c).BL;
        x = TL(1);
        y = TL(2);
        width = TR(1)-x;
        height = BL(2) - y;
        crop = imcrop(rectifiedChessboard,[x y width height]);
        resized = imresize(crop, ImageCellSize);
        med = medfilt2(resized,[5 5]);
        cropCell = imsharpen(med);
        
        
        %Calculate HOG on the cell's cropped image and identify the class
        %of the chessboard's piece
        hog = extractHOGFeatures(cropCell,'CellSize',CellSize,'BlockSize',BlockSize);
        [Label, ~] = predict(PieceClassifier,double(hog));
        Cells(c).pieceClass = Label{1};
        
        %Find the piece's color
        if ~strcmp(Label{1},'EmptySquare')
            Cells(c).pieceColor = findPieceColor(rectifiedChessboard, Cells(c));
        end
        
        %Find the piece's orientation so that after we can understand the
        %global chessboard's orientation
        if doFindPiecesOrientation && ~strcmp(Label{1},'EmptySquare')
            piecesOrientations(c) = getPieceOrientation(cropCell, Cells(c), Templates, FirstCellColor);
        end
        
    end
end