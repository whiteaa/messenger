import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :messenger, MessengerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "0E8m7qxYvk53XQehlNrAmK5jURAF1UaRhn4SyW1G2zxs76M1wGQq4SBcCjFPDh4k",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
