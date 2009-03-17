ActionController::Routing::Routes.draw do |map|
  map.resource :session
  map.resources :iterations
  map.resources :organisations
  map.resources :projects do |project|
    project.resources :iterations do |iteration|
      iteration.resources :stories
    end
    project.resources(:stories, 
                      :collection => { 
                        :backlog => :get,
                        :finished => :get 
                      }) do |story|
      story.resources :acceptance_criteria
    end
  end

  map.resources :users do |user|
    user.resource :verification
  end

  map.resources :iterations do |iteration|
    iteration.resource :burndown
    iteration.resource :active_iteration
  end

  map.root :controller => 'home', :action => 'show'
end
