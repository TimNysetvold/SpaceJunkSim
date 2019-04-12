function spaceArray = collide(spaceArray,collisionsIndexes)
    global timestep
    object1 = spaceArray(collisionsIndexes(1),:);
    object2 = spaceArray(collisionsIndexes(2),:);
    type = 2;
    size = 1000;
    lookAhead = 60/timestep;
    numClouds = round(rand(1)*2);     % file:///C:/Users/timny/OneDrive/Desktop/Satellite_Collision_Modeling_with_Physics-Based_Hy.pdf
    posObj(1,:) = object1(1:3);
    posObj(2,:) = object2(1:3);
    velObj(1,:) = object1(4:6);
    velObj(2,:) = object2(4:6);
    
    for iterator = 1:2+numClouds
        baseSelection = mod(iterator,2)+1;
        pos = posObj(baseSelection,:);
        normpos = pos/norm(pos);
        normVel = velObj(baseSelection,:)/norm(velObj(baseSelection,:));
        randVelTemp = rand(1,3)-.5;  % take a random vector
        randVel = randVelTemp - dot(randVelTemp,normpos) * normpos;       % make it orthogonal to k
        randVel = randVel/norm(randVel);  % normalize it
        
        sumNorms = (randVel*.1 + normVel*.9)/norm(randVel*.1 + normVel*.9);
        velCloud = sumNorms*norm(velObj(baseSelection,:));
        newObjects(iterator,:) = [pos,velCloud,size,type,lookAhead];
    end
    
    spaceArray(collisionsIndexes(1),:) = newObjects(1,:);
    spaceArray(collisionsIndexes(2),:) = newObjects(2,:);
    
    for iterator = 1:numClouds
        spaceArray(end+1,:) = newObjects(iterator,:);
    end    
    disp 'Crashed'
end