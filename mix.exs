defmodule Massex.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :massex,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:absinthe, "~> 1.4", optional: true},
      {:ecto, "~> 3.0", optional: true},
      {:jason, ">= 0.0.0", optional: true},
      {:decimal, "~> 1.0"}
    ]
  end
end
