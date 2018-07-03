defmodule HTTProm.Base do
  @moduledoc """
  The base for extending HTTProm implementations, which works in much the same
  way as HTTPoison.Base.
  """

  defmacro __using__(opts) do
    quote do
      use HTTPoison.Base

      alias HTTProm.Instrumenter

      @label Keyword.fetch!(unquote(opts), :label)

      def request(method, url, body \\ "", headers \\ [], options \\ []) do
        start_time  = :erlang.system_time()
        result      = super(method, url, body, headers, options)
        duration    = :erlang.system_time() - start_time

        Instrumenter.instrument(%{result: result, time: duration, label: @label})

        result
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end
