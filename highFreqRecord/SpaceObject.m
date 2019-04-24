classdef SpaceObject
    
    properties 
    %properties that must be defined for each space object
    position
    velocity
    volume
    acceleration
    active
    name
    collideDistance
    end

    methods
        function obj = SpaceObject(position, velocity, volume)
            global massOfEarth
            global gravitationalConstant
            
            obj.position = position;
            %print(position)
            obj.velocity = velocity;
            %print(velocity)
            obj.volume = volume;
            obj.acceleration = -(gravitationalConstant*massOfEarth*obj.position)/(norm(obj.position)^3);
            %print(obj.acceleration)
            obj.active = 1;
        end
        
        
        
        function creatorObjectArray = collide(obj,otherSpaceObject,distBetweenObjects)
            creatorObjectArray = [];
            totalRadius = obj.collideDistance+otherSpaceObject.collideDistance;
            overlap = (totalRadius-distBetweenObjects)/totalRadius;
            numFragments = int(rand(1)*overlap*obj.volume*otherSpaceObject.volume);   %Approximate value; appears reasonable considering data from file:///C:/Users/timny/OneDrive/Desktop/Satellite_Collision_Modeling_with_Physics-Based_Hy.pdf
            volDistributionGenerator =  rand(numFragments);
            normalizer = nsum(volDistributionGenerator);
            volDistribution = (volDistributionGenerator/normalizer)*(obj.volume+otherSpaceObject.volume);
            velDistributionGeneratorobj = rand(1,numFragments);
            velDistributionGeneratorOther = rand(1,numFragments);
            velDistributionobj = (velDistributionGeneratorobj)*(obj.velocity);
            velDistributionOther = (velDistributionGeneratorOther)*(otherSpaceObject.velocity);
            velDistribution = velDistributionobj+velDistributionOther;
            for n=0:numFragments
                vel = velDistribution(:,n)';
                creatorObjectArray = [creatorObjectArray;SpaceJunk(obj.position,vel,volDistribution(n))] %FixMe: this line does not have altitude variation right now. It's also broken in other ways. Vel should be 7800?
            end 
        end

        function obj = changeVolume(obj,volume)
            obj.volume = volume;
        end

        function obj = move(obj)
            global massOfEarth
            global gravitationalConstant
            global timestep
            obj.acceleration = -(gravitationalConstant*massOfEarth*obj.position)/(norm(obj.position)^3);
            obj.velocity = obj.velocity + obj.acceleration*timestep;
            obj.position = obj.position + obj.velocity*timestep;
            if ~all(isfinite(obj.position)) 
                print("error")
            %print(obj.position)
            end
        end
        
        function obj = die(obj)
            obj.active = False;
            obj.position = ones(3,1);
        end
    end
end

