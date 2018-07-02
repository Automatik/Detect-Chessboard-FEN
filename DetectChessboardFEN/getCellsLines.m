 function Lines = getCellsLines(chessboard)
 
    %Cerco gli angoli interni della cornice nera che mi permettono di
    %essere più preciso nel trovare le linee
    corners = getInnerCorners(chessboard);
    %Calcolo le linee separanti le celle da questi angoli
    [Verts, Horizs] = getLinesFromCorners(corners);
    Lines = [Verts, Horizs];
    
 end
 
 function corners = getInnerCorners(chessboard)
 
    if size(chessboard,3) > 1
        gray = rgb2gray(chessboard);
    else
        gray = chessboard;
    end
    %Binarizzo l' immagine
    h = histeq(gray);  
    T = adaptthresh(h,0.47);
    bw = ~imbinarize(h,T);
    
    %Trovo il contorno più grande che rappresenta la cornice nera
    [B,~] = bwboundaries(bw,'noholes');
    is_square = false;
    while ~is_square
        lengths = cellfun(@length,B);
        boundary_index = find(lengths==max(lengths),1);
        boundary = B{boundary_index};        
        poly = roipoly(bw,boundary(:,2),boundary(:,1));
        %Trovo gli angoli più esterni di questo contorno
        points = getExternPoints(poly);
        [points(:,2),points(:,1)] = sortPoints(points(:,2),points(:,1));
        x = points(:,2);
        y = points(:,1);
        %Controllo se è circa un quadrato per evitare erronei boundaries
        %trovati
        is_square = isSquare([x,y]);
        if ~is_square
            %Se non è un quadrato elimino il contorno erroneo trovato e
            %riprovo con il prossimo
            B(boundary_index) = [];
        end
    end
    
    %Se ho trovato la cornice quadrata nera
    if is_square
        %Cerco ora gli angoli interni della cornice nera
        mask = poly2mask(x,y,size(bw,1),size(bw,2));
        ext = ~mask;
        ext = imdilate(ext,strel('square',7));
        chess = ~(ext+bw);
        chess1 = bwareaopen(chess,250);
        points = getExternPoints(chess1);

        %Aggiusto gli angoli tramite i valori massimi e minimi delle
        %ascisse e delle ordinate(in caso magari uno o due angoli non siano
        %stati individuati correttamente)
        x = points(:,2);
        y = points(:,1);
        TL = [min(x), min(y)];
        TR = [max(x), min(y)];
        BR = [max(x), max(y)];
        BL = [min(x), max(y)];
        corners = [TL; TR; BR; BL];
    else
        corners = [];
    end
 
 end
 
 function [Verts, Horizs] = getLinesFromCorners(corners)
 
    %Trovo le linee orizzontali e verticali a partire dai 4 angoli forniti 
    %e per ogni linea indico il punto di inizio e fine e la sua inclinazione
 
    if isequal(size(corners),[4,2])
    
        TL = corners(1,:);
        TR = corners(2,:);
        BL = corners(4,:);

        width = TR(1)-TL(1);
        height = BL(2)-TL(2);

        cellWidth = width/8;
        cellHeight = height/8;        
        

        Horizs = struct('point1',{},'point2',{},'theta',{});
        Verts = struct('point1',{},'point2',{},'theta',{});

        %get horizontal lines
        h = TL(2);
        for row = 1:9
            Horizs(row).point1 = [TL(1) h];
            Horizs(row).point2 = [TR(1) h];
            Horizs(1).theta = 90;
            h = h + cellHeight;
        end

        %get vertical lines
        w = TL(1);
        for col = 1:9
            Verts(col).point1 = [w TL(2)];
            Verts(col).point2 = [w BL(2)];
            Verts(col).theta = 0;
            w = w + cellWidth;
        end
    else
        Verts = [];
        Horizs = [];
    end
 end
 
 function points = getExternPoints(bw) %the corners
    [I,J] = find(bw==1);
    IJ = [I,J];
    %Trova dove la somma e la differenza delle coordinate nell' immagine
    %sono massimizzate e minimizzate
    [~,idx]=min(IJ*[1 1; -1 -1; 1 -1; -1 1].');
    points = IJ(idx,:);
 end