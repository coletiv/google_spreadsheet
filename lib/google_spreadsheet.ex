defmodule GoogleSpreadsheet do
  @moduledoc """
  Elixir package to work with Google (Drive) Sheets
  """

  alias Goth.Token

  @auth_drive_scope "https://www.googleapis.com/auth/drive"
  @auth_spreadsheets_scope "https://www.googleapis.com/auth/spreadsheets"
  @api_url_file_permissions "https://www.googleapis.com/drive/v3/files"
  @api_url_spreadsheet "https://sheets.googleapis.com/v4/spreadsheets"
  @json_accept {"Accept", "application/json"}
  @json_content_type {"Content-Type", "application/json"}
  @user_agent {"User-Agent",
               "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:61.0) Gecko/20100101 Firefox/61.0"}

  @doc """
  Add email to file (spreadsheet_id) as a writer
  """
  def add_writer_permissions_to_spreadsheet(spreadsheet_id, email) do
    body =
      Poison.encode!(%{
        "role" => "writer",
        "type" => "user",
        "emailAddress" => email
      })

    with {:ok, authorization_token} <- get_token(@auth_drive_scope),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.post(
             "#{@api_url_file_permissions}/#{spreadsheet_id}/permissions",
             body,
             [@json_content_type, @json_accept, @user_agent, authorization_token],
             recv_timeout: 10_000
           ),
         {:ok, decoded_body} <- Poison.decode(body) do
      decoded_body
    else
      {:ok, %HTTPoison.Response{}} ->
        {:error, "Invalid request"}

      _ ->
        {:error, "Unauthenticated / Unauthorized"}
    end
  end

  @doc """
  Get last worksheet from spreadsheet (use spreadsheet_id)
  """
  def get_last_worksheet(spreadsheet_id) when is_bitstring(spreadsheet_id) do
    with {:ok, authorization_token} <- get_token(),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(
             "#{@api_url_spreadsheet}/#{spreadsheet_id}/",
             [@json_content_type, @json_accept, @user_agent, authorization_token],
             recv_timeout: 10_000
           ),
         {:ok, decoded_body} <- Poison.decode(body) do
      case Blankable.blank?(decoded_body["sheets"]) do
        true ->
          nil

        false ->
          decoded_body["sheets"]
          |> Enum.map(fn item -> item["properties"] end)
          |> Enum.sort(&(&1["index"] >= &2["index"]))
          |> List.first()
      end
    else
      {:ok, %HTTPoison.Response{}} ->
        {:error, "Invalid request"}

      _ ->
        {:error, "Unauthenticated / Unauthorized"}
    end
  end

  @doc """
  Duplicate worksheet in spreadsheet (use spreadsheet_id and worksheet_id)
  """
  def duplicate_worksheet(spreadsheet_id, worksheet_id)
      when is_bitstring(spreadsheet_id) and is_number(worksheet_id) do
    body =
      Poison.encode!(%{
        "destinationSpreadsheetId" => spreadsheet_id
      })

    with {:ok, authorization_token} <- get_token(),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.post(
             "#{@api_url_spreadsheet}/#{spreadsheet_id}/sheets/#{worksheet_id}:copyTo",
             body,
             [@json_content_type, @json_accept, @user_agent, authorization_token],
             recv_timeout: 10_000
           ),
         {:ok, decoded_body} <- Poison.decode(body) do
      decoded_body
    else
      {:ok, %HTTPoison.Response{}} ->
        {:error, "Invalid request"}

      _ ->
        {:error, "Unauthenticated / Unauthorized"}
    end
  end

  @doc """
  Update worksheet title in spreadsheet (use spreadsheet_id, worksheet_id and title)
  """
  def update_worksheet_title(spreadsheet_id, worksheet_id, title)
      when is_bitstring(spreadsheet_id) and is_number(worksheet_id) and is_bitstring(title) do
    body =
      Poison.encode!(%{
        "requests" => [
          %{
            "updateSheetProperties" => %{
              "properties" => %{
                "sheetId" => worksheet_id,
                "title" => title
              },
              "fields" => "title"
            }
          }
        ]
      })

    with {:ok, authorization_token} <- get_token(),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.post(
             "#{@api_url_spreadsheet}/#{spreadsheet_id}:batchUpdate",
             body,
             [@json_content_type, @json_accept, @user_agent, authorization_token],
             recv_timeout: 10_000
           ),
         {:ok, decoded_body} <- Poison.decode(body) do
      decoded_body
    else
      {:ok, %HTTPoison.Response{}} ->
        {:error, "Invalid request"}

      _ ->
        {:error, "Unauthenticated / Unauthorized"}
    end
  end

  @doc """
  function for rewrite row between columns
  """
  def rewrite_row(
        spreadsheet_id,
        worksheet_title,
        row \\ 1,
        column_start,
        column_end,
        values
      ) do
    body =
      Poison.encode!(%{
        "data" => [
          %{
            "values" => [values],
            "major_dimension" => "ROWS",
            "range" => "#{worksheet_title}!#{column_start}#{row}:#{column_end}#{row}"
          }
        ],
        "includeValuesInResponse" => false,
        "valueInputOption" => "USER_ENTERED"
      })

    with {:ok, authorization_token} <- get_token(),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.post(
             "#{@api_url_spreadsheet}/#{spreadsheet_id}/values:batchUpdate",
             body,
             [@json_content_type, @json_accept, @user_agent, authorization_token],
             recv_timeout: 10_000
           ),
         {:ok, decoded_body} <- Poison.decode(body) do
      decoded_body
    else
      {:ok, %HTTPoison.Response{}} ->
        {:error, "Invalid request"}

      _ ->
        {:error, "Unauthenticated / Unauthorized"}
    end
  end

  @doc """
    function for append row between columns
  """
  def append_row(
        spreadsheet_id,
        worksheet_title,
        column_start,
        column_end,
        values
      ) do
    body =
      Poison.encode!(%{
        "values" => [values],
        "major_dimension" => "ROWS"
      })

    with {:ok, authorization_token} <- get_token(),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.post(
             "#{@api_url_spreadsheet}/#{spreadsheet_id}/values/#{worksheet_title}!#{column_start}#{
               1
             }:#{column_end}#{1}:append?value_input_option=USER_ENTERED&include_values_in_response=false&insert_data_option=INSERT_ROWS",
             body,
             [@json_content_type, @json_accept, @user_agent, authorization_token],
             recv_timeout: 10_000
           ),
         {:ok, decoded_body} <- Poison.decode(body) do
      decoded_body
    else
      {:ok, %HTTPoison.Response{}} ->
        {:error, "Invalid request"}

      _ ->
        {:error, "Unauthenticated / Unauthorized"}
    end
  end

  @doc """
  Get all rows until find a empty row between columns (start and end)
  """
  def get_rows_until_empty(
        spreadsheet_id,
        worksheet_title,
        row_start \\ 1,
        column_start \\ "A",
        column_end \\ "Z",
        accumulated_rows \\ []
      ) do
    # get next row
    case get_row(spreadsheet_id, worksheet_title, row_start, column_start, column_end) do
      {:error, _reason} ->
        []

      # no more row to fetch
      [] ->
        accumulated_rows

      row_values ->
        row = [%{"row" => row_start, "values" => row_values}]

        get_rows_until_empty(
          spreadsheet_id,
          worksheet_title,
          row_start + 1,
          column_start,
          column_end,
          accumulated_rows ++ row
        )
    end
  end

  @doc """
  Get row between columns (start and end)
  """
  def get_row(spreadsheet_id, worksheet_title, row, column_start, column_end) do
    with {:ok, authorization_token} <- get_token(),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(
             "#{@api_url_spreadsheet}/#{spreadsheet_id}/values/#{worksheet_title}!#{column_start}#{
               row
             }:#{column_end}#{row}",
             [@json_content_type, @json_accept, @user_agent, authorization_token],
             recv_timeout: 10_000
           ),
         {:ok, decoded_body} <- Poison.decode(body) do
      with %{"values" => values} <- decoded_body do
        List.flatten(values)
      else
        _ ->
          []
      end
    else
      {:ok, %HTTPoison.Response{}} ->
        {:error, "Invalid request"}

      _ ->
        {:error, "Unauthenticated / Unauthorized"}
    end
  end

  # get google auth token
  defp get_token(scope \\ @auth_spreadsheets_scope) do
    with {:ok, %Token{type: type, token: token, expires: _expires}} <- Token.for_scope(scope) do
      {:ok, {"authorization", "#{type} #{token}"}}
    else
      _ ->
        {:error, "Unauthenticated / Unauthorized"}
    end
  end
end
