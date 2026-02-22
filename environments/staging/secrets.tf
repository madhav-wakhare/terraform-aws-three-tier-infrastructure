# Fetch secret metadata from AWS Secrets Manager by name
data "aws_secretsmanager_secret" "rds" {
  name = "wg/staging/rds"
}

# Fetch the latest active version of the secret value
data "aws_secretsmanager_secret_version" "rds" {
  secret_id = data.aws_secretsmanager_secret.rds.id
}

locals {
  _raw = data.aws_secretsmanager_secret_version.rds.secret_string

  # Gracefully handles two secret formats:
  #   JSON object : { "username": "admin", "password": "..." }  ← recommended
  #   Plain string: "mysecretpassword"                           ← falls back safely
  _json       = try(jsondecode(local._raw), {})
  db_username = try(local._json["username"], "admin")
  db_password = try(local._json["password"], local._raw)
}
