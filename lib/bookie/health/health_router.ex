defmodule Bookie.Health.Router do
  use Bookie, :router

  alias Bookie.Health.{
    Controller
  }

  get("/", Controller, :index)
end
