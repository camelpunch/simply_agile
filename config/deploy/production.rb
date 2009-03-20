set :deploy_to, "/rails/besimplyagile.com"

set :domain, "www.jandaweb.com"
server domain, :app, :web
role :db, domain, :primary => true
