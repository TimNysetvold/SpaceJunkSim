function safetyVal = SpaceJunkSim(input1,input2)


%[1-3 randPos', 4-6 randVel', 7 size, 8 type, 9 nextLook]





    delete 'distances.csv';
    global massOfEarth
    global gravitationalConstant
    global timestep
    massOfEarth = 5.972*(10^24);
    gravitationalConstant = 6.674*10^(-11);
    timestep = .01;               %given in seconds
    
    
    %Begin Independent Variables
    totalIterations = 100000;
    startNumJunkSatellites = 12000*.15;
    startNumJunkClouds = 30000*.15;
    %startNumSmallObjects = 300000*.2;   %a pessimistic estimate of this area of orbit's beginning density
    launchRate = 100; %per 10 iterations, right now. Will be changed to per day
    avSatelliteLife = 10000; %iterations, right now; will be changed to days
    rangeSatelliteLife = 10000; %iterations, right now; will be changed to days
    avJunkSize = 1; %m^2
    avCloudSize = 1000; %m^2
    avSatelliteSize = 10; %m^2
    rangeOrbit = 10000;
    rangeVel = 100;
    %Note: Normal speed in LEO is about 7.8 km/s. With some factor of
    %safety, 10 km/s
    maxVel = 10000; %m/s

    startNumLasers = 3;
    startNumSatellites = 3;
    startNumCleaners = 3;  
    
    %Begin parameters
    %All distances in meters, weights in kg, time in sec
    collisionDistance = 100;        %Any pass within 100 m is probabalistically considered a collision
    cloudDistance = 1000;           %Radius of a debris cloud within which there may be collision
    cleanerDistance = 5000;         %The maximum distance a cleaner satellite can reach; 5 km
    laserDistance = 100000;         %The maximum field of view of a laser; 100km

    %Earth's radius is 6,371,000 meters, + max 2,000,000 meters of altitude. Min 161000 m altitude.
    spaceArray = []
    laserArray = []
    %spaceArray = tall(spaceArray);
    creatorObjectArray = [];

    positionArray = [0,0,0]
    xdata = positionArray(:,1);
    ydata = positionArray(:,2);
    zdata = positionArray(:,3);
    datapoints = scatter3(xdata, ydata, zdata);


    for x = 0:startNumJunkSatellites
        %Creates spacejunk
        [randPos,randVel] = getOrbit();
        sizeObject = lognrnd(.2,1)*avJunkSize;
        type = 1;
        nextLook = 0;
        creatorObject = [randPos',randVel',sizeObject,type,nextLook]; %FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
        %6371000 is radius of the earth. We assume satellites are 100k up
        spaceArray(end+1,:) = creatorObject;
        %print(x)
    end

    for x = 0:startNumJunkClouds
        %Creates spacejunk
        [randPos,randVel] = getOrbit();
        sizeObject = lognrnd(.2,1)*avCloudSize;
        type = 2;
        nextLook = 0;
        creatorObject = [randPos',randVel',sizeObject,type,nextLook]; %FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
        %6371000 is radius of the earth. We assume satellites are 100k up
        spaceArray(end+1,:) = creatorObject;
        %print(x)
    end
    
    for x = 0:startNumSatellites   
        %Creates satellites
        [randPos,randVel] = getOrbit();
        sizeObject = lognrnd(.666,1)*avSatelliteSize;
        type = 3;
        nextLook = 0;
        creatorObject = [randPos',randVel',sizeObject,type,nextLook]; %FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
        %6371000 is radius of the earth. We assume satellites are 100k up
        spaceArray = [spaceArray;creatorObject];
        %print(x)
    end


    for x = 0:startNumCleaners  
        %Creates cleaners
        [randPos,randVel] = getOrbit();
        sizeObject = lognrnd(.666,1)*avSatelliteSize;
        type = 4;
        nextLook = 0;
        creatorObject = [randPos',randVel',sizeObject,type,nextLook]; %FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
        %6371000 is radius of the earth. We assume satellites are 100k up
        spaceArray = [spaceArray;creatorObject];
        %print(x)
    end


    for x = 0:startNumLasers
        %Creates laser brooms
        avObjSize = 0;
        type = 5;
        creatorObject = launchObject(type,avObjSize);
        laserArray = [laserArray;creatorObject];
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%Measure Beginning Vars%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%Begin Dependent Variables
objectDensity = 0;
avoidanceActions = 0;
riskToISS = 0;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%Begin Iterator Loop%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iteration=1:totalIterations
    %If necessary, launch an additional satellite
    if mod(iteration,launchRate) == 0
        tempCreator = launchObject(1,avJunkSize);
        spaceArray = [spaceArray;tempCreator];
    end

    %Refresh the matrices we'll need
    positionArray = spaceArray(:,1:3);
    nextLookVec = spaceArray(:,9);
    
    objectsToLookAt = find(~nextLookVec);
    
    for iterator=1:length(objectsToLookAt)
        trueIndex = objectsToLookAt(iterator);
        thisType = spaceArray(trueIndex,8);
        thisDistances = (pdist2(positionArray,positionArray(trueIndex,:)))';
        thisDistances(thisDistances==0) = 1e9;
            if thisType == 1
                collisionsIndexes = find(thisDistances<collisionDistance);
                if ~isempty(collisionsIndexes)
                    [spaceArray,positionArray] = collide(collisionsIndexes);
                end
            elseif thisType == 2
                cloudIndexes = find(thisDistances<cloudDistance);
                if ~isempty(cloudIndexes)
                    [spaceArray,positionArray] = cloud(cloudIndexes);
                end
            elseif thisType == 3
                collisionsIndexes = find(thisDistances<collisionDistance);
                if ~isempty(collisionsIndexes)
                    [spaceArray,positionArray] = collide(collisionsIndexes);
                end
            elseif thisType == 4
                cleanerIndexes = find(thisDistances<cleanerDistance);
                if ~isempty(cleanerIndexes)
                    [spaceArray,positionArray] = clean(cleanerIndexes);
                end
            elseif thisType ==5
                laserIndexes = find(thisDistances<laserDistance);
                if ~isempty(laserIndexes)
                    [spaceArray,laserArray,positionArray] = laserShot(laserIndexes);
                end
            end
        
        spaceArray(iterator,9) = floor(min(thisDistances)/(timestep*maxVel)); %FixMe: Not sure if this is precisely right
    end
    
    spaceArray = move(spaceArray);
    
    %Decrement how long until we look at each element
    spaceArray(:,9) = spaceArray(:,9)-1;
    
    %Graph every so often
    if mod(iteration,100) == 0
        xdata = positionArray(1:500,1);
        ydata = positionArray(1:500,2);
        zdata = positionArray(1:500,3);
        scatter3(xdata,ydata,zdata)
        pause(.0001)
    end

    %disp(iteration)
    %print(h.heap())
    %print(spaceArray)
end

    
%anim = animation.FuncAnimation(fig,update,frames=25,init_func=init,interval=200,blit=True)
orbitRisk = 1;
disp("Made to below anim")
[temp,temp2] = size(spaceArray);
disp(temp)
disp(orbitRisk)
    

end
