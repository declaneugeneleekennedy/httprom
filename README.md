# HTTProm

An [HTTPoison](https://github.com/edgurgel/httpoison) wrapper which allows
configurable instrumentation using [Prometheus.ex](https://github.com/deadtrickster/prometheus.ex).

## Installation

The package can be installed by adding `httprom` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:httprom, "~> 0.1.0"}
  ]
end
```

## Usage

Currently supports instrumentation of:

* Timers via Histogram
* Counters which can be configured for specific status codes

Setting up the histogram and counters is all done using configuration:

```elixir
use Mix.Config

config :httprom, :metrics, [
  # Capture request time
  [
    type: :histogram,
    config: [
      name: :api_request_time,
      labels: [:method],
      buckets: [100, 300, 500, 750, 1000],
      help: "Request time"
    ]
  ],
  # Count 200 response
  [
    type: :counter,
    for_status: 200, # Change to whatever status you want to count
    config: [
      name: :ok_status,
      help: "200 OK counter"
    ]
  ],
  # Count 500 response
  [
    type: :counter,
    for_status: 500,
    config: [
      name: :internal_server_error_status,
      help: "500 Internal Server Error counter"
    ]
  ]
]
```

In order to instrument your requests, just use `HTTProm` in place of
`HTTPoison` in your code, for example:

```elixir
# Original
{:ok, response} = HTTPoison.get("http://example.com")

# Instrumented
{:ok, response} = HTTProm.get("http://example.com")
```

Metrics which are captured using the above method will be automatically given
the label `:httprom`.

As with `HTTPoison`, `HTTProm` supports extension. To create your own client,
just `use HTTProm.Base` and provide a custom label:

```elixir
defmodule GithubClient do
  use HTTProm.Base, label: :github_client

  def request(method, url) do
    # Perform some custom setup
    super(method, url)
  end
```

## License

```
This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the LICENSE file for more details.
```
