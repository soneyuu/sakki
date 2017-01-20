require "bundler/setup"
Bundler.require(:default)
require "sinatra/reloader"

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  configure do
    set :views, settings.root + "/views"
  end

  get "/" do
    slim :index
  end
end
