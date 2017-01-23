require "bundler/setup"
Bundler.require(:default)
require "sinatra/reloader"

Dir["models/*.rb"].each do |model|
  require_relative model
end

Dir["repositories/*.rb"].each do |repository|
  require_relative repository
end

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  configure do
    set :views, settings.root + "/views"
  end

  helpers do
    def entry_repository
      @@entry_repository ||= EntryRepository.new
    end
  end

  get "/" do
    slim :index
  end

  get "/entries/new" do
    slim :new
  end

  post "/entries" do
    entry = Entry.new
    entry.title = params[:title]
    entry.body = params[:body]
    id = entry_repository.save(entry)

    redirect to("/entries/#{id}")
  end

  get "/entries/:id" do
    @entry = entry_repository.fetch(params[:id].to_i)
    p @entry

    slim :entry
  end
end
