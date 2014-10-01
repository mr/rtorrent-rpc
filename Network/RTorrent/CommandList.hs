{-# LANGUAGE TypeFamilies #-}

{-|
Module      : Commands
Copyright   : (c) Kai Lindholm, 2014
License     : MIT
Maintainer  : megantti@gmail.com
Stability   : experimental

A module for defined commands.
-}

module Network.RTorrent.CommandList 
  ( module Network.RTorrent.Torrent
  , module Network.RTorrent.Priority
  , module Network.RTorrent.File
  , module Network.RTorrent.TorrentCommand

  -- * Functions for getting global variables
  , Global 
  , getUpRate 
  , getDownRate
  , getSimple
  , getDirectory
  , getPid

  , getUploadRate
  , getDownloadRate
  , setUploadRate
  , setDownloadRate

  , loadTorrent

  -- * Re-exported from "Network.RTorrent.Action"
  , (<+>)
  , sequenceActions
  , simpleAction
  -- * Re-exported from "Network.RTorrent.Commands"
  , (:*:)(..)
  , MultiCommand (..)
  , AnyCommand (..)
  )
  where

import Control.DeepSeq
import Network.XmlRpc.Internals

import Network.RTorrent.Action
import Network.RTorrent.Commands
import Network.RTorrent.File
import Network.RTorrent.Torrent
import Network.RTorrent.Priority
import Network.RTorrent.TorrentCommand


-- | Get a raw rtorrent variable.
getSimple :: (XmlRpcType a, NFData a) => String -> Global a
getSimple = Global parseSingle []

-- | Get the current up rate, in bytes per second.
getUpRate :: Global Int
getUpRate = getSimple "get_up_rate"

-- | Get the current down rate, in bytes per second.
getDownRate :: Global Int
getDownRate = getSimple "get_down_rate"

-- | Get the default download directory.
getDirectory :: Global String
getDirectory = getSimple "get_directory"

-- | Get the maximum upload rate, in bytes per second.
--
-- @0@ means no limit.
getUploadRate :: Global Int
getUploadRate = getSimple "get_upload_rate"

-- | Get the maximum download rate, in bytes per second.
--
-- @0@ means no limit.
getDownloadRate :: Global Int
getDownloadRate = getSimple "get_download_rate"

-- | Set the maximum upload rate, in bytes per second.
setUploadRate :: Int -> Global Int
setUploadRate i = Global parseSingle [ValueInt i] "set_upload_rate"

-- | Set the maximum download rate, in bytes per second.
setDownloadRate :: Int -> Global Int
setDownloadRate i = Global parseSingle [ValueInt i] "set_download_rate"

-- | Get the process id.
getPid :: Global Int
getPid = getSimple "system.pid"

-- | Load a torrent file.
loadTorrent :: String -- ^ Path
        -> Global Int
loadTorrent path = Global parseSingle [ValueString path] "load"

-- | Get a variable with result type @t@.
data Global t = Global (Value -> t) [Value] String
instance Command (Global a) where
    type Ret (Global a) = a
    commandCall (Global _ args cmd) = mkRTMethodCall cmd args
    commandValue (Global parse _ _) = parse

instance Functor Global where
    fmap f (Global g args s) = Global (f . g) args s
