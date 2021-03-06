{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators #-}

module Config where

import Network.Socket
import Polysemy
import System.Directory
import System.Environment

data Config m a where
  GetArguments :: Config m [String]
  GetAddress :: Config m (HostName, ServiceName)

makeSem ''Config

interpretConfig :: Member (Embed IO) r => Sem (Config ': r) a -> Sem r a
interpretConfig =
  interpret
    ( \case
        GetArguments -> embed getArgs
        GetAddress -> embed $ do
          homeDir <- getHomeDirectory
          let fileP = homeDir ++ "/.yeelight_wrapper.config"
          r <- doesFileExist fileP
          if r
            then do
              [host, port] <- lines <$> readFile fileP
              return (host, port)
            else do
              writeFile fileP "Null\n55443"
              return ("Null", "55443")
    )
