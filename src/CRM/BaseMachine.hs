{-# LANGUAGE DataKinds #-}

module CRM.BaseMachine where

import CRM.Topology
import "base" Data.Kind (Type)
import "profunctors" Data.Profunctor (Profunctor (..), Strong (..))

-- * Specifying state machines

{- | A `BaseMachine topology input output` describes a state machine with
   allowed transitions constrained by a given `topology`.
   A state machine is composed by an `initialState` and an `action`, which
   defines the `output` and the new `state` given the current `state` and an
   `input`
-}
data
  BaseMachine
    (topology :: Topology vertex)
    (input :: Type)
    (output :: Type) = forall state.
  BaseMachine
  { initialState :: InitialState state
  , action
      :: forall initialVertex
       . state initialVertex
      -> input
      -> ActionResult topology state initialVertex output
  }

instance Profunctor (BaseMachine topology) where
  lmap :: (a -> b) -> BaseMachine topology b c -> BaseMachine topology a c
  lmap f (BaseMachine initialState action) =
    BaseMachine
      { initialState = initialState
      , action = (. f) . action
      }

  rmap :: (b -> c) -> BaseMachine topology a b -> BaseMachine topology a c
  rmap f (BaseMachine initialState action) =
    BaseMachine
      { initialState = initialState
      , action = ((f <$>) .) . action
      }

instance Strong (BaseMachine topology) where
  first' :: BaseMachine topology a b -> BaseMachine topology (a, c) (b, c)
  first' (BaseMachine initialState action) =
    BaseMachine
      { initialState = initialState
      , action = \state (a, c) -> (,c) <$> action state a
      }

  second' :: BaseMachine topology a b -> BaseMachine topology (c, a) (c, b)
  second' (BaseMachine initialState action) =
    BaseMachine
      { initialState = initialState
      , action = \state (c, a) -> (c,) <$> action state a
      }

{- | A value of type `InitialState state` describes the initial state of a
   state machine, describing the initial `vertex` in the `topology` and the
   actual initial data of type `state vertex`
-}
data InitialState (state :: vertex -> Type) where
  InitialState :: state vertex -> InitialState state

{- | The result of an action of the state machine.
   An `ActionResult topology state initialVertex output` contains an `output` and a `state finalVertex`,
   where the transition from `initialVertex` to `finalVertex` is allowed by the machine `topology`
-}
data
  ActionResult
    (topology :: Topology vertex)
    (state :: vertex -> Type)
    (initialVertex :: vertex)
    (output :: Type)
  where
  ActionResult
    :: AllowedTransition topology initialVertex finalVertex
    => state finalVertex
    -> output
    -> ActionResult topology state initialVertex output

instance Functor (ActionResult topology state initialVertex) where
  fmap
    :: (a -> b)
    -> ActionResult topology state initialVertex a
    -> ActionResult topology state initialVertex b
  fmap f (ActionResult state output) =
    ActionResult state (f output)