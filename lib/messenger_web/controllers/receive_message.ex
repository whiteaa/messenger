defmodule MessengerWeb.ReceiveMessageController do
  use MessengerWeb, :controller

  def receive(conn, %{"queue" => queue, "message" => message}) do
    # Add message to QueuePool and immediately return 200
    Messenger.QueuePool.queue_message(queue, message)
    conn
      |> Plug.Conn.send_resp(200, [])
      |> Plug.Conn.halt()
  end

end
