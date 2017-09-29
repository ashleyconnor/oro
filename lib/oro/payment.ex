defmodule Oro.Payment do
  @moduledoc """
  Struct which holds all payment data
  """

  import IEx

  defstruct [:payment_id,
             :tx_hash,
             :amount,
             :block_height,
             :unlock_time]

  @doc """
  Creates payment struct from JSON payment object.
  """
  def from_json(payment) do
    # IEx.pry

    %Oro.Payment{
      payment_id:   Map.get(payment, "payment_id"),
      tx_hash:      Map.get(payment, "tx_hash"),
      amount:       Oro.xmr_to_decimal(Map.fetch!(payment, "amount")),
      block_height: Map.get(payment, "block_height"),
      unlock_time:  Map.get(payment, "unlock_time")
    }
  end

  @doc """
  Returns `true` if argument is a monero payment; otherwise `false`.
  """
  def payment?(%Oro.Payment{}), do: true
  def payment?(_), do: false

end
