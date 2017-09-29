defmodule Oro do
  @moduledoc """
  Opinionated interface to Monero-wallet-RPC API.
  This probject is largely based off the Bitcoin RPC implementation Gold.
  """
  use Application

  require Logger

  alias Oro.Transfer
  alias Oro.Payment
  alias Oro.Transaction
  alias Oro.Receipt

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    opts = [strategy: :one_for_one, name: Oro.Supervisor]
    Supervisor.start_link([], opts)
  end

  @doc """
  Returns wallet's total available balance, raising an exception on failure.
  """
  def getbalance(name, account \\ nil)
  def getbalance(name, nil) do
    call(name, :getbalance) |> handle_getbalance
  end
  def getbalance(name, account) do
    call(name, {:getbalance, [account]}) |> handle_getbalance
  end

  defp handle_getbalance({:ok, %{"balance" => balance, "unlocked_balance" => unlocked_balance}}), do:
    {:ok, %{"balance" => xmr_to_decimal(balance),
      "unlocked_balance" => xmr_to_decimal(unlocked_balance)}}
  defp handle_getbalance(otherwise), do:
    otherwise

  @doc """
  Returns most recent transfers in wallet
  """
  def incoming_transfers(name, transfer_type \\ "all") do
    case call(name, {:incoming_transfers, %{transfer_type: transfer_type}}) do
      {:ok, %{"transfers" => transfers}} ->
        {:ok, Enum.map(transfers, &Transfer.from_json/1)}
      otherwise ->
        otherwise
    end
  end

  @doc """
  Returns a list of transfers
  """
  def get_transfers(name, types \\ []) do
    types = types |> Map.new(fn type -> {Atom.to_string(type), true} end)
    case call(name, {:get_transfers, types}) do
      {:ok, result} ->
        {:ok, Enum.map(result, fn {key, transfers} -> {key, Enum.map(transfers, &Transaction.from_json/1)} end)}
      otherwise ->
        otherwise
    end
  end

  @doc """
  Returns most recent payments in wallet for given payment_id
  """
  def get_payments(name, payment_id) do
    case call(name, {:get_payments, %{payment_id: payment_id}}) do
      {:ok, %{"payments" => payments}} ->
        {:ok, Enum.map(payments, &Payment.from_json/1)}
      otherwise ->
        otherwise
    end
  end

  @doc """
  Returns an integrated address with the given payment_id
  defaults to random address
  """
  def make_integrated_address(name, payment_id \\ "") do
    case call(name, {:make_integrated_address, %{payment_id: payment_id}}) do
      {:ok, %{"integrated_address" => address}} ->
        {:ok, address}
      otherwise ->
        otherwise
    end
  end

  @doc """
  Returns the current block height
  """
  def getheight(name) do
    case call(name, {:getheight, []}) do
      {:ok, %{"height" => height}} ->
        {:ok, height}
      otherwise ->
        otherwise
    end
  end

  @doc """
  Returns the current block height
  """
  def transfer(name, destinations, opts \\ []) do
    mixin = Keyword.get(opts, :mixin, 4)
    priority = Keyword.get(opts, :priority, 1)
    payment_id = Keyword.get(opts, :payment_id, nil)
    unlock_time = Keyword.get(opts, :unlock_time, 0)
    get_tx_key = Keyword.get(opts, :get_tx_key, true)
    get_tx_hex = Keyword.get(opts, :get_tx_hex, true)

    case call(name, {:transfer, %{
      "destinations" => destinations,
      "mixin" => mixin,
      "priority" => priority,
      "unlock_time" => unlock_time,
      "payment_id" => payment_id,
      "get_tx_key" => get_tx_key,
      "get_tx_hex " => get_tx_hex
    }}) do
      {:ok, payment} ->
        {:ok, Receipt.from_json(payment)}
      otherwise ->
        otherwise
    end
  end

  @doc """
  Call generic RPC command
  """
  def call(name, method) when is_atom(method), do:
    call(name, {method, []})
  def call(name, {method, params}) when is_atom(method) do
    case load_config(name) do
      :undefined ->
        {:error, {:invalid_configuration, name}}
      config ->
        handle_rpc_request(method, params, config)
    end
  end

  ##
  # Internal functions
  ##
  defp handle_rpc_request(method, params, config) when is_atom(method) do
    %{hostname: hostname, port: port} = config

    Logger.debug "Monero-wallet-RPC request for method: #{method}, params: #{inspect params}"
    Logger.debug "Hostname: #{hostname} Port: #{port}"

    params = PoisonedDecimal.poison_params(params)

    command = %{"jsonrpc": "2.0",
                "method": to_string(method),
                "params": params,
                "id": 0}

    # headers = ["Authorization": "Basic " <> Base.encode64(user <> ":" <> password)]
    headers = ["Content-Type": "application/json"]

    options = [timeout: 30000, recv_timeout: 20000]

    encoded = Poison.encode!(command)

    Logger.debug("Encoded: #{encoded}")

    case HTTPoison.post("http://" <> hostname <> ":" <> to_string(port) <> "/json_rpc", encoded, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Logger.debug "Response: #{ inspect body }"
        %{"result" => result} = Poison.decode!(body)
        {:ok, result}
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        handle_error(code, body)
    end
  end

  @statuses %{401 => :forbidden, 404 => :notfound, 500 => :internal_server_error}

  defp handle_error(status_code, error) do
    status = @statuses[status_code]
    Logger.debug "Monero-wallet-RPC error status #{status}: #{error}"
    case Poison.decode(error) do
      {:ok, %{"error" => %{"message" => message}}} ->
        {:error, %{status: status, error: message}}
      {:error, :invalid, _pos} ->
        {:error, %{status: status, error: error}}
      {:error, {:invalid, _token, _pos}} ->
        {:error, %{status: status, error: error}}
    end
  end

  @doc """
  Converts a integer XMR amount to decimal
  """
  def xmr_to_decimal(balance) when is_integer(balance) do
    %Decimal{sign: if(balance < 0, do: -1, else: 1), coef: abs(balance), exp: -12}
  end

  defp load_config(node_name) do
    case :application.get_env(:oro, node_name) do
      {:ok, config} -> Enum.into(config, %{})
      :undefined -> :undefined
    end
  end

end
