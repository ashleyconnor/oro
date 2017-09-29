defmodule Oro.Transaction do
  @moduledoc """
  Struct which holds all transaction data
  """

  import IEx

  defstruct [:txid,
             :payment_id,
             :height,
             :timestamp,
             :amount,
             :fee,
             :note,
             :destinations,
             :type]

  @doc """
  Creates transaction struct from JSON transaction object.
  """
  def from_json(tx) do
    # IEx.pry

    %Oro.Transaction{
      txid:         Map.get(tx, "txid"),
      payment_id:   Map.get(tx, "payment_id"),
      height:       Map.get(tx, "height"),
      timestamp:    Map.get(tx, "timestamp"),
      amount:       Oro.xmr_to_decimal(Map.fetch!(tx, "amount")),
      fee:          Oro.xmr_to_decimal(Map.fetch!(tx, "fee")),
      note:         Map.get(tx, "note"),
      destinations: Map.get(tx, "destinations"),
      type:         Map.get(tx, "type")
    }
  end

  @doc """
  Returns `true` if argument is a monero transaction; otherwise `false`.
  """
  def transaction?(%Oro.Transaction{}), do: true
  def transaction?(_), do: false

end
