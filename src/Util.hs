
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies      #-}

module Util where

import           Mint               (MintParams (MintParams), mintScript)
import           PlutusLedgerApi.V2 (serialiseCompiledCode)
import           PlutusTx
import           Prelude            (IO, ($))
import           System.IO          (print)



params :: MintParams
params = MintParams "b5b425aa8b18c537da26366fe4da1c709440daa7878ac25c63d89086" "HydrADA"

compiledScript :: CompiledCode (BuiltinData -> BuiltinData -> ())
compiledScript = mintScript params

printValidator :: IO ()
printValidator = print $ serialiseCompiledCode compiledScript
