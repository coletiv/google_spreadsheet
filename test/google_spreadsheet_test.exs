defmodule GoogleSpreadsheetTest do
  use ExUnit.Case
  doctest GoogleSpreadsheet

  @tag :normal
  test "send_new_message are pushed to the client" do
    spreadsheet_id = "11-uGmVZiO8ZZ6MWNAf4pKsgrmuW5cMNxpSMm7VY9-u0"
    IO.inspect(spreadsheet_id, label: "spreadsheet_id")

    %{"sheetId" => worksheet_id, "title" => title} =
      GoogleSpreadsheet.get_last_worksheet(spreadsheet_id)

    IO.inspect(worksheet_id, label: "worksheet_id")
    IO.inspect(title, label: "title")

    IO.inspect(GoogleSpreadsheet.get_rows_until_empty(spreadsheet_id, title, 1, "A", "E"),
      label: "get_rows"
    )

    IO.inspect(
      GoogleSpreadsheet.rewrite_row(spreadsheet_id, title, 3, "A", "E", [
        "12",
        "22",
        "32",
        "42",
        "52"
      ]),
      label: "rewrite"
    )

    IO.inspect(
      GoogleSpreadsheet.append_row(spreadsheet_id, title, "A", "E", ["1", "2", "3", "4", "5"]),
      label: "append_row"
    )

    IO.inspect(
      GoogleSpreadsheet.add_writer_permissions_to_spreadsheet(
        spreadsheet_id,
        "marciopinto.net@gmail.com"
      ),
      label: "permissions"
    )

    IO.inspect(GoogleSpreadsheet.get_rows_until_empty(spreadsheet_id, title, 1, "A", "E"),
      label: "get_rows"
    )

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
