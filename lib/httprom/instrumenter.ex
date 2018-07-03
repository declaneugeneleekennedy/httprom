defmodule HTTProm.Instrumenter do
  @moduledoc false

  use Prometheus.Metric

  def setup do
    Enum.each(metrics(), fn opts ->
      type    = Keyword.fetch!(opts, :type)
      config  = Keyword.fetch!(opts, :config)
      module  = get_module(type, opts)

      module.new config
    end)
  end

  def instrument(%{result: {:ok, %HTTPoison.Response{} = result}, time: time}) do
    Enum.each(metrics(), fn opts ->
      type   = Keyword.fetch!(opts, :type)
      config = Keyword.fetch!(opts, :config)
      module = get_module(type, opts)

      name = Keyword.fetch!(config, :name)

      case type do
        :histogram ->
          apply(module, :observe, [
            [name: name, labels: [result.request_url, result.status_code]],
            time
          ])
        :counter ->
          apply(module, :inc, [[name: name]])
      end
    end)
  end

  defp get_module(type, config) do
    default = case type do
      :histogram -> Histogram
      :counter -> Counter
      _ -> raise ArgumentError, "Unknown metric: #{inspect(type)}"
    end

    Keyword.get(config, :module, default)
  end

  defp metrics, do: Application.fetch_env!(:httprom, :metrics)
end
