
-- Hadoop Streaming MapReduce interface for Haskell
-- (c) 2010 Paul Butler <paulgb @ gmail>
-- 
-- You may use this module under the zlib/libpng license.
-- (http://www.opensource.org/licenses/zlib-license.php)
--
-- See README, LICENSE, and /examples for more information.
-- 
-- Happy MapReducing!

module MapReduce (mrMain, Map, Reduce, dummyMap, dummyReduce, key, value) where

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
    "    -r     Run the Reduce portion of the MapReduce job\n" ++
    "    -i     Identity function. Use as a mapper when only\n" ++
    "           reduce functionality is needed, and as a reducer\n" ++
    "           when only map functionality is needed."

-- Dummy Map function, for when you only need reduce
-- functionality (use the "-i" command-line option instead
-- of "-m")
dummyMap :: Map
dummyMap = const []

-- Dummy Reduce function, for when you only need reduce
-- functionality (use the "-i" command-line option instead
-- of "-r")
dummyReduce :: Reduce
dummyReduce = const . const []

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
        ["-i"] -> interact id
        _ -> putStrLn usage_message

