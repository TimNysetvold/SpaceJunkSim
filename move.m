function spaceArray = move(spaceArray)
    global timestep
    global gravitationalConstant
    global massOfEarth
    position = spaceArray(:,1:3);
    acceleration = -(gravitationalConstant.*massOfEarth.*position)./(vecnorm(position,2,2).^3);
    velocity = spaceArray(:,4:6) + acceleration*timestep;
    position = position + velocity*timestep;
    spaceArray(:,4:6) = velocity;
    spaceArray(:,1:3) = position;
end