use Mix.Config

config :alchemy,
  token: "test",
  youtube_dl_path: "/usr/local/bin/youtube-dl",
  ffmpeg_path: "/usr/local/bin/ffmpeg"

import_config "secrets.exs"
