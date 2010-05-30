require "rubygems"
require "active_record"
require 'socket'
require 'hpricot'
require 'open-uri'

module Grabber

  ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :dbfile  => File.dirname(__FILE__) + "/mastermind.db")

  class State < ActiveRecord::Base
    belongs_to :server
  end

  class Downtime < ActiveRecord::Base
    belongs_to :server
  end

  class Server < ActiveRecord::Base
    has_many :states
    has_many :downtimes
  
    def update_state
      state = get_oplayers(get_website,get_online_status)
      state.time = Time.now               #set state time
      if state.save                       #if save is ok connect it to the server
        self.states << state
        self.save
        puts "... #{state.oplayers_all} players online (h:#{state.oplayers_horde},a:#{state.oplayers_alliance})"
      else
        puts "... error!"
        return false                      #if something goes wrong return false
      end
    end
  
    def check_downtime
      online = get_online_status
      if online != self.online
        if self.online == true && online == false
          downtime = Downtime.new
          downtime.begin = Time.now
          self.downtimes < downtime
          puts "... server gone down"
        elsif self.online == false && online == true
          downtime = self.downtimes.last
          downtime.update_attribute(:end,Time.now)
          puts "... server gone up"
        end
      else
        puts "... nothing happend"
      end
      self.online = online
      self.save
    end
  
    def get_online_status
      begin
        t = TCPSocket.new(self.host, self.port)
      rescue
        return false
      else
        t.close
        return true
      end
    end
  
    def get_website
      begin
        return Hpricot(open("http://www.rising-gods.de"))
      rescue
        return false
      end
    end
  
    def get_oplayers(doc,online)
      return false unless doc
      state = State.new
   
      if online == true                           #if server is on update oplayers, if not set 0
        state.oplayers_all = (doc/"#oplayers_#{self.name}").inner_html.to_i
        state.oplayers_alliance = (doc/"#alliance_#{self.name}").inner_html.to_i
        state.oplayers_horde = (doc/"#horde_#{self.name}").inner_html.to_i
      else
        state.oplayers_all = 0
        state.oplayers_alliance = 0
        state.oplayers_horde = 0
      end
      return state
    end
  
  end
end