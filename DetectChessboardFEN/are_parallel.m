function parallel = are_parallel(lines1, lines2)
    %Two parallel lines have similar Theta(or Theta+Pi)
    
    %Threshold for the theta attribute to be considered parallel or
    %perpendicular
    T = 45; 
    
    parallel = false;
    diff = abs(lines1.theta-lines2.theta);
    if diff <= T || diff >= T+90
        parallel = true;
    end
end