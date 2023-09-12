defmodule BeExercise.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias BeExercise.Repo

  alias BeExercise.Accounts.AuthorizationRole
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
    |> limit(5)
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
    user =
      User
      |> where(email: ^email)
      |> preload(:authorization_role)
      |> Repo.one()

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

  @doc """
  Gets a single user with preloaded role. Returns nil if empty.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      nil

  """
  @spec get_user_with_role(integer()) :: struct() | nil
  def get_user_with_role(id) do
    User
    |> where(id: ^id)
    |> preload(:authorization_role)
    |> Repo.one()
  end

  def list_authorization_role_names do
    AuthorizationRole
    |> select([ar], ar.name)
    |> Repo.all()
  end

  def get_authorization_role_id(role_name) do
    AuthorizationRole
    |> where(name: ^role_name)
    |> select([ar], ar.id)
    |> Repo.one()
  end

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

  def confirm_user_token(%User{} = user) do
    {_, user_token} = UserToken.build_email_token(user, "confirm")
    Repo.insert!(user_token)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
    |> Repo.transaction()
  end

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  def parse_user_id(user_id) do
    change =
      %User{}
      |> Ecto.Changeset.cast(%{id: user_id}, [:id])
      |> Ecto.Changeset.fetch_change(:id)

    case change do
      {:ok, id} -> id
      :error -> nil
    end
  end
end
