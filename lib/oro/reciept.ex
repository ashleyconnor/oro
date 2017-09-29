defmodule Oro.Receipt do
  @moduledoc """
  Struct which holds all reciept data
  """

  import IEx

  defstruct [:fee, :tx_blob, :tx_hash, :tx_key]

  @doc """
  Creates payment struct from JSON payment object.
  """
  def from_json(payment) do
    # IEx.pry

    %Oro.Receipt{
      fee:        Oro.xmr_to_decimal(Map.fetch!(payment, "fee")),
      tx_blob:    Map.get(payment, "tx_blob"),
      tx_key:     Map.get(payment, "tx_key"),
      tx_hash:    Map.get(payment, "tx_hash")
    }
  end

  @doc """
  Returns `true` if argument is a monero payment; otherwise `false`.
  """
  def receipt?(%Oro.Receipt{}), do: true
  def receipt?(_), do: false

end
