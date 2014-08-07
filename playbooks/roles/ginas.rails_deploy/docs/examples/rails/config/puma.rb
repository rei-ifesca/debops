# What environment should the server be started under?
environment ENV['RAILS_ENV']

# Feel free to experiment with this, 0/16 is a good starting point.
threads ENV['THREADS_MIN'].to_i, ENV['THREADS_MAX'].to_i

# Go with at least 1 per CPU core, a higher amount will usually help for fast
# responses such as reading from a cache.
workers ENV['WORKERS'].to_i

# Listen on a tcp port or unix socket.
if ENV['LISTEN_ON'].start_with?('unix:')
  bind "unix:/#{ENV['LISTEN_ON']}"
else
  bind "tcp://#{ENV['LISTEN_ON']}"
end

# The path where the pid file will be written to.
pidfile "#{ENV['RUN_STATE_PATH']}/#{ENV['SERVICE']}.pid"

# Use a shorter timeout instead of the 60s default. If you are handling large
# uploads you may want to increase this.
worker_timeout 30

# The paths to where logs will be written to.
stdout_redirect "#{ENV['LOG_PATH']}/#{ENV['SERVICE']}.access.log",
                "#{ENV['LOG_PATH']}/#{ENV['SERVICE']}.error.log"

# Preload the application before starting the workers.
preload_app!

# The path to the puma binary without any arguments, it will inherit everything
# from the original process.
restart_command 'bin/puma'

on_worker_boot do
  # Don't bother having the master process hang onto older connections.
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
