defmodule Runner.Client do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_args) do
    say("starting")

    with {:ok, socket} <- :gen_tcp.connect('localhost', 4040, [:binary, active: true]),
         :ok <- :gen_tcp.send(socket, "SUBSCRIBE blah\n") do
      {:ok, %{socket: socket}}
    else
      {:error, reason} -> {:stop, reason}
    end
  end

  def create_remote_repo do
  end

  def handle_info({:tcp, _socket, data}, state) do
    say("Received: #{data}")
    state = data |> String.trim() |> String.split(" ") |> handle_message(state)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    say("Socket was closed")
    {:stop, state}
  end

  def handle_info({:tcp_error, _socket, reason}, state) do
    say("received error: #{reason}")
    {:noreply, state}
  end

  defp handle_message(["push", _repo, branch, _hash], state) do
    say("I should pull #{branch}")
    state
  end

  defp handle_message(["OK"], state) do
    say("OK is ok")
    state
  end

  defp say(str) do
    IO.puts("client: #{str}")
  end
end
