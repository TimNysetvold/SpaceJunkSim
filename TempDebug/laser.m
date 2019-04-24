function [spaceArray,laseredDebris] = laser(indexes,spaceArray,laseredDebris)
    global timestep
    for iterator = 2:length(indexes)
        objectType = spaceArray(indexes(iterator),8);
        if objectType == 1 || objectType == 2
            spaceArray(indexes(iterator),:) = [0,0,0,0,0,0,0,6,1e9];
            spaceArray(indexes(1),9) = spaceArray(indexes(1),9) + 60*10/timestep; %thirty minutes of cooldown per shot
            laseredDebris = laseredDebris+1;
            break
        end
    end
end