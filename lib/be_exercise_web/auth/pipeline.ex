defmodule BeExerciseWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :be_exercise,
    error_handler: BeExerciseWeb.Auth.ErrorHandler,
    module: BeExerciseWeb.Auth.Guardian

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
