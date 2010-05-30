require File.dirname(__FILE__) + "/grabber"

class Worker
  def initialize(server)
    @server = server
    @counter = 1
  end

  def start
    puts "Worker for #{@server.name} started ..."
    loop do
      if @server.last_playerscheck + 600 <= Time.now
        puts "checking onlineplayer..."
        @server.update_state
        @server.last_playerscheck = Time.now
        @server.save
        @server.reload
      end
      if @server.last_onlinecheck + 60 <= Time.now && @server.has_players
        puts "checking server status..."
        @server.check_downtime
        @server.last_onlinecheck = Time.now
        @server.save
        @server.reload
      end
    
      sleep 10
    end
  end
  
end

