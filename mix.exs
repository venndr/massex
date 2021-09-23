defmodule Massex.MixProject do
  use Mix.Project

  @version "1.0.0"
  @description "A whole-value pattern library for handling masses"
  @homepage_url "https://github.com/venndr/massex"

  def project do
    [
      app: :massex,
      version: @version,
      description: @description,
      docs: fn ->
        [
          source_ref: "v#{@version}",
          canonical: "http://hexdocs.pm/massex",
          main: "Massex",
          source_url: @homepage_url,
          extras: ["README.md", "CONTRIBUTING.md"]
        ]
      end,
      package: %{
        contributors: ["John Maxwell", "Niklas Lindgren", "Bjørn Zeiler Hougaard"],
        licenses: ["MIT"],
        links: %{
          "GitHub" => @homepage_url
        },
        maintainers: ["John Maxwell", "Niklas Lindgren", "Bjørn Zeiler Hougaard"]
      },
      homepage_url: @homepage_url,
      source_url: @homepage_url,
      elixir: "~> 1.10",
      preferred_cli_env: [check: :test],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        # plt_add_deps: :jason,
        plt_add_apps: [:absinthe, :ecto, :jason]
      ]
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
      {:absinthe, "~> 1.6", optional: true},
      {:ecto, "~> 3.0", optional: true},
      {:jason, "~> 1.2.2", optional: true},
      {:decimal, "~> 2.0"},
      # Development Utils
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false, optional: true},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false, optional: true},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false, optional: true}
    ]
  end
end
