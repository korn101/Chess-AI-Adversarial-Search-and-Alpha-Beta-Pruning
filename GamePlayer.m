% this class defines a game player object which will run an entire game and
% at the end store values of:
%   - whether it was a win or loss for white
%   - time of a game
%   - final winning move

classdef GamePlayer < handle
    properties (Hidden)
        
    end
    
    properties (GetAccess = public, SetAccess = private)
        currentCM; % the current chess master game being played.
        movesArray; % current moves array.
        treeArray; % store the tree structures
        boolTie; % was it a draw?
        boolWhiteWin; % did white win?
        totalGameTime; % how long did this game take?
        strWinningMove; % how was the game won?
        strWinFEN; % the winning end game.
        totalMoves;
        branchFactor;
    end
    
    events
        %specify events
    end
    
    
    methods
        function GAMEPLAYER = GamePlayer(branchFact, FEN)
            GAMEPLAYER.currentCM = ChessMaster;
            
            GAMEPLAYER.currentCM.SpawnChessEngine(); %Creates a new chess enigne object, and opens the ChessEngine window.
            GAMEPLAYER.currentCM.CElist(1).autocolor=2; %Changes the autoplay color to black.
            GAMEPLAYER.currentCM.CElist(1).alock=0; %Tells the AI to not automatically start play.
            GAMEPLAYER.currentCM.CElist(1).execMode = 3;%Tells the AI to chose 'Play' as execution mode.
            GAMEPLAYER.currentCM.CElist(1).playMode = 1;%Tells the AI the playmode.
            
            % ANALYSIS
            GAMEPLAYER.currentCM.SpawnChessEngine(); %Creates a new chess enigne object, and opens the ChessEngine window.
            GAMEPLAYER.currentCM.CElist(2).autoanalyze = 1; %Sets the AI to autoanalyze.
            GAMEPLAYER.currentCM.CElist(2).autocolor=3; %Changes the autoplay color to both.
            GAMEPLAYER.currentCM.CElist(2).alock=1; %Tells the AI to start autoanalyze.
            GAMEPLAYER.currentCM.CElist(2).execMode = 4;%Tells the AI to chose 'Analize' as execution mode.
            GAMEPLAYER.currentCM.CElist(2).playMode = 2;%Tells the AI the playmode.
            GAMEPLAYER.currentCM.CElist(2).newGame=0;%Tells the AI that a new game has already begun.
            
            % We now have Chess Master game running in the background.
            
            % The basic idea is to:
            %   Build a forward-looking minimax with a chosen branch factor
            %   Use Alpha-Beta pruning to choose the best move to make next.
            %   Save this move to a player move array.
            %   Discard the old tree.
            %   Make the move.
            %   Wait for StockFish response
            %   Repeat
            
            GAMEPLAYER.movesArray = {[]};
            GAMEPLAYER.treeArray = {[]};
            GAMEPLAYER.boolTie = true; % assume that a tie occurs
            GAMEPLAYER.totalMoves = 0;
            GAMEPLAYER.branchFactor = branchFact;
            GAMEPLAYER.currentCM.LoadPosition(FEN);
            
        end
        
        function playGame(GAMEPLAYER)
            % play a game limited to 50 moves in this GamePlayer object
            % until a win or 50 moves is surpassed.
            
            tTicker = tic;
            
            for noMoves = 1:50
                GAMEPLAYER.treeArray{noMoves} = Tree(GAMEPLAYER.branchFactor, GAMEPLAYER.currentCM.GetFENstr());
                
                GAMEPLAYER.treeArray{noMoves}.buildMinMax(6);
                
                bests = cell(1,1);
                maxFound = -1*inf;
                maxFoundIndex = 1;
                
                for i = 1:GAMEPLAYER.treeArray{noMoves}.branchFactor
                    if (GAMEPLAYER.treeArray{noMoves}.Root.numberOfNodes >= GAMEPLAYER.treeArray{noMoves}.branchFactor)
                        bests{i} =  GAMEPLAYER.treeArray{noMoves}.doAlphaBeta(GAMEPLAYER.treeArray{noMoves}.Root.Nodes{i}, GAMEPLAYER.treeArray{noMoves}.totalDepth - 1, -1*inf, 1*inf, true);
                        if bests{i} > maxFound
                            maxFound = bests{i};
                            maxFoundIndex = i;
                        end
                    end
                end
                
                %
                
                % now that we have the index of the best move. Let's make it.
                GAMEPLAYER.movesArray{noMoves} = GAMEPLAYER.treeArray{noMoves}.Root.Nodes{maxFoundIndex}.getString();
                
                GAMEPLAYER.currentCM.MakeMove(GAMEPLAYER.movesArray{noMoves});
                
                % evaluate the game:
                
                while (GAMEPLAYER.currentCM.CElist(2).tlock==true) %Check if the thinking lock is active on the CElist(1) engine. If the lock is active the AI is still searching for the best move.
                    pause(0.001);%Check every 0.05s.
                end
                
                if (GAMEPLAYER.currentCM.CElist(2).viewScore > 10) %Extract the score of the board using the CElist 2 engine. Positive score will benefit White, negative benefits black.
                    %fprintf('Outcome Apparent - WHITE WINS\n');
                    GAMEPLAYER.boolTie = false;
                    GAMEPLAYER.boolWhiteWin = true;
                    GAMEPLAYER.totalMoves = noMoves; % record the number of moves made.
                    break;
                elseif (GAMEPLAYER.currentCM.CElist(2).viewScore < -10)
                    %fprintf('Outcome Apparent - BLACK WINS\n');
                    GAMEPLAYER.boolTie = false;
                    GAMEPLAYER.boolWhiteWin = false;
                    GAMEPLAYER.totalMoves = noMoves; % record the number of moves made.
                    break;
                end
                
                % also check that checkmate hasnt happened.
                currMoves = GAMEPLAYER.currentCM.GetSANstrs();
                % if we got the enemy in checkmate, break.
                if (isempty(strfind(char(currMoves((noMoves*2) - 1)), '#')) == false) % did we get the AI in check ?
                    GAMEPLAYER.boolTie = false;
                    GAMEPLAYER.boolWhiteWin = true;
                    GAMEPLAYER.totalMoves = noMoves;
                    break; % break out.
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % now tell black to move, wait for him and then proceed when he
                % finishes. (and turn AI off)
                GAMEPLAYER.currentCM.CElist(1).alock=1;
                GAMEPLAYER.currentCM.AutoPlay();
                while (GAMEPLAYER.currentCM.turnColor == 2)
                    pause(0.001);
                end
                GAMEPLAYER.currentCM.CElist(1).alock=0;
                
                while (GAMEPLAYER.currentCM.CElist(2).tlock==true) %Check if the thinking lock is active on the CElist(1) engine. If the lock is active the AI is still searching for the best move.
                    pause(0.001);%Check every 0.05s.
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                if (GAMEPLAYER.currentCM.CElist(2).viewScore > 10) %Extract the score of the board using the CElist 2 engine. Positive score will benefit White, negative benefits black.
                    %fprintf('Outcome Apparent - WHITE WINS\n');
                    GAMEPLAYER.boolTie = false;
                    GAMEPLAYER.boolWhiteWin = true;
                    GAMEPLAYER.totalMoves = noMoves; % record the number of moves made.
                    break;
                elseif (GAMEPLAYER.currentCM.CElist(2).viewScore < -10)
                    %fprintf('Outcome Apparent - BLACK WINS\n');
                    GAMEPLAYER.boolTie = false;
                    GAMEPLAYER.boolWhiteWin = false;
                    GAMEPLAYER.totalMoves = noMoves; % record the number of moves made.
                    break;
                end
                
                % also check that checkmate hasnt happened.
                currMoves = GAMEPLAYER.currentCM.GetSANstrs();
                % if we got the enemy in checkmate, break.
                if (isempty(strfind(char(currMoves((noMoves*2))), '#')) == false) % did the AI get US in checkmate?
                    GAMEPLAYER.boolTie = false;
                    GAMEPLAYER.boolWhiteWin = false;
                    GAMEPLAYER.totalMoves = noMoves;
                    break; % break out.
                end
                
                
                
            end
            
            % at this point we know the game is over. Toc the timer.
            GAMEPLAYER.totalGameTime = toc(tTicker) ./ 60;
            
            GAMEPLAYER.strWinningMove = GAMEPLAYER.currentCM.GetLANstrs();
            GAMEPLAYER.strWinFEN = GAMEPLAYER.currentCM.GetFENstr();
            
            %GAMEPLAYER.currentCM.Close();
            if (GAMEPLAYER.boolTie == true)
                GAMEPLAYER.totalMoves = 50;
            end
            
            fprintf('====\nThe game with BF %d ended in %d moves, ', GAMEPLAYER.branchFactor,GAMEPLAYER.totalMoves);
            if (GAMEPLAYER.boolTie == true)
                fprintf('The game was a tie.');
            else
                if (GAMEPLAYER.boolWhiteWin == true)
                    fprintf('with WHITE winning.\n');
                else
                    fprintf('with BLACK winning.\n');
                end
            end
            fprintf('and ran for %d minutes\n=====\n', GAMEPLAYER.totalGameTime);
            
            GAMEPLAYER.currentCM.Close();
        end
    end
    
end