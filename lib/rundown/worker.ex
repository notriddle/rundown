defmodule Rundown.Worker do
  @moduledoc false
  use GenServer
  require Logger
  def start_link(name) do
    GenServer.start_link(__MODULE__, :no_args, name: name)
  end
  def init(:no_args) do
    # In case you were curious, Port.open will launch an executable on Windows
    # without the `.exe` extension.
    # The executable actually does have that extension,
    # but we can leave it out here and Windows will implicitly recognize that
    # priv\native\rundown-server (which does not exist) should launch
    # priv\native\rundown-server.exe (which does).
    path = Path.join([:code.priv_dir(:rundown), "native", "rundown-server"])
    port = Port.open({:spawn, path}, [:binary])
    {:ok, port}
  end
  def handle_call({:convert, url, markdown}, _from, port) do
    # Request
    true = Port.command(port, [
      url |> byte_size |> Integer.to_string,
      ":",
      url,
      markdown |> byte_size |> Integer.to_string,
      ":",
      markdown,
    ])
    # Response
    html = retrieve_netstring(port)
    {:reply, {:ok, html}, port}
  end
  def retrieve_netstring(port), do: retrieve_netstring_len_("", "", port)
  def retrieve_netstring_len_(len, ":" <> buf, port) do
    len
    |> String.to_integer()
    |> retrieve_netstring_payload_(buf, port)
  end
  def retrieve_netstring_len_(len, "", port) do
    Logger.debug("l:len=#{len}")
    Logger.debug("l:buf empty")
    receive do
      {^port, {:data, buf}} ->
        retrieve_netstring_len_(len, buf, port)
    after
      10_000 -> raise "timeout"
    end
  end
  def retrieve_netstring_len_(len, buf, port) do
    Logger.debug("l:len=#{len}")
    Logger.debug("l:buf=#{buf}")
    <<b :: 8, buf :: binary>> = buf
    len = <<len :: binary, b :: 8>>
    retrieve_netstring_len_(len, buf, port)
  end
  def retrieve_netstring_payload_(len, buf, _) when len === byte_size(buf) do
    buf
  end
  def retrieve_netstring_payload_(len, buf, port) do
    Logger.debug("len=#{len}")
    Logger.debug("buf=#{buf}")
    receive do
      {^port, {:data, data}} ->
        retrieve_netstring_payload_(len, buf <> data, port)
    after
      10_000 -> raise "timeout"
    end
  end
end
