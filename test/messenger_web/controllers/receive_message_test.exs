defmodule MessengerWeb.ReceiveMessageTest do
  use MessengerWeb.ConnCase

  test "GET /receive-message", %{conn: conn} do

    # Create text file to save output from /receive-message
    filename = "./test/message_output.txt"
    File.touch!(filename)
    File.write(filename, "")

    # Send series of messages to /receive-message
    queue1 = "a"
    queue2 = "b"
    queue3 = "c"
    assert response(get(conn, "/receive-message?queue=#{queue1}&message=1"), 200) =~ ""
    assert response(get(conn, "/receive-message?queue=#{queue2}&message=1"), 200) =~ ""
    assert response(get(conn, "/receive-message?queue=#{queue3}&message=1"), 200) =~ ""
    assert response(get(conn, "/receive-message?queue=#{queue1}&message=2"), 200) =~ ""
    assert response(get(conn, "/receive-message?queue=#{queue2}&message=2"), 200) =~ ""
    assert response(get(conn, "/receive-message?queue=#{queue3}&message=2"), 200) =~ ""
    assert response(get(conn, "/receive-message?queue=#{queue3}&message=3"), 200) =~ ""
    assert response(get(conn, "/receive-message?queue=#{queue3}&message=4"), 200) =~ ""
    assert response(get(conn, "/receive-message?queue=#{queue1}&message=3"), 200) =~ ""
    # Wait for messages to finish being processed
    :timer.sleep(5000)

    # Uncomment to test timeout functionality
    #:timer.sleep(60000)
    #assert response(get(conn, "/receive-message?queue=#{queue1}&message=4"), 200) =~ ""
    #assert response(get(conn, "/receive-message?queue=#{queue2}&message=3"), 200) =~ ""

    # Read results from text file
    results = File.read!(filename)
    lines = String.split(results, ["\n", "\r", "\r\n"])
      |> Enum.filter(fn x -> x != "" end)

    # Loop through and validate results
    Enum.reduce(lines, %{}, fn line, data ->
      [queue_name | [message | [timestamp]]] = String.split(line, ",")
      {message, _} = Integer.parse(message)
      {timestamp, _} = Integer.parse(timestamp)
      if Map.has_key?(data, queue_name) do
        {old_message, old_timestamp} = Map.get(data, queue_name)
        # Assert this message was sent at least one second later than previous
        # message for this queue
        assert old_timestamp < timestamp
        # Assert messages were output in correct order
        assert old_message + 1 == message
        Map.put(data, queue_name, {message, timestamp})
      else
        # Assert first message for each queue == 1
        assert message == 1
        Map.put(data, queue_name, {message, timestamp})
      end
    end)

    # Close and remove text file
    File.close(filename)
    File.rm(filename)
  end
end
