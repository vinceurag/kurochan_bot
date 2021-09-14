use Mix.Config

config :nostrum,
  token: "test",
  youtubedl: "/usr/local/bin/youtube-dl",
  ffmpeg: "/usr/local/bin/ffmpeg"

import_config "secrets.exs"
