defmodule Oro.Transaction do
  @moduledoc """
  Struct which holds all transaction data
  """

  defstruct [:account,
             :address,
             :category,
             :amount,
             :vout,
             :fee,
             :confirmations,
             :blockhash,
             :blockindex,
             :txid,
             :time,
             :timereceived,
             :comment,
             :otheraccount]

  @doc """
  Creates Transaction struct from JSON transaction object.
  """
  def from_json(tx) do
    %Oro.Transaction{
      account:       Map.get(tx, "account", nil),
      address:       Map.get(tx, "address", nil),
      category:      case Map.get(tx, "category", nil) do
                       nil -> nil
                       otherwise -> String.to_atom otherwise
                     end,
      amount:        Oro.xmr_to_decimal(Map.fetch!(tx, "amount")),
      vout:          Map.get(tx, "vout", nil),
      fee:           Oro.xmr_to_decimal(Map.get(tx, "fee", nil)),
      confirmations: Map.fetch!(tx, "confirmations"),

      blockhash:     Map.get(tx, "blockhash", nil),
      blockindex:    Map.get(tx, "blockindex", nil),
      txid:          Map.fetch!(tx, "txid"),

      time:          Map.fetch!(tx, "time"),
      timereceived:  Map.fetch!(tx, "timereceived"),
      comment:       Map.get(tx, "comment", nil),
      otheraccount:  Map.get(tx, "otheraccount", nil)
    }
  end

  @doc """
  Returns `true` if argument is a bitcoin transaction; otherwise `false`.
  """
  def transaction?(%Oro.Transaction{}), do: true
  def transaction?(_), do: false

end
