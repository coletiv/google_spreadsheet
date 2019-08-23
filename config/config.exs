use Mix.Config

config :goth,
  json: "./config/gdrive_client_secret.json" |> File.read!()

import_config "#{Mix.env()}.exs"
