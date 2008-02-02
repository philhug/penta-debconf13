ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.
  map.connect '/penta/', :controller => 'pentabarf'

  map.connect '/penta/schedule/:conference', :controller => 'schedule', :action => 'index', :language => 'en'
  map.connect '/penta/schedule/:conference/index.:language.html', :controller => 'schedule', :action => 'index'
  map.connect '/penta/schedule/:conference/day/:id.:language.html', :controller => 'schedule', :action => 'day'
  map.connect '/penta/schedule/:conference/speakers.:language.html', :controller => 'schedule', :action => 'speakers'
  map.connect '/penta/schedule/:conference/speaker/:id.:language.html', :controller => 'schedule', :action => 'speaker'
  map.connect '/penta/schedule/:conference/events.:language.html', :controller => 'schedule', :action => 'events'
  map.connect '/penta/schedule/:conference/event/:id.:language.html', :controller => 'schedule', :action => 'event'
  map.connect '/penta/schedule/:conference/day/:id.:language.html', :controller => 'schedule', :action => 'day'
  map.connect '/penta/schedule/:conference/track/:track/index.:language.html', :controller => 'schedule', :action => 'track_events'
  map.connect '/penta/schedule/:conference/track/:track/:id.:language.html', :controller => 'schedule', :action => 'track_event'
  map.connect '/penta/schedule/:conference/style.css', :controller => 'schedule', :action => 'css'
  map.connect '/penta/schedule/:conference/:action.:language.html',:controller => 'schedule'
  map.connect '/penta/schedule/:conference/:action/:id.:language.html',:controller => 'schedule'

  map.connect '/penta/feedback/:conference/style.css',:controller => 'feedback', :action => 'css'
  map.connect '/penta/feedback/:conference/:action/:id.:language.html',:controller => 'feedback'

  map.connect '/penta/submission/:conference/:action/:id', :controller => 'submission'

  map.connect '/penta/image/:action/:id.:size.:extension', :controller=> 'image'
  map.connect '/penta/image/:action/:id.:size', :controller=> 'image'

  # Install the default route as the lowest priority.
  map.connect '/penta/:controller/:action/:id.:format'
  map.connect '/penta/:controller/:action/:id'
end
