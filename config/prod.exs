use Mix.Config

config :goth,
  json: "./config/gdrive_client_secret.json" |> File.read!()
