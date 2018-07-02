function cells = getCells(Lines)
    
    if size(Lines,2) ~= 18
        %If the lines are not 18 there are no 64 cells to find
        cells = [];
    else
       %Assume the first 9 lines are verticals, e the others are
       %horizontals. And that they are sorted
       verts = Lines(1:9);
       horizs = Lines(10:18);
       
       %Initialize the struct with 64 cells containing the cells's corners,
       %the color, and the possibly piece's color and its class
       cells = struct('TL',{},'TR',{},'BL',{},'BR',{},'color',{},'pieceColor',{},'pieceClass',{});
       cells(64).TL = 0;
       
       %Find cells from the lines intersections
       index = 1;
       for i = 1:(length(verts)-1)
           for j = 1:(length(horizs)-1)
                %get corners
                TL = linesIntersection([verts(i).point1; verts(i).point2; horizs(j).point1; horizs(j).point2]);
                TR = linesIntersection([verts(i+1).point1; verts(i+1).point2; horizs(j).point1; horizs(j).point2]);
                BL = linesIntersection([verts(i).point1; verts(i).point2; horizs(j+1).point1; horizs(j+1).point2]);
                BR = linesIntersection([verts(i+1).point1; verts(i+1).point2; horizs(j+1).point1; horizs(j+1).point2]);
                cells(index).TL = round(TL);
                cells(index).TR = round(TR);
                cells(index).BL = round(BL);
                cells(index).BR = round(BR);
                index = index + 1;
           end
       end
       if size(cells,2) ~= 64
           cells = [];
       end
    end
end