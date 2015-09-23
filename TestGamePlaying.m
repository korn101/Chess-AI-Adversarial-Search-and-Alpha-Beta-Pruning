%clear all the memory and console output
clc;
close all;

clear;

for branches = 1:4
    
    fprintf('=== BEGINNING BRANCH %d @ Time: %s ===\n', branches, datestr(now));
    
    games = {[]};
    
    % for every branching factor, play 10 games.
    for noGames = 1:10
        games{noGames} = GamePlayer(branches, '');
        games{noGames}.playGame();
        fprintf('-->Finised Game Test #%d \n', noGames);
    end
    
    % now calculate: avg game time for white.
    %                ratio of games won for white.
    %                number of moves needed to win for white.
    
    sumTimeWhite = 0;
    sumWhiteWins = 0;
    sumBlackWins = 0;
    sumMovesForWhite = 0;
    
    for i = 1:10
        % first sum up the number of white and black wins.
        if (games{i}.boolTie == false)
            if (games{i}.boolWhiteWin == true)
                sumWhiteWins = sumWhiteWins + 1;
                sumTimeWhite = sumTimeWhite + games{i}.totalGameTime;
                sumMovesForWhite = sumMovesForWhite + games{i}.totalMoves;
            else
                sumBlackWins = sumBlackWins + 1;
            end
            
        end
        
        
    end
    
    % at the end, calculate the averages.
    avgWinRatio = sumWhiteWins./(sumWhiteWins + sumBlackWins);
    avgMoves = sumMovesForWhite./(sumWhiteWins);
    avgTimeWhite = sumTimeWhite./sumWhiteWins;
    
    fprintf('Win Ratio: %d\n', avgWinRatio);
    fprintf('Average Moves to Win: %d\n', avgMoves);
    fprintf('Average Time to Win: %d\n', avgTimeWhite);
    
    % at the end of 10 games. Save the workspace.
    filename = strcat('run-', strcat(int2str(branches), '.mat'));
    save(filename);
    
    fprintf('=== ENDED BRANCH %d @ Time: %s ===\n', branches, datestr(now));
    
end
