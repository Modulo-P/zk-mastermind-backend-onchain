{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Cardano.Api (AsType (AsPlutusScript, AsPlutusScriptV2), PlutusScriptV2, PlutusScriptVersion (PlutusScriptV2), Script (PlutusScript), SerialiseAsRawBytes (deserialiseFromRawBytes), hashScript, writeFileTextEnvelope)
import Cardano.Api.Shelley (PlutusScript (..))
import Control.Monad (when)
import qualified Data.ByteString as B
import qualified Data.ByteString.Base16 as Base16
import Data.ByteString.Short (fromShort)
import qualified Data.ByteString.Short as Bs
import Data.Either (fromRight)
import Data.String (IsString (fromString))
import qualified PlutusLedgerApi.V2 as V2
import PlutusTx.Builtins.Class (stringToBuiltinByteString)
import qualified PlutusTx.Show as P
import System.Environment (getArgs)
import Util (compiledScript)

main :: IO ()
main =
  do
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
    let plutusScript = fromRight (error "Error decoding script") $ deserialiseFromRawBytes (AsPlutusScript AsPlutusScriptV2) (fromShort serialisedScript)
    let scriptHash = hashScript $ PlutusScript PlutusScriptV2 plutusScript
    putStrLn $ "Wrapped ADA asset id: " ++ filter (/= '"') (show scriptHash ++ show (P.show $ stringToBuiltinByteString "HydrADA"))
