function spaceArray = collide(spaceArray,ownIndex)
    global timestep
    object = spaceArray(ownIndex,:);
    type = 2;
    size = 1000;
    lookAhead = 180/timestep;
    numClouds = round(rand(1)*2)+1;     % file:///C:/Users/timny/OneDrive/Desktop/Satellite_Collision_Modeling_with_Physics-Based_Hy.pdf
    posObj = object(1:3);
    velObj = object(4:6);
    
    for iterator = 1:numClouds
        normposObj = posObj/norm(posObj);
        normVel = velObj/norm(velObj);
        randVelTemp = rand(1,3)-.5;  % take a random vector
        randVel = randVelTemp - dot(randVelTemp,normposObj) * normposObj;       % make it orthogonal to k
        randVel = randVel/norm(randVel);  % normalize it
        
        sumNorms = (randVel*.1 + normVel*.9)/norm(randVel*.1 + normVel*.9);
        velCloud = sumNorms*norm(velObj);
        newObjects(iterator,:) = [posObj,velCloud,size,type,lookAhead];
    end
    
    spaceArray(ownIndex,:) = newObjects(1,:);
    
    for iterator = 1:numClouds
        spaceArray(end+1,:) = newObjects(iterator,:);
    end    
end