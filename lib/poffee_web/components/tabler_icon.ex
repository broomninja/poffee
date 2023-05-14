# credo:disable-for-this-file Credo.Check.Readability.Specs

defmodule PoffeeWeb.Components.TablerIcon do
  @moduledoc """
  Icon components.
  """
  use Phoenix.Component

  @doc """
  Renders a [Tabler Icon](https://tabler-icons.io/).

  Icons are extracted from our `assets/vendor/tabler` directory and bundled
  within our compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.tabler_icon name="tabler-x" />
      <.tabler_icon name="tabler-refresh" class="ml-1 w-3 h-3 animate-spin" />
  """
  attr :name, :string, required: true, doc: "the name of the icon from the tabler library"

  attr :class, :string,
    default: nil,
    doc: "the optional additional classes to add to the icon element"

  attr :gradient, :boolean, default: false, doc: "whether to add a gradient color to the icon"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the icon element"

  def tabler_icon(%{name: "tabler-" <> _} = assigns) do
    ~H"""
    <span
      {@rest}
      class={[
        "shrink-0",
        @name,
        @gradient and
          "relative before:content-['*'] before:absolute before:top-0 before:left-0 before:w-full before:h-full before:bg-gradient-to-br before:from-info before:via-primary before:to-alert",
        @class
      ]}
    />
    """
  end

  @doc """
  Renders a button with an icon only.

  ## Examples

      <.tabler_icon_button icon="tabler-x" label="Remove" color={:alert} />
      <.tabler_icon_button icon="tabler-add" label="Add" phx-click="add" />
  """
  attr :icon, :string, required: true, doc: "name of the icon to add to the button"
  attr :label, :string, required: true, doc: "the button's label for screen readers"
  attr :rest, :global, include: ~w(disabled form name type value)

  attr :color, :atom,
    default: :black,
    values: [:black, :alert, :info, :success, :warning],
    doc: "the background color"

  attr :size, :atom, default: :lg, values: [:md, :lg], doc: "the button size"

  def tabler_icon_button(assigns) do
    ~H"""
    <button
      class={[
        "flex items-center justify-center",
        "phx-submit-loading:opacity-75 rounded-lg py-2 px-3 focus:outline-offset-2",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        "disabled:bg-gray-light2x disabled:cursor-not-allowed disabled:text-gray-light",
        @color == :black && "bg-gray-dark hover:bg-gray-dark2x focus:outline-gray-dark",
        @color == :alert && "bg-alert hover:bg-alert-dark focus:outline-alert",
        @color == :success && "bg-success hover:bg-success-dark focus:outline-success",
        @color == :info && "bg-info hover:bg-info-dark focus:outline-info",
        @color == :warning && "bg-warning hover:bg-warning-dark focus:outline-warning",
        @size == :md && "h-8 w-8",
        @size == :lg && "h-10 w-10"
      ]}
      {@rest}
    >
      <span class="sr-only"><%= @label %></span> <.tabler_icon name={@icon} />
    </button>
    """
  end
end
