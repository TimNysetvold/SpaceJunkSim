function safetyVals = SpaceJunkSim(runNum)

    filename = 'DOEShorts.csv';
    DOE = dlmread(filename);
    input = DOE(runNum,:);
    totalTime = round(input(1));
    cleanFlag = round(input(2));
    launchRate = round(input(3));
    startNumCleaners = round(input(4));
    startNumLasers = round(input(5));
%[1-3 randPos', 4-6 randVel', 7 size, 8 type, 9 nextLook]

    global massOfEarth
    global gravitationalConstant
    global timestep
    massOfEarth = 5.972*(10^24);
    gravitationalConstant = 6.674*10^(-11);
    timestep = .05;               %given in seconds
    
    
%     %Begin Independent Variables presets. Used for debugging
%     totalTime = .125; %in days
%     cleanFlag = 0;          %0 or 1; determine whether cleanersats can clean clouds
%     launchRate = 10000; %per 10 iterations, right now. Will be changed to per day
%     startNumCleaners = 3;  
%     startNumLasers = 3;
    
    totalIterations = 24*60*60*totalTime/timestep;
    startNumJunkSatellites = 10000*.05;
    startNumJunkClouds = 300000/100*.05;    %assume 100 small objects per cloud
    startNumSatellites = 2000*.15;
    
    %Begin parameters
    %All distances in meters, weights in kg, time in sec
    collisionDistance = 100;        %Any pass within 100 m is considered a collision
    cloudDistance = 1000;           %Radius of a debris cloud within which there may be collision
    cleanerDistance = 5000;         %The maximum distance a cleaner satellite can reach; 5 km
    laserDistance = 100000;         %The maximum field of view of a laser; 100km
    
    avJunkSize = 1; %m^2            %Note: Sizes don't currently matter
    avCloudSize = 1000; %m^2
    avSatelliteSize = 10; %m^2
    %Note: Normal speed in LEO is about 7.8 km/s. With some factor of
    %safety, 10 km/s
    maxVel = 10000; %m/s

    spaceArray = [];
    creatorObjectArray = [];

    
%     positionArray = [0,0,0];
%     xdata = positionArray(:,1);
%     ydata = positionArray(:,2);
%     zdata = positionArray(:,3);
%     datapoints = scatter3(xdata, ydata, zdata);


    for x = 1:startNumJunkSatellites
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

    for x = 1:startNumJunkClouds
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
    
    for x = 1:startNumSatellites   
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


    for x = 1:startNumCleaners  
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


    for x = 1:startNumLasers
        %Creates laser brooms
        avObjSize = 0;
        type = 5;
        creatorObject = launchObject(type,avObjSize,0,[0,0,0]);
        spaceArray = [spaceArray;creatorObject];
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%Debug Section%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%     spaceArray(1,1:6) = spaceArray(2,1:6)+1; %crashes two satellites
    
    
%     spaceArray(end-startNumLasers-1,1:6) = spaceArray(3,1:6)+100; %cleans a junk
    
%    spaceArray(end,1:6) = spaceArray(4,1:6)+100; %lasers a junk
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%Measure Beginning Vars%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%Begin Dependent Variables
[startObjectDensity,startRiskToISS,startYearRisk,startSmallObjects,startLargeObjects,startSatRisk] = findStats(spaceArray);          %within applicable orbit, per one year
avoidanceActions = 0;
largeObjectCollisions = 0;
cloudCollisions = 0;
cleanedDebris = 0;
laseredDebris = 0;
    
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
        tempCreator = launchObject(1,avJunkSize,avJunkSize*.1);
        spaceArray = [spaceArray;tempCreator];
    end
    

    %Refresh the matrices we'll need
    positionArray = spaceArray(:,1:3);
    nextLookVec = spaceArray(:,9);
    
    objectsToLookAt = find(~nextLookVec);
    
    for iterator=1:length(objectsToLookAt)
        selfIndex = objectsToLookAt(iterator);
        thisWait = spaceArray(selfIndex,9);
        if thisWait ==0
            thisType = spaceArray(selfIndex,8);
            thisDistances = (pdist2(positionArray,positionArray(selfIndex,:)))';
            thisDistances(thisDistances==0) = 1e9;
            if thisType == 1
                collisionsIndexes = find(thisDistances<collisionDistance);
                if ~isempty(collisionsIndexes)
                    if (any(spaceArray(collisionsIndexes,8) == 1))
                        collideObjectIndex = collisionsIndexes(spaceArray(collisionsIndexes,8) == 1);
                        spaceArray = collide(spaceArray,selfIndex);
                        spaceArray = collide(spaceArray,collideObjectIndex);
                        largeObjectCollisions = largeObjectCollisions + 2;
                    end
                end
            elseif thisType == 2
                cloudIndexes = find(thisDistances<cloudDistance);
                if ~isempty(cloudIndexes)
                    if (any(spaceArray(cloudIndexes,8) == 1))
                        cloudObjectIndex = find(spaceArray(cloudIndexes,8) == 1);
                        spaceArray = cloud(spaceArray,[selfIndex,cloudObjectIndex]);
                        cloudCollisions = cloudCollisions+1;
                        %disp 'made a cloudcollision'
                    end
                end
            elseif thisType == 3
                collisionsIndexes = find(thisDistances<collisionDistance);
                if ~isempty(collisionsIndexes)
                    avoidanceActions = avoidanceActions+1;
                end
            elseif thisType == 4
                junkIndexes = find(thisDistances<cleanerDistance);
                if ~isempty(junkIndexes)
                    junkObjects = spaceArray(junkIndexes,:);
                    junkIndexes = junkIndexes(junkObjects(:,8)<2);
                    if ~isempty(junkIndexes)
                        spaceArray = clean(spaceArray,junkIndexes,cleanFlag);
                        cleanedDebris = cleanedDebris+1;
                    end
                end
            elseif thisType ==5
                junkIndexes = find(thisDistances<laserDistance);
                if ~isempty(junkIndexes)
                    junkObjects = spaceArray(junkIndexes,:);
                    junkIndexes = junkIndexes(junkObjects(:,8)<2);
                    if ~isempty(junkIndexes)
                        [spaceArray] = laser([selfIndex,junkIndexes],spaceArray);
                        laseredDebris = laseredDebris+1;
                    end
                end
            end
            
            if thisType ~= 5
                spaceArray(iterator,9) = floor(min(thisDistances)/(timestep*maxVel)); %FixMe: Not sure if this is precisely right
            end    
        end
    end
    
    spaceArray = move(spaceArray);
    
    %Decrement how long until we look at each element
    spaceArray(:,9) = spaceArray(:,9)-1;
    
    
%     Graph every so often
    if mod(iteration,50000) == 0
        xdata = positionArray(:,1);
        ydata = positionArray(:,2);
        zdata = positionArray(:,3);
        cdata = spaceArray(:,8);
        scatter3(xdata,ydata,zdata,cdata*20,cdata*50)
        pause(.0001)
    end

    %disp(iteration)
    %print(h.heap())
    %print(spaceArray)
end

    

spaceArray(spaceArray>1e10) = 0;
spaceArray = spaceArray(any(spaceArray,2),:);

% %%%Debug code
%     for x = 1:10
%         %Creates spacejunk
%         [randPos,randVel] = getOrbit();
%         sizeObject = lognrnd(.2,1)*avJunkSize;
%         type = 1;
%         nextLook = 0;
%         creatorObject = [randPos',randVel',sizeObject,type,nextLook]; %FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
%         %6371000 is radius of the earth. We assume satellites are 100k up
%         spaceArray(end+1,:) = creatorObject;
%         %print(x)
%     end
% 
%     for x = 1:10
%         %Creates spacejunk
%         [randPos,randVel] = getOrbit();
%         sizeObject = lognrnd(.2,1)*avCloudSize;
%         type = 2;
%         nextLook = 0;
%         creatorObject = [randPos',randVel',sizeObject,type,nextLook]; %FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
%         %6371000 is radius of the earth. We assume satellites are 100k up
%         spaceArray(end+1,:) = creatorObject;
%         %print(x)
%     end




spaceArray = spaceArray(any(spaceArray,2),:);

[endObjectDensity,endRiskToISS,endYearRisk,endSmallObjects,endLargeObjects,endSatRisk,sumEndSatRisk] = findStats(spaceArray);

data = [runNum,startObjectDensity,startRiskToISS',startYearRisk,startSmallObjects,startLargeObjects,startSatRisk',endObjectDensity,endRiskToISS',endYearRisk,endSmallObjects,endLargeObjects,endSatRisk',sumEndSatRisk,largeObjectCollisions,cloudCollisions,avoidanceActions,cleanedDebris,laseredDebris];
dlmwrite('SpaceJunkData.csv',data,'-append')
safetyVals = data;

end
