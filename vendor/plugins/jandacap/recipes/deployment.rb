require 'capistrano/ext/multistage'
set :default_stage, "development"

set(:repository) { "git@git.jandaweb.com:#{application}.git" }
set :scm, :git

set :admin_runner, "rails"
set :runner, "rails"

set :ssh_options, { :forward_agent => true }

namespace :deploy do
  desc <<-DESC
    Prompt the user for confirmation if we are deploying to production. This
    task should be called before the deploy task, it exits straight away if the
    user does not respond with 'yes'.
  DESC
  task :confirm_deployment do
    if ( stage rescue false ) && stage == :production
      set :continue do
        Capistrano::CLI.ui.ask(
          "\n*****\tYOU ARE DEPLOYING TO THE PRODUCTION SERVER\n" +
          "\tcontinue? (yes/[no]) "
        )
      end

      if continue != "yes"
        exit 0
      end
      puts
    end
  end

  desc 'Display the names of the servers for this task'
  task :display_servers do
    servers = roles[:web].servers.map { |server| server.host }.join(', ')
    logger.trace "\nDeploying to #{servers}\n\n"
  end
end

namespace :passenger do
  desc "Restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

namespace :deploy do
  %w(start restart).each do |name|
    task name, :roles => :app do
      passenger.restart end
  end
end

before :deploy, "deploy:display_servers"
after "production",                 "deploy:confirm_deployment"
