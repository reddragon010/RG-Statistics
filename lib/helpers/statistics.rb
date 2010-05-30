require File.dirname(__FILE__) + "/../../grabber/grabber"

module StatisticsHelper
  def get_states(servername)
    @server = Grabber::Server.find_by_name(servername)
    time_start  = round_time(@server.states.first.time)
    time_end    = round_time(@server.states.last.time)
    states      = @server.states.find(:all, :conditions => ["time >= ? AND time <= ?",time_start,time_end])
    formatted_states = Array.new
    states.each do |state|
      state.time = round_time(state.time)
      formatted_states << state
    end
    return formatted_states
  end
  
  def data(servername)
    @server = Grabber::Server.find_by_name(servername)
    data = Array.new
    
    @server.states.all.each do |state|
      data << "[new Date(#{state.time.year}, #{state.time.month} , #{state.time.day}, #{state.time.hour}, #{state.time.min}), #{state.oplayers_all},  #{state.oplayers_alliance}, #{state.oplayers_horde}]"
    end
    return data
  end
  
  def round_time(time)
    time - ((time.min % 10) * 60 + time.sec)
  end
end