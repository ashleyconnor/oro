defmodule Oro.PoisonedDecimal do
  @moduledoc """
  Wrapper for Decimal library to use different encoding than the one prepared for Decimal in Ecto
  """

  defstruct [:decimal]

  def new(%Decimal{} = decimal) do
    %Oro.PoisonedDecimal{decimal: decimal}
  end

  def poison_params(%Oro.PoisonedDecimal{} = params) do
    params
  end

  def poison_params(%Decimal{} = params) do
    params |> new
  end

  def poison_params({key, value}) do
    {poison_params(key), poison_params(value)}
  end

  def poison_params(params) when is_list(params) do
    params |> Enum.map(&poison_params/1)
  end

  def poison_params(%{__struct__: s} = params) do
    params
    |> Map.from_struct()
    |> Map.to_list()
    |> poison_params
    |> s.__struct__
  end

  def poison_params(%{} = params) do
    params
    |> Map.to_list()
    |> poison_params
    |> Map.new()
  end

  def poison_params(params), do: params
end
