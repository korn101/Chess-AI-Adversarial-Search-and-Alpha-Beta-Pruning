classdef Node < matlab.mixin.Copyable
    properties (SetAccess = private, GetAccess = public)
        boolMax; % is this a max or min node?
        strMove;
        Nodes = { [] }; % empty cell array
        numberOfNodes; % number of children
        strFEN; % fen string of THIS node.
        priority; % priority of the node, determined on node creation for heuristics.
        parentNode; % the parent of this node used to generate solution string
        boolExpanded; % has this node already been fully expanded?
    end
    
    methods
        function NODE = Node(move, sFEN, max, parent, prior)
            NODE.strMove = move;
            NODE.numberOfNodes = 0;
            NODE.strFEN = sFEN;
            if (isempty(parent) == false)
                NODE.parentNode = parent;
            else
               NODE.parentNode = ''; 
            end
            
            NODE.boolMax = max;
            NODE.priority = prior;
            NODE.boolExpanded = false;
            
            % the following code determines what type of piece the player
            % has moved in this node. 
            
            
        end
        
        function setExpanded(NODE)
           NODE.boolExpanded = true; 
        end
        
        function printDebug(NODE)
            
            if (isempty(NODE.strPlayerMove))
                fprintf('ROOT has %d children: ', NODE.numberOfNodes);
            else
                fprintf('%s, has %d children: ', NODE.strMove, NODE.numberOfNodes);
            end
            
            for n = 1:NODE.numberOfNodes
                disp(NODE.Nodes{n});
            end
            
            fprintf('\n');
            
        end
        function addChild(NODE, newnode)
            
            NODE.Nodes{NODE.numberOfNodes + 1} = newnode;
            NODE.numberOfNodes = NODE.numberOfNodes + 1;
            
            
        end
        
        function disp(NODE)
            fprintf('[%s, Priority: %f]', NODE.strMove, NODE.priority);
        end
        
        function strReturn=getString(node)
           
            strReturn = strcat(node.strMove);
            
        end
        
        function boolReturn = isTerminal(NODE)
            if NODE.numberOfNodes > 0
                boolReturn = false;
            else
                boolReturn = true;
            end
        end
        
        
    end
    
    
    
end
