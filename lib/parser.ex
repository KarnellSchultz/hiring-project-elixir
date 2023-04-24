defmodule Parser do
  @moduledoc """
   Parser reads raw electricity consumption data and parses it into a
   defined, internal data format.
  """

  @consumption_data_path "data/consumption_data.json"

  @doc """
  This is the entrypoint for the parser application. You can call this
  function during development to test your solution.

  -- You do not need to modify this function --
  """
  def run do
    {:ok, json} = read_consumption_data()

    parse(json)
  end

  @doc """
  Reads and decodes raw consumption data from json file located at the
  path specified in @consumption_data_path.

  -- You do not need to modify this function --
  """
  def read_consumption_data do
    with {:ok, body} <- File.read(@consumption_data_path),
         {:ok, json} <- Poison.decode(body),
         do: {:ok, json}
  end

  #
  # YOUR SOLUTION BELOW THIS POINT
  #

  @doc """
  Parses the consumption data in consumption_data to internal data format
  """

  def getPeriods(timeSeries) do
    get_in(timeSeries, ["Period"])
    |> Enum.map(fn period ->
      %{
        interval_start: get_in(period, ["timeInterval", "start"]),
        interval_end: get_in(period, ["timeInterval", "end"]),
        points: get_in(period, ["Point"])
      }
    end)
  end

  def formatData(pointQuantity, metering_point_id, interval_start, interinterval_end) do
    %{
      metering_point_id: metering_point_id,
      interval_start: interval_start,
      interval_end: interinterval_end,
      quantity: String.to_float(pointQuantity)
    }
  end

  def getTimeIntervals(dateTime, time) do
    hourInSeconds = 3600
    offset = time * hourInSeconds
    {:ok, initDateTime, 0} = DateTime.from_iso8601(dateTime)
    startDateTime = DateTime.add(initDateTime, offset, :second)
    endDateTime = DateTime.add(startDateTime, hourInSeconds, :second)

    %{
      interval_start: DateTime.to_iso8601(startDateTime),
      interval_end: DateTime.to_iso8601(endDateTime)
    }
  end

  def getTimeSeries(consumption_data) do
    List.first(consumption_data["result"])
    |> Map.get("MyEnergyData_MarketDocument")
    |> Map.get("TimeSeries")
    |> List.first()
  end

  def parse(consumption_data) do
    timeSeries = getTimeSeries(consumption_data)
    metering_point_id = get_in(timeSeries, ["MarketEvaluationPoint", "mRID", "name"])
    periods = getPeriods(timeSeries)

    Enum.map(periods, fn period ->
      get_in(period, [:points])
      |> Enum.map(fn point ->
        intervals =
          getTimeIntervals(
            get_in(period, [:interval_start]),
            String.to_integer(get_in(point, ["position"]))
          )

        formatData(
          Map.get(point, "out_Quantity.quantity"),
          metering_point_id,
          intervals[:interval_start],
          intervals[:interval_end]
        )
      end)
    end)
    |> List.flatten()
  end
end
