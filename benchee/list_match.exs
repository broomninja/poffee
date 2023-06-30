defmodule Benchmark do

  def use_head_tail(list) do
    case list do
      [] -> true
      [_head|_tail] -> true
      _ -> false
    end 
  end

  def use_list_concat(list) do
    case list do
      [] -> true
      [_] ++ _ -> true
      _ -> false
    end 
  end

  def erlang_is_list(list) do
    is_list(list)
  end
end

inputs = %{
  "small list" => Enum.to_list(1..100),
  "medium list" => Enum.to_list(1..10_000),
  "large list" => Enum.to_list(1..1_000_000)
}

Benchee.run(
  %{
    "erlang is_list" => 
      fn list -> Benchmark.erlang_is_list(list) end,
    "Head tail match" => 
      fn list -> Benchmark.use_head_tail(list) end,
    "List concat match" => 
      fn list -> Benchmark.use_list_concat(list) end
  },
  inputs: inputs,
  time: 0.8,
  memory_time: 1,
  warmup: 1
)
