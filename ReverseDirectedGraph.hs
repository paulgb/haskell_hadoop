
module ReverseDirectedGraph where

import MapReduce (mrMain, Map, Reduce, key, value)

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

