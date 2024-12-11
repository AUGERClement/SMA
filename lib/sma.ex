defmodule Sma do
  @moduledoc """
  Documentation for `Sma`.
  """

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

  argument :
    - pair
    the concerned pair, in a binance compatible format (default value is "BTCUSDT")

  return :
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
  Function fetching the last prices of a pair.

  arguments :
    - pair
    The concerned pair, in a binance compatible format (default value is "BTCUSDT")
    - limit
    The maximum number of trades to consult

  return :
    A list of prices, of size 'limit'
  """
  def fetch_last_prices(pair \\ "BTCUSDT", limit \\ 30) do
    "https://api.binance.com/api/v3/trades"
    |> HTTPoison.get!([], params: %{symbol: pair, limit: limit}) #empty header
    |> extract_body()
    #|> IO.inspect(label: "The content of the reply is ")
    |> Enum.map(fn x -> x["price"] end) # Extract price data from each trade
    |> Enum.map(fn x -> String.to_float(x) end) # Convert to number
  end

  @doc """
  Function computing the Simple Moving Average of a asset.
  More infos can be found on https://www.investopedia.com/terms/s/sma.asp

  argument :
    - prices
    An array of numbers (prices)

  return :
    The computed SMA
  """
  def computeSMA(prices) do
    Enum.sum(prices) / Enum.count(prices)
  end

  @doc """
  Function wrapping the Step 1 and 2 of the case study (See README for more accurante description)

  arguments :
    - pair
    The concerned pair, in a binance compatible format (default value is "BTCUSDT")
    - limit
    The maximum number of trades to consult
  """
  def fetch_and_process(pair \\ "BTCUSDT", limit \\ 30) do
    fetch_24hr_data(pair) #Step 1

    # Step 2
    Sma.fetch_last_prices(pair, limit)
    |> Sma.computeSMA()
    |> IO.inspect(label: "The SMA based on the last #{limit} trades is ")
  end
end

Application.ensure_all_started(:httpoison) # Ensure HTTPoison is running

# Step 1
Sma.fetch_24hr_data()

# Step 2
Sma.fetch_last_prices()
|> Sma.computeSMA()
|> IO.inspect(label: "The SMA based on the last 30 trades is ")

# Step 3 (Repeating 4 times the previous steps, while waiting a minutes between each)
Enum.each(1..4, fn  _ ->
  Process.sleep(60000) # Sleep for 60 seconds
  Sma.fetch_and_process()
end)
