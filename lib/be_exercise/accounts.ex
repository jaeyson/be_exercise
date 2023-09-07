defmodule BeExercise.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias BeExercise.Repo

  alias BeExercise.Accounts.User
  alias BeExercise.Accounts.UserToken

  def list_user_id(%{order_by: order_by, filter_by: filter_by}) do
    order_by =
      if is_nil(order_by) do
        :asc
      else
        String.to_existing_atom(order_by)
      end

    User
    |> where([u], ilike(u.name, ^"%#{filter_by}%"))
    |> order_by({^order_by, :name})
    |> select([:id])
    |> Repo.all()
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def confirm_user_token(%User{} = user, type \\ :register) do
    {_, user_token} = UserToken.build_email_token(user, "confirm")
    Repo.insert!(user_token)

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:user, User.confirm_changeset(user))
      |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))

    multi =
      case type do
        :register ->
          multi

        :seeder ->
          multi
          |> Ecto.Multi.run(:send_email, fn _repo, %{user: user} ->
            fn -> BEChallengex.send_email(%{name: user.name}) end
            |> Task.async()
            |> Task.await()
          end)
      end

    Repo.transaction(multi)
  end

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end
end
