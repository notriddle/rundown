defmodule RundownTest do
  use ExUnit.Case
  doctest Rundown

  # Test the netstring framing.
  test "output mapping works for len=0" do
    assert Rundown.convert("http://3.ly/", "") == {:ok, ""}
  end
  test "output mapping works for len=1..1_000" do
    for i <- 1..1_000 do
      string = 'x' |> Stream.cycle() |> Enum.take(i) |> List.to_string()
      html = "<p>#{string}</p>\n"
      assert Rundown.convert("http://3.ly/", string) == {:ok, html}
    end
  end
  test "output mapping works for len=10_000..11_000" do
    for i <- 10_000..11_000 do
      string = 'x' |> Stream.cycle() |> Enum.take(i) |> List.to_string()
      html = "<p>#{string}</p>\n"
      assert Rundown.convert("http://3.ly/", string) == {:ok, html}
    end
  end
  test "output mapping works for len=10_000_000" do
    string = 'x' |> Stream.cycle() |> Enum.take(10_000_000) |> List.to_string()
    html = "<p>#{string}</p>\n"
    assert Rundown.convert("http://3.ly/", string) == {:ok, html}
  end
end
