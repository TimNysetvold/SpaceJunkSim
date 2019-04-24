clear all
min = 1e15;

for runNum = 1:28
    
    string = num2str(runNum);
    name = strcat('SpaceJunkData',string,'.csv');
    data = csvread(name);
    pastVal = 0;
    
    [C,ia,ic] = unique(data(:,1),'rows','last');
    dataParsed = data(ia,:);
    
    dataSave(runNum,:,:) = dataParsed(end-5345:end,:);
    
    minCandidate = dataParsed(end,1);
    if minCandidate<min
        min = minCandidate;
    end
    
end

for runNum2 = 1:28
    temp = squeeze(dataSave(runNum2,:,:));
    minIndex = find(temp(:,1)==min);
    debug = temp(minIndex,:);
    finalReport(runNum2,:) = temp(minIndex,:);
end
csvwrite('SpaceJunkDataParse.csv',finalReport)

