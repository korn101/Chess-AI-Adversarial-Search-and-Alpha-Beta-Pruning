%clear all the memory and console output
clc;
close all;

clear;

%load('run-2.mat');
load('run-2.mat');

sumD = 0; % average total depth per game
sumN = 0; % average number of nodes
sumT = 0; % average number of trees per game

avgDepths = cell(1,1);
avgNodes = cell(1,1);

for gameNo=1:2 % loop through all games.
    
    for treeNo = 1:games{gameNo}.totalMoves % loop over each tree.
        
        % sum the depths and number of nodes values for each tree.
        sumD = sumD + games{gameNo}.treeArray{treeNo}.totalDepth;
        sumN = sumN + games{gameNo}.treeArray{treeNo}.totalNodes;
        
        
    end
    
    avgDepths{gameNo} = sumD./games{gameNo}.totalMoves;
    avgNodes{gameNo} = sumN./games{gameNo}.totalMoves;
    
    sumN = 0;
    sumD = 0;
    sumT = sumT + games{gameNo}.totalMoves;
    
end

for i=1:2
    sumD = sumD + avgDepths{i};
    sumN = sumN + avgNodes{i};
end

averageNodesPerGame = sumN./5;
averageDepthPerGame = sumD./5;
avaregeTreesPerGame = sumT./5;