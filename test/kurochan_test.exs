defmodule KurochanTest do
  use ExUnit.Case
  doctest Kurochan

  test "greets the world" do
    assert Kurochan.hello() == :world
  end
end
