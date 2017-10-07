defmodule Rundown.Mixfile do
  use Mix.Project

  def project do
    [
      app: :rundown,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      compilers: Mix.compilers ++ [:rust_server],
      deps: deps(),
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
      {:ex_doc, "~> 0.14", only: :dev},
    ]
  end
end

defmodule Mix.Tasks.Compile.RustServer do
  use Mix.Task
  @shortdoc "Compiles the Rust server"
  def run(_) do
    {_, os} = :os.type()
    if File.exists?(exe_prebuilt_path()) do
      File.cp(exe_prebuilt_path(), exe_priv_path())
    else
      compile()
    end
  end

  defp compile do
    File.rm_rf("priv/native")
    File.mkdir("priv/native")

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
    "priv/native/rundown-server#{exe_suffix()}"
  end
  defp exe_prebuilt_path do
    "prebuilt/#{Atom.to_string(os)}/rundown-server#{exe_suffix()}"
  end
  defp exe_suffix do
    case :os.type() do
      {:unix, _} -> ""
      {:win32, _} -> ".exe"
    end
  end
end
