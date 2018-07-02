function [x,y] = sortPoints(x,y)
    %Find the centroid
    cx = mean(x);
    cy = mean(y);
    %Find the corners
    a = atan2(y - cy, x - cx);
    %Find the correct order
    [~,order] = sort(a);
    %Sort the coordinates
    x = x(order);
    y = y(order);
end