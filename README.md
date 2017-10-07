Convert Markdown into HTML, securely
====================================

[Documentation](https://hexdocs.pm/rundown)

Converts Markdown to safe HTML.
This is an Elixir frontend to the Rust-based [Ammonia] and [Comrak] libraries,
allowing your users to use HTML or Markdown syntax, just like they can on GitHub.
The Hex.PM version, however, has pre-compiled binaries for Linux,
Mac OS X, and Windows.

[Ammonia]: https://github.com/notriddle/ammonia
[Comrak]: https://github.com/kivikakk/comrak

## Compiling

To build directly from the repo,
you're going to need the Rust and Elixir compilers.
The [hex.pm] distribution, however, ships pre-built binaries for
Windows, macOS, Linux, and FreeBSD on x86_64,
so you don't need a Rust compiler there.

[hex.pm]: https://hex.pm/

## Installation

```elixir
def deps do
  [
    {:rundown, "~> 0.1.0"}
  ]
end
```
