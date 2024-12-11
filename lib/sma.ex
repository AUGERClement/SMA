defmodule Sma do
  @moduledoc """
  Documentation for `Sma`, the module containing all fuctions bound to the case study.

  This module is filled with functions calling the Binance API or processing the returns of said calls.
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

  # Due to detailed explanations by François Monteleon
  # some shades of the study were grasped.
  # Hence the following functions would meet the newfound requirement
  # See detailed explanation in the Readme

  @doc """
  This function pauses the program for the specified duration.

  argument :
    - seconds
    the amount of time the program must wait (in seconds)

  return :
    Nothing

  """
  def wait(seconds \\ 10) do
    Process.sleep(seconds * 1000)
  end

  @doc """
  Rolls the price history, by poping the last of the list (oldest) and putting the newest one in front

  arguments :
    - prices
    The list of prices so far

    - pair
    The concerned pair, in a binance compatible format (default value is "BTCUSDT")

  return :
    The updated list of prices
  """
  def update_prices(prices, pair \\ "BTCUSDT") do
    newest =
      fetch_last_prices(pair)
      |> List.last()
      #|> IO.inspect(label: "last price is ")

    [newest | Enum.drop(prices, -1)] # Pop the oldest/last price, add the newest/first price
    #|> IO.inspect()
  end

  @doc """
  This function rolls the price history.
  Then, if x is divisible by 6, it fetch and print main data from the 24hr timeframe using `fetch_24hr_data`, and finally offer a prediction about the ticker

  arguments :
    - x
    The current occurence of the treatment

    - prices
    The list of prices so far

    - pair
    The concerned pair, in a binance compatible format (default value is "BTCUSDT")

  return :
    The updated list of prices

  """
  def refresh_data(x, prices, pair \\ "BTCUSDT") do
    prices = Sma.update_prices(prices, pair)
    newest = List.first(prices)

    if rem(x, 6) == 0 do # Every minute
      IO.inspect("Every minute, data will be updated")
      Sma.fetch_24hr_data()
      |> IO.inspect()

      sma =
        Sma.computeSMA(prices)
          |> IO.inspect(label: "Current SMA is ")

      cond do
        sma > newest -> IO.inspect("SMA is above last trading price. Bearish")
        true -> IO.inspect("SMA is below last trading price. Bullish")
      end
    end
    prices
  end
end

Application.ensure_all_started(:httpoison) # Ensure HTTPoison is running

_version1 = """
# Step 1
Sma.fetch_24hr_data()
|> IO.inspect()

# Step 2
Sma.fetch_last_prices()
|> Sma.computeSMA()
|> IO.inspect(label: "The SMA based on the last 30 trades is ")

# Step 3 (Repeating 4 times the previous steps, while waiting a minutes between each)
Enum.each(1..4, fn  _ ->
  Process.sleep(60000) # Sleep for 60 seconds
  Sma.fetch_and_process()
end)
"""

# Version 2, accounting for the detailed explanation
prices =
  Sma.fetch_last_prices() # Get our starting price list (30 most recent ones)
  |> Enum.reverse() #For optimisation, we need to put the newest elems at the begining

#IO.inspect(prices)

0..30 # We are looking for a 5 mins (300 sec) average updating every 10s.
|> Enum.reduce(prices, fn x, acc ->
  tmp = Sma.refresh_data(x, acc)
  Sma.wait()
  tmp
end)
