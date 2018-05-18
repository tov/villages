{-# LANGUAGE BangPatterns, FlexibleContexts #-}
module Main where

import Control.Monad (when)
import Data.Array.IO (IOUArray)
import Data.Array.MArray (newArray, writeArray, readArray, getBounds)
import System.Random (randomIO, randomRIO)

nFamilies :: Int
nFamilies = 1000000

main :: IO ()
main = generateVillage nFamilies >>= avgChildrenPerFamily >>= print

-- data

data Village = Village {
  villageGirls :: !(IOUArray Int Int),
  villageBoys  :: !(IOUArray Int Int)
}

data Family = Family {
  familyGirls :: !Int,
  familyBoys  :: !Int
}

-- generation

generateVillage :: Int -> IO Village
generateVillage n = do
  village <- newEmptyVillage n
  populateVillage village
  return village

newEmptyVillage :: Int -> IO Village
newEmptyVillage n = do
  girls <- newArray (1, n) 0
  boys  <- newArray (1, n) 0
  return $ Village girls boys

populateVillage :: Village -> IO ()
populateVillage village = do
  (low, high) <- getBounds (villageGirls village)
  let loop i = when (i <= high) $ do
        writeFamily village i =<< generateFamily
        loop (i + 1)
  loop low

generateFamily :: IO Family
generateFamily = do
  let addChild !girls = do
        isBoy <- randomIO
        if isBoy then
          return (Family girls 1)
        else do
          let girls' = girls + 1
          wantsAnotherChild <- oneChanceInFour
          if wantsAnotherChild
            then addChild girls'
            else return (Family girls' 0)
  wantsFirstChild <- not <$> oneChanceInFour
  if wantsFirstChild
    then addChild 0
    else return (Family 0 0)

writeFamily :: Village -> Int -> Family -> IO ()
writeFamily village ix family = do
  writeArray (villageGirls village) ix (familyGirls family)
  writeArray (villageBoys village) ix (familyBoys family)

oneChanceInFour :: IO Bool
oneChanceInFour = do
  b <- randomRIO (1 :: Int, 4)
  return $ b == 1

-- queries

avgChildrenPerFamily :: Village -> IO Double
avgChildrenPerFamily (Village girls boys) = do
  totalFamilies <- arrayLength girls
  girlCount     <- sumArray girls
  boyCount      <- sumArray boys
  let totalChildren = girlCount + boyCount
  return $ fromIntegral totalChildren / fromIntegral totalFamilies

-- array utils

sumArray array = do
  (low, high) <- getBounds array
  let loop !acc i =
        if i <= high then do
          element <- readArray array i
          loop (element + acc) (i + 1)
        else return acc
  loop 0 low

arrayLength array = do
  (low, high) <- getBounds array
  return $ high - low + 1
