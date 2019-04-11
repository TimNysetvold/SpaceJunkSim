function spaceArray = launchObject(type,avObjSize)
        [randPos,randVel] = getOrbit();
        size = lognrnd(.2,1)*avObjSize;
        lookAhead = 0;
        creatorObject = [randPos',randVel',size,type,lookAhead]; %FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
        %6371000 is radius of the earth. We assume satellites are 100k up
        spaceArray = creatorObject;
end
    