import numpy as np
from numpy import *
import scipy
import scipy.linalg
from scipy import spatial
import matplotlib.pyplot as plt
from mpl_toolkits import mplot3d
#from guppy import hpy


#This is the space junk simulator made by Tim Nysetvold for ME 578. It is an agent-based model of low earth orbit.
#Each item in space is an object, which inherits the "SpaceObject" class defined below.


#h = hpy()

#Begin Independent Variables
startNumSpaceJunk = 20000



#Begin parameters
#All distances in meters, weights in kg, time in sec
collisionDistance = 1000      #The maximum radius of a single satellite
cleanerDistance = 10000       #The maximum distance any cleaner satellite can reach
radOrbit = 6471000            #The average radius of LEO (FixMe: this is not a validated value)


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
        #print(self.acceleration)
        self.active = True
        
    def collide(self,OtherSpaceObject):
        print("The Collide functionality is not yet available")
        self.die()
        
        
    def move(self):
        self.acceleration = -(gravitationalConstant*5.972*(10**24)*self.position)/(np.linalg.norm(self.position)**3)
        self.velocity = self.velocity + self.acceleration
        self.position = self.position + self.velocity
        #print(self.position)
        
    def die(self):
        #not complete
        self.position = np.array([[0,0,0]])
        self.velocity = np.array([[0,0,0]])
        self.active = False
        print("I DIED!")
        
    def whois(self):
        return "SpaceObject"
        
        
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
    def __init__(self,position,velocity,volume):
        SpaceObject.__init__(self,position,velocity,volume)
        
    def avoid(self,OtherSatellite):
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
        
    def clean(self,OtherSpaceObject):
        print("I cleaned:")
        print(OtherSpaceObject)
        OtherSpaceObject.die()
        
        
        
    def whois(self):
        return "CleanerSatellite"
        
    def __str__(self):
        return "A CleanerSatellite"



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
    
    #multiply the vectors by their magnitudes
    randVel = randVel*randVelMag
    randPos = randPos*radOrbit
    
    return randPos,randVel

#plt.ion()
#fig = plt.figure()
#ax = fig.add_subplot(111, projection='3d')
#positionArray = np.append(positionArray,np.array([[0,0,0]]),axis=0)
"""
xdata = positionArray[:,0]
ydata = positionArray[:,1]
zdata = positionArray[:,2]
"""
#datapoints = ax.scatter(xdata, ydata, zdata)
#fig.show()




##############################################################################
##############################################################################
##############################################################################
#######################Begin Instantiation####################################
##############################################################################
##############################################################################
##############################################################################
#Instantiation of different items

spaceArray = np.array([])
    
for x in range(0,startNumSpaceJunk):   
    #Creates spacejunk

    randPos,randVel = getOrbit()
    creatorObject = SpaceJunk(randPos,randVel,100) #FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
    #6371000 is radius of the earth. We assume satellites are 100k up
    spaceArray = np.append(spaceArray,creatorObject)
    #print(x)
    
for x in range(0,3):   
    #Creates satellites
    randPos,randVel = getOrbit()
    creatorObject = Satellite(randPos,randVel,100) #FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
    #6371000 is radius of the earth. We assume satellites are 100k up
    spaceArray = np.append(spaceArray,creatorObject)
    #print(x)
    
    
for x in range(0,3):   
    #Creates cleaners
    randPos,randVel = getOrbit()
    creatorObject = CleanerSatellite(randPos,randVel,100,6000) #FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
    #6371000 is radius of the earth. We assume satellites are 100k up
    spaceArray = np.append(spaceArray,creatorObject)
    #print(x)
    
    
    
#Debug code: used to set two orbital bodies close to each other
spaceArray[2].position = spaceArray[startNumSpaceJunk-100].position+1
spaceArray[3].position = spaceArray[startNumSpaceJunk+5].position+2

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
    positionArray = np.zeros((spaceArray.size,3))
    deletionIndices = np.array([])
    index = 0
    for x in spaceArray:
        position = x.position
        #print(position)
        position = np.ndarray.flatten(position)
        positionArray[index,0:3] = position
            
        #at the end of this, we increment the counter.
        index += 1
        
    #These lines find the distances between each object and every other object. 
    #They also take the majority of the compute resources
    distances = scipy.spatial.distance.pdist(positionArray,'euclidean')
    distancesArray = spatial.distance.squareform(distances)
    distancesArray = np.triu(distancesArray,1)
    distancesArray[distancesArray == 0] = 10e9
    
    collisionsIndexes = np.asarray(np.where(distancesArray <= collisionDistance)).T
    cleanablesIndexes = np.asarray(np.where(distancesArray <= cleanerDistance)).T
    
    counter = 0
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
                        currentObject.clean(spaceArray[indicesToCheck[0]])
                    elif spaceArray[indicesToCheck[1]].whois() == "SpaceJunk":
                        currentObject.clean(spaceArray[indicesToCheck[1]])
        
        elif objectType == "Satellite":
            print("Got a satellite")
        elif objectType == "SpaceJunk":
            closeToThisJunkIndices = np.where(collisionsIndexes[:,1] == counter)
            closeToThisJunk = collisionsIndexes[closeToThisJunkIndices]
            
            for iterator in range(0,int(closeToThisJunk.size/2)):    #Checks each element of the list individually for whether it can be cleaned by this particular satellite
                indicesToCheck = closeToThisJunk[iterator,:]
                print(distancesArray[indicesToCheck[0],indicesToCheck[1]])
                distBetweenObjects = np.copy(distancesArray[indicesToCheck[0],indicesToCheck[1]])
                otherObject = spaceArray[indicesToCheck[0]]
                if otherObject.whois() == "SpaceJunk":
                    if distBetweenObjects<=(currentObject.collideDistance+otherObject.collideDistance):
                        currentObject.collide(spaceArray[indicesToCheck[0]])
        else:
            print("Object Type Error")
            
        if currentObject.active == False:
            print(index)
            np.append(deletionIndices,index)
        else:
            currentObject.move()
            
        counter +=1
        index +=1
        #print(index)
        
        """
    if iteration%50 == 0:
        positionArray = np.append(positionArray,np.array([[0,0,0]]),axis=0)
        xdata = positionArray[1:500,0]
        ydata = positionArray[1:500,1]
        zdata = positionArray[1:500,2]
        #datapoints._offsets3d = (xdata,ydata,zdata)
        #ax.set_xlim(-9000000,9000000)
        #ax.set_ylim(-9000000,9000000)
        #ax.set_zlim(-9000000,9000000)
        #plt.draw()
        #plt.pause(1)
        """
    spaceArray = np.delete(spaceArray,deletionIndices)
    print(iteration)
    #print(h.heap())
    #print(spaceArray)

    
#anim = animation.FuncAnimation(fig,update,frames=25,init_func=init,interval=200,blit=True)

print("Made to below anim")

plt.show()

"""
dummy = SpaceObject(1,2,3)
dummy.split(1,1)
"""
        
        
    
    
    