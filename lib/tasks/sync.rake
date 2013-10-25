namespace :sync do
  desc "Copy the production database into this local installation"
  task :production => [:environment] do
    db_host_username = 'chalkle'
    db_host = "my.chalkle.com"

    db_config = YAML.load_file('config/database.yml')[Rails.env]

    psql_params = "-U #{db_config["username"]}"
    psql_params += " -d #{db_config["database"]}"
    password_setting = "PGPASSWORD=""#{db_config["password"]}"" " if db_config["password"]

    puts "#{Time.now} Running dump_prod.sh..."
    system "ssh #{db_host_username}@#{db_host} \"./dump_prod.sh\""

    puts "#{Time.now} Synchronising sql file..."
    system "rsync -azP -e ssh --progress #{db_host_username}@#{db_host}:~/prod_dump.sql ./tmp/production_data.sql"

    puts "#{Time.now} Importing sql..."
    system "#{password_setting}psql #{psql_params} -f ./tmp/production_data.sql"
    puts "#{Time.now} Done."
  end
end
