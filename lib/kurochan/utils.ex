defmodule Kurochan.Utils do
  alias Nostrum.Voice
  alias Nostrum.Voice.Audio
  alias Nostrum.Struct.VoiceState

  def play_search_result(guild_id, title) do
    voice = Voice.get_voice(guild_id)

    cond do
      not VoiceState.ready_for_rtp?(voice) ->
        {:error, "Must be connected to voice channel to play audio."}

      VoiceState.playing?(voice) ->
        {:error, "Audio already playing in voice channel."}

      true ->
        unless is_nil(voice.ffmpeg_proc), do: Porcelain.Process.stop(voice.ffmpeg_proc)
        Voice.set_speaking(voice, true)

        ffmpeg_proc = spawn_ffmpeg(title)

        voice =
          Voice.update_voice(guild_id,
            ffmpeg_proc: ffmpeg_proc
          )

        {:ok, pid} = Task.start(fn -> Audio.init_player(voice) end)
        Voice.update_voice(guild_id, player_pid: pid)
        :ok
    end
  end

  def spawn_ffmpeg(title) do
    %Porcelain.Process{out: outstream} = search_with_youtubedl(title)

    res =
      Porcelain.spawn(
        Application.get_env(:nostrum, :ffmpeg, "ffmpeg"),
        [
          ["-re"],
          ["-i", "pipe:0"],
          ["-ac", "2"],
          ["-ar", "48000"],
          ["-f", "s16le"],
          ["-acodec", "libopus"],
          ["-loglevel", "quiet"],
          ["pipe:1"]
        ]
        |> List.flatten(),
        in: outstream,
        out: :stream
      )

    case res do
      {:error, reason} ->
        raise(Nostrum.Error.VoiceError, reason: reason, executable: "ffmpeg")

      proc ->
        proc
    end
  end

  def search_with_youtubedl(title) do
    res =
      Porcelain.spawn(
        Application.get_env(:nostrum, :youtubedl, "youtube-dl"),
        [
          ["-f", "bestaudio"],
          ["-o", "-"],
          ["-q"],
          ["ytsearch:zedd%clarity"]
        ]
        |> List.flatten(),
        out: :stream
      )

    case res do
      {:error, reason} ->
        raise(Nostrum.Error.VoiceError, reason: reason, executable: "youtube-dl")

      proc ->
        proc
    end
  end
end
