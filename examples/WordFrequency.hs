
-- Count the frequency of words in a text document. Words
-- are any non-space characters separated by spaces.
-- Outputs, with one line per word, each word followed by
-- the number of times it occurs.

module Main where

import Hadoop.MapReduce (mrMain, Map, Reduce)

wfMap :: Map
wfMap = words

wfReduce :: Reduce
wfReduce key values =
    return $ key ++ " " ++ (show $ length values)

main = mrMain wfMap wfReduce

