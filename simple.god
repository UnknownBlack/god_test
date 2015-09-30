God::Contacts::Email.defaults do |d|
  d.from_email = 'lazarus.effect21@gmail.com'
  d.from_name = 'lazarus_god'
  d.delivery_method = :sendmail
end

God.contact(:email) do |c|
  c.name = 'lazarus'
  c.group = 'developers'
  c.to_email = 'lazarus.effect21@gmail.com'
end

God.watch do |w|
  w.name = "simple"
  w.start = "ruby /home/hallo/projects/god_test/simple.rb"
  w.keepalive(:memory_max => 50.megabytes,
                :cpu_max => 50.percent)

  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.interval = 20
      c.above = 50.megabytes
      c.notify = 'lazarus'
    end
  end

end

