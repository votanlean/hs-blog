{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE StandaloneDeriving    #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE DuplicateRecordFields #-}

module DB where
import qualified  Data.ByteString as BS
import qualified  Data.Text as Text
import            Database.Beam

data UserT f = 
  User
    { _id :: C f Integer
    , _name :: C f Text.Text
    , _email :: C f Text.Text
    }
      deriving Generic
type User = UserT Identity
deriving instance Show UserId
deriving instance Show User

instance Table UserT where
  data PrimaryKey UserT f = UserId (Columnar f Integer) deriving Generic
  primaryKey = UserId . (_id :: UserT f -> C f Integer)
type UserId = PrimaryKey UserT Identity

instance Beamable UserT
instance Beamable (PrimaryKey UserT)

data MessageT f = 
  Message
    { _id :: C  f Integer
    , _from :: PrimaryKey UserT f
    , _content :: C f Text.Text
    }
      deriving Generic
type Message = MessageT Identity
deriving instance Show (PrimaryKey MessageT Identity)
deriving instance Show Message

instance Table MessageT where
  data PrimaryKey MessageT f = MessageId (Columnar f Integer) deriving Generic
  primaryKey = MessageId . (_id :: MessageT f -> C f Integer)
type MessageId = PrimaryKey MessageT Identity

instance Beamable MessageT
instance Beamable (PrimaryKey MessageT)

data AwesomeDb f = AwesomeDb
                    { _ausers :: f (TableEntity UserT)
                    , _messages :: f (TableEntity MessageT) }
                      deriving Generic

connectionString :: BS.ByteString
connectionString = "postgres://noptryrylbbldq:3e10e3ec5c2efc990b1367456aff2af1d2016f848c15167990fdbe9fd3035589@ec2-54-159-35-35.compute-1.amazonaws.com:5432/d824hirmfm0i6p"

instance Database be AwesomeDb

awesomeDB :: DatabaseSettings be AwesomeDb
awesomeDB = defaultDbSettings