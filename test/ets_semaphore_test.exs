defmodule EtsSemaphoreTest do
  use ExUnit.Case
  doctest EtsSemaphore

  test "message passing" do
    pid =
      spawn(fn ->
        receive do
          {:ping, sender} -> send(sender, :pong)
        end
      end)

    send(pid, {:ping, self()})

    assert_receive(:pong, 1_000)
  end
end
