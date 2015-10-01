require 'net/http'

class EyeOfGod

  def initialize
    @array_retry = []
  end


  def monitor_url(url_data)
    url_data.each do |url_data|
      # Init hash_data
      url_data = url_data.merge({notifs: [], errors: []})

      # Check if an ssl connection is required and handles errors of url format
      data_valid = check_url(url_data)

      if data_valid != []
        url_data = url_data.merge({uri: data_valid [0], response: data_valid[1]})
        check_code(url_data)
      end

      if ARGV[0] == "show"
        show(url_data)
      end
    end
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
      url_data[:notifs].push("email")
    end
  end


  # Show of data, errors, notifs
  def show(url_data)
    msg_format_info = "I -"

    puts "####################"
    puts "#{msg_format_info} NAME: #{url_data[:url]}"
    puts "#{msg_format_info} URL: #{url_data[:url]}"

    if url_data[:errors] != []
      errors_eye(url_data[:errors])
    else
      puts "#{msg_format_info} RESPONSE: [#{url_data[:response].to_hash['date'][0]}]: #{[url_data[:response].code, url_data[:response].message].join(" -- ")}"
    end

    if url_data[:notifs] != []
      notifs_eye(url_data[:notifs])
    else
      puts "#{msg_format_info} Not notifications."
    end

    puts "####################\n\n"
  end


  # Show msg error
  def errors_eye(errors)
    msg_format_error = "E -"

    errors.each do |error|
      if error === "url_not_exist"
        puts "#{msg_format_error} ERROR fatal => url does not exist !"
      else
        puts "#{msg_format_error} ERROR fatal => error not found !"
      end
    end
  end


  # Show msg notif
  def notifs_eye(notifs)
    msg_format_notif = "N -"

    notifs.each do |notif|
      if notif === "email"
        puts "#{msg_format_notif} Notification by email"
      else
        puts "#{msg_format_notif} Other notification"
      end
    end
  end


  # Push email notification
  def notif_email

  end
end



#####################################################################################
url_data = [{name: "blog", url: "www.over-blog.com"},
            {name: "perdu", url: "www.perdu.com/index.html"},
            {name: "test_code_error", url: "www.reveauxlettres.fr/truc/truc.html"},
            {name: "test_url_error", url: "www.tqeruihqfui.com"}]

eye = EyeOfGod.new
c = 1

loop do
  puts "\n\n#{c}\n"
  eye.monitor_url(url_data)

  sleep(30)
  c += 1
end



