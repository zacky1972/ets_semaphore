defmodule EtsSemaphore do
  @moduledoc """
  Documentation for `EtsSemaphore`.
  """

  alias :ets, as: Ets

  @type t() :: atom()
  @s :semaphore
  @w :waiting_list

  @doc """
  Creates a new semaphore named as an atom `s`.
  """
  @spec new(t()) :: t()
  def new(s) do
    Ets.new(s, [:set, :public, :named_table])
    s
  end

  @doc """
  Acquires the given semaphore.
  """
  @spec acquire(t()) :: :ok
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

  @doc """
  Releases the given semaphore.
  """
  @spec release(t()) :: :ok
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

  @doc """
  Deletes the given semaphore.
  """
  @spec delete(t()) :: :ok
  def delete(s) do
    Ets.delete(s)
    :ok
  end
end
