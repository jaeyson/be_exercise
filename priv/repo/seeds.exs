alias BeExercise.Seeder

seed_count = 20_000

Seeder.create_authorization_roles()
Seeder.create_currencies()
Seeder.create_users(seed_count)
Seeder.create_user(%{name: "John Doe", email: "john@doe.co", password: "Password!123"}, "admin")
