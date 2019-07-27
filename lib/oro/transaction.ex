defmodule Oro.Transaction do
  @moduledoc """
  Struct which holds all transaction data
  """

  defstruct [
    :txid,
    :payment_id,
    :height,
    :timestamp,
    :amount,
    :fee,
    :note,
    :address,
    :type,
    :double_spend_seen,
    :destinations,
    :subaddr_index,
    :unlock_time,
    :suggested_confirmations_threshold,
    :confirmations
  ]

  @doc """
  Creates transaction struct from JSON transaction object.
  """
  def from_json(tx) do
    %Oro.Transaction{
      address: Map.get(tx, "address"),
      amount: Oro.xmr_to_decimal(Map.fetch!(tx, "amount")),
      double_spend_seen: Map.get(tx, "double_spend_seen"),
      note: Map.get(tx, "note"),
      txid: Map.get(tx, "txid"),
      payment_id: Map.get(tx, "payment_id"),
      height: Map.get(tx, "height"),
      timestamp: Map.get(tx, "timestamp"),
      fee: Oro.xmr_to_decimal(Map.fetch!(tx, "fee")),
      destinations: Map.get(tx, "destinations"),
      type: Map.get(tx, "type"),
      unlock_time: Map.get(tx, "unlock_time"),
      subaddr_index: Map.get(tx, "subaddr_index"),
      confirmations: Map.get(tx, "confirmations"),
      suggested_confirmations_threshold: Map.get(tx, "suggested_confirmations_threshold")
    }
  end

  @doc """
  Returns `true` if argument is a monero transaction; otherwise `false`.
  """
  def transaction?(%Oro.Transaction{}), do: true
  def transaction?(_), do: false
end
