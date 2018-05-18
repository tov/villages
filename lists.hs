module Main where

import System.Random
import Control.Monad
import Control.Monad.State
import Data.List

n    = 1000000

main = sample (generate_village n) >>= print . avg_kids_per_family

-- Data definitions

type Village = [Family]
type Family  = [Child]
data Child   = Girl | Boy deriving Eq

-- Village generation

generate_village :: Int -> Distribution Village
generate_village n = replicateM n generate_family

generate_family :: Distribution Family
generate_family = do
  wants_first_child <- not <$> one_chance_in 4
  if wants_first_child then do
      child <- generate_child
      extend_family [child]
  else return []

extend_family :: Family -> Distribution Family
extend_family family@(Boy : _) = return family
extend_family family = do
  wants_another_child <- one_chance_in 4
  if wants_another_child then do
    child <- generate_child
    extend_family (child : family)
  else return family

-- Randomness utilities

type Distribution = State StdGen

sample :: Distribution a -> IO a
sample m = evalState m <$> newStdGen

one_chance_in :: Int -> Distribution Bool
one_chance_in n = do
  state <- get
  let (pick, state') = randomR (1, n) state
  put state'
  return $ pick == 1

generate_child :: Distribution Child
generate_child = do
  b <- one_chance_in 2
  return $ if b then Girl else Boy

-- Queries

avg_kids_per_family  = avg_pred_per_family (const True)
avg_girls_per_family = avg_pred_per_family (== Girl)
avg_boys_per_family  = avg_pred_per_family (== Boy)

avg_pred_per_family :: (Child -> Bool) -> Village -> Double
avg_pred_per_family pred village =
  count_children pred village / genericLength village

girls_to_boys :: Village -> Double
girls_to_boys village = girls / boys
  where
    girls = count_children (== Girl) village
    boys  = count_children (== Boy) village

count_children :: Num a => (Child -> Bool) -> Village -> a
count_children pred = genericLength . filter pred . concat

