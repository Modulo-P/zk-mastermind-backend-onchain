{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Cardano.Api (PlutusScriptV2, writeFileTextEnvelope)
import Cardano.Api.Shelley (PlutusScript (..))
import Control.Monad (when)
import qualified Data.ByteString as B
import qualified Data.ByteString.Base16 as Base16
import qualified Data.ByteString.Short as Bs
import Data.String (IsString (fromString))
import qualified PlutusLedgerApi.V2 as V2
import System.Environment (getArgs)
import Util (compiledScript)

main :: IO ()
main = do
  args <- getArgs
  when (length args /= 1) $ error "Usage: mint-script <pubKeyHash>"
  let pubKeyHash = fromString $ head args
  let serialisedScript = V2.serialiseCompiledCode $ compiledScript pubKeyHash
  putStrLn $ "PubKeyHash: " ++ show pubKeyHash
  B.writeFile "validator.uplc" . Base16.encode $ Bs.fromShort serialisedScript
  result <- writeFileTextEnvelope "validator.plutus" Nothing (PlutusScriptSerialised serialisedScript :: PlutusScript PlutusScriptV2)
  case result of
    Left err -> putStrLn $ "Error: " ++ show err
    Right () -> putStrLn "Success"
