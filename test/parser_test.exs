defmodule ParserTest do
  use ExUnit.Case
  doctest Parser

  #
  # YOUR TEST(S) BELOW THIS POINT
  #

  test "find out if my thing works" do
    assert Parser.getTimeIntervals("2021-12-31T23:00:00Z", 1) == %{
             interval_end: "2022-01-01T01:00:00Z",
             interval_start: "2022-01-01T00:00:00Z"
           }
  end

  test "parser returns the correct range of periods" do
    assert Parser.getPeriods(%{
             "MarketEvaluationPoint" => %{
               "mRID" => %{"codingScheme" => "A10", "name" => "927613927390263674"}
             },
             "Period" => [
               %{
                 "Point" => [
                   %{
                     "out_Quantity.quality" => "A04",
                     "out_Quantity.quantity" => "0.1",
                     "position" => "1"
                   }
                 ],
                 "resolution" => "PT1H",
                 "timeInterval" => %{
                   "end" => "2022-01-01T23:00:00Z",
                   "start" => "2021-12-31T23:00:00Z"
                 }
               }
             ],
             "businessType" => "A04",
             "curveType" => "A01",
             "measurement_Unit.name" => "KWH",
             "metering_point_id" => "927613927390263674"
           }) == [
             %{
               interval_end: "2022-01-01T23:00:00Z",
               interval_start: "2021-12-31T23:00:00Z",
               points: [
                 %{
                   "out_Quantity.quality" => "A04",
                   "out_Quantity.quantity" => "0.1",
                   "position" => "1"
                 }
               ]
             }
           ]
  end

test "make sure the parser returns the correct keys" do
  first = List.first(Parser.run())
  assert Map.has_key?(first, :interval_start) && Map.has_key?(first, :interval_end) &&
    Map.has_key?(first, :metering_point_id) && Map.has_key?(first, :quantity)
end

end
