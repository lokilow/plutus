{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE DerivingStrategies    #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE RecordWildCards       #-}
{-# LANGUAGE TypeApplications      #-}
{-# LANGUAGE TypeOperators         #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Server where

import           API                         (API)
import           Control.Monad.Except        (ExceptT)
import           Control.Monad.IO.Class      (MonadIO, liftIO)
import           Control.Monad.Logger        (LoggingT, MonadLogger, logInfoN, runStderrLoggingT)
import           Control.Monad.Reader        (ReaderT, runReaderT)
import           Data.Aeson                  (FromJSON, ToJSON, eitherDecode, encode)
import           Data.Aeson                  as Aeson
import           Data.Proxy                  (Proxy (Proxy))
import           Data.String                 as S
import           Data.Text                   (Text)
import qualified Data.Text                   as Text
import           GHC.Generics                (Generic)
import           Git                         (gitRev)
import           Network.Wai.Middleware.Cors (cors, corsRequestHeaders, simpleCorsResourcePolicy)
import           Servant                     (Application, Handler (Handler), Server, ServerError, hoistServer, serve,
                                              (:<|>) ((:<|>)), (:>))
import qualified WebSocket                   as WS

version :: Applicative m => m Text
version = pure gitRev

handlers :: Server API
handlers = version :<|> WS.handle

app :: Application
app =
  cors (const $ Just policy) $ serve (Proxy @API) handlers
  where
    policy =
      simpleCorsResourcePolicy

initializeApplication :: IO Application
initializeApplication = pure app
