defmodule Sma do
  @moduledoc """
  Documentation for `Sma`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Sma.hello()
      :world

  """
  def hello do
    :world
  end

  @doc """
  Function extracting the body out of a binance public API reply.

  argument:
    - the binance API reply
    A JSON string

  return:
    A elixir built-in type containing the extracted data (usually a map or an array of those)
  """
  def extract_body(%HTTPoison.Response{body: payload}) do
    payload
    |> Jason.decode!()
  end

  @doc """
  Function fetching and displaying data on the binance public API for a defined pair (step 1 of the case study in README)
  The data we are looking for are :
    - Current price
    - 24hr high
    - 24hr low
    - 24hr volume

  argument:
    - pair
    the concerned pair, in a binance compatible format (default value is "BTCUSDT")

  return:
    Nothing
  """
  def fetch_24hr_data(pair \\ "BTCUSDT") do
    "https://api.binance.com/api/v3/ticker/24hr"
    |> HTTPoison.get!([], params: %{symbol: pair}) #empty header
    |> extract_body() # extract the payload from the API response
    |> Map.take(["lastPrice", "highPrice", "lowPrice", "volume"])
    |> IO.inspect()
  end

  @doc """
  Function fetching and displaying data on the binance public API for a defined pair (step 1 of the case study in README)
  The data we are looking for are :
    - Current price
    - 24hr high
    - 24hr low
    - 24hr volume

  argument:
    - pair
    The concerned pair, in a binance compatible format (default value is "BTCUSDT")
    - limit
    The maximum number of trades to consult

  return:
    A list of prices, of size 'limit'
  """
  def fetch_last_prices(pair \\ "BTCUSDT", limit \\ 30) do
    "https://api.binance.com/api/v3/trades"
    |> HTTPoison.get!([], params: %{symbol: pair, limit: limit}) #empty header
    |> IO.inspect()
  end
end

Application.ensure_all_started(:httpoison) # Ensure HTTPoison is running
Sma.fetch_24hr_data()
#Sma.fetch_last_prices()
