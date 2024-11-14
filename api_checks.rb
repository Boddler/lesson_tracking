require 'net/http'
require 'uri'
require 'json'
require "dotenv"
Dotenv.load

access_token = ENV["LINETOKEN"]

message_text = "Last one for today"
recipient_user_id = ENV["LINEID"] # Replace with the user ID you want to send the message to

# Prepare the HTTP request
uri = URI.parse("https://api.line.me/v2/bot/message/push")
header = {
  "Content-Type" => "application/json",
  "Authorization" => "Bearer #{access_token}"
}

# Construct the message body
body = {
  to: recipient_user_id,
  messages: [
    {
      type: "text",
      text: message_text
    }
  ]
}

# Make the POST request
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
request = Net::HTTP::Post.new(uri.request_uri, header)
request.body = body.to_json

response = http.request(request)

# Print the response
if response.is_a?(Net::HTTPSuccess)
  puts "Message sent successfully!"
else
  puts "Failed to send message: #{response.body}"
end
