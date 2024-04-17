{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Cardano.Api (PlutusScriptV2, writeFileTextEnvelope)
import Cardano.Api.Shelley (PlutusScript (..))
import Control.Monad (when)
import qualified Data.ByteString as B
import qualified Data.ByteString.Base16 as Base16
import qualified Data.ByteString.Short as B
import Data.Maybe (fromJust)
import Data.Text (pack)
import qualified PlutusLedgerApi.V2 as V2
import System.Environment (getArgs)
import Text.Hex (decodeHex)
import Util (compiledScript)

main :: IO ()
main = do
  args <- getArgs
  when (length args /= 1) $ error "Usage: mint-script <pubKeyHash>"
  let pubKeyHash = V2.PubKeyHash $ V2.toBuiltin $ fromJust $ decodeHex $ pack $ head args
  let serialisedScript = V2.serialiseCompiledCode $ compiledScript pubKeyHash
  B.writeFile "validator.uplc" . Base16.encode $ B.fromShort serialisedScript
  result <- writeFileTextEnvelope "validator.plutus" Nothing (PlutusScriptSerialised serialisedScript :: PlutusScript PlutusScriptV2)
  case result of
    Left err -> putStrLn $ "Error: " ++ show err
    Right () -> putStrLn "Success"
