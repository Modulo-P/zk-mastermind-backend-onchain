{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Cardano.Api            (PlutusScriptV2, writeFileTextEnvelope)
import           Cardano.Api.Shelley    (PlutusScript (..))
import qualified Data.ByteString        as B
import qualified Data.ByteString.Base16 as Base16
import qualified Data.ByteString.Short  as B
import qualified PlutusLedgerApi.V2     as V2
import           Util                   (compiledScript)





main :: IO ()
main = do
  B.writeFile "validator.uplc" . Base16.encode $ B.fromShort serialisedScript
  result <- writeFileTextEnvelope "validator.plutus" Nothing (PlutusScriptSerialised serialisedScript :: PlutusScript PlutusScriptV2)
  case result of
    Left err -> putStrLn $ "Error: " ++ show err
    Right () -> putStrLn "Success"
  where
    serialisedScript = V2.serialiseCompiledCode compiledScript

