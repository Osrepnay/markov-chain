module Main where

import           Control.Applicative
import           Control.Monad
import           Control.Monad.Trans.State.Lazy
import           Data.Foldable
import           Data.Hashable
import           Data.List
import           Data.Maybe
import           Debug.Trace
import           Intern
import           Lib
import           System.Environment
import           System.IO
import           System.Random
main :: IO ()
main = do
    args     <- getArgs
    fileHandle <- openFile (head args) ReadMode
    contents <- hGetContents fileHandle
    let (splitContents, pool) = runState (traverse (traverse intern . words) (lines contents)) newPool
    putStrLn $ "Finished interning data " ++ show (hash splitContents)
    let allRelations = concat $ pairs <$> splitContents
    putStrLn $ "Finished processing data " ++ show (hash allRelations)
    let markovChain = newMarkovChain
    let markovChainFinished =
            finishMarkovChain $ foldl' (\mk (x0, x1) -> addRelation x0 x1 mk) markovChain allRelations
    putStrLn $ "Created markov chain " ++ show (hash markovChainFinished)
    let wordsKeys = evalState (getNFromChain (read $ args !! 2) (getKey (args !! 1)) markovChainFinished) (mkStdGen 0)
    let words     = flip getStr pool <$> wordsKeys
    putStrLn $ unwords words
    where
        getNFromChain :: RandomGen r => Int -> Key -> MarkovChainFinished -> State r [Key]
        getNFromChain n k mk =
            reverse
                <$> iterate (\s -> s >>= (\nk -> maybe (pure nk) (fmap (: nk)) (weightedNext (head nk) mk))) (pure [k])
                !!  (n - 1)
        pairs xs = zip xs $ tail xs
