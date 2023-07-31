defmodule Poffee.Social.CreateFeedbackComponent do
  use PoffeeWeb, :live_component

  alias Poffee.Social
  alias Poffee.Social.Feedback
  alias Poffee.Utils

  require Logger

  @default_assigns %{}

  @impl Phoenix.LiveComponent
  def mount(socket) do
    socket =
      socket
      |> assign(@default_assigns)
      |> assign_form(create_new_feedback_changeset())

    {:ok, socket, temporary_assigns: []}
  end

  @impl Phoenix.LiveComponent
  def handle_event("create_feedback", %{"feedback" => feedback_params}, socket) do
    Logger.debug(
      "[CreateFeedbackComponent.handle_event.create_feedback] params = #{inspect(feedback_params)}"
    )

    case Social.create_feedback(feedback_params) do
      {:ok, _feedback} ->
        changeset = Feedback.changeset(%Feedback{})

        # we are using push_nagivate in parent LV which will hide the modal for us
        # socket = hide_create_feedback_modal(socket) 

        # send message to the parent LV to reload the current page and display successful flash message
        send(self(), {__MODULE__, :new_feedback_created_refresh, %{flash_message: "Feedback saved!"}})

        {:noreply, socket |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        send(
          self(),
          {__MODULE__, :flash, %{level: :error, message: "Error when creating feedback!"}}
        )

        {:noreply, socket |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"feedback" => feedback_params}, socket) do
    Logger.debug(
      "[CreateFeedbackComponent.handle_event.validate] params = #{inspect(feedback_params)}"
    )

    changeset = Feedback.changeset(%Feedback{}, feedback_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  ##########################################
  # Helper functions for data loading
  ##########################################

  defp create_new_feedback_changeset() do
    Feedback.changeset(%Feedback{})
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset)
    assign(socket, form: form)
  end

  ##########################################
  # Helper functions for HEEX rendering
  ##########################################

  # defp hide_create_feedback_modal(socket) do
  #   push_event(socket, "js-exec", %{to: "#live-create-feedback-modal", attr: "phx-remove"})
  # end
end
