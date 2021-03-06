defmodule Cachex.Actions.DelTest do
  use CachexCase

  # This case tests that we can safely remove items from the cache. We test the
  # removal of both existing and missing keys, as the behaviour is the same for
  # both. We also ensure that hooks receive the delete notification successfully.
  test "removing entries from a cache" do
    # create a forwarding hook
    hook = ForwardHook.create(%{ results: true })

    # create a test cache
    cache = Helper.create_cache([ hooks: [ hook ] ])

    # add some cache entries
    { :ok, true } = Cachex.set(cache, 1, 1)

    # delete some entries
    result1 = Cachex.del(cache, 1)
    result2 = Cachex.del(cache, 2)

    # verify both are true
    assert(result1 == { :ok, true })
    assert(result2 == { :ok, true })

    # verify the hooks were updated with the delete
    assert_receive({ { :del, [ 1, [] ] }, ^result1 })
    assert_receive({ { :del, [ 2, [] ] }, ^result2 })

    # retrieve all items
    value1 = Cachex.get(cache, 1)
    value2 = Cachex.get(cache, 2)

    # verify the items are gone
    assert(value1 == { :missing, nil })
    assert(value2 == { :missing, nil })
  end

end
