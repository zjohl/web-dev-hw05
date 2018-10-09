defmodule MemoryWeb.PageController do
  use MemoryWeb, :controller

  def join(conn, %{"join" => %{"user" => user, "game" => game}}) do
    conn
    |> put_session(:user, user)
    |> redirect(to: "/game/#{game}")
  end

  def game(conn, params) do
    user = get_session(conn, :user)
    if user do
      render conn, "game.html", game: params["game"], user: user
    else
      conn
      |> put_flash(:error, "How did you even get here? You need to log in.")
      |> redirect(to: "/")
    end
end

  def index(conn, _params) do
    render conn, "index.html"
  end
end
