defmodule ConfigHelper do
  def get_env!(name) do
    System.get_env(name) ||
      raise "environment variable #{name} is missing."
  end

  def get_list_env!(name) do
    case get_env!(name) do
      str when is_binary(str) -> String.split(str, [" ", ","], trim: true)
      _ -> raise "environment variable #{name} is not a list of strings."
    end
  end

  def get_boolean_env(name, default \\ false) do
    case String.downcase(System.get_env(name) || "") do
      "true" -> true
      "false" -> false
      _ -> default
    end
  end
end
