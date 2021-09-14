defmodule Kurochan do
  use Alchemy.Cogs
  alias Alchemy.Embed

  import Embed

  @green 0x00FF00
  @red 0xFF0000

  Cogs.def ping do
    %Embed{}
    |> color(@green)
    |> description("🏓 Pong!")
    |> Embed.send()
  end

  Cogs.def play("") do
    %Embed{}
    |> color(@red)
    |> description("🤦‍♂️ Tukmol ka, lagay ka title or URL.")
    |> Embed.send()
  end

  Cogs.set_parser(:play, &List.wrap/1)

  Cogs.def play(search_term) do
    {:ok, guild} = Cogs.guild()
    {:ok, member} = Cogs.member()

    search =
      case search_term do
        "https://" <> _ = url -> url
        title -> "ytsearch:#{URI.encode(title)}"
      end

    voice_channel_id =
      guild
      |> Map.get(:voice_states)
      |> Enum.find(%{}, fn voice_state ->
        voice_state.user_id == member.user.id
      end)
      |> Map.get(:channel_id)

    Alchemy.Voice.join(guild.id, voice_channel_id)
    Alchemy.Voice.play_url(guild.id, search)

    %Embed{}
    |> title("✅ Now Playing...")
    |> color(@green)
    |> description(search_term)
    |> author(name: member.user.username, icon_url: Alchemy.User.avatar_url(member.user))
    |> Embed.send()
  end

  Cogs.def stop do
    {:ok, guild} = Cogs.guild()

    Alchemy.Voice.stop_audio(guild.id)

    %Embed{}
    |> color(@red)
    |> title("❌ Music stopped, tukmol!")
    |> Embed.send()
  end

  Cogs.def dc do
    {:ok, guild} = Cogs.guild()

    Alchemy.Voice.leave(guild.id)

    %Embed{}
    |> color(@red)
    |> title("👋 Paalam, kaibigan.")
    |> Embed.send()
  end
end
