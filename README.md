# Oro

> Esperanto: oro {noun} - gold {noun}


Documentation: http://hexdocs.pm/oro/

## Usage

Add oro as a dependency in your `mix.exs` file.

```elixir
def deps do
  [ { :oro, "~> 0.1.0" } ]
end
```

You will also need to configure your application to connect to the
correct node

```elixir
config :oro, :my_node, [
  hostname: "localhost",
  port: 8332,
  user: "monero-rpc",
  password: "changeme"
]
```

After you are done, run `mix deps.get` in your shell to fetch and compile Oro. Start an interactive Elixir shell with `iex -S mix`.

```iex
iex> Oro.getbalance!(:my_node)
#Decimal<9074.99999583>
iex> Oro.listtransactions!(:my_node)
[%Oro.Transaction{account: "", address: "mvZZq9C8ZiK85fLPL26N7n81D5jKu8SgcD",
  amount: #Decimal<12.50000226>,
  blockhash: "7e5ca54602567bec3fa7067344ae0916236e01d2c9f6cae80509b291f97edf0f",
  blockindex: 0, category: :immature, comment: nil, confirmations: 3, fee: nil,
  otheraccount: nil, time: 1442466804, timereceived: 1442466804,
  txid: "6c173c5b90bc0c565e15d0144d57e81ec9ce95aac86f0e77c354d7acf1fbf68b",
  vout: 0}]
```

## Testing

You need a private testnet setup to run tests. This [this](https://github.com/libra-ventures/monero-docker-testnet/) project gives you what you need.


When you are done setting everything up you can run tests with `docker compose up` and then `mix test`.

## Features
  * Uses the [Decimal](https://github.com/ericmj/decimal) library for representing XMR amounts, to avoid loss of precision
  * Directly maps [Monero-wallet-RPC functions](https://getmonero.org/resources/developer-guides/wallet-rpc.html)

## TODO

- Map missing RPC methods
- Tests