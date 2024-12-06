local memory = require "memory"
local ban = false
local cam = false
local gem = false
local badabum = false
local act = false
local run = false
local limit = nil

function main()  
    while not isSampAvailable() do wait(100) end 

    sampRegisterChatCommand("rzdbot", function() 
        act = not act 
        sampAddChatMessage(act and "{8B00FF}[RZDBot]{E6A8D7} Бот подключился к игре и принял задачу..." or "{8B00FF}[RZDBot]{E6A8D7} Вы успешно выключили бота!" ) 
    end)

    -- Добавление команды /rzdmenu
    sampRegisterChatCommand("rzdmenu", function() 
        sampAddChatMessage("{8B00FF}[RZDBotMenu]{E6A8D7} Доступные команды:   /rzdbot - вкл\выкл бота,   /rzdmenu - открывет меню бота,   /rzdinfo - информация") 
    end)

    -- Добавление команды /rzdinfo
    sampRegisterChatCommand("rzdinfo", function() 
        sampAddChatMessage("{8B00FF}[RZDBotMenu]{E6A8D7} Создано\by - RsaN1T?,  daniilberzh |  Последнее обновление: 06.12.2024") 
    end)

    while true do wait(0)
        if run then
            runToPoint(260.56005859375, 116.55545806885)
            runToPoint(246.60028076172, 116.64780426025)
            runToPoint(245.62966918945, 112.46089172363)  
            run = false
        end
        if act then
            if badabum == true then
                setVirtualKeyDown(72, true)
                wait(300)
                setVirtualKeyDown(72, false)
            end 
            if isCharInAnyCar(PLAYER_PED) then  
                local posX, posY, posZ = getCharCoordinates(PLAYER_PED)
                local result, x, y, z = SearchMarker(posX, posY, posZ, 1000.0, true)
                local distance = getDistanceBetweenCoords3d(posX, posY, posZ, x, y, z)
                local vehicle = storeCarCharIsInNoSave(PLAYER_PED)
                local speed = getCarSpeed(vehicle) * 3.6
                if ban == true and speed < 160 then
                    setGameKeyState(14, -255)
                    local addres = getCarPointer(vehicle) + 0x05A4
                    local speeD = memory.getfloat(addres, true)
                    memory.setfloat(addres, speeD + 0.00000001, true)
                elseif gem == true and speed ~= 0 then
                    local addres = getCarPointer(vehicle) + 0x05A4
                    local speeD = memory.getfloat(addres, true)
                    memory.setfloat(addres, speeD / 1.07, true)
                end
                if cam == true and speed > 60 then
                    local addres = getCarPointer(vehicle) + 0x05A4
                    local speeD = memory.getfloat(addres, true)
                    memory.setfloat(addres, speeD / 1.01, true)
                elseif speed < 60 and cam == true then
                    setGameKeyState(14, -255)
                    local addres = getCarPointer(vehicle) + 0x05A4
                    local speeD = memory.getfloat(addres, true)
                    memory.setfloat(addres, speeD + 0.00000001, true)
                end
            end
        end
    end
end

function onReceivePacket(id, bs)  
    if id == 220 then
        raknetBitStreamIgnoreBits(bs, 8)
        if (raknetBitStreamReadInt8(bs) == 17) then
            raknetBitStreamIgnoreBits(bs, 32)
            local str = raknetBitStreamReadString(bs, raknetBitStreamReadInt32(bs))
            if act then
                if str:find('vue%.c') and str:find("railway/updateStats") then
                    sendClick(("@13, start, 2, 1"))
                end
                if str:find("vue%.c") and str:find('railway/showNotification') and str:find("Требуется предупредительный сигнал") then
                    badabum = true
                else 
                    badabum = false 
                end
                if str:find("vue%.c") and str:find('railway/showNotification') and str:find('Снизьте скорость') then  
                    ban = false
                    gem = false
                    cam = true
                end
                if str:find("vue%.c") and str:find("railway/showNotification") and str:find("следующей станции") then
                    cam = false
                    gem = false
                    ban = true
                end
                if str:find("window.executeEvent") and str:find("cef.addNotification") and str:find("Вы заработали") then 
                    run = true
                end
                if str:find("vue%.c") and str:find("railway/showNotification") and str:find("остановитесь") then
                    cam = false
                    ban = false
                    gem = true 
                end
            end
        end
    end
end

function sendClick(str)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220) -- packet id
    raknetBitStreamWriteInt8(bs, 18) -- packet type
    raknetBitStreamWriteInt8(bs, #str) -- str len
    raknetBitStreamWriteInt8(bs, 0)
    raknetBitStreamWriteInt8(bs, 0)
    raknetBitStreamWriteInt8(bs, 0)
    raknetBitStreamWriteString(bs, str)
    raknetBitStreamWriteInt32(bs, 0)
    raknetBitStreamWriteInt8(bs, 0)
    raknetBitStreamWriteInt8(bs, 0)
    raknetSendBitStreamEx(bs, 2, 9, 6)
    raknetDeleteBitStream(bs)
end

function SearchMarker(posX, posY, posZ, radius, isRace)
    local ret_posX = 0.0
    local ret_posY = 0.0
    local ret_posZ = 0.0
    local isFind = false

    for id = 0, 31 do
        local MarkerStruct = 0
        if isRace then 
            MarkerStruct = 0xC7F168 + id * 56
        else 
            MarkerStruct = 0xC7DD88 + id * 160 
        end
        local MarkerPosX = representIntAsFloat(readMemory(MarkerStruct + 0, 4, false))
        local MarkerPosY = representIntAsFloat(readMemory(MarkerStruct + 4, 4, false))
        local MarkerPosZ = representIntAsFloat(readMemory(MarkerStruct + 8, 4, false))

        if MarkerPosX ~= 0.0 or MarkerPosY ~= 0.0 or MarkerPosZ ~= 0.0 then
            if getDistanceBetweenCoords3d(MarkerPosX, MarkerPosY, MarkerPosZ, posX, posY, posZ) < radius then
                ret_posX = MarkerPosX
                ret_posY = MarkerPosY
                ret_posZ = MarkerPosZ
                isFind = true
                radius = getDistanceBetweenCoords3d(MarkerPosX, MarkerPosY, MarkerPosZ, posX, posY, posZ)
            end
        end
    end  
    return isFind, ret_posX, ret_posY, ret_posZ
end

function runToPoint(tox, toy)
    local x, y, z = getCharCoordinates(PLAYER_PED)
    local angle = getHeadingFromVector2d(tox - x, toy - y)
    local xAngle = math.random(-50, 50) / 100
    setCameraPositionUnfixed(xAngle, math.rad(angle - 90))
    stopRun = false
    while getDistanceBetweenCoords2d(x, y, tox, toy) > 0.8 do
        setGameKeyState(1, -255)
        wait(1)
        x, y, z = getCharCoordinates(PLAYER_PED)
        angle = getHeadingFromVector2d(tox - x, toy - y)
        setCameraPositionUnfixed(xAngle, math.rad(angle - 90))
        if stopRun then
            stopRun = false
            break
        end
    end
end
