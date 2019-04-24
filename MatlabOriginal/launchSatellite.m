function spaceArray = launchSatellite()
    spaceArray =np.array([])
    randPos,randVel = getOrbit()
    creatorObject = Satellite(randPos,randVel,100)
    spaceArray = np.append(spaceArray,creatorObject)
    end