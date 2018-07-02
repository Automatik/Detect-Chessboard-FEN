folder = 'Chessboards';
pathToSave = 'Dataset';
files = dir(folder);
for f = 3:98  %length(files)
    file = files(f).name;
    num_image = file(1:(length(file))-4);
    extension = file((length(file)-2):length(file));
    if strcmp(extension,'jpg')
        path = strcat(folder,'/',file);
        image = imread(path);
        fprintf('Segmenting %s\n',file);
        gray = rgb2gray(image);
        [chessboard,corners] = segmentChessboard(gray);
        outputSize = 1008; %504
        rectifiedChessboard = rectifyChessboard(chessboard,corners,outputSize);
        
        if ~isempty(rectifiedChessboard)
            Lines = getCellsLines(rectifiedChessboard);
            Cells = getCells(Lines);
            Cells = getCellsColor(rectifiedChessboard, Cells);
            for i = 1:length(Cells)
                tl = Cells(i).TL;
                tr = Cells(i).TR;
                bl = Cells(i).BL;
                col = Cells(i).color;
                x = tl(1);
                y = tl(2);
                width = tr(1)-x;
                height = bl(2) - y;
                crop = imcrop(rectifiedChessboard,[x y width height]);
                resized = imresize(crop, [125 125]);
                med = medfilt2(resized,[5 5]);
                cropCell = imsharpen(med);
                if col == 0
                    str = "Black";
                else
                    str = "White";
                end
                num_cell = num2str(i);
                filename = char(strcat(pathToSave,'/',str,'-',num_image,'-',num_cell,'.jpg'));
                imwrite(cropCell, filename);
            end
        end
    end
end