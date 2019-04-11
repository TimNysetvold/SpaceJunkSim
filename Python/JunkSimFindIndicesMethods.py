# -*- coding: utf-8 -*-
"""
Created on Wed Mar 20 13:38:31 2019

@author: timny
"""

    """
    Possible alternative methods for finding collisions:
    
    x = [5,1,7,0,3,4,5,3,2,6,7,3,6]
    get_indexes = lambda x, xs: [i for (y, i) in zip(xs, range(len(xs))) if x <= y]
    print(get_indexes(collisionDistance,distancesArray))

    for yindex in range(xindex+1,distancesArray.shape[1]):
        if(distancesArray[xindex,yindex] < collisionDistance):
            collisions = np.append(collisions,[[xindex,yindex]],axis=0)
            
for iterator in range(1,collisions.shape[1]-1):
    print(collisions)
    row = collisions[iterator,:]
    spaceArray[row[0]].collide(spaceArray[row[1]]) 
    """
    #print(collisions)
            
    #print(deletionIndexes)
    #deletionIndexes = deletionIndexes.astype(int)
    #spaceArray = np.delete(spaceArray, deletionIndexes)

    #Now, we cycle through the array again and move the surviving elements.
    """
    spaceArray[1].active = False
    spaceArray[12].active = False
    spaceArray[55].active = False
    """