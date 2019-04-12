function spaceArray = laser(indexes,spaceArray)
    global timestep
    for iterator = 2:length(indexes)
        objectType = spaceArray(indexes(iterator),8);
        if objectType == (1 | 2)
            spaceArray(indexes(iterator),:) = [0,0,0,0,0,0,0,0,1e15];
            laserArray(indexes(1),9) = 180/timestep; %three minutes of cooldown per shot
            break
        end
    end
end