classdef Tree < handle
    properties (Hidden)
        
    end
    
    properties (GetAccess = public, SetAccess = private)
        
        Root; % empty cell array
        CM;   % current Chessmaster game. Only one should exist in the tree.
        totalNodes; % total number of nodes in the tree.
        visitedNodes = {[]}; %
        noVisited;
        branchFactor;
        tempList = {[]};
        tempListSize;
        totalDepth;
        noVisitedAlphaBeta; % number of nodes visited by alpha beta
        noPrunesAlphaBeta; % number of times we pruned a section of the tree.
    end
    
    events
        %specify events
        
    end
    
    
    methods
        function TREE = Tree(branches, tempFEN)
            % constructor
            % construct the tree by plotting the moves
            
            TREE.noVisitedAlphaBeta = 0;
            TREE.noPrunesAlphaBeta = 0;
            TREE.branchFactor = branches;
            TREE.noVisited = 0;
            TREE.totalNodes = 0;
            TREE.tempListSize = 0;
            TREE.CM = ChessMaster;  %This will create a new instance of the ChessMaster object and assign it to CM. This will open
            %up a new GUI window. If there were no errors, the ChessMaster game is ready and you can start playing.
            
            TREE.CM.SpawnChessEngine(); %Creates a new chess enigne object, and opens the ChessEngine window.
            TREE.CM.CElist(1).autoanalyze = 1; %Sets the AI to autoanalyze.
            TREE.CM.CElist(1).autocolor=3; %Changes the autoplay color to both.
            TREE.CM.CElist(1).alock=1; %Tells the AI to start autoanalyze.
            TREE.CM.CElist(1).execMode = 4;%Tells the AI to chose 'Analize' as execution mode.
            TREE.CM.CElist(1).playMode = 2;%Tells the AI the playmode.
            TREE.CM.CElist(1).newGame=0;%Tells the AI that a new game has already begun.
            
            TREE.Root = Node('root', tempFEN, true, '', 0);
            
            TREE.CM.LoadPosition(tempFEN);
            TREE.CM.AutoPlay();
            
            
            
        end
        
        function res = doAlphaBeta(TREE, node, depth, a, b, isMax)
            
            if (depth <= 0)
                %fprintf('====terminal reached\n====');
                TREE.noVisitedAlphaBeta = TREE.noVisitedAlphaBeta + 1;
                res = node.priority;
            else
                
                if (isMax == true)
                    % max player
                    v = -1*inf;
                    for cNode = 1:node.numberOfNodes
                        v = max(v, TREE.doAlphaBeta(node.Nodes{cNode}, depth - 1,a,b, false));
                        a = max(a, v);
                        if (b <= a)
                            TREE.noPrunesAlphaBeta = TREE.noPrunesAlphaBeta + 1;
                            break; % this is the beta cut off
                        end
                        
                    end
                    TREE.noVisitedAlphaBeta = TREE.noVisitedAlphaBeta + 1;
                    res = v;
                    
                else
                    % min player
                    v = inf;
                    for cNode = 1:node.numberOfNodes
                        v = min(v, TREE.doAlphaBeta(node.Nodes{cNode}, depth - 1, a,b,true));
                        b = min(b, v);
                        if (b <= a)
                            TREE.noPrunesAlphaBeta = TREE.noPrunesAlphaBeta + 1;
                            break; % this is the alpha cut-off
                        end
                        
                        
                    end
                    TREE.noVisitedAlphaBeta = TREE.noVisitedAlphaBeta + 1;
                    res = v;
                end
                
            end
        end
        
        function buildMinMax(TREE, depth)
            % build a min max with the constraints.
            
            if (depth > 0)
                tStart = tic;
                for i2 = 1:depth
                    tElapsed = toc(tStart);
                    if (tElapsed > 60)
                        %fprintf('Time elapsed! finished at depth %d\n', i2-1);
                        TREE.totalDepth = i2-1;
                        break;
                    else
                        %fprintf('Expanding to depth %d...\n', i2);
                        TREE.expandMinMax(TREE.Root, i2);
                        TREE.totalDepth = i2;
                    end
                end
                
                
            end
            
            TREE.CM.Close();
            
        end
        
        function expandMinMax(TREE, node, depth)
            
            
            
            if ((depth <= 0))
                %fprintf('===============================\n REACHED THE BOTTOM OF THE TREE.\n =============================== \n');
            else
                
                TREE.CM.LoadPosition(node.strFEN);
                TREE.CM.AutoPlay();
                % set up the board
                % find all moves and evaluate
                % pick moves based on the branchFactor criteria
                % create nodes from this list of best.
                % depth limited recurse ?
                
                % Since we don't want to unneccessarily expand nodes that
                % have already been expanded by the algorithm, skip the
                % find all moves and create children section of this code
                % those already expanded.
                
                if (node.boolExpanded ~= true)
                    
                    % HUGOS MODIFIED CODE:
                    
                    board = TREE.CM.giveBoard(); %This gives us the BoardState object currently assosicated with CM. We can use this to find all the possible moves
                    all_moves = board.GetAllMoves(TREE.CM.turnColor); % This will return a matrix with all the possible moves that we can make. The matrix will scale automatically dependant on the number of pieces and possible moves.
                    %You can remove the ';' from the line above to print the matrix out to the console so that you can view it.
                    %The following section is an example of how you can extract all the individual moves from the matrix.
                    num_pc = size(all_moves); %This returns the size of the matrix. The first value will tell us how many pieces there are.
                    %The second value will be the maximum number of moves that those pieces can make. The third one will always be 6, indicating the moves themselves.
                    Moves = cell(1,1); %Matlab cell array that stores all the moves
                    itt=1;
                    for i = 1:num_pc(1) %This is a for loop that will iterate over all the chess pieces.
                        
                        for j = 1:num_pc(2)%This is a for loop that will iterate over all the moves. This will iterate for the maximum number of moves that a piece can make.
                            if all_moves(i,j,1)~=0%If the piece does not have a move, a value of '0' will be saved in the array.
                                if all_moves(i,j,5)==0%If the piece does not have a promotion, generate a standard LAN string that can be used to move the piece.
                                    LAN = Move.GenerateLAN(all_moves(i,j,1),all_moves(i,j,2),all_moves(i,j,3),all_moves(i,j,4));%Generate the LAN string
                                    Moves(itt) = java.lang.String(LAN);%Saves the LAN move to a cell array
                                    itt = itt+1;
                                else %If the piece needs to be promoted, generate the relevant LAN string
                                    LAN = Move.GenerateLAN(all_moves(i,j,1),all_moves(i,j,2),all_moves(i,j,3),all_moves(i,j,4),all_moves(i,j,5));%LAN string that includes a promotion
                                    Moves(itt) = java.lang.String(LAN);%Saves the LAN move to a cell array
                                    itt = itt+1;
                                end
                                
                            end
                        end
                    end
                    
                    % At this point we have all the moves. Now we can evaluate
                    % them.
                    TREE.tempListSize = 0;
                    
                    moves = size(Moves);%Get the number of moves
                    %tic
                    for y = 1:moves(2)%Iterate through all the moves, running each one and printing out the AI response of each move.
                        %if (isempty(Moves{1,y}) == false) % make sure that the move is valid.
                        TREE.CM.MakeMove(char(Moves(1,y)));%Remove the ';' to see the SAN string of the move you make
                        while (TREE.CM.CElist(1).tlock==true) %Check if the thinking lock is active on the CElist(1) engine. If the lock is active the AI is still searching for the best move.
                            pause(0.001);%Check every 0.05s.
                        end
                        Cost = TREE.CM.CElist(1).viewScore; %Extract the score of the board using the CElist 2 engine. Positive score will benefit White, negative benefits black.
                        
                        % NOW we add to this list.
                        TREE.tempListSize = TREE.tempListSize + 1;
                        TREE.tempList{TREE.tempListSize} = Node(char(Moves(1,y)), TREE.CM.GetFENstr(), not(node.boolMax), node, Cost);  % add to the list,
						
                        % Now that we added the move to the list, we can sort
                        % the list - and then undo and add the remainder of the
                        % moves to the list.
                        
                        % Simple insertion sort: (HIGHEST TO LOWEST USE > )
                        %                        (LOWEST TO HIGHEST USE < )
                        
                        itt = TREE.tempListSize;
                        if (itt > 1)
                            if (node.boolMax == true)
                                while (TREE.tempList{itt}.priority > TREE.tempList{itt-1}.priority)
                                    temp = copy(TREE.tempList{itt});
                                    TREE.tempList{itt} = copy(TREE.tempList{itt-1});
                                    TREE.tempList{itt-1} = temp;
                                    
                                    itt = itt - 1;
                                    if (itt == 1)
                                        break;
                                    end
                                end
                            else
                                while (TREE.tempList{itt}.priority < TREE.tempList{itt-1}.priority)
                                    temp = copy(TREE.tempList{itt});
                                    TREE.tempList{itt} = copy(TREE.tempList{itt-1});
                                    TREE.tempList{itt-1} = temp;
                                    
                                    itt = itt - 1;
                                    if (itt == 1)
                                        break;
                                    end
                                end
                            end
                        end
                        
                        TREE.CM.Undo(); %Undo the last half move.
                        %Or you can load the boardpostion and call CM.AutoPlay. Note CM.Undo does seem to process faster.
                        %CM.LoadPosition('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');%Reset the board.
                        %CM.AutoPlay();
                        %end
                    end
                    
                    if TREE.tempListSize > TREE.branchFactor
                        
                        for i1 = 1:TREE.branchFactor
                            node.addChild(copy(TREE.tempList{i1}));
                            TREE.totalNodes = TREE.totalNodes + 1;
                        end
                    else
                        for i1 = 1:TREE.tempListSize
                            node.addChild(copy(TREE.tempList{i1}));
                            TREE.totalNodes = TREE.totalNodes + 1;
                        end
                    end
                    % at this point, we know that all possible child nodes
                    % have been expanded for this node. So set the
                    % boolExpanded to True.
                    node.setExpanded();
                    % and clear the temp list.
                    TREE.tempList = {[]};
                    TREE.tempListSize = 0;
                    
                else
                    %fprint('THIS NODE HAS ALREADY BEEN EXPANDED, YAY.\n');
                end
                
                % now iterate through the nodes, and recursively call down.
                for in=1:node.numberOfNodes
                    
                    % the idea is to now expand the children of the node passed
                    % as parameter.
                    
                    TREE.expandMinMax(node.Nodes{in}, depth - 1);
                    TREE.CM.LoadPosition(node.strFEN);
                    TREE.CM.AutoPlay();
                end
               
                
            end
            
            
        end
        
        function printFirstLayer(TREE)
            
            TREE.Root.printDebug();
            fprintf('Tree Total Nodes (including Root): %d\n', TREE.totalNodes + 1);
            
        end
        
        function closeCM(TREE)
            
            fprintf('TREE TOTAL NUMBER OF NODES: %d \n', TREE.totalNodes);
            TREE.CM.Close();
            
        end
        
        function disp(TREE)
            fprintf('Tree: %s\n', TREE.Root.printDebug());
        end
        
        function visitedAdd(TREE, node)
            TREE.visitedNodes{TREE.noVisited + 1} = strcat(node.strPlayerMove, strcat(',',node.strAImove));
            TREE.noVisited = TREE.noVisited + 1;
            
        end
        
        function printVisited(TREE)
            
            for i= 1:TREE.noVisited
                fprintf('%d - %s\n', i, TREE.visitedNodes{i});
            end
            
        end
        
    end
    
    
    
    
    methods(Static = true)
        
    end
    
    
    
end