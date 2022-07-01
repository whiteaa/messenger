defmodule Messenger.QueuePool do
  use Agent
  @moduledoc """
  QueuePool module is an Agent that holds a Map of MessageQueues where the
  {key, value} = {queue_name, MessageQueue}
  """

  @spec start_link(%{}) :: {:ok, pid()}
  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  @spec queue_message(String.t, String.t) :: :ok
  def queue_message(queue_name, message) do
    case Agent.get(__MODULE__, & &1) |> Map.fetch(queue_name) do
      :error     -> new_message_queue(queue_name, message)
      {:ok, pid} ->
        if Process.alive?(pid) do
          GenServer.cast(pid, message)
        else
          new_message_queue(queue_name, message)
        end
    end
    :ok
  end

  def new_message_queue(queue_name, message) do
    {:ok, pid} = GenServer.start_link(MessageQueue, queue_name)
    Agent.update(__MODULE__, fn state -> Map.put(state, queue_name, pid) end)
    GenServer.cast(pid, message)
  end
end


defmodule MessageQueue do
  use GenServer
  @moduledoc """
  MessageQueue module is a GenServer that handles message queueing by
  outputing at most one message per second. Timeouts after 60 seconds.
  """

  @spec init(String.t) :: {:ok, String.t}
  @impl true
  def init(state) do
    {:ok, state, 60000}
  end

  @spec handle_cast(String.t, String.t) :: {:noreply, String.t}
  @impl true
  def handle_cast(message, state) do
    if Mix.env() == :test do
      # If in the testing environment, save messages to a text file for validation
      {:ok, file} = File.open("./test/message_output.txt", [:append])
      IO.write(file, "#{state},#{message},#{System.os_time(:second)}\n")
      File.close(file)
      :timer.sleep(1000)
      {:noreply, state, 60000}
    else
      IO.puts(message)
      :timer.sleep(1000)
      {:noreply, state, 60000}
    end
  end

  def handle_info(:timeout, _) do
    {:stop, :normal, ""}
  end

end
