defmodule IgniterToolbox.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/yourusername/igniter_toolbox"

  def project do
    [
      app: :igniter_toolbox,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      name: "IgniterToolbox",
      description: "A collection of useful Igniter-based Mix tasks for code generation",
      source_url: @source_url
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:igniter, "~> 0.5"},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
