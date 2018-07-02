%Folder containing in couple the images of the chessboards and their
%related groundtruth
folder = 'Chessboards';

%Number of images contained in the folder
n_images = (length(dir(folder))-2)/2;

%Counter of the FEN strings correctly identified
correct_FENS = 0;

%Loading template images
Templates = loadTemplates();

%Loading the classifier, or if file not present, train a new one with
%the descriptor's file
PieceClassifier = loadPieceClassifier();

for n = 1:n_images
    
    if n < 10
        str = strcat('00',num2str(n));
    else
        str = strcat('0',num2str(n));
    end

    pathImage = strcat(folder,'/',str,'.jpg'); %path immagine
    pathFEN = strcat(folder,'/',str,'.fen'); %path for the FEN groundtruth
    
    Image = imread(pathImage);
    
    %Return the FEN encoding for this image
    FEN = detectChessboardFEN(Image, PieceClassifier, Templates);
    
    %Return the FEN groundtruth contained in the respective file .fen
    FEN_GT = readFENGroundTruth(pathFEN);
    
    if strcmp(FEN,"") %Segmentation or recognition error
        fprintf('Chessboard %s FEN could not be detected\n',str);
    elseif strcmp(FEN_GT,"") %Groundtruth file not found or malformed
        fprintf('Chessboard %s groundtruth could not be loaded\n',str);
    elseif strcmp(FEN,FEN_GT) %The FEN string is correct
        fprintf("Image %s FEN string correct: %s\n",str,FEN);
        correct_FENS = correct_FENS + 1;
    else %The FEN string is wrong
        fprintf("Image %s FEN string error!\n gt: %s FEN: %s\n",str,FEN_GT,FEN); 
    end   
 
end

%Algorithm's precision based on the total FEN strings calculated correctly
correct_FENS_perc = correct_FENS * 100 / n_images;
fprintf("Chessboard FEN detection precision: %f \n",correct_FENS_perc);

function templates = loadTemplates()
    files = dir('Templates');
    n = length(files);
    templates = struct('Template',{});
    templates(n-2).Template = 0;
    pieces = {'Bishop','King','Knight','Pawn','Queen','Rook'};
    for k = 1:n-2 %Avoid the two directories "." e ".."
        templates(k).Template = imread(strcat('Templates/',files(k+2).name));
        %Using the alphabetical order of the images to assign the
        %template's class
        if k<=6
            templates(k).Class = pieces{k};
            templates(k).Color = 0;
        else
            templates(k).Class = pieces{k-6};
            templates(k).Color = 1;
        end
    end
end

function pieceClassifier = loadPieceClassifier()

    if exist('pieceClassifier.mat', 'file') == 2
        load('pieceClassifier.mat','pieceClassifier');
    else
        %If the descriptor's file doesn't exist create it again from
        %Dataset
        if ~(exist('descriptors.mat','file') == 2)
            createDescriptorFile();
        end
        %Training the new classifier and saving it to file
        load('descriptors.mat','hogFeatures');
        [~, labels] = readlists();
        cv = cvpartition(labels,'Holdout',0.3);
        [~, pieceClassifier] = trainClassifier(hogFeatures,labels,cv);
        save('pieceClassifier.mat','pieceClassifier');
    end
    
end

function FEN_GT = readFENGroundTruth(pathFEN)
    if exist(pathFEN,'file') == 2
        f = fopen(pathFEN);
        tline = fgetl(f);
        if ischar(tline)
            FEN_GT = tline;
        else
            FEN_GT = "";
        end
        fclose(f);
    else
        FEN_GT = "";
    end
end