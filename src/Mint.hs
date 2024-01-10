{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoImplicitPrelude     #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TemplateHaskell       #-}

module Mint where

import           PlutusCore.Core             (plcVersion100)
import           PlutusLedgerApi.V1.Value    (singleton, valueOf)
import           PlutusLedgerApi.V2          (PubKeyHash,
                                              ScriptContext (scriptContextPurpose, scriptContextTxInfo),
                                              TokenName,
                                              TxInfo (txInfoMint, txInfoSignatories),
                                              UnsafeFromData (unsafeFromBuiltinData))
import           PlutusLedgerApi.V2.Contexts (ScriptPurpose (..))
import           PlutusTx                    (CompiledCode)
import qualified PlutusTx                    as Tx
import           PlutusTx.Prelude
import qualified PlutusTx.Prelude            as Tx


data MintParams = MintParams
  {
    mpMinter    :: PubKeyHash,
    mpTokenName :: TokenName
  }

Tx.makeLift ''MintParams

{-# INLINABLE mint #-}
mint :: MintParams -> () -> ScriptContext -> Bool
mint params _ ctx =
    quantityMinting < 0 ||
    (
      traceIfFalse "wrong minter" (minter `elem` txInfoSignatories (scriptContextTxInfo ctx)) &&
      traceIfFalse "wrong token name" (quantityMinting > 0 && minted == singleton symbol tokenName quantityMinting)
    )
  where
    tokenName = mpTokenName params
    minter = mpMinter params
    minted = txInfoMint $ scriptContextTxInfo ctx
    quantityMinting = valueOf minted symbol tokenName
    symbol = case scriptContextPurpose ctx of
      Minting cs -> cs
      _          -> error ()

{-# INLINABLE unTypedMint #-}
unTypedMint :: MintParams -> Tx.BuiltinData -> Tx.BuiltinData -> ()
unTypedMint params _ ctx =
  Tx.check (
    mint params () (unsafeFromBuiltinData ctx)
  )

mintScript :: MintParams -> CompiledCode (Tx.BuiltinData -> Tx.BuiltinData -> ())
mintScript params = $$(Tx.compile [|| unTypedMint ||]) `Tx.unsafeApplyCode` Tx.liftCode plcVersion100 params
