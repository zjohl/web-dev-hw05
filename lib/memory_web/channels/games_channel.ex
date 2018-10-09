defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel
  alias Memory.Game
  alias Memory.GameServer

  # From nat's lecture notes

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = BackupAgent.get(name) || Game.new()
      socket = socket
               |> assign(:game, game)
               |> assign(:name, name)
      BackupAgent.put(name, game)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("click", %{"index" => ii}, socket) do
    view = GameServer.click(socket.assigns[:game], socket.assigns[:user], ii)
    {:reply, {:ok, %{ "game" => view}}, socket}
  end

  def handle_in("restart", nil, socket) do
    name = socket.assigns[:name]
    game = Game.restart()
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  defp authorized?(_payload) do
    ## TODO check somethign here?
    true
  end
end
