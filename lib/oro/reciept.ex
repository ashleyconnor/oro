defmodule Oro.Receipt do
  @moduledoc """
  Struct which holds all reciept data
  """

  defstruct [:amount, :fee, :tx_blob, :tx_hash, :tx_key, :tx_metadata, :unsigned_txset, :multisig_txset]

  @doc """
  Creates payment struct from JSON payment object.
  """
  def from_json(payment) do
    %Oro.Receipt{
      amount: Oro.xmr_to_decimal(Map.fetch!(payment, "amount")),
      fee: Oro.xmr_to_decimal(Map.fetch!(payment, "fee")),
      tx_blob: Map.get(payment, "tx_blob"),
      tx_key: Map.get(payment, "tx_key"),
      tx_hash: Map.get(payment, "tx_hash"),
      tx_metadata: Map.get(payment, "tx_metadata"),
      unsigned_txset: Map.get(payment, "unsigned_txset"),
      multisig_txset: Map.get(payment, "multisig_txset"),
    }
  end

  @doc """
  Returns `true` if argument is a monero payment; otherwise `false`.
  """
  def receipt?(%Oro.Receipt{}), do: true
  def receipt?(_), do: false
end
