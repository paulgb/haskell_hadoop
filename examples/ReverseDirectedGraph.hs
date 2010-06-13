
-- Takes a directed graph and reverses every edge in it.
-- The directed graph is expected to be described as follows.
-- Each line corrisponds to one node in the graph. The line
-- begins with the name of the node followed by a space, and
-- is followed by the names of adjacent nodes, separated by
-- spaces. The output graph is in the same format.

module ReverseDirectedGraph where

import Hadoop.MapReduce (mrMain, Map, Reduce, key, value)

wfMap :: Map
wfMap line =
    let node = key line in
    do
        adjacentNode <- words $ value line
        return $ adjacentNode ++ " " ++ node

wfReduce :: Reduce
wfReduce key values =
    return $ key ++ " " ++ (unwords values)

main = mrMain wfMap wfReduce

