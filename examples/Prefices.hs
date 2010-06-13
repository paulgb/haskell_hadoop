

module Prefices where

import Hadoop.MapReduce (mrMain, Map, Reduce, key, value)
import Data.List (inits, sort, nub)

pMap :: Map
pMap line = [prx ++ " " ++ line | prx <- tail $ inits line]

pReduce :: Reduce
pReduce prx wrds = return $ prx ++ " " ++ (unwords $ sort $ nub wrds)

main = mrMain pMap pReduce

