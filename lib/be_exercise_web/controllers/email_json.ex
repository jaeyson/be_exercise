defmodule BeExerciseWeb.EmailJSON do
  @doc """
  Sends an email to all users and returns a count of sent emails.
  """
  def invite_users(%{message: message}) do
    %{message: message}
  end
end
