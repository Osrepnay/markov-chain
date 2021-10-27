module Lib where

import           Control.Monad.Trans.State.Lazy
import           Data.HashMap.Lazy              ( HashMap )
import qualified Data.HashMap.Lazy             as HashMap
import           Data.List
import           Data.Maybe
import           Intern
import           System.Random

type MarkovChainUnfinished = HashMap Key (HashMap Key Int)

-- sorted
type MarkovChainFinished = HashMap Key [(Key, Int)]

newMarkovChain :: MarkovChainUnfinished
newMarkovChain = HashMap.empty

addRelation :: Key -> Key -> MarkovChainUnfinished -> MarkovChainUnfinished
addRelation p k m = existsElse p (existsElse k (+ 1) 1) (HashMap.fromList [(k, 1)]) m
    where
        -- in hashmap m, replaces value v of key k with f v if k already exists, else inserts key pair k o
        existsElse k f o m = case HashMap.lookup k m of
            Just v  -> HashMap.insert k (f v) m
            Nothing -> HashMap.insert k o m

finishMarkovChain :: MarkovChainUnfinished -> MarkovChainFinished
finishMarkovChain mk = sortBy (\(_, a) (_, b) -> compare b a) . HashMap.toList <$> mk

mostCommonNext :: Key -> MarkovChainFinished -> Maybe Key
mostCommonNext k mk = fst . head <$> relationsNonEmpty k mk

weightedNext :: RandomGen r => Key -> MarkovChainFinished -> Maybe (State r Key)
weightedNext k mk = uncurry weightedRandomElement <$> keyRelations
    where
        keyRelations = unzip <$> relationsNonEmpty k mk
        weightedRandomElement :: RandomGen r => [Int] -> [Int] -> State r Int
        weightedRandomElement xs ws = (\rn -> xs !! firstSatisfies (rn <) 0 cumulativeSums) <$> randomRState
            where
                firstSatisfies _ i [] = error "stinky"
                firstSatisfies f i (x : xs) | f x = i
                                            | otherwise = firstSatisfies f (i + 1) xs
                cumulativeSums = reverse $ foldl (\b a -> (a + head (b ++ [0])) : b) [] ws
                randomRState   = state $ randomR (0, last cumulativeSums - 1)

relationsNonEmpty :: Key -> MarkovChainFinished -> Maybe [(Key, Int)]
relationsNonEmpty k mk = HashMap.lookup k mk >>= (\xs -> if null xs then Nothing else Just xs)

relations :: Key -> MarkovChainFinished -> Maybe [(Key, Int)]
relations = HashMap.lookup
