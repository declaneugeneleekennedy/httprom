defmodule HTTProm.Base do
  @moduledoc """
  The base for extending HTTProm implementations, which works in much the same
  way as HTTPoison.Base.
  """

  defmacro __using__(_) do
    quote do
      use HTTPoison.Base

      alias HTTProm.Instrumenter

      def request(method, url, body \\ "", headers \\ [], options \\ []) do
        start_time  = :erlang.system_time()
        result      = super(method, url, body, headers, options)
        duration    = :erlang.system_time() - start_time

        Instrumenter.instrument(%{time: duration, result: result})

        result
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end
