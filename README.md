# Haskell-Hadoop

Haskell-Hadoop is a simple Haskell interface to Hadoop Streaming jobs.

## Install

To install the library, run `cabal install`. The library will be
available as `Hadoop.MapReduce`

If you prefer, you can use Setup.hs for more control.
Use `runghc Setup.hs --help` for more details.

## Using

The programmer writes the map and reduce functions, and Haskell-Hadoop
takes care of the rest.

The map and reduce functions must conform to the signatures given below.

    type Map = String -> [String]
    type Reduce = String -> [String] -> [String]

Note that the interface deals entirely in strings; it is up to the
programmer to parse input from the strings and convert output to strings.

### Map

The first stage of the MapReduce job is map. The map function takes a
single record and returns zero or more strings as output. These strings
become records for the reduce job and may be key-value pairs separated
by the tab character.

#### Example

    myMapper :: Map
    myMapper record = [word ++ " 1" | word <- words record]

### Sort

The second stage is sort, which groups records by key. This is handled
by Hadoop.

### Reduce

The third stage is reduce. For each key group, the reduce function is
called with two arguments. The first is the key (as a string), and
the second is a list of the values in that group as strings.

#### Example

    myReducer :: Reduce
    myReducer key values = [key ++ " " ++ (show $ sum $ (map read) values)]

## Running with Hadoop

To run the program with Hadoop, use the streaming jar and use the compiled
program as the mapper and reducer with the `-m` and `-r` arguments
respectively.

    /path-to-hadoop/bin/hadoop
        jar /path-to-hadoop/contrib/streaming/hadoop-[version]-streaming.jar
        -input /path-to-input/
        -output /path-to-output/
        -mapper "/path-to-mapreduce/mapreduce-program -m"
        -reducer "/path-to-mapreduce/mapreduce-program -r"

## Notes

Haskell-Hadoop assumes that the tab character (\t) is used to separate
keys and values, and that the newline character is used to separate
records. These are the same defaults used by Hadoop Streaming.


