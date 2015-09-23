%clear all the memory and console output
clc;
close all;

clear;

avgTimes = cell(1,1); % stores the number of average times for each respective branch factor
avgDepth = cell(1,1); % stores average depths
avgNodes = cell(1,1); % average number of nodes.
avgABTime = cell(1,1); % average time taken to perform an AB search.
avgABRatio = cell(1,1); % average ratio of the tree that was visited by AB.

noOfTrees = 10; % number of trees to average for each calculation.

for branchingFactors = 1:4
    
    fprintf('Testing branch factor = %d..\n', branchingFactors);
    
    treeArray = cell(1,1);
    timeArray = cell(1,1);
    depthArray = cell(1,1);
    abTimeArray = cell(1,1);
    abRatioArray = cell(1,1);
    
    for testNumber = 1:noOfTrees
        treeArray{testNumber} = Tree(branchingFactors, ''); % init tree
        
        tTestTime = tic;
        treeArray{testNumber}.buildMinMax(6); % build minmax and time
        tElapsed = toc(tTestTime);
        
        timeArray{testNumber} = tElapsed; % store the time in time array.
        
        depthArray{testNumber} = treeArray{testNumber}.totalDepth; % store the depth it got up to in time array.
        
        tTestAB = tic;
        treeArray{testNumber}.doAlphaBeta(treeArray{testNumber}.Root, treeArray{testNumber}.totalDepth - 1, -1*inf, 1*inf, true);
        tElapsedAB = toc(tTestAB);
        
        abTimeArray{testNumber} = tElapsedAB; % store the time taken for AB in seconds
        abRatioArray{testNumber} = ((treeArray{testNumber}.noVisitedAlphaBeta)./(treeArray{testNumber}.totalNodes)); % calculate ratio of nodes visited by AB.
    end
    
    % now that we have a table of times and depths, we can get our
    % averages.
    
    sumT = 0;
    sumD = 0;
    sumN = 0;
    sumABT = 0;
    sumABR = 0;
    for i=1:noOfTrees
        
        sumT = sumT + timeArray{i};
        sumD = sumD + depthArray{i};
        sumN = sumN + treeArray{i}.totalNodes;
        sumABT = sumABT + abTimeArray{i};
        sumABR = sumABR + abRatioArray{i};
    end
    
    avgTimes{branchingFactors} = sumT./noOfTrees;
    avgDepth{branchingFactors} = sumD./noOfTrees;
    avgNodes{branchingFactors} = sumN./noOfTrees;
    avgABTime{branchingFactors} = sumABT./noOfTrees;
    avgABRatio{branchingFactors} = sumABR./noOfTrees;
    
    fprintf('For branch factor: %d, avgABTime was %d, and avgABRatio was %d\n', branchingFactors, avgABTime{branchingFactors}, avgABRatio{branchingFactors});
    
end