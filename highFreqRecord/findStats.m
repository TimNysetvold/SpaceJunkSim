function [objectDensity,riskToISS,yearRisk,numSmallObjects,numLargeObjects,riskToRocket,sumRocketRisk] = findStats(spaceArray)
    objectDensity = 0;
    riskToISS = 0;
    numLargeObjects = 0;
    numSmallObjects = 0;
    for iterator=1:length(spaceArray)
        thisType = spaceArray(iterator,8);
        if thisType == 1
            numLargeObjects = numLargeObjects + 1;
        elseif thisType == 2
            numSmallObjects = numSmallObjects + abs(round(normrnd(30,15)))+10;
        elseif thisType == 3
            numLargeObjects = numLargeObjects + 1;
        elseif thisType == 4
            numLargeObjects = numLargeObjects + 1;
        elseif thisType ==5
        end
    end
    
    totObjects = numLargeObjects + numSmallObjects;
    
    %%%To use the FAA's collision risk calculator, values must be converted
    %%%to km instead of m.
    upperEdgeOrbit = 6371 + 800 + 10;
    lowerEdgeOrbit = 6371 + 800 - 10;
    volOrbit = 4/3*pi*upperEdgeOrbit^3 - 4/3*pi*lowerEdgeOrbit^3;
    objectDensity = totObjects/volOrbit;
    crossSectionalAreaISS =  74*110/(1000^2);
    Tyear = 60*60*24*365; %1 year in seconds
    avOrbitalVelocity = 10; %m/s; see relative velocity section of FAA paper
    
    Riss = crossSectionalAreaISS*objectDensity*avOrbitalVelocity*Tyear;
    riskToISS = zeros(10,1);
    for k=1:10
        riskToISS(k) = Riss^k*exp(-Riss)/(factorial(k));  
    end
    
    yearRisk = 1-exp(-Riss); 
    
    Tcross = 60*10; %10 minutes of crossing time; this is a guess
    crossSectionalAreaRocket = 70*3.66/(1000^2);
    Rrocket = crossSectionalAreaRocket*objectDensity*avOrbitalVelocity*Tcross;
    
    riskToRocket = zeros(10,1);
    for k=1:10
        riskToRocket(k) = Rrocket^k*exp(-Rrocket)/(factorial(k));  
    end
    sumRocketRisk = 1-exp(-Rrocket); 
    %1-exp(-AC*SPD*VR*T) https://www.faa.gov/about/office_org/headquarters_offices/ast/media/poisson.pdf
end