
-- Hadoop Streaming MapReduce interface for Haskell
-- (c) 2010 Paul Butler <paulgb @ gmail>
-- 
-- You may use this module under the zlib/libpng license.
-- (http://www.opensource.org/licenses/zlib-license.php)
--
-- See README, LICENSE, and /examples for more information.
-- 
-- Happy MapReducing!

module Hadoop.MapReduce (mrMain, Map, Reduce, key, value) where

import System (getArgs)
import Data.List (groupBy)

-- Map and Reduce corrispond to the type signatures required
-- for the "map" and "reduce" functions of the MapReduce job.
-- Note that these do NOT corrispond to the type signatures
-- of haskell's `map` and `reduce` functions.

type Map = String -> [String]
type Reduce = String -> [String] -> [String]

-- Interactor is a type signature of the function required
-- by the haskell `interact` function.
type Interactor = String -> String

-- Field separator. Hadoop uses the space character (' ')
-- by default, but comma (',') and tab ('\t') are also
-- common. Ideally there should be a way to change the
-- separator without modifying the source.
separator = ' '

usage_message =
    "Notice: This is a streaming MapReduce program.\n" ++
    "It must be called with one of the following arguments:\n" ++
    "    -m     Run the Map portion of the MapReduce job\n" ++
    "    -r     Run the Reduce portion of the MapReduce job\n"

-- For the reduce step, each line consists of a key and
-- (optionally) a value. The function `key` extracts
-- the key from a line.
key :: String -> String
key = takeWhile (/= separator)

-- Like `key`, `value` extracts the value from a line.
value :: String -> String
value = (drop 1) . dropWhile (/= separator)

-- Given two lines, `compareKeys` returns True if the lines
-- have the same key.
compareKeys :: String -> String -> Bool
compareKeys a b = (key a) == (key b)

-- Given a map function, `mapper` returns a function that
-- can be passed to haskell's `interact` function.
mapper :: Map -> Interactor
mapper mrMap = 
    unlines . (concatMap mrMap) . lines

-- Given a reduce function, `reducer` returns a function
-- that can be passed to haskell's `interact` function.
reducer :: Reduce -> Interactor
reducer mrReduce input =
    let groups = groupBy compareKeys $ lines input :: [[String]] in
    unlines $ concatMap
        (\g -> mrReduce (key $ head g) (map value g :: [String])) groups

-- Main function for a map reduce program
mrMain :: Map -> Reduce -> IO () 
mrMain mrMap mrReduce = do
    args <- getArgs
    case args of
        ["-m"] -> interact (mapper mrMap)
        ["-r"] -> interact (reducer mrReduce)
        _ -> putStrLn usage_message

-- Main function for a map-only job
mapMain :: Map -> IO ()
mapMain mrMap = do
    args <- getArgs
    case args of
        ["-m"] -> interact (mapper mrMap)
        ["-r"] -> interact id
        _ -> putStrLn usage_message

-- Main function for a reduce-only job
reduceMain :: Reduce -> IO ()
reduceMain mrReduce = do
    args <- getArgs
    case args of
        ["-m"] -> interact id
        ["-r"] -> interact (reducer mrReduce)
        _ -> putStrLn usage_message

