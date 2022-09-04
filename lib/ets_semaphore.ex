defmodule EtsSemaphore do
  @moduledoc """
  Documentation for `EtsSemaphore`.
  """

  alias :ets, as: Ets

  @type t() :: atom()
  @s :semaphore
  @w :waiting_list

  @spec new(t()) :: t()
  def new(s) do
    Ets.new(s, [:set, :public, :named_table])
    s
  end

  def acquire(s) do
    case Ets.update_counter(s, @s, [{2, 0}, {2, 1}], {@s, 0}) do
      [0, _] ->
        :ok

      [_, _] ->
        Ets.update_counter(s, @s, {2, -1})
        w = Ets.update_counter(s, @w, {2, 1}, {@w, 0})
        Ets.insert(s, {w, self()})

        receive do
          :signal ->
            acquire(s)
        end
    end
  end

  def release(s) do
    [_, _] = Ets.update_counter(s, @s, [{2, 0}, {2, -1, 0, 0}])
    [w, _] = Ets.update_counter(s, @w, [{2, 0}, {2, -1, 0, 0}], {@w, 0})
    release_sub(s, w)
  end

  defp release_sub(_s, 0), do: :ok

  defp release_sub(s, w) do
    case Ets.lookup(s, w) do
      [{^w, pid}] ->
        Ets.delete(s, w)
        send(pid, :signal)

      [] ->
        :ok
    end

    release_sub(s, w - 1)
  end

  def delete(_s) do
  end
end
