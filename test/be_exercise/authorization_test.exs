defmodule BeExercise.AuthorizationTest do
  use ExUnit.Case
  import BeExerciseWeb.Auth.Authorization

  alias BeExercise.Accounts.User

  describe "member role:" do
    test "can read", do: assert(can("member") |> read?(User))
    test "can't create", do: refute(can("member") |> create?(User))
    test "can update", do: assert(can("member") |> update?(User))
    test "can't delete", do: refute(can("member") |> delete?(User))
  end

  describe "finance role:" do
    test "can read", do: assert(can("finance") |> read?(User))
    test "can't create", do: refute(can("finance") |> create?(User))
    test "can update", do: assert(can("finance") |> update?(User))
    test "can't delete", do: refute(can("finance") |> delete?(User))
  end

  describe "admin role:" do
    test "can read", do: assert(can("admin") |> read?(User))
    test "can create", do: assert(can("admin") |> create?(User))
    test "can update", do: assert(can("admin") |> update?(User))
    test "can delete", do: assert(can("admin") |> delete?(User))
  end
end
