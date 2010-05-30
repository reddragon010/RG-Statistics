require File.dirname(__FILE__) + "/grabber"

def setup
  ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :dbfile  => "mastermind.db")
  
  ActiveRecord::Schema.define do
    create_table :servers do |table|
        table.string    :name
        table.string    :host
        table.integer   :port
        table.boolean   :has_players
        table.boolean   :online
        table.datetime  :last_onlinecheck, :default => Time.now
        table.datetime  :last_playerscheck, :default => Time.now
    end

    create_table :states do |table|
        table.integer   :server_id
        table.integer   :oplayers_all
        table.integer   :oplayers_horde
        table.integer   :oplayers_alliance
        table.datetime  :time, :default => Time.now
    end
    
    create_table :downtimes do |table|
        table.integer   :server_id
        table.datetime  :begin
        table.datetime  :end
    end
  end
  
  Server.create :name => "login", :host => "94.23.195.96",  :port => 3724, :has_players => false
  Server.create :name => "pve",   :host => "94.23.33.162",  :port => 8085, :has_players => true
  Server.create :name => "pvp",   :host => "94.23.6.9",     :port => 8090, :has_players => true
end