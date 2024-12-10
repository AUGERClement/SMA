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
  Function extracting data from binance public API reply.
  The data we are looking for are :
    - Current price
    - 24hr high
    - 24hr low
    - 24hr volume

  argument:
    - the binance API reply
    The payload must include at least one concerned field. Else, the return will be %{}

  return:
    A map containing the extracted key data
  """
  def extract_data(%HTTPoison.Response{body: payload}) do
    payload
    |> Jason.decode!()
    |> Map.take(["lastPrice", "highPrice", "lowPrice", "volume"])
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
    |> extract_data() # gutting the API reply, keeping only the key data
    |> IO.inspect()
  end
end

Application.ensure_all_started(:httpoison) # Ensure HTTPoison is running
Sma.fetch_24hr_data()
