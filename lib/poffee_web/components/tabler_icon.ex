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
  Renders a button with an icon and optional text.

  ## Examples

      <.tabler_icon_button icon="tabler-x" label="Remove" color={:alert} />
      <.tabler_icon_button icon="tabler-add" label="Add" phx-click="add" />

      # with text slot
      <.tabler_icon_button icon="tabler-add" label="Add" phx-click="add">Add</.tabler_icon_button>
  """
  attr :icon, :string, required: true, doc: "name of the icon to add to the button"
  attr :label, :string, required: true, doc: "the button's label for screen readers"
  attr :rest, :global, include: ~w(disabled form name type value)

  attr :textcolor, :atom,
    default: :black,
    values: [:black, :white, :inherit],
    doc: "text color"

  attr :iconcolor, :atom,
    default: :black,
    values: [:black, :white, :inherit],
    doc: "the icon color"

  attr :bgcolor, :atom,
    default: :primary,
    values: [:black, :white, :blue, :alert, :info, :success, :warning, :primary, :secondary],
    doc: "the background color"

  attr :size, :atom, default: :lg, values: [:md, :lg, :auto], doc: "the button size"

  attr :class, :string,
    default: nil,
    doc: "the optional additional classes to add to the icon element"

  slot :inner_block, required: false

  def tabler_icon_button(assigns) do
    ~H"""
    <button
      class={[
        "flex items-center justify-center",
        "phx-submit-loading:opacity-75 rounded py-2 px-2 focus:outline-offset-2",
        "text-sm font-semibold leading-6",
        "disabled:bg-gray-light2x disabled:cursor-not-allowed disabled:text-gray-light",
        @bgcolor == :black && "bg-gray-dark hover:bg-gray-dark2x focus:outline-gray-dark",
        @bgcolor == :white && "bg-white hover:bg-white-dark focus:outline-white-dark",
        @bgcolor == :alert && "bg-alert hover:bg-alert-dark focus:outline-alert",
        @bgcolor == :success && "bg-success hover:bg-success-dark focus:outline-success",
        @bgcolor == :info && "bg-info hover:bg-info-dark focus:outline-info",
        @bgcolor == :warning && "bg-warning hover:bg-warning-dark focus:outline-warning",
        @bgcolor == :primary && "bg-primary hover:bg-primary-dark focus:outline-primary",
        @bgcolor == :secondary &&
          "bg-secondary-400 hover:bg-secondary-500 focus:outline-secondary-400",
        @bgcolor == :blue &&
          "bg-blue-100 hover:bg-blue-500 text-blue-500 hover:text-white focus:outline-blue-100",
        @size == :auto && "h-8",
        @size == :md && "h-8 w-8",
        @size == :lg && "h-10 w-10"
      ]}
      {@rest}
    >
      <span class="sr-only"><%= @label %></span>
      <span class={[
        "flex items-center justify-center",
        @iconcolor == :black && "text-black active:text-black/80",
        @iconcolor == :white && "text-white active:text-white/80"
      ]}>
        <.tabler_icon name={@icon} class={@class} />
      </span>

      <span
        :if={@inner_block != []}
        class={[
          "whitespace-nowrap ml-2 mr-1",
          @textcolor == :black && "text-black active:text-black/80",
          @textcolor == :white && "text-white active:text-white/80"
        ]}
      >
        <%= render_slot(@inner_block) %>
      </span>
    </button>
    """
  end
end
