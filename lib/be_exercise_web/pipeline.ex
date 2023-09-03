defmodule BeExerciseWeb.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :be_exercise,
    error_handler: BeExerciseWeb.ErrorHandler.JSON,
    module: BeExerciseWeb.Guardian

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
