-- Default values
itemid = 5640  -- Magplant Remote (default)
far = 5        -- Jarak default

delay = 50

function toBool(v)
    return v == true or v == "true" or v == 1 or v == "1"
end

running = false
protect = 1
autocheat = false
IsLeft = false

local json = [[
{
  "sub_name": "PNB MODULE",
  "icon": "Settings",
  "menu": [
   {"type":"label","text":"SC INI DI LENGKAPI DENGAN PROTECTOR"},
   {"type":"label","text":"============================="},
   
   {"type":"label","text":"=== KONFIGURASI ITEM ==="},
   {"type":"input_int","text":"Item ID","alias":"itemid","default":"5640"},
   {"type":"input_int","text":"Jarak (far)","alias":"far","default":"3"},
   {"type":"input_int","text":"delay (Ms)","alias":"delays","default":"50"},
   
   {"type":"label","text":"=== KONTROL POSISI ==="},
   {"type":"toggle","text":"posisi kanan/kiri","alias":"posisi","default":false},
   {"type":"label","text":"jika On = kiri / Off = kanan"},
   
   {"type":"label","text":"=== FITUR KEAMANAN ==="},
   {"type":"toggle","text":"AutoCheat If Player Enter","alias":"autocheat","default":false},
   
   {"type":"label","text":"============================="},
   {"type":"toggle_button","text":"Start","alias":"autowork"}
  ]
}
]]

addIntoModule(json)

AddHook(function(t, n, v)
    if n == "autowork" then
        running = toBool(v)
    elseif n == "posisi" then
        IsLeft = toBool(v)
    elseif n == "autocheat" then
        autocheat = toBool(v)
    elseif n == "itemid" then
        itemid = tonumber(v) or 5640
        LogToConsole("`g[Config]`7 Item ID diubah: " .. itemid)
    elseif n == "far" then
        far = tonumber(v) or 3
        LogToConsole("`g[Config]`7 Jarak (far) diubah: " .. far)
    elseif n == "delays" then
        delay = tonumber(v) or 50
    end
end, "onValue")

EditToggle("Antilag", true)
EditToggle("No Particle", true)
Sleep(200)

function cheato()
   
    sendPacket(2,
        "action|dialog_return\n"..
        "dialog_name|cheats\n"..
        "itemid|" .. itemid .. "\n"..
        "slot|" .. far .. "\n"..
        "checkbox_cheat_autofish|0\n"..
        "checkbox_cheat_antibounce|0\n"..
        "checkbox_cheat_speed|0\n"..
        "checkbox_cheat_double_jump|0\n"..
        "checkbox_cheat_jump|0\n"..
        "checkbox_cheat_heat_resist|0\n"..
        "checkbox_cheat_strong_punch|0\n"..
        "checkbox_cheat_long_punch|0\n"..
        "checkbox_cheat_long_build|0\n"..
        "checkbox_cheat_autocollect|1\n"..
        "checkbox_cheat_fastpull|0\n"..
        "checkbox_cheat_fastdrop|0\n"..
        "checkbox_cheat_fasttrash|0\n"..
        "chat|"
    )
 
    
    sleep(400)
    
    local me = GetLocal()
    if me then
        print(">>> Player ditemukan: " .. me.name)
        
        local tileX = math.floor(me.posX / 32)
        local tileY = math.floor(me.posY / 32)
        local targetX = me.isLeft and (tileX - 1) or (tileX + 1)

        
   local pkt = {
        x = tileX * 32,
        y = tileY * 32,
        px = tileX,
        py = tileY,
        type = 3,
        value = itemid
    }
    SendPacketRaw(false, pkt)
    
    end
end

AddHook(function(ev)
    if autocheat then
        if ev.v1 == "OnSpawn" then
            local data = ev.v2 or ""
            if data:find("spawn|avatar") then
                protect = protect + 1
                running = false
cheato()
                LogToConsole("player di World : "..protect)
            end
        end

        if ev.v1 == "OnRemove" then
            if protect > 1 then
                protect = protect - 1
                LogToConsole("Player Keluar : "..protect)
            end

            if protect == 1 then
                running = true
                LogToConsole("`9player keluar, autowork lanjut")
            else
                LogToConsole("player masih ada : "..protect)
            end
        end
    end
    
    if ev.v1 == "OnTalkBubble" then
        local msg = string.lower(ev.v3 or "")
        if msg:find("empty") then
            if running then
                running = false
                LogToConsole("`2Empty MagPlant")
            end
        end
    end
end, "OnVariant")

function place(x, y)
    local pkt = {
        x = x * 32,
        y = y * 32,
        px = x,
        py = y,
        type = 3,
        value = itemid
    }
    SendPacketRaw(false, pkt)
end

function punch(x, y)
    local pkt = {
        x = x * 32,
        y = y * 32,
        px = x,
        py = y,
        type = 3,
        value = 18
    }
    SendPacketRaw(false, pkt)
end

function autoWork()
    while true do
        if running then
            local me = GetLocal()
            if me then
                local playerTileX = math.floor(me.posX / 32)
                local playerTileY = math.floor(me.posY / 32)
                
                local startX
                if IsLeft then
                    startX = playerTileX - 1
                else
                    startX = playerTileX + 1
                end
                
                for i = 1, far do
                    local targetX
                    if IsLeft then
                        targetX = startX - (i - 1)
                    else
                        targetX = startX + (i - 1)
                    end
                    place(targetX, playerTileY)
                end
                
                Sleep(delay)
                
                for i = 1, far do
                    local targetX
                    if IsLeft then
                        targetX = startX - (i - 1)
                    else
                        targetX = startX + (i - 1)
                    end
                    punch(targetX, playerTileY)
                end
                
                Sleep(delay)
            else
                Sleep(100)
            end
        else
            Sleep(100)
        end
    end
end

runThread(autoWork)
