import Config

config :joken, default_signer: System.get_env("JWT_SECRET", "very-secret-dummy-cryptograhic-key")
