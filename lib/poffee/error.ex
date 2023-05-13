defmodule Poffee.Error do
  @moduledoc """
    see https://leandrocp.com.br/2020/08/leveraging-exceptions-to-handle-errors-in-elixir/
  """

  @type t() :: %__MODULE__{
          module: module(),
          reason: atom(),
          changeset: Ecto.Changeset.t() | nil
        }
  defexception [:module, :reason, :changeset]

  @spec wrap(module(), atom()) :: t()
  def wrap(module, reason), do: %__MODULE__{module: module, reason: reason}

  @spec wrap(module(), atom(), Ecto.Changeset.t()) :: t()
  def wrap(module, reason, changeset) do
    %__MODULE__{module: module, reason: reason, changeset: changeset}
  end

  @doc """
  Return the message for the given error.

  ### Examples

       iex> {:error, %MyApp.Error{} = error} = do_something()
       iex> Exception.message(error)
       "Unable to perform this action."

  """
  @spec message(t()) :: String.t()
  def message(%__MODULE__{reason: reason, module: module}) do
    module.format_error(reason)
  end
end
