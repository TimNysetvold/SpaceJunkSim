import numpy as np
from numpy import *
import scipy
import scipy.linalg
from scipy import spatial
import matplotlib.pyplot as plt
from mpl_toolkits import mplot3d
import collections
import itertools as IT
#from guppy import hpy


#This is the space junk simulator made by Tim Nysetvold for ME 578. It is an agent-based model of low earth orbit.
#Each item in space is an object, which inherits the "SpaceObject" class defined below.


#h = hpy()

#Begin Independent Variables
startNumSpaceJunk = 20000
launchRate = 1 #per 10 iterations, right now. Will be changed to per day
avSatelliteLife = 10000 #iterations, right now; will be changed to days
rangeSatelliteLife = 10000 #iterations, right now; will be changed to days
avJunkSize = 1 #m^2
avSatelliteSize = 10 #m^2
rangeOrbit = 10000
rangeVel = 100

startNumLasers = 3
startNumSatellites = 3
startNumCleaners = 3



#Begin parameters
#All distances in meters, weights in kg, time in sec
collisionDistance = 20        #The maximum radius of a single satellite; 20 m
cleanerDistance = 100         #The maximum distance any cleaner satellite can reach; 100m
laserDistance = 10000         #The maximum field of view of any laser; 10km
watchDistance = 100000       #The distance at which we begin watching satellites every second instead of every 100 seconds; 100km
radOrbit = 6471000            #The average radius of LEO (FixMe: this is not a validated value)
timestep = .001               #given in seconds
majortimestep = 100           #also seconds 


#Begin constants
gravitationalConstant = 6.674*10**(-11)
massOfEarth = 5.972*(10**24)

#Earth's radius is 6,371,000 meters, + max 2,000,000 meters of altitude. Min 161000 m altitude.


class SpaceObject:
    def __init__(self, position, velocity, volume):
        
        #properties that must be defined for each space object
        self.position = position
        #print(position)
        self.velocity = velocity
        #print(velocity)
        self.volume = volume
        self.acceleration = -(gravitationalConstant*massOfEarth*self.position)/(np.linalg.norm(self.position)**3)
        self.nearestNeighbors = np.array([])
        #print(self.acceleration)
        self.active = True
        
    def collide(self,otherSpaceObject,distBetweenObjects):
        creatorObjectArray = np.array([])
        totalRadius = self.collideDistance+otherSpaceObject.collideDistance
        overlap = (totalRadius-distBetweenObjects)/totalRadius
        numFragments = int(np.random.rand(1)*overlap*self.volume*otherSpaceObject.volume)       #Approximate value; appears reasonable considering data from file:///C:/Users/timny/OneDrive/Desktop/Satellite_Collision_Modeling_with_Physics-Based_Hy.pdf
        volDistributionGenerator =  np.random.rand(numFragments)
        normalizer = np.sum(volDistributionGenerator)
        volDistribution = (volDistributionGenerator/normalizer)*(self.volume+otherSpaceObject.volume)
        velDistributionGeneratorSelf = np.random.rand(1,numFragments)
        velDistributionGeneratorOther = np.random.rand(1,numFragments)
        velDistributionSelf = (velDistributionGeneratorSelf)*(self.velocity)
        velDistributionOther = (velDistributionGeneratorOther)*(otherSpaceObject.velocity)
        velDistribution = velDistributionSelf+velDistributionOther
        for n in range(0,numFragments):
            velocity = np.transpose([velDistribution[:,n]])
            #print(velocity)
            creatorObjectArray = np.append(creatorObjectArray,SpaceJunk(self.position,velocity,volDistribution[n])) #FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?

        return creatorObjectArray
        
    def changeVolume(self,volume):
        self.volume = volume
        
    def move(self):
        self.acceleration = -(gravitationalConstant*5.972*(10**24)*self.position)/(np.linalg.norm(self.position)**3)
        self.velocity = self.velocity + self.acceleration*timestep
        self.position = self.position + self.velocity*timestep
        if not all(np.isfinite(self.position)):
            print("error")
        #print(self.position)
        
    def whois(self):
        return "SpaceObject"
    
    def die(self):
        self.active = False
        self.position = np.ones((3,1))
        
        
    def __str__(self):
        return "A SpaceObject"
    
    
class SpaceJunk(SpaceObject):
    def __init__(self,position,velocity,volume):
        SpaceObject.__init__(self,position,velocity,volume)
        self.collideDistance = (self.volume*3/(4*np.pi))**(1/3)
        
    def whois(self):
        return "SpaceJunk"
        
    def __str__(self):
        return "SpaceJunk"
       
class Satellite(SpaceObject):
    def __init__(self,position,velocity,volume):    #(self,position,velocity,volume,avLife,rangeLife)
        SpaceObject.__init__(self,position,velocity,volume)
        #self.life = np.random.rand()*rangeLife+avLife
        
    def avoid(self,OtherSatellite):
        self.life = self.life-30
        print("This Functionality is not yet available")
        
    def whois(self):
        return "Satellite"
        
    def __str__(self):
        return "A Satellite"
    
class CleanerSatellite(Satellite):
    def __init__(self,position,velocity,volume,cleanDistance):
        SpaceObject.__init__(self,position,velocity,volume)
        self.cleanDistance = cleanDistance
        
    def avoid(self,OtherSatellite):
        print("This Functionality is not yet available")        
        
        
    def whois(self):
        return "CleanerSatellite"
        
    def __str__(self):
        return "A CleanerSatellite"
    
class LaserBroom(SpaceObject):
    def __init__(self, viewCenter, fieldOfView):
        self.viewCenter = viewCenter
        self.fieldOfView = fieldOfView
        self.position = viewCenter
        self.cooldown  = 0
        self.maxCoolDown = 100
        self.active = True
        
    def move(self):
        #overloaded; laser views do not move over time
        return 1
        
    def shootdown(self,otherSpaceObject):
        self.cooldown = self.maxCoolDown
        otherSpaceObject.die()
        print("This functionality is not yet debugged")
        
    def whois(self):
        return "LaserBroom"
        
    def __str__(self):
        return "A LaserBroom"
    
    def coolLaser(self):
        if self.cooldown > 0:
            self.cooldown -= 1
        else:
            self.cooldown = 0



def getOrbit():
    
    randPos = np.random.rand(3,1)-.5    #Find a random vector and normalize it
    pnorm = 1/np.linalg.norm(randPos)
    randPos = pnorm*randPos
    
    randVelTemp = np.random.rand(1,3)-.5  # take a random vector
    randVel = np.transpose(randVelTemp) - randVelTemp.dot(randPos) * randPos       # make it orthogonal to k
    randVel /= np.linalg.norm(randVel)  # normalize it
    
    vnorm = 1/(np.linalg.norm(randVel))
    randVel *= vnorm
    
    #Determine the magnitude of the velocity needed for a circular orbit
    randVelMag = np.sqrt(gravitationalConstant*massOfEarth/radOrbit) #FixMe: Add random term here to create non-circular orbits
    
    #Get random perturbations so not all orbits are perfectly circular and in the same location
    randPosPerturbation = (np.random.rand(3,1)-.5)*rangeOrbit
    randVelPerturbation = (np.random.rand(3,1)-.1)*rangeVel
    
    #multiply the vectors by their magnitudes
    randVel = randVel*randVelMag + randVelPerturbation
    randPos = randPos*radOrbit + randPosPerturbation
    
    return randPos,randVel

def launchJunk():
    spaceArray =np.array([])
    randPos,randVel = getOrbit()
    creatorObject = SpaceJunk(randPos,randVel,100)
    spaceArray = np.append(spaceArray,creatorObject)
    return(spaceArray)
    
def launchSatellite():
    spaceArray =np.array([])
    randPos,randVel = getOrbit()
    creatorObject = Satellite(randPos,randVel,100)
    spaceArray = np.append(spaceArray,creatorObject)
    return(spaceArray)

def launchCleaner():
    spaceArray =np.array([])
    randPos,randVel = getOrbit()
    creatorObject = CleanerSatellite(randPos,randVel,100)
    spaceArray = np.append(spaceArray,creatorObject)
    return(spaceArray)
    
def using_loop(matrix,criteria):
    output = np.array([])
    index1 = 0
    for item in matrix:
        if any(item == criteria):
            index2 = 0
            for item2 in item:
                if item2 == criteria:
                    output = np.append(output,[index1,index2])
                else:
                    index2 +=1
        index1 +=1
    return output

def val_less(matrix,criteria):
    output = np.array([])
    index1 = 0
    for item in matrix:
        if any(item <= criteria):
            index2 = 0
            for item2 in item:
                if item2 <= criteria:
                    output = np.append(output,[index1,index2])
                else:
                    index2 +=1
        index1 +=1
    return output


##############################################################################
##############################################################################
##############################################################################
#######################Begin Instantiation####################################
##############################################################################
##############################################################################
##############################################################################
#Instantiation of different items

spaceArray = np.array([])
creatorObjectArray = np.array([])

plt.ion()
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
positionArray = np.array([[0,0,0]])
xdata = positionArray[:,0]
ydata = positionArray[:,1]
zdata = positionArray[:,2]
datapoints = ax.scatter(xdata, ydata, zdata)
fig.show()

    
for x in range(0,startNumSpaceJunk):   
    #Creates spacejunk
    randPos,randVel = getOrbit()
    size = np.random.logseries(.333)*avJunkSize
    creatorObject = SpaceJunk(randPos,randVel,size) #FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
    #6371000 is radius of the earth. We assume satellites are 100k up
    spaceArray = np.append(spaceArray,creatorObject)
    #print(x)
    
for x in range(0,startNumSatellites):   
    #Creates satellites
    randPos,randVel = getOrbit()
    size = np.random.logseries(.333)*avSatelliteSize
    creatorObject = Satellite(randPos,randVel,size) #FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
    #6371000 is radius of the earth. We assume satellites are 100k up
    spaceArray = np.append(spaceArray,creatorObject)
    #print(x)
    
    
for x in range(0,startNumCleaners):   
    #Creates cleaners
    randPos,randVel = getOrbit()
    size = np.random.logseries(.333)*avSatelliteSize
    creatorObject = CleanerSatellite(randPos,randVel,size,6000) #FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
    #6371000 is radius of the earth. We assume satellites are 100k up
    spaceArray = np.append(spaceArray,creatorObject)
    #print(x)
    
    
for x in range(0,startNumLasers):
    #Creates laser brooms
    randPos,randVel = getOrbit()
    creatorObject = LaserBroom(randPos,1000)
    spaceArray = np.append(spaceArray,creatorObject)
    
    
    
#Debug code: used to set two orbital bodies close to each other
#spaceArray[2].position = spaceArray[startNumSpaceJunk-100].position+1
spaceArray[3].position = spaceArray[startNumSpaceJunk+5].position+2
watchedIndexes = np.array([])
deletionIndices = np.array([])


##############################################################################
##############################################################################
##############################################################################
#########################Begin Iterator Loop##################################
##############################################################################
##############################################################################
##############################################################################

#Now we will create the main control loop. Each pass through this loop constitutes one time step of travel.
for iteration in range(0,5):
    #print(iteration)
    
    #Instantiate various matrices needed fresh each loop
    positionArraySize = spaceArray.size
    positionArray = np.zeros((positionArraySize,3))
    
    #If necessary, launch an additional satellite
    if iteration%launchRate == 0:
        tempCreator = launchJunk()
        creatorObjectArray = np.append(creatorObjectArray,tempCreator)
    
    index = 0
    for x in spaceArray:
        position = x.position
        #print(position)
        position = np.ndarray.flatten(position)
        positionArray[index,0:3] = position
        if np.linalg.norm(position) <= 161000 and x.active:
            #if a satellite is below the lower limit of low earth orbit, it is eliminated due to atmospheric drag.
            print("Satellite %f fell into the atmosphere",index)
            deletionIndices = np.append(deletionIndices,index)
            x.die()
            
        #at the end of this, we increment the counter.
        index += 1
        
    """
    for x in laserArray:
        position = x.viewCenter
        position = np.ndarray.flatten(position)
        positionArray[index,0:3] = position
        
        index +=1
    """
        
    #These lines find the distances between each object and every other object. 
    #They also take the majority of the compute resources
    
    if iteration%majortimestep == 0:
        
        
        #In this section, we eliminate references to deleted objects
        if iteration != 0:
            print(deletionIndices)
            spaceArray = np.delete(spaceArray,deletionIndices.astype(int))
            spaceArray = np.append(spaceArray,creatorObjectArray)
            deletionIndices = np.array([])
            creatorObjectArray = np.array([])
        
        distances = scipy.spatial.distance.pdist(positionArray,'euclidean')
        distancesArray = spatial.distance.squareform(distances)
        distancesArray = np.triu(distancesArray,1)
        distancesArray[distancesArray == 0] = 10e9
    else:
        for element in watchedIndexes:
            index1 = int(element[0])
            index2 = int(element[1])
            object1 = spaceArray[index1]
            object2 = spaceArray[index2]
            if object1.active == True and object2.active == True:
                position1 = object1.position
                position2 = object2.position
                distancesArray[index1,index2] = np.linalg.norm(position1-position2)
            else:
                distancesArray[index1,index2] = 1e9
        
    
    collisionsIndexes = np.asarray(np.where(distancesArray <= collisionDistance)).T
    cleanablesIndexes = np.asarray(np.where(distancesArray <= cleanerDistance)).T
    lasersIndexes = np.asarray(np.where(distancesArray <= laserDistance)).T
    watchedIndexes = np.asarray(np.where(distancesArray <= watchDistance)).T
    
    
    #Set index for loop
    index = 0
    for currentObject in spaceArray:
        
        objectType = currentObject.whois()
        
        if objectType == "CleanerSatellite":
            #In here, we figure out whether the cleaner satellite is close enough to any junk to clean it.
            closeToThisCleanerIndices = np.where(cleanablesIndexes[:,1] == index)
            closeToThisCleaner = cleanablesIndexes[closeToThisCleanerIndices]
            
            for iterator in range(0,int(closeToThisCleaner.size/2)):    #Checks each element of the list individually for whether it can be cleaned by this particular satellite
                indicesToCheck = closeToThisCleaner[iterator,:]
                distBetweenObjects = np.copy(distancesArray[indicesToCheck[0],indicesToCheck[1]])
                if distBetweenObjects<=currentObject.cleanDistance:
                    if spaceArray[indicesToCheck[0]].whois() == "SpaceJunk":
                        deletionIndices = np.append(deletionIndices,indicesToCheck[0])
                        spaceArray[indicesToCheck[0]].die()
                        print("cleaned something")
                    elif spaceArray[indicesToCheck[1]].whois() == "SpaceJunk":
                        deletionIndices = np.append(deletionIndices,indicesToCheck[1])
                        spaceArray[indicesToCheck[1]].die()
                        print(deletionIndices)
                        print("Cleaner Elif Validated")
        
        elif objectType == "Satellite":
            print("Got a satellite")
            
        elif objectType == "LaserBroom":
            if currentObject.cooldown == 0 :
                closeToThisLaserIndices = np.where(lasersIndexes[:,1] == index)
                closeToThisLaser = lasersIndexes[closeToThisLaserIndices]
                for iterator in range(0,int(closeToThisLaser.size/2)):    #Checks each element of the list individually for whether it can be cleaned by this particular satellite
                    indicesToCheck = closeToThisLaser[iterator,:]
                    distBetweenObjects = np.copy(distancesArray[indicesToCheck[0],indicesToCheck[1]])
                    otherObject = spaceArray[indicesToCheck[0]]
                    if otherObject.whois() == "SpaceJunk":
                        if distBetweenObjects<=(x.fieldOfView):
                            x.shootdown(otherObject)
                            deletionIndices = np.append(deletionIndices,int(indicesToCheck[0]))
                            print("Shot at something")
                            break            
            else:
                currentObject.coolLaser()
            
        elif objectType == "SpaceJunk":
            closeToThisJunkIndices = np.where(collisionsIndexes[:,1] == index)
            closeToThisJunk = collisionsIndexes[closeToThisJunkIndices]
            
            for iterator in range(0,int(closeToThisJunk.size/2)):    #Checks each element of the list individually for whether it can be cleaned by this particular satellite
                indicesToCheck = closeToThisJunk[iterator,:]
                distBetweenObjects = np.copy(distancesArray[indicesToCheck[0],indicesToCheck[1]])
                otherObject = spaceArray[indicesToCheck[0]]
                if otherObject.whois() == "SpaceJunk":
                    if distBetweenObjects<=(currentObject.collideDistance+otherObject.collideDistance):
                        newJunk = currentObject.collide(spaceArray[indicesToCheck[0]],distBetweenObjects)
                        creatorObjectArray = np.append(creatorObjectArray,newJunk)
                        deletionIndices = np.append(deletionIndices,int(indicesToCheck)) #FixMe: not how this works
                        currentObject.die()
                        otherObject.die()
                        print("collided")
                        
        else:
            print("Object Type Error")
            
        
        currentObject.move()
            
        index +=1
        #print(index)
        

        
    if iteration%3 == 0:
        positionArray = np.append(positionArray,np.array([[0,0,0]]),axis=0)
        xdata = positionArray[1:500,0]
        ydata = positionArray[1:500,1]
        zdata = positionArray[1:500,2]
        datapoints._offsets3d = (xdata,ydata,zdata)
        ax.set_xlim(-9000000,9000000)
        ax.set_ylim(-9000000,9000000)
        ax.set_zlim(-9000000,9000000)
        plt.draw()
        plt.pause(1)
               
            
    
    
    print(iteration)
    #print(h.heap())
    #print(spaceArray)

    
#anim = animation.FuncAnimation(fig,update,frames=25,init_func=init,interval=200,blit=True)
orbitRisk = 1
print("Made to below anim")
print(spaceArray.shape)
print(orbitRisk)
plt.show()

"""
dummy = SpaceObject(1,2,3)
dummy.split(1,1)
"""
        
        
    
    
    