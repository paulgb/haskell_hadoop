
module WordFrequency where

import MapReduce (mrMain, Map, Reduce)

wfMap :: Map
wfMap = words

wfReduce :: Reduce
wfReduce key values =
    return $ key ++ " " ++ (show $ length values)

main = mrMain wfMap wfReduce

