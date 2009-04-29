DB = YAML::load(File.open(File.join(File.dirname(__FILE__), 'database.yml'))).symbolize_keys!
ActiveRecord::Base.establish_connection(DB[:source])

TABLES = %w(mains seconds)

TABLES.each do |t|
  ActiveRecord::Base.connection.execute("drop table if exists #{t};")
end

TABLES.each do |t|
  ActiveRecord::Base.connection.execute("create table #{t} (id integer, val integer, seconds_id integer, mains_id integer, created_at datetime default null);")
end

