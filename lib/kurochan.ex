defmodule Kurochan do
  @moduledoc """
  Documentation for `Kurochan`.
  """

  alias Nostrum.Cache.GuildCache

  def get_voice_channel_from_msg(msg) do
    msg.guild_id
    |> GuildCache.get!()
    |> Map.get(:voice_states)
    |> Enum.find(%{}, fn voice_states ->
      voice_states.user_id == msg.author.id
    end)
    |> Map.get(:channel_id)
  end
end
