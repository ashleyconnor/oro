use Mix.Config

config :logger, :console, format: "[$level] $message\n", level: :debug

config :oro, :regtest, [
  hostname: "127.0.0.1",
  port: 18082,
  user: "",
  password: ""
]
