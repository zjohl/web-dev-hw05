defmodule Memory.Game do
  # I used Nat"s lectures notes as a reference for this assignment
#
# Two player game:
# keep track of correct guesses for each person
# determine if someone has won
# switch between playing and observing (observer can see guesses)
# keep track of whose turn it is
#
# per player
# { isTurn, numClicks?, numCorrect }
# maybe user token, maybe just name
#
#
#

  # Things to keep track of:index
  # visibleTiles: {},
  # inactiveTiles: {},
  #
  # array of tiles {index, value}


  def new do
    %{
      tiles: new_game(),
      visibleTiles: [],
      inactiveTiles: [],
      players: %{},
      currentPlayer: 1,
      currentPlayerClicks: 0,
      changed: true,
    }
  end

  def restart do
    %{
      tiles: new_game(),
      visibleTiles: [],
      inactiveTiles: [],
      players: %{},
      currentPlayer: 1,
      currentPlayerClicks: 0,
      changed: true,
    }
  end

  def next_player_num(game) do
    map_size(Map.get(game, :players, %{})) + 1
  end

  def new_player(game) do
    %{
      playerNum: next_player_num(game),
      numClicks: 0,
      numCorrect: 0,
    }
  end

  def client_view(game, user) do
    %{
      visibleTiles: game.visibleTiles,
      inactiveTiles: game.inactiveTiles,
      players: game.players,
      currentPlayer: game.currentPlayer,
      changed: game.changed,
    }
  end

  def get_tile(game, index) do
    Enum.find(game.tiles, fn tile ->
      index == tile.index
    end)
  end

  def can_click(game, pinfo) do
    pinfo.playerNum == game.currentPlayer && map_size(Map.get(game, :players)) >= 2
  end

  def num_clicks(game, pinfo) do
    if(can_click(game, pinfo)) do
      pinfo.numClicks + 1
    else
      pinfo.numClicks
    end
  end

  def current_player(game, pinfo) do
    if (can_click(game, pinfo) && game.currentPlayerClicks == 2) do
      if (game.currentPlayer == 1) do
        2
      else
        1
      end
    else
      game.currentPlayer
    end
  end

  def current_player_clicks(game, pinfo) do
    if (can_click(game, pinfo)) do
      if (game.currentPlayerClicks == 2) do
        1
      else
        game.currentPlayerClicks + 1
      end
    else
      game.currentPlayerClicks
    end
  end

  def player_score(game, pinfo, previously_scored) do
    num_previously_scored = length(previously_scored)
    num_scored = length(game.inactiveTiles)

    pinfo.numCorrect + (num_scored - num_previously_scored)
  end

  def visible_tiles(game, pinfo, index) do
    clicked_tile = get_tile(game, index)
    cond do
      (!can_click(game, pinfo)) ->
        game.visibleTiles
      (length(game.visibleTiles) == 2) ->
        [clicked_tile]
      (length(game.visibleTiles) == 1 && Enum.at(game.visibleTiles, 0).index != clicked_tile.index) ->
        Enum.concat(game.visibleTiles, [clicked_tile])
      true ->
        [clicked_tile]
    end
  end

  def inactive_tiles(game, pinfo, index) do
    if (can_click(game, pinfo) && length(game.visibleTiles) == 2) do
      visible_tile1 = Enum.at(game.visibleTiles, 0)
      visible_tile2 = Enum.at(game.visibleTiles, 1)

      if (visible_tile1.value == visible_tile2.value) do
        Enum.concat(game.inactiveTiles, [visible_tile1, visible_tile2])
      else
        game.inactiveTiles
      end
    else
      game.inactiveTiles
    end
  end

  def add_player(game, user) do
    players = Map.get(game, :players)
    pinfo = Map.get(players, user, new_player(game))
    game = Map.update(game, :players, %{}, &(Map.put(&1, user, pinfo)))
  end

  def click(game, user, index) do
    if index >= 16 || index < 0 do
      raise "That's not a real tile"
    end

    players = Map.get(game, :players)
    pinfo = Map.get(players, user, new_player(game))

    previously_scored = game.inactiveTiles

    pinfo = Map.put(pinfo, :numClicks, num_clicks(game, pinfo))

    game = Map.update(game, :players, %{}, &(Map.put(&1, user, pinfo)))
    game = Map.put(game, :visibleTiles, visible_tiles(game, pinfo, index))
    game = Map.put(game, :inactiveTiles, inactive_tiles(game, pinfo, index))

    pinfo = Map.put(pinfo, :numCorrect, player_score(game, pinfo, previously_scored))

    game = Map.put(game, :changed, can_click(game, pinfo))
    game = Map.put(game, :currentPlayerClicks, current_player_clicks(game, pinfo))
    game = Map.put(game, :currentPlayer, current_player(game, pinfo))
    game = Map.update(game, :players, %{}, &(Map.put(&1, user, pinfo)))

    IO.puts inspect game, pretty: true
    game
  end

  def new_game do
    pos_vals = ["A", "B", "C", "D", "E", "F", "G", "H", "A", "B", "C", "D", "E", "F", "G", "H"]

    vals = Enum.shuffle(pos_vals)
    vals_index = Enum.with_index(vals)

    Enum.map vals_index, fn {val, i} ->
      %{
        index: i,
        value: val,
      }
    end
  end

end