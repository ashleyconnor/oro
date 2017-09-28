defmodule Oro.Mixfile do
  use Mix.Project

  def project do
    [
      app: :oro,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:decimal,   "~> 1.1"},
      {:httpoison, "~> 0.7"},
      {:poison, "~> 3.0 or ~> 2.0"}
    ]
  end
end
