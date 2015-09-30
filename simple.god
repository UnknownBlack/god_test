
RAILS_ROOT = File.dirname(File.dirname(__FILE__))


God.load "#{RAILS_ROOT}/config.god"

%w{3000}.each do |port|
  God.watch do |w|
    name_app = "simple"
    pid_file = "$HOME/.god/pids/#{name_app}.pid"

    w.name = name_app
    w.dir = RAILS_ROOT
    w.pid_file = pid_file
    w.start = "ruby #{RAILS_ROOT}/simple.rb"
    w.stop = "kill -s QUIT $(cat #{pid_file})"
    w.restart = "kill -s HUP $(cat #{pid_file})"
    w.start_grace = 20.seconds
    w.restart_grace = 20.seconds

    w.behavior(:clean_pid_file)


    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 5.seconds
        c.running = false
      end
    end


    w.restart_if do |restart|
      restart.condition(:memory_usage) do |c|
        c.above = 50.megabytes
        c.times = [3, 5] # 3 out of 5 intervals
        c.pid_file = pid_file
      end

      restart.condition(:cpu_usage) do |c|
        c.above = 25.percent
        c.times = 5
        c.pid_file = pid_file
      end
    end


    w.lifecycle do |on|
      on.condition(:flapping) do |c|
        c.to_state = [:start, :restart]
        c.times = 5
        c.within = 5.minute
        c.transition = :unmonitored
        c.retry_in = 10.minutes
        c.retry_times = 5
        c.retry_within = 2.hours
      end
    end


    # NOTIF Email
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.interval = 20
        c.above = 50.megabytes
        c.notify = 'lazarus'
        echo "Restart !" >> RAILS_ROOT/logg
      end
    end
  end
end


