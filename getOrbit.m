function [randPos,randVel] = getOrbit(rangeOrbit,rangeVel,radOrbit)
    %debug code
    rangeOrbit = 1000;
    rangeVel = 100;
    radOrbit = 6371000 + 800000;            %The area of orbit I'm interested in (800 km area)
    
    
    gravitationalConstant = 6.674*10^(-11);
    massOfEarth = 5.972*(10^24);    

    randPos = rand(3,1)-.5;     %Find a random vector and normalize it
    pnorm = 1/norm(randPos);
    randPos = pnorm*randPos;
    
    randVelTemp = rand(1,3)-.5;  % take a random vector
    randVel = randVelTemp' - dot(randVelTemp,randPos) * randPos;       % make it orthogonal to k
    randVel = randVel/norm(randVel);  % normalize it
    
    vnorm = 1/(norm(randVel));
    randVel =randVel*vnorm;
    
    %Determine the magnitude of the velocity needed for a circular orbit
    randVelMag = sqrt(gravitationalConstant*massOfEarth/radOrbit); %FixMe: Add random term here to create non-circular orbits
    
    %Get random perturbations so not all orbits are perfectly circular and in the same location
    randPosPerturbation = (rand(3,1)-.5)*rangeOrbit;
    randVelPerturbation = (rand(3,1)-.1)*rangeVel;
    
    %multiply the vectors by their magnitudes
    randVel = randVel*randVelMag + randVelPerturbation;
    randPos = randPos*radOrbit + randPosPerturbation;