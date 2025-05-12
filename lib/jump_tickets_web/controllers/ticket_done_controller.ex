defmodule JumpTicketsWeb.TicketDoneController do
  use JumpTicketsWeb, :controller

  alias JumpTickets.Ticket
  alias JumpTickets.External.Notion
  alias JumpTickets.External.Notion.Parser
  alias JumpTickets.Ticket.DoneNotifier
  alias Logger

  @doc """
  Handles a Notion webhook for when a ticket is marked as Done.

  Expects a JSON payload with the `entity.id` key.
  """
  def notion_webhook(conn, %{"entity" => %{"id" => page_id}}) do
    conn = json(conn, %{status: "ok", message: "Webhook received"})

    Task.start(fn ->
      with %Ticket{} = ticket <- Notion.get_ticket_by_page_id(page_id),
           :ok <- DoneNotifier.notify_ticket_done(ticket) do
        :ok
      else
        error ->
          Logger.error("Failed to process ticket done notification: #{inspect(error)}")
      end
    end)

    conn
  end
end
