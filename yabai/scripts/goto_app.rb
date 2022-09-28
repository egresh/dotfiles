#!/usr/bin/env ruby

require 'json'

YABAI = '/opt/homebrew/bin/yabai'.freeze

all_windows = []

displays = JSON
           .parse(`#{YABAI} -m query --displays`)
           .map { |prop| prop['index'] }

displays.each do |display|
  spaces = JSON
           .parse(`#{YABAI} -m query --spaces --display #{display}`)
           .map { |prop| prop['index'] }

  spaces.each do |space|
    windows = JSON.parse(`#{YABAI} -m query --windows --space #{space}`)
    windows.each do |window|
      app   = window['app']
      title = window['title']
      window_id = window['id']

      # next unless app.match(/Microsoft Teams/)

      all_windows.push({ space: space, app: app, title: title, window_id: window_id })
    end
  end
end

exit 0 if ARGV.empty?
app = ARGV.first

w = all_windows.find do |w|
  w[:app].match(/#{app}/i)
end

exit 1 if w.nil?

system("#{YABAI} -m space --focus #{w[:space]}")
system("#{YABAI} -m window --focus #{w[:window_id]}")

# teams = teams_windows.reject! { |t| t[:title].match(/Notification/) }.first

# system("#{YABAI} -m space --focus #{teams[:space]}")
# system("#{YABAI} -m window --focus #{teams[:window_id]}")
