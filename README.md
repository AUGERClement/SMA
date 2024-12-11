# Sma.exs

## Introduction

This elixir script is filling the requirements of the technical test proposed by the company Constella Capital. Here is the problem statement :

```
Case Study: Data Fetching and Transformation for a Crypto Exchange
Objective

You are tasked with fetching real-time cryptocurrency market data from a public API, performing basic transformations, and outputting the data in a specific format.
Scope

Your task is to:

    Connect to the Binance API (or another public crypto exchange API of your choice).

    Fetch live market data for the BTC/USDT trading pair.

    Transform the data by calculating the moving average of the price and displaying a snapshot.

    Print the transformed data in a clear format.

Requirements

    Data Fetching:

        Fetch and display the following fields from the BTC/USDT ticker:

            Current Price

            24-Hour High

            24-Hour Low

            24-Hour Volume

    Data Transformation:

        Calculate a 5-minute simple moving average (SMA) based on the last 30 prices, using either Rest or Websocket API.

        Save this SMA value to output.*

    Output:

        Print the data in a formatted output that shows:

            Current Price

            24-Hour High, 24-Hour Low, and 24-Hour Volume

            Calculated 5-minute SMA

        Ensure the data refreshes every minute for a total of 5 refreshes (5 minutes of data).

    Bonus (Optional):

        Detect price drops/hikes by comparing the current price to the 5 minutes SMA

Constraints

    You may use Elixir or any language you're comfortable with.

    Make use of any external library.

    Code must be clean and well-documented.

Expected Deliverables

    A file containing the complete code (e.g. Elixir script or livebook file .livemd)

    A brief README explaining:

        The libraries used.

        Instructions for running the script.

        Assumptions you made, if any.
```

## Technical environment

- Erlang OTP 24
- Elixir version 1.13

### Library used

- HTTPoison (HTTP toolkit, version 2.0.0)
- Jason (JSON toolkit, version 1.4.4)

## Usage

```
mix run
```
## Detailed explanations

Due to the wording of the case study, bringing confusion, I asked for more details.
The following were provided (in french) :

```
C'est un peu confus, mais je pense que l'idée était de scanner les prix toutes les 10 secondes (30 points pour 5 minutes).
```

Meaning, the program must refresh the price history every 10 seconds for 5 minutes, and provide the remaining data (price, 24h high, 24h low, 24h volume, and SMA) every minute.