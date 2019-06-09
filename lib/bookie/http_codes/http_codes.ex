defmodule HTTPCodes do
  @moduledoc """
  HTTPCodes used to save all http related codes
  """
  def ok, do: 200
  def bad_request, do: 400
  def unauthorized, do: 401
  def no_permission, do: 403
end
