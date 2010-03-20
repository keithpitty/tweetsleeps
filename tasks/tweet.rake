require 'rubygems'
require 'twitter'

namespace :tweet do
  desc "post a test tweet (arg: username)"
  task :test, :username do |t, args|
    unless args.username
      raise "Please try again with the username e.g. rake tweet:test[twitteruser]"
    end
    client(args.username).update("Testing at #{Time.now} ...")
  end
  
  desc "post a message about the number of days until an event (args: username, event_msg and event_date in yyyymmdd format and optional hashtags)"
  task :days_until, :username, :event_msg, :event_date, :tags do |t, args|
    unless args.username args.event_msg && args.event_date
      raise "Please try again with the username, event message and date e.g. rake tweet:days_until[twitteruser,railscamp,20100416] and optional an additional hashtags arg"
    end
    msg = message(days_until(Date.parse(args.event_date)), args.event_msg)
    msg << " #{args.tags}" if args.tags
    if msg.length > 140
      raise "Not sending tweet because message is too long!"
    end
    client(args.username).update(msg) unless msg.blank?
  end
end

def client(username)
  Twitter::Base.new(Twitter::HTTPAuth.new(username, password_for(username)))
end

def message(days_left, event_msg)
  case 
  when days_left > 1
    "Only #{days_left} sleeps until #{event_msg}!"
  when days_left == 1
    "Only one sleep until #{event_msg}!"
  when days_left == 0
    "No more sleeps until #{event_msg}. It's on today!"
  else
    nil
  end
end
    

def password_for(username)
  users = YAML::load_file(File.expand_path("~/.tweetsleeps/users.yml"))
  raise 'User not found!' unless users[username]
  users[username]
end

def days_until(event_date)
  (event_date - Date.today).to_i
end