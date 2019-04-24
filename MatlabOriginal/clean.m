function spaceArray = clean(spaceArray,junkIndexes,flag)
    for iterator = 1:length(junkIndexes)
        objectType = spaceArray(junkIndexes(iterator),8);
        if objectType == 1 %If the object is intact space junk, it's eliminated.
            spaceArray(junkIndexes(iterator),:) = [0,0,0,0,0,0,0,6,1e15];
        elseif flag == 1 %Depending on the parameters of the sim, it might also eliminate clouds.
            if objectType == 2
                spaceArray(junkIndexes(iterator),:) = [0,0,0,0,0,0,0,6,1e15];
            end
        end
    end
end