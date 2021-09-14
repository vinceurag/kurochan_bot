defmodule Kurochan.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @token Application.get_env(:alchemy, :token)

  use Application
  use Alchemy.Cogs

  alias Alchemy.Client

  @impl true
  def start(_type, _args) do
    run = Client.start(@token)
    Cogs.set_prefix("!!")
    use Kurochan
    run
  end
end
