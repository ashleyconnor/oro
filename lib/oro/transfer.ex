defmodule Oro.Transfer do
  @moduledoc """
  Struct which holds all transfer data
  """

  defstruct [:amount,
             :spent,
             :global_index,
             :tx_hash,
             :tx_size]

  @doc """
  Creates transfer struct from JSON transfer object.
  """
  def from_json(transfer) do
    %Oro.Transfer{
      spent:        Map.get(transfer, "spent"),
      amount:       Oro.xmr_to_decimal(Map.fetch!(transfer, "amount")),
      global_index: Map.get(transfer, "global_index"),
      tx_hash:      Map.get(transfer, "tx_hash"),
      tx_size:      Map.get(transfer, "tx_size")
    }
  end

  @doc """
  Returns `true` if argument is a monero transfer; otherwise `false`.
  """
  def transfer?(%Oro.Transfer{}), do: true
  def transfer?(_), do: false
end
