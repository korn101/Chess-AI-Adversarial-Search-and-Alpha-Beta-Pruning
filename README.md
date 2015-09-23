Chess Artificial Intelligence
=========

Adversarial MiniMax Search and Alpha-Beta Pruning:

This code will look into the effectiveness of using Adversarial Search techniques in order to create an effective A.I. that can compete with the Stock-Fish A.I. limited to 6-plies. (seeing 6 moves ahead)

Using the concepts of decision trees, minimax and alpha-beta pruning it is possible to create an A.I. that can make some good decisions and possibly even beat the StockFish (or a human player for that matter).

In order to realise the decision tree needed to perform the alpha-beta pruning on, we need to first construct it. Due to the overwhelming number of moves possible in chess, we will narrow the scope of the tree by only selecting specific portions of the tree to expand - this is the fundamental idea in Alpha-Beta pruning , to eliminate moves that we know will invariably cause a future loss in the game.
