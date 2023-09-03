import Ecto.Changeset
import Ecto.Query, warn: false

alias BeExercise.Accounts
alias BeExercise.Accounts.User
alias BeExercise.Finances
alias BeExercise.Finances.Currency
alias BeExercise.Finances.Salary
alias BeExercise.Repo
alias BeExerciseWeb.Guardian

# IEx.configure(
#   inspect: [
#     limit: :infinity,
#     printable_limit: :infinity
#   ]
# )
