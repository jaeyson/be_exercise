alias BeExercise.Seeder

seed_count = 10

Seeder.create_authorization_roles()
Seeder.create_currencies()
Seeder.create_users(seed_count)
