#!/usr/bin/env bash

sudo apt install mpv
mkdir ~/.config/mpv && mkdir ~/.config/mpv/scripts || echo "Directory already exist"
echo  "mp.add_periodic_timer(1/30, function()
    local time_pos = mp.get_property_number("time-pos", 0)
    local hours = math.floor(time_pos / 3600)
    local minutes = math.floor((time_pos % 3600) / 60)
    local seconds = math.floor(time_pos % 60)
    local milliseconds = math.floor((time_pos * 1000) % 1000)
    local time_str = string.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
    local seconds_str = string.format("%.3f", time_pos)
    
    local frame = mp.get_property_number("estimated-frame-number", 0)
    mp.osd_message("Time: " .. time_str .. "\nFrame: " .. frame .. "\ntime(s):" .. seconds_str, 0.1)
end)" > ~/.config/mpv/scripts/timeNframenumber.lua
