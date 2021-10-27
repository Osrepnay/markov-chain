module Intern where

import           Control.Monad.Trans.State.Lazy
import           Data.Hashable                  ( hash )
import qualified Data.IntMap                   as IntMap
import           Data.Maybe                     ( fromJust )

type Interner = IntMap.IntMap String
type Key = Int

intern :: String -> State Interner Key
intern str = state (\s -> (strHash, IntMap.insert strHash str s)) where strHash = hash str

getKey :: String -> Key
getKey = hash

getStr :: Key -> Interner -> String
getStr = curry $ fromJust . uncurry IntMap.lookup

newPool :: Interner
newPool = IntMap.empty
