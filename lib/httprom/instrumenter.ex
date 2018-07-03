defmodule HTTProm.Instrumenter do
  @moduledoc false

  use Prometheus.Metric

  def setup do
    Enum.each(metrics(), fn opts ->
      type    = Keyword.fetch!(opts, :type)
      module  = get_module(type, opts)

      config =
        opts
        |> Keyword.fetch!(:config)
        |> Keyword.update(:labels, [:source], fn labels ->
          [:source | labels]
        end)

      module.new config
    end)
  end

  def instrument(%{result: {:ok, %HTTPoison.Response{} = result}, time: time, label: label}) do
    Enum.each(metrics(), fn opts ->
      type   = Keyword.fetch!(opts, :type)
      config = Keyword.fetch!(opts, :config)
      module = get_module(type, opts)

      name = Keyword.fetch!(config, :name)

      case type do
        :histogram ->
          module.observe [name: name, labels: [label, result.request_url, result.status_code]], time
        :counter ->
          module.inc [name: name, labels: [label]]
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
