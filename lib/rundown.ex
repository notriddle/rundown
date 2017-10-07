defmodule Rundown do
  @moduledoc """
  Convert Markdown to safe HTML.
  """

  @doc """
  Convert Markdown to safe HTML.

  ## Examples

      iex> Rundown.convert("https://github.com/notriddle/rundown/", "test [link](.)")
      {:ok, "<p>test <a href=\\"https://github.com/notriddle/rundown/\\" rel=\\"noopener noreferrer\\">link</a></p>\\n"}

  """
  def convert(url, markdown) do
    GenServer.call(get_worker(), {:convert, url, markdown}, 10_000)
  end

  defp create_worker_queue do
    :rundown
    |> Application.get_env(:workers)
    |> Enum.reduce(:queue.new(), &:queue.cons/2)
  end
  defp get_worker do
    workers = Process.get(Rundown.Workers) || create_worker_queue()
    worker = :queue.head(workers)
    workers = :queue.tail(workers)
    workers = :queue.snoc(workers, worker)
    Process.put(Rundown.Workers, workers)
    worker
  end
end
