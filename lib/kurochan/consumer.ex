defmodule Kurochan.Consumer do
  use Nostrum.Consumer

  require Logger

  alias Nostrum.Api
  alias Nostrum.Voice

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!ping" ->
        Api.create_message(msg.channel_id, "pong!")

      "!summon" ->
        case Kurochan.get_voice_channel_from_msg(msg) do
          nil ->
            Api.create_message(msg.channel_id, "Sali ka muna sa voice channel, tukmol.")

          voice_channel_id ->
            Voice.join_channel(msg.guild_id, voice_channel_id)
        end

      "!play" ->
        if Voice.ready?(msg.guild_id) do
          Voice.play(msg.guild_id, "https://www.youtube.com/watch?v=dQw4w9WgXcQ", :ytdl)
        else
          Api.create_message(msg.channel_id, "Sali ka muna sa voice channel, tukmol.")
        end

      "!play https://" <> url ->
        url = "https://" <> url

        if Voice.ready?(msg.guild_id) do
          Voice.play(msg.guild_id, url, :ytdl)
        else
          Api.create_message(msg.channel_id, "Sali ka muna sa voice channel, tukmol.")
        end

      "!play " <> title ->
        if Voice.ready?(msg.guild_id) do
          Voice.play(
            msg.guild_id,
            "ytsearch:#{URI.encode(title)}",
            :ytdl
          )
        else
          Api.create_message(msg.channel_id, "Sali ka muna sa voice channel, tukmol.")
        end

      "!stop" ->
        Voice.stop(msg.guild_id)

      _ ->
        :ignore
    end
  end

  def handle_event({:VOICE_SPEAKING_UPDATE, payload, _ws_state}) do
    Logger.debug("VOICE SPEAKING UPDATE #{inspect(payload)}")
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end
