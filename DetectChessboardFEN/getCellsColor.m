function cells = getCellsColor(Chessboard, Cells)
    if size(Chessboard,3) ~= 1
        Chessboard = rgb2gray(Chessboard);
    end
    
    if size(Cells,2) ~= 64
        cells = [];
    else
        
        %The cells' color of the chessboard have only two possible
        %sequences, so first find the two possible default sequences and
        %then build the one identified from the chessboard. So compare them
        %and the sequence which is less far from the identified one is the
        %chessboard's sequence
        [seq1, seq2] = createBlackWhiteDefaultSequence(length(Cells));
        [myseq, cells] = createMyBlackWhiteSequence(Cells, Chessboard);
        
        %Find the default sequence more close to the identified one
        r1 = norm(seq1-myseq);
        r2 = norm(seq2-myseq);
        if r1 < r2
            seq = seq1;
        else
            seq = seq2;
        end
        
        %Correct the cells' color with the default sequence which is
        %for definition correct
        pos = find((seq-myseq)~=0);
        if length(pos) >= 32
            %If more than half of the colors are wrong than it wasn't the
            %correct sequence
            cells = []; 
        else
            for k = 1:length(pos)
                cells(1,pos(k)).color = seq(pos(k)); 
            end
        end
    end
end

function [seq1, seq2] = createBlackWhiteDefaultSequence(numCells)
    %Create the two possible sequences of a chessboard
    seq1 = zeros(numCells,1);
    j = 1;
    while j <= 8
        if (mod(j,2) ~= 0)
            t = 0;
        else
            t = 1;
        end
        for i = ((8*j)-7):(8*j)
            if(mod(i,2) == 0)
                seq1(i) = 1-t;
            else
                seq1(i) = 0+t;
            end
        end
        j = j+1;
    end
    seq2 = imcomplement(seq1);
end

function [myseq, cells] = createMyBlackWhiteSequence(Cells, Image)

    %For every cell, binarize it and from the mean decide if it's white
    %or black
    im = im2double(Image);
    myseq = zeros(length(Cells),1);
    idx = 1;
    while idx <= length(Cells)
        TL = Cells(idx).TL;
        TR = Cells(idx).TR;
        BL = Cells(idx).BL;
        cellImage = im(TL(2):BL(2),TL(1):TR(1));
        erode = imerode(cellImage,strel('square',10));
        bw = imbinarize(erode,'global');
        
        avg = mean2(bw);
        if avg > 0.5
            %The color of the cell is White
            myseq(idx) = 1;
            Cells(idx).color = 1;
        else
            %The color of the cell is Black
            myseq(idx) = 0;
            Cells(idx).color = 0;
        end
        idx = idx + 1;
    end
    cells = Cells;
end