defmodule GoogleSpreadsheetTest do
  use ExUnit.Case
  doctest GoogleSpreadsheet

  @tag :normal
  test "send_new_message are pushed to the client" do
    # spreadsheet_id = "1alLUQ6t0-FPV9NRnSQzxQoA01C3jo0Qtmf2iAWlaVD0"
    # IO.inspect(spreadsheet_id, label: "spreadsheet_id")

    # %{"sheetId" => worksheet_id, "title" => worksheet_title} =
    #   GoogleSpreadsheet.get_last_worksheet(spreadsheet_id)

    # IO.inspect(worksheet_id, label: "worksheet_id")
    # IO.inspect(worksheet_title, label: "worksheet_title")

    # GoogleSpreadsheet.get_rows(spreadsheet_id, worksheet_title, 2, 1000, "A", "E")
    # |> Enum.filter(fn %{"row" => _row, "values" => values} -> length(values) == 5 end)
    # |> IO.inspect(
    #   label: "get_rows",
    #   limit: :infinity
    # )
  end
end
