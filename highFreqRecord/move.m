function spaceArray = move(spaceArray)
    global timestep
    global gravitationalConstant
    global massOfEarth
    
    %Since lasers don't move, we find all of them and will replace them
    %later. This is kludgy, but will be lesss work than trying to not calculate
    %their movement to begin with
    unmovingPositions = (spaceArray(:,8) == 5 | spaceArray(:,8) ==6);
    laserSave = spaceArray(unmovingPositions,:);
    
    position = spaceArray(:,1:3);
    temp = vecnorm(position,2,2);
    denom = temp.*temp.*temp;
    acceleration = -(gravitationalConstant.*massOfEarth.*position)./denom;
    velocity = spaceArray(:,4:6) + acceleration*timestep;
    position = position + velocity*timestep;
    spaceArray(:,4:6) = velocity;
    spaceArray(:,1:3) = position;
    
    spaceArray(unmovingPositions,:) = laserSave;
end