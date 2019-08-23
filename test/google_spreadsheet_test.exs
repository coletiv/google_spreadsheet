defmodule GoogleSpreadsheetTest do
  use ExUnit.Case
  doctest GoogleSpreadsheet

  @tag :normal
  test "send_new_message are pushed to the client" do
    # spreadsheet_id = "11-uGmVZiO8ZZ6MWNAf4pKsgrmuW5cMNxpSMm7VY9-u0"
    # IO.inspect(spreadsheet_id, label: "spreadsheet_id")

    # %{"sheetId" => worksheet_id} = GoogleSpreadsheet.get_last_worksheet(spreadsheet_id)

    # IO.inspect(worksheet_id, label: "worksheet_id")

    # %{"sheetId" => worksheet_id_created} =
    #   GoogleSpreadsheet.duplicate_worksheet(spreadsheet_id, worksheet_id)

    # IO.inspect(worksheet_id_created, label: "worksheet_id_created")

    # IO.inspect(
    #   GoogleSpreadsheet.update_worksheet_title(
    #     spreadsheet_id,
    #     worksheet_id_created,
    #     "Set 02"
    #   )
    # )
  end
end
