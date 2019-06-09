defmodule Bookie.Health.Router do
  @moduledoc """
  simple router for health modules
  in case in future we have more modules where health check is reuired then we should add those
  at this place only
  """
  use Bookie, :router

  alias Bookie.Health.{
    Controller
  }

  get("/", Controller, :index)
end
