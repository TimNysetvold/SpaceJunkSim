function spaceArray = clean(spaceArray,collisionsIndexes,flag)
    for iterator = 1:length(collisionsIndexes)
        objectType = spaceArray(indexes(iterator),8);
        if objectType == 1 %If the object is intact space junk, it's eliminated.
            spaceArray(collisionsIndexes(iterator),:) = [0,0,0,0,0,0,0,0,1e15];
        elseif flag == 1 %Depending on the parameters of the sim, it might also eliminate clouds.
            if objectType == 2
                spaceArray(collisionsIndexes(iterator),:) = [0,0,0,0,0,0,0,0,1e15];
            end
        end
    end
end