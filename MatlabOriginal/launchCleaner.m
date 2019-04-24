function spaceArray = launchCleaner()
    spaceArray =np.array([])
    randPos,randVel = getOrbit()
    creatorObject = CleanerSatellite(randPos,randVel,100)
    spaceArray = np.append(spaceArray,creatorObject)
    end