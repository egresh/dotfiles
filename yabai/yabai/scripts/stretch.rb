#!/usr/bin/env ruby
require 'json'

YABAI  = '/usr/local/bin/yabai'.freeze
Window = Struct.new(:x, :y, :w, :h)

def window_settings
  `#{YABAI} -m query --windows --window`
end

def update_to(x: 0, y: 0)
  command = "#{YABAI} -m window --resize left:#{x}:0"
  `#{command}`
  # command = "#{YABAI} -m window --resize right:#{x}:0"
  # `#{command}`
end

settings_before = window_settings
window_1 = Window.new(JSON.parse(settings_before)['frame']['x'],
                      JSON.parse(settings_before)['frame']['y'],
                      JSON.parse(settings_before)['frame']['w'],
                      JSON.parse(settings_before)['frame']['h'])

puts "Starting..."

p window_1
update_to(x: -100)

settings_after = window_settings
window_2 = Window.new(JSON.parse(settings_after)['frame']['x'],
                      JSON.parse(settings_after)['frame']['y'],
                      JSON.parse(settings_after)['frame']['w'],
                      JSON.parse(settings_after)['frame']['h'])

puts "After..."
p window_2

x_diff = window_2.x - window_1.x
w_diff = window_2.w - window_1.w

puts x_diff
puts w_diff
