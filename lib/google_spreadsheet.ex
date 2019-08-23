defmodule GoogleSpreadsheet do
  @moduledoc """
  Elixir package to work with Google (Drive) Sheets
  """

  alias Goth.Token

  @auth_scope "https://www.googleapis.com/auth/spreadsheets"
  @api_url_spreadsheet "https://sheets.googleapis.com/v4/spreadsheets"
  @json_accept {"Accept", "application/json"}
  @json_content_type {"Accept", "application/json"}
  @user_agent {"User-Agent",
               "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:61.0) Gecko/20100101 Firefox/61.0"}

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
      {:ok, %HTTPoison.Response{status_code: 200, body: _body}} ->
        {:error, "Invalid title"}

      _ ->
        {:error, "Unauthenticated / Unauthorized"}
    end
  end

  # get google auth token
  defp get_token() do
    with {:ok, %Token{type: type, token: token, expires: _expires}} <-
           Token.for_scope(@auth_scope) do
      {:ok, {"authorization", "#{type} #{token}"}}
    else
      _ ->
        {:error, "Unauthenticated / Unauthorized"}
    end
  end
end
