defmodule HTTProm.Counter do
  @moduledoc false

  @callback new(Keyword.t()) :: any()
  @callback inc(Keyword.t()) :: any()
end
