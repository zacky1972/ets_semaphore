s = :s
EtsSemaphore.new(s)

Benchee.run(
  %{
    "acquire" => {
      fn -> EtsSemaphore.acquire(s) end,
      after_each: fn _ ->
        EtsSemaphore.release(s)
      end
    },
    "release" => {
      fn _ -> EtsSemaphore.release(s) end,
      before_each: fn _ ->
        EtsSemaphore.acquire(s)
      end
    }
  },
  print: [fast_warning: false]
)
