ActionController::Routing::Routes.draw do |map|
  map.resource :session
  map.resources :iterations
  map.resources :organisations
  map.resources :projects do |project|
    project.resources :iterations
    project.resources(:stories, :collection => { :finished => :get }) do |story|
      story.resources :acceptance_criteria
    end
  end
  map.resources :users

  map.resources :iterations do |iteration|
    iteration.resource :burndown
    iteration.resource :active_iterations
  end

  map.root :controller => 'home', :action => 'show'
end
