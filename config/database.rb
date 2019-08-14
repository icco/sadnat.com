##
# Database config for relational db.
RACK_ENV = ENV['RACK_ENV'] ||= 'development'  unless defined?(RACK_ENV)
RACK_ENV = RACK_ENV.to_sym

init = Time.now
connections = {
  :development => "postgres://localhost/sadnat",
  :test => "postgres://postgres@localhost/sadnat_test",
  :production => ENV['DATABASE_URL']
}

# Setup our logger
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Include Active Record class name as root for JSON serialized output.
ActiveRecord::Base.include_root_in_json = true

# Store the full class name (including module namespace) in STI type column.
ActiveRecord::Base.store_full_sti_class = true

# Use ISO 8601 format for JSON serialized times and dates.
ActiveSupport.use_standard_json_time_format = true

# Don't escape HTML entities in JSON, leave that for the #json_escape helper.
# if you're including raw json in an HTML page.
ActiveSupport.escape_html_entities_in_json = false

# Include Active Record class name as root for JSON serialized output.
ActiveRecord::Base.include_root_in_json = false

# Store the full class name (including module namespace) in STI type column.
ActiveRecord::Base.store_full_sti_class = true

# Now we can estabilish connection with our db
if connections[RACK_ENV]
  url = URI(connections[RACK_ENV])
  options = {
    :adapter => url.scheme,
    :host => url.host,
    :port => url.port,
    :database => url.path[1..-1],
    :username => url.user,
    :password => url.password
  }

  case url.scheme
  when "sqlite"
    options[:adapter] = "sqlite3"
    options[:database] = url.host + url.path
  when "postgres"
    options[:adapter] = "postgresql"
  end

  ActiveRecord::Base.establish_connection(options)
else
  raise "No database configuration for #{RACK_ENV.inspect}"
end
