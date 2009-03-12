set :deploy_to, "/rails/simply-agile.dev.jandaweb.com"

set :domain, "dev.jandaweb.com"
server domain, :app, :web
role :db, domain, :primary => true
