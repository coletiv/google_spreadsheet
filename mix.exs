defmodule GoogleSpreadsheet.MixProject do
  use Mix.Project

  def project do
    [
      app: :google_spreadsheet,
      version: "1.0.0",
      elixir: "~> 1.7",
      description: "Elixir package to work with Google (Drive) Sheets",
      docs: [extras: ["README.md"]],
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  def package do
    [
      name: :google_spreadsheet,
      files: ["lib", "mix.exs"],
      maintainers: ["Nuno Marinho"],
      links: %{"Github" => "https://github.com/coletiv/google_spreadsheet"},
      licenses: ["MIT"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  [
    applications: [
      :logger,
      :goth,
      :httpoison,
      :gen_stage,
      :poison
    ],
    mod: {GoogleSpreadsheet, []}
  ]

  defp deps do
    [
      # gdrive Auth
      {:goth, "~> 1.1.0"},
      # rest requests
      {:httpoison, "~> 1.5.1"},
      {:gen_stage, "~> 0.14"},
      # Handle JSON
      {:poison, "~> 4.0.1"},
      {:earmark, "~> 1.3.6", only: :dev},
      {:ex_doc, "~> 0.21.2", only: :dev},
      {:logger_file_backend, ">= 0.0.10", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      # blankable
      {:blankable, "~> 1.0.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]
end
