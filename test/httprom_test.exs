defmodule HTTPromTest do
  use ExUnit.Case

  import Mox

  alias HTTPoison.Response
  alias HTTProm.Instrumenter
  alias Plug.Conn

  setup :set_mox_global
  setup :verify_on_exit!

  setup tags do
    Application.put_env(:httprom, :metrics, tags[:config])

    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "HTTProm" do
    @tag config: [
      [
        type: :histogram,
        module: HistogramMock,
        config: [
          name: :histo_magnifico,
          labels: [:method],
          buckets: [100, 300, 500, 750, 1000],
          help: "Magnificent Histogram"
        ]
      ],
      [
        type: :counter,
        module: CounterMock,
        for_status: 200,
        config: [
          name: :status_ok,
          help: "Status counter for 200 OK"
        ]
      ]
    ]
    test "can observe an HTTP request", %{bypass: bypass} do
      Bypass.expect_once bypass, "GET", "/hello", fn conn ->
        Conn.resp(conn, 200, "ok")
      end

      url = "http://localhost:#{bypass.port}/hello"

      HistogramMock
      |> expect(:new, fn [
                          name: :histo_magnifico,
                          labels: [:method],
                          buckets: [100, 300, 500, 750, 1000],
                          help: "Magnificent Histogram"
                        ] ->
        :ok
      end)
      |> expect(:observe, fn [
                              name: :histo_magnifico,
                              labels: [^url, 200]
                            ],
                            time
                            when is_integer(time) ->
        :ok
      end)

      CounterMock
      |> expect(:new, fn [
                            name: :status_ok,
                            help: "Status counter for 200 OK"
                        ] ->
                            :ok
                          end)
      |> expect(:inc, fn [name: :status_ok] -> :ok end)

      Instrumenter.setup()

      HTTProm.get(url)
    end

    @tag config: [
      [
        type: :unknown,
        module: :none,
        config: [
          does: :not,
          matter: :lol
        ]
      ]
    ]
    test "that setup fails for unknown metrics" do
      assert_raise ArgumentError, "Unknown metric: :unknown", fn ->
        Instrumenter.setup()
      end
    end

    @tag config: [
      [
        type: :unknown,
        module: :none,
        config: [
          name: :it,
          does: :not,
          matter: :lol
        ]
      ]
    ]
    test "that instrument fails for unknown metrics" do
      assert_raise ArgumentError, "Unknown metric: :unknown", fn ->
        Instrumenter.instrument(%{result: {:ok, %Response{}}, time: 0})
      end
    end
  end
end
