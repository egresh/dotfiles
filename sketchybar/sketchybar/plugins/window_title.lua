#!/usr/bin/env lua

local yabai = require 'yabai'
local bar   = require 'sketchybar'

local item_name       = os.getenv("NAME")
local sender          = os.getenv("SENDER")
local current_program = os.getenv("INFO")

local yabai_label = yabai:getCurrentSpaceLabel()
local item = bar:get_item(item_name)
local font = item.label.font
local text = "spc: " .. yabai_label .. " prg: " .. current_program

print("ITEM " .. item_name)
print("PREOGEAM " .. current_program)
print("YABAI LABEL: " .. yabai_label)
print("TEXT LENGTH: " .. string.len(text))
print(font)


-- item.geometry.width is expressed in points
local _, _, points = string.find(font, ":(%d+)")
print(points)

--[[ local total_characters = item.geometry.width / (points  - 5) ]]

--[[ print("T " .. total_characters) ]]
--[[ local padding = total_characters / 3 ]]

--[[ print(padding) ]]

local new_width = string.len(text) * points
print("NW: " .. new_width)

--[[ local padding = spaces / 2 ]]

--[[ local to_execute = bar.bin .. " --set " .. item_name .. " label=" .. '"' .. text .. '"' .. ]]
--[[                    " label.padding_left=" .. padding .. " label.padding_right=" .. padding ]]
local to_execute = bar.bin .. " --set " .. item_name .. " label=" .. '"' .. text .. '"' ..
    " width=" .. new_width

print(to_execute)
os.execute(to_execute)
