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

  test "semaphore 1" do
    s = :s

    EtsSemaphore.new(s)
    EtsSemaphore.acquire(s)
    receiver = self()

    _pid =
      spawn(fn ->
        EtsSemaphore.acquire(s)
        EtsSemaphore.release(s)
        send(receiver, :ping)
      end)

    refute_receive(:ping, 1_000)
    EtsSemaphore.release(s)
    assert_receive(:ping, 1_000)
    EtsSemaphore.delete(s)
  end

  test "semaphore 2" do
    s = :s

    EtsSemaphore.new(s)
    EtsSemaphore.acquire(s)
    receiver = self()

    _pid =
      spawn(fn ->
        EtsSemaphore.acquire(s)
        EtsSemaphore.release(s)
        send(receiver, :ping)
      end)

    _pid =
      spawn(fn ->
        EtsSemaphore.acquire(s)
        EtsSemaphore.release(s)
        send(receiver, :ping)
      end)

    refute_receive(:ping, 1_000)
    EtsSemaphore.release(s)
    assert_receive(:ping, 1_000)
    assert_receive(:ping, 1_000)
    EtsSemaphore.delete(s)
  end
end
