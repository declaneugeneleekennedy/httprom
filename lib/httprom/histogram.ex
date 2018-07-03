defmodule HTTProm.Histogram do
  @moduledoc false

  @callback new(Keyword.t()) :: any()
  @callback observe(Keyword.t(), integer()) :: any()
end
