defmodule Oro do
  @moduledoc """
  Opinionated interface to Monero-wallet-RPC API.
  This probject is largely based off the Bitcoin RPC implementation Gold.
  """
  use Application

  require Logger

  alias Oro.Transaction

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

  defp handle_getbalance({:ok, balance}), do:
    {:ok, xmr_to_decimal(balance)}
  defp handle_getbalance(otherwise), do:
    otherwise

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
  def xmr_to_decimal(%{"balance" => balance, "unlocked_balance" => unlocked_balance}) do
    %{
      "balance": xmr_to_decimal(balance),
      "unlocked_balance": xmr_to_decimal(unlocked_balance)
    }
  end

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
