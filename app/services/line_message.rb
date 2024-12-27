require 'net/http'
require 'uri'
require 'json'

class LineMessage
  include ApplicationHelper

  def initialize(params)
    @line_id = params
  end

  def call(pull)
    if pull.nil?
      puts "No info found in the pull"
      return
    end
    message = parse(pull)
    if message.nil?
      puts "No new lessons found"
      return
    end
    message_text = build_message(message)
    perform_action(message_text)
  end

  private

  attr_reader :params

  def perform_action(message)
    access_token = ENV["LINETOKEN"]
    uri = URI.parse("https://api.line.me/v2/bot/message/push")
    header = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{access_token}"
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = message.to_json
    response = http.request(request)
    if response.is_a?(Net::HTTPSuccess)
      puts "Message sent successfully!"
    else
      puts "Failed to send message: #{response.body}"
    end
  end

  def build_message(message)
    {
      to: @line_id,
      messages: [
        {
          type: "text",
          text: message
        }
      ]
    }
  end

  def parse(pull)
    new_lessons = []
    pull.scrapes.each do |scrape|
      scrape.slots.each do |slot|
        new_lessons << slot.lesson if slot.updated
      end
    end
    interpolate(new_lessons.sort_by(&:date))
  end

  def interpolate(lsns)
    array = []
    new_lsns = lsns.select { |lsn| lsn.booked }
    cnc_lsns = lsns.reject { |lsn| lsn.booked }
    today = Date.today
    new_lsns.each do |lsn|
      if lsn.date >= today
        array << "\n#{lsn.ls} - #{lsn.date} - #{lsn.time} - #{text_title(lsn.text)}"
      end
    end
    unless cnc_lsns.empty?
      array << "\n\nCancelled Lessons:"
      cnc_lsns.each do |lsn|
        old_lsn = lsn.slots.last.matching_lesson
        if lsn.date >= today
          array << "\n#{lsn.ls} - #{lsn.date} - #{lsn.time} - #{text_title(old_lsn.text) if old_lsn}"
        end
      end
    end
    if array.empty?
      return nil
    end
    message = (["New Lessons:"].concat(array)).reduce(:+)
    if message.size > 4999
      message = message.slice(0, 4950) + "\n..... \nMessage too long - please check the web"
    end
    message
  end
end
