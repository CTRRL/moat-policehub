local QBCore = exports['qb-core']:GetCoreObject()
local isOpened = false;

local function toggleNuiFrame(shouldShow)
  SetNuiFocus(shouldShow, shouldShow)
  SendReactMessage('setVisible', shouldShow)
end

local function toggleNuiFrameNoFocus(shouldShow)
  SendReactMessage('setVisible', shouldShow)
end

RegisterNUICallback('hideFrame', function(_, cb)
  toggleNuiFrame(false)
  isOpened = false;
  cb({})
end)

RegisterNUICallback('showMDT', function(_, cb)
  SetNuiFocus(false, false)
  TriggerServerEvent('mdt:server:openMDT') -- change this if needed
  cb({})
end)

RegisterKeyMapping("+dragPolicehub", "Drag moat-policehub UI", "keyboard", "i")

RegisterCommand("+dragPolicehub", function()
  local PlayerData = QBCore.Functions.GetPlayerData()
  local playerJob = PlayerData.job.name
  if playerJob == "police" then
    if isOpened then
      toggleNuiFrame(true)
      SendReactMessage('setDraggable', true)
      isOpened = true;
    else
      toggleNuiFrame(true)
      SendReactMessage('setDraggable', true)
      isOpened = true;
    end
  end
end)

RegisterKeyMapping("policehub-open", "Toggle moat-policehub", "keyboard", "l")
RegisterCommand('policehub-open', function()
  local PlayerData = QBCore.Functions.GetPlayerData()
  local playerJob = PlayerData.job.name
  if playerJob == "police" then
    if not isOpened then
      toggleNuiFrameNoFocus(true)
      TriggerServerEvent('moat-policehub:server:getOfficers');
      isOpened = true;
    else
      toggleNuiFrameNoFocus(false)
      isOpened = false;
    end
  end
end)

RegisterNUICallback('SetFocus', function(data, cb)
  SetNuiFocus(data.Focus, data.Focus)
end)

RegisterNUICallback('getOfficers', function(data, cb)
  QBCore.Functions.TriggerCallback('moat-policehub:server:officersCount', function(Count)
    local retData <const> = { count = Count }
    cb(retData)
  end)
end)

RegisterNUICallback('getDuty', function(data, cb)
  local Status = ""
  Player = QBCore.Functions.GetPlayerData()

  if Player.job.onduty then
    Status = "#3FD13C"
  else
    Status = "#C53830"
  end

  cb(Status)
end)

RegisterNetEvent('moat-policehub:client:sendOfficersData')
AddEventHandler('moat-policehub:client:sendOfficersData', function(officers, officersCount)
  local Status = ""
  Player = QBCore.Functions.GetPlayerData()

  if Player.job.onduty then
    Status = "#3FD13C"
  else
    Status = "#C53830"
  end

  SendReactMessage('officersData', { officers = officers })
  SendReactMessage('getOfficers', { count = officersCount })
  SendReactMessage('getDuty', { status = Status })
end)

RegisterNUICallback('checkPlateNumber', function(data, cb)
  TriggerServerEvent("moat-policehub:server:checkPlateNumber", data.plate);
end)

RegisterNUICallback('flagPlateNumber', function(data)
  TriggerServerEvent("moat-policehub:server:flagPlateNumber", data.plate, data.reason);
end)

RegisterNUICallback('removePlateNumber', function(data)
  TriggerServerEvent("moat-policehub:server:removeFlagged", data.plate, data.reason);
end)

CreateThread(function()
  while true do
    TriggerServerEvent("moat-policehub:server:getOfficers")
    Wait(500)
  end
end)

-- in-real time data update
RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(jobInfo)
  if isOpened then
    Player = QBCore.Functions.GetPlayerData()
    if Player.job.name ~= "police" then
      SendReactMessage('setDraggable', false)
      toggleNuiFrame(false)
      isOpened = false;
    end
  end

  -- we already have a while loop thread, No?
  -- TriggerServerEvent("moat-policehub:server:getOfficers")
end)

RegisterNUICallback('changeOfficerDuty', function(data, cb)
  TriggerServerEvent("moat-policehub:server:ChangeDuty", data.duty)
  cb({})
end)

RegisterNUICallback('changeCallSign', function(data, cb)
  TriggerServerEvent("QBCore:Server:SetMetaData", "callsign", data.callsign)
  TriggerServerEvent('moat-policehub:server:NOTIFY', "Changed callsign sucessfully to " .. data.callsign, "success")

  cb({})
end)
