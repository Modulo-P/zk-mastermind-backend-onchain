{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Util where

import Mint (MintParams (MintParams), mintScript)
import PlutusLedgerApi.V2 (PubKeyHash (..), serialiseCompiledCode)
import PlutusTx
import System.IO (print)
import Prelude (IO, ($))

compiledScript :: PubKeyHash -> CompiledCode (BuiltinData -> BuiltinData -> ())
compiledScript pkh = mintScript $ MintParams pkh "HydrADA"

printValidator :: PubKeyHash -> IO ()
printValidator pkh = print $ serialiseCompiledCode $ compiledScript pkh
