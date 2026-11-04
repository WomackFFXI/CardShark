_addon.name = 'CardShark'
_addon.author = 'Womack'
_addon.version = '4.4'
_addon.commands = {'cardshark', 'cs'}

require('luau')
local packets = require('packets')
local files = require('files')
local texts = require('texts')
local config = require('config')
local res = require('resources')

-- Default position settings for draggable window
local defaults = {}
defaults.pos = {}
defaults.pos.x = 300
defaults.pos.y = 200
defaults.bg = {}
defaults.bg.alpha = 180
defaults.bg.red = 0
defaults.bg.green = 0
defaults.bg.blue = 0
defaults.text = {}
defaults.text.font = 'Arial'
defaults.text.size = 10
defaults.text.alpha = 255
defaults.padding = 8
defaults.flags = {}
defaults.flags.draggable = true
defaults.flags.bold = true

local settings = config.load(defaults)

-- Create Onscreen Text Window
local display_box = texts.new(settings)

-- Elemental Color Map (RGB Formatting Tags)
local color_map = {
    ['Fire Crest Card'] = '\\cs(255,80,80)', -- Red
    ['Earth Crest Card'] = '\\cs(255,255,100)', -- Yellow
    ['Lightning Crest Card'] = '\\cs(200,100,255)', -- Purple
    ['Wind Crest Card'] = '\\cs(100,255,100)', -- Green
    ['Light Crest Card'] = '\\cs(255,255,255)', -- White
    ['Dark Crest Card'] = '\\cs(160,160,160)', -- Gray / Dark
    ['Water Crest Card'] = '\\cs(80,140,255)', -- Blue
    ['Ice Crest Card'] = '\\cs(130,220,255)' -- Light Blue
}

-- Database storage (saved to CardShark_Data.lua)
local data_file = files.new('CardShark_Data.lua')
local drop_database = {}

if data_file:exists() then
    drop_database = dofile(windower.addon_path .. 'CardShark_Data.lua') or {}
else
    data_file:write('return {}\n')
end

local function save_database()
    local str = 'return {\n'
    for zone, cards in pairs(drop_database) do
        str = str .. string.format(' ["%s"] = {\n', zone)
        for card, mobs in pairs(cards) do
            str = str .. string.format(' ["%s"] = {\n', card)
            for mob_name, _ in pairs(mobs) do
                str = str .. string.format(' ["%s"] = true,\n', mob_name)
            end
            str = str .. ' },\n'
        end
        str = str .. ' },\n'
    end
    str = str .. '}\n'
    data_file:write(str)
end

-- Recent Kill History Queue for Packet Fallback
local recent_kills = {}

local function add_recent_kill(mob_name)
    if not mob_name or mob_name == '' or mob_name == 'Unknown Mob' then return end
    if #recent_kills > 0 and recent_kills[1].name == mob_name and (os.clock() - recent_kills[1].time < 1) then
        return
    end
    table.insert(recent_kills, 1, {name = mob_name, time = os.clock()})
    if #recent_kills > 15 then
        table.remove(recent_kills)
    end
end

local function get_packet_mob()
    if #recent_kills > 0 and (os.clock() - recent_kills[1].time < 12) then
        return recent_kills[1].name
    end
    local current_target = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('st')
    if current_target and current_target.name and current_target.name ~= '' then
        return current_target.name
    end
    return "Unknown Mob"
end

-- Update Draggable Text Window (Grouped Display)
local function update_display()
    local zone_info = windower.ffxi.get_info()
    if not zone_info or not zone_info.zone or not res.zones[zone_info.zone] then 
        display_box:hide()
        return 
    end

    local zone_name = res.zones[zone_info.zone].en
    local zone_data = drop_database[zone_name]

    local text_str = string.format('\\cs(255,215,0)=== CardShark: %s ===\\cr\n', zone_name)

    if not zone_data or next(zone_data) == nil then
        text_str = text_str .. '\\cs(160,160,160)No card drops logged yet.\\cr\n'
    else
        for card, mobs in pairs(zone_data) do
            local color_code = color_map[card] or '\\cs(200,200,200)'
            
            local mob_list = {}
            for mob_name, _ in pairs(mobs) do
                table.insert(mob_list, mob_name)
            end
            table.sort(mob_list)

            local mobs_string = table.concat(mob_list, ', ')
            text_str = text_str .. string.format('%s%-18s\\cr : %s%s\\cr\n', color_code, card, color_code, mobs_string)
        end
    end

    display_box:text(text_str)
    display_box:show()
end

-- Core Data Registration
local function register_drop(zone_name, card_name, mob_name)
    if not card_name or not mob_name or mob_name == '' then return end
    
    drop_database[zone_name] = drop_database[zone_name] or {}
    drop_database[zone_name][card_name] = drop_database[zone_name][card_name] or {}

    if not drop_database[zone_name][card_name][mob_name] then
        drop_database[zone_name][card_name][mob_name] = true
        save_database()
        windower.add_to_chat(207, string.format('[CardShark] NEW DROP LOGGED: %s dropped %s in %s!', mob_name, card_name, zone_name))
    end

    update_display()
end

-- METHOD 1: Direct Chat Log Parser ("You find a [Item] on the [Mob].")
windower.register_event('incoming text', function(original, modified, mode)
    local clean_text = original:strip_format()
    local item_found, mob_found = clean_text:match("You find a ([%a%s]+) on the ([%a%s]+)%.$")
    
    if item_found and mob_found and item_found:find('Crest Card') then
        local zone_info = windower.ffxi.get_info()
        if zone_info and res.zones[zone_info.zone] then
            local zone_name = res.zones[zone_info.zone].en
            register_drop(zone_name, item_found, mob_found)
        end
    end
end)

-- METHOD 2: Network Packet Watcher (0x028 Death Action + 0x020 Item Drop Pool)
windower.register_event('incoming chunk', function(id, data)
    if id == 0x028 then
        local p = packets.parse('incoming', data)
        if p and p.Target and p.Target > 0 then
            if p.Category == 11 or p.Category == 3 or p.Category == 4 or p.Category == 1 then
                local mob = windower.ffxi.get_mob_by_id(p.Target)
                if mob and mob.name and mob.name ~= '' and mob.is_npc then
                    add_recent_kill(mob.name)
                end
            end
        end
    elseif id == 0x020 then
        local p = packets.parse('incoming', data)
        if p then
            local item_id = p['Item']
            if item_id and item_id > 0 then
                local item_info = res.items[item_id]
                if item_info and item_info.en and item_info.en:find('Crest Card') then
                    local card_name = item_info.en
                    local zone_info = windower.ffxi.get_info()
                    local zone_name = (zone_info and res.zones[zone_info.zone]) and res.zones[zone_info.zone].en or "Unknown Zone"
                    local mob_name = get_packet_mob()

                    -- Only register via packet if chat parser didn't already lock it down instantly
                    if mob_name ~= "Unknown Mob" then
                        register_drop(zone_name, card_name, mob_name)
                    end
                end
            end
        end
    end
end)

-- Refresh on Zone Change
windower.register_event('zone change', function(new_zone_id, old_zone_id)
    coroutine.schedule(function()
        update_display()
    end, 3)
end)

windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        update_display()
    end
end)

-- Command Handler
windower.register_event('addon command', function(...)
    local args = {...}
    local cmd = args[1] and args[1]:lower() or nil

    if cmd == 'hide' then
        display_box:hide()
    elseif cmd == 'show' then
        update_display()
    elseif cmd == 'help' then
        windower.add_to_chat(207, '[CardShark] Commands:')
        windower.add_to_chat(207, ' //cs show - Displays the window')
        windower.add_to_chat(207, ' //cs hide - Hides the window')
    else
        update_display()
    end
end)
