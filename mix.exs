defmodule EtsSemaphore.MixProject do
  use Mix.Project

  def project do
    [
      app: :ets_semaphore,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "EtsSemaphore",
      source_url: "https://github.com/zacky1972/ets_semaphore",
      docs: [
        main: "EtsSemaphore",
        extras: ["README.md"]
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
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false},
      {:benchee, "~> 1.0", only: :dev}
    ]
  end
end
