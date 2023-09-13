defmodule BeExerciseWeb.ErrorJSONTest do
  use BeExerciseWeb.ConnCase, async: true

  test "renders 404" do
    assert BeExerciseWeb.ErrorJSON.render("404.json", %{}) == %{error: "Not Found"}
  end

  test "renders 500" do
    assert BeExerciseWeb.ErrorJSON.render("500.json", %{}) == %{error: "Internal Server Error"}
  end
end
