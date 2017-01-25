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

  def self.database_config
    YAML.load_file("config/database.yml")[ENV['RACK_ENV'] || 'development']
  end

  def self.database
    @database ||= Mysql2::Client.new(database_config)
  end

  helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials &&
      @auth.credentials == [ENV['BLOG_USERNAME'], ENV['BLOG_PASSWORD']]
    end

    def entry_repository
      @@entry_repository ||= EntryRepository.new(App.database)
    end

    def title
      str = ""
      if @entry
        str = @entry.title + " - "
      end
      str + "burogu"
    end
  end

  get "/" do
    slim :index
  end

  get "/entries/new" do
    protected!
    slim :new
  end

  post "/entries" do
    protected!
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
