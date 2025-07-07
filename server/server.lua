local QBCore = exports['qb-core']:GetCoreObject()
local Plates = {}

local function isEmpty(s)
    return not not tostring(x):find("^%s*$")
end

-- officers count callback, to obviously get active officers.
QBCore.Functions.CreateCallback('moat-policehub:server:officersCount', function(source, cb)
    local count = 0
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player.PlayerData.job and Player.PlayerData.job.name == "police" then
            count = count + 1
        end
    end
    cb(count)
end)

function getRadioChannel(source)
    return Player(source).state['radioChannel']
end

RegisterServerEvent('moat-policehub:server:getOfficers')
AddEventHandler('moat-policehub:server:getOfficers', function()
    local src = source
    local data = {}

    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(v)
        if Player.PlayerData.job.name == "police" then
            local officerData = {
                status = Player.PlayerData.job.onduty,
                callsign = Player.PlayerData.metadata["callsign"],
                name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                frequency = getRadioChannel(v),
            }

            table.insert(data, officerData)
        end
    end

    TriggerClientEvent('moat-policehub:client:sendOfficersData', src, data, #data)
end)

RegisterServerEvent("moat-policehub:server:checkPlateNumber")
AddEventHandler("moat-policehub:server:checkPlateNumber", function(plateNumber)
    local src = source
    local result = json.decode(LoadResourceFile(GetCurrentResourceName(), "plates.json"))

    if result then
        local plateArray = result[plateNumber]

        if plateArray then
            for _, value in ipairs(plateArray) do
                TriggerClientEvent('QBCore:Notify', src, value, "success")
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "plate is clean!", "success")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "checkPlateNumber: Error decoding file", "success")
        print("error decoding plates.json");
    end
end)

RegisterServerEvent("moat-policehub:server:flagPlateNumber");
AddEventHandler("moat-policehub:server:flagPlateNumber", function(plateNumber, reason)
    if isEmpty(plateNumber) then
        TriggerClientEvent('QBCore:Notify', src, "Plate number cant be empty!", "success")
        return
    end
    if isEmpty(reason) then
        TriggerClientEvent('QBCore:Notify', src, "Reason cant be empty!", "success")
        return
    end

    local src = source
    local result = json.decode(LoadResourceFile(GetCurrentResourceName(), "plates.json"))

    Plates = result

    if not Plates[plateNumber] then
        Plates[plateNumber] = {}
    end

    table.insert(Plates[plateNumber], reason)
    SaveResourceFile(GetCurrentResourceName(), "plates.json", json.encode(Plates))
    TriggerClientEvent('QBCore:Notify', src, plateNumber .. ": " .. reason, "success")
end)


function removePlateFromFile(PlatesList, plateNumber)
    if PlatesList[plateNumber] then
        PlatesList[plateNumber] = nil -- null out the plate
        return true                   -- return success once the plate is removed
    end
    return false                      -- no matching plate found
end

RegisterServerEvent("moat-policehub:server:removeFlagged")
AddEventHandler("moat-policehub:server:removeFlagged", function(plateNumber)
    if isEmpty(plateNumber) then
        TriggerClientEvent('QBCore:Notify', src, "Plate number cant be empty!", "success")
        return
    end
    local src = source
    local result = json.decode(LoadResourceFile(GetCurrentResourceName(), "plates.json"))

    Plates = result

    if removePlateFromFile(Plates, plateNumber) then
        SaveResourceFile(GetCurrentResourceName(), "plates.json", json.encode(Plates))
        TriggerClientEvent('QBCore:Notify', src, "Successfully Removed " .. plateNumber, "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "No Matching plate found for removal.", "error")
    end
end)


RegisterServerEvent("moat-policehub:server:NOTIFY")
AddEventHandler("moat-policehub:server:NOTIFY", function(message, stat)
    local src = source

    TriggerClientEvent('QBCore:Notify', src, message, stat)
end)

RegisterServerEvent("moat-policehub:server:ChangeDuty")
AddEventHandler("moat-policehub:server:ChangeDuty", function(duty)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.SetJobDuty(duty)
    TriggerClientEvent('QBCore:Client:SetDuty', src, duty)
    DutyStat = "Off Duty"
    if duty then
        DutyStat = "On Duty"
    end

    TriggerClientEvent('QBCore:Notify', src, "Changed duty to " .. duty, "success")
end)
