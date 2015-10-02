require 'net/http'

class EyeOfGod

  def initialize
    @app_errors = {}
  end


  def monitor_url(url_data)
    # Init url_data
    url_data = url_data.merge({notifs: [], errors: []})

    # Check if an ssl connection is required and handles errors of url format
    data_valid = check_url(url_data)

    if data_valid != []
      url_data = url_data.merge({uri: data_valid [0], response: data_valid[1]})
      check_code(url_data)
    end

    log_write(url_data)

    if ARGV.include?("show"); show(url_data) end
  end


  # Check if an ssl connection is required and gère the errors of url format
  def check_url(url_data)
    begin
      data = ssl_check(url_data[:url])
    rescue
      url_data[:errors].push("url_not_exist")
      url_data[:notifs].push("email")
      data = []
    end
    data
  end


  # Check if an ssl connection is required
  def ssl_check(url)
    uri = "http://#{url}"
    response = Net::HTTP.get_response(URI(uri))

    if response.to_hash["location"]
      uri = response.to_hash["location"][0]
      response = Net::HTTP.get_response(URI(uri))
    end

    [uri, response]
  end


  # Check code of response get
  def check_code(url_data)
    if url_data[:response].code != '200'
      url_data[:notifs].push("slack-tech")

      if @app_errors["#{url_data[:name]}"]
        @app_errors["#{url_data[:name]}"] += 1
      else
        @app_errors["#{url_data[:name]}"] = 1
      end

      if @app_errors["#{url_data[:name]}"] > 5
        restart_app(url_data[:restart])
        url_data[:notifs].push("email")
      end

      if @app_errors["#{url_data[:name]}"] > 10
        url_data[:notifs].push("sms")
      end

    else
      @app_errors["#{url_data[:name]}"] = 0
    end
  end


  def restart_app(reset)

  end


  # Writing the logs
  def log_write(url_data)

    file_name = "log/#{url_data[:name]}"
    msg_format_info = "I -"

    if !File.exist?(file_name)
      File.new(file_name, "w+")
    end

    File.open(file_name, "a") do |f|
      f.puts "#_#-#-#-#-#-#-#-#-#-#"
      f.puts "#{msg_format_info} NAME: #{url_data[:name]}"
      f.puts "#{msg_format_info} URL: #{url_data[:url]}"

      if url_data[:errors] != []
        errors_eye(url_data[:errors], f)
      else
        f.puts "#{msg_format_info} RESPONSE: [#{url_data[:response].to_hash['date'][0]}]: #{[url_data[:response].code, url_data[:response].message].join(" -- ")}"
      end

      if url_data[:notifs] != []
        notifs_eye(url_data[:notifs], f)
      else
        f.puts "#{msg_format_info} Not notifications."
      end

      f.puts "#-#-#-#-#-#-#-#-#-#_#\n\n"
    end
  end


  # Show of data, errors, notifs
  def show(url_data)
    puts reverse_s(/#_#.+?#_#/m.match(reverse_s(open("log/#{url_data[:name]}").read.to_s)).to_s) + "\n\n"
  end


  def reverse_s(str)
    half_length = str.length / 2
    half_length.times {|i| str[i], str[-i-1] = str[-i-1], str[i] }
    str
  end


  # Show msg error
  def errors_eye(errors, f)
    msg_format_error = "E -"

    errors.each do |error|
      case error
      when "url_not_exist"
        f.puts "#{msg_format_error} ERROR fatal => url not match !"
      else
        f.puts "#{msg_format_error} ERROR fatal => error unknown !"
      end
    end
  end


  # Show msg notif
  def notifs_eye(notifs, f)
    msg_format_notif = "N -"

    notifs.each do |notif|
      case notif
      when "email"
        f.puts "#{msg_format_notif} Notification by email"
      else
        f.puts "#{msg_format_notif} Other notification"
      end
    end
  end


  # Push email notification
  def notif_email

  end
end



#####################################################################################
url_data = [{name: "blog", url: "www.over-blog.com", restart: "scalingo "},
            {name: "perdu", url: "www.perdu.com/index.html", restart: "scalingo "},
            {name: "test_code_error", url: "www.reveauxlettres.fr/truc/truc.html", restart: "scalingo "},
            {name: "test_url_error", url: "www.tqeruihqfui.com", restart: "scalingo "}]

eye = EyeOfGod.new
c = 1

loop do
  if ARGV.include?("show"); puts "\n\n----- Checking #{c} -----\n"; c += 1 end

  url_data.each do |url_data|
    eye.monitor_url(url_data)
  end

  # for the tests
  if ARGV.include?("exit"); exit end

  sleep()
end



