
-- Alternate word frequency example. Functionally identical
-- to WordFrequency.hs, but can be used as a combiner.

module Main where

import Hadoop.MapReduce (mrMain, Map, Reduce)

wfMap :: Map
wfMap record = [word ++ " 1" | word <- words record]

wfReduce :: Reduce
wfReduce key values = [key ++ " " ++  (show $ sum $ (map read) values)]

main = mrMain wfMap wfReduce

