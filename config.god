God::Contacts::Email.defaults do |d|
  d.from_email = 'god@gog-simple.com'
  d.from_name = 'God'
  d.delivery_method = :sendmail
end

God.contact(:email) do |c|
  c.name = 'lazarus'
  c.group = 'developers'
  c.to_email = 'lazarus.effect21@gmail.com'
end

# God::Contacts::Email.defaults do |d|
#   d.from_email = 'system@example.com'
#   d.from_name = 'Process monitoring'
#   d.delivery_method = :smtp
#   d.server_host = 'smtp.gmail.com'
#   d.server_port = 587
#   d.server_auth = true
#   d.server_domain = 'example.com'
#   d.server_user = 'system@example.com'
#   d.server_password = 'myPassword'
# end