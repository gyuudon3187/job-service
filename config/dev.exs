import Config

config :job_service,
  ecto_repos: [JobService.Repo]

config :job_service, JobService.Repo,
  username: System.get_env("DB_USER") || "postgres",
  password: System.get_env("DB_PASSWORD") || "postgres",
  database: System.get_env("DB_NAME") || "job_service_dev",
  hostname: System.get_env("DB_HOST") || "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: System.get_env("POOL_SIZE") || 15

config :joken,
  default_signer: System.get_env("JWT_SECRET") || "very-secret-dummy-cryptograhic-key"
