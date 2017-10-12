defmodule Rundown.Mixfile do
  use Mix.Project

  def project do
    [
      app: :rundown,
      version: "0.1.7",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      compilers: Mix.compilers ++ [:rust_server],
      deps: deps(),
      package: package(),
      source_url: "https://github.com/notriddle/rundown",
      docs: [
        main: "readme",
        extras: [ "README.md" ] ],
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Rundown.Application, []},
      env: [workers: [Rundown.A, Rundown.B, Rundown.C, Rundown.D]]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:earmark, "~> 1.2.3", only: :dev},
      {:ex_doc, "~> 0.17.1", only: :dev},
    ]
  end

  defp package, do: [
    name: :rundown,
    description: "Convert Markdown into (a safe subset of) HTML",
    files: ["prebuilt", "lib", "mix.exs"],
    maintainers: ["Michael Howell <michael@notriddle.com>"],
    licenses: ["MIT", "Apache-2.0"],
    links: %{"Github" => "https://github.com/notriddle/rundown/"}
  ]
end

defmodule Mix.Tasks.Compile.RustServer do
  use Mix.Task
  @shortdoc "Compiles the Rust server"
  def run(_) do
    File.rm_rf("priv/native")
    File.mkdir_p("priv/native")

    if File.exists?(exe_prebuilt_path()) do
      File.cp(exe_prebuilt_path(), exe_priv_path())
    else
      compile()
    end
  end

  defp compile do
    {result, error_code} = System.cmd("cargo", ["build", "--release"],
      stderr_to_stdout: true,
      cd: "server/")
    IO.binwrite(result)

    if error_code != 0 do
      raise Mix.Error, message: """
        Could not run `cargo build`.
        Please make sure the Rust compiler suite is installed.
      """
    end

    File.cp(exe_build_path(), exe_priv_path())

    Mix.Project.build_structure
    :ok
  end

  defp exe_build_path do
    "server/target/release/rundown-server#{exe_suffix()}"
  end
  defp exe_priv_path do
    Path.join([:code.priv_dir(:rundown), "native", "rundown-server#{exe_suffix()}"])
  end
  defp exe_prebuilt_path do
    {_, os} = :os.type()
    "prebuilt/#{Atom.to_string(os)}/rundown-server#{exe_suffix()}"
  end
  defp exe_suffix do
    case :os.type() do
      {:unix, _} -> ""
      {:win32, _} -> ".exe"
    end
  end
end
