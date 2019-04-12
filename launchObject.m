function spaceArray = launchObject(type,avObjSize,avObjStDv,velOverride)
    if nargin==3
        [randPos,randVel] = getOrbit();
        size = normrnd(avObjSize,avObjStDv);
        lookAhead = 0;
        creatorObject = [randPos',randVel',size,type,lookAhead]; %FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
        %6371000 is radius of the earth. We assume satellites are 100k up
        spaceArray = creatorObject;
    elseif nargin == 4
        [randPos,~] = getOrbit();
        size = normrnd(avObjSize,avObjStDv);
        lookAhead = 0;
        creatorObject = [randPos',velOverride,size,type,lookAhead]; %FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
        %6371000 is radius of the earth. We assume satellites are 100k up
        spaceArray = creatorObject;
    end
end
    