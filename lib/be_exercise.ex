defmodule BeExercise do
  @moduledoc """
  BeExercise keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def set_default(val, default \\ nil) do
    if is_nil(val) or String.trim(val) === "" do
      default
    else
      val
    end
  end

  def set_int(val, default) do
    if is_nil(val) or String.trim(val) === "" do
      default
    else
      try do
        String.to_integer(val)
      rescue
        _argument_error -> default
      end
    end
  end
end
