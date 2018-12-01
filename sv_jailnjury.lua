--[[
FiveM-JailNJury
A Jail and Justice System that gives power back to the players.
Copyright (C) 2018  Jarrett Boice

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

local jailed_file = LoadResourceFile(GetCurrentResourceName(), JailConfig.jailFile)
jailedPlayers = json.decode(jailed_file)

local votes = 0
local votesNeeded = 2
local timeToVerdict = false

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    Citizen.Wait(1000 * 60)
    SaveResourceFile(GetCurrentResourceName(), JailConfig.jailFile, json.encode(jailedPlayers), -1)
  end
end)

Citizen.CreateThread(function()
  Citizen.Wait(0)
  RegisterCommand("requesttrial", function(source, args, rawCommand)
    local _source = source
    local targetPedPermId = getPlayerID(_source)
    local isJailedInfo = isJailed(targetPedPermId)
    if isJailedInfo then
      local jailedTime = isJailedInfo[2]
      local jailedCharges = isJailedInfo[3]
      local hasRequestedTrial = isJailedInfo[4]
      TriggerClientEvent("chatMessage", _source, "^1Requesting a trial... Please Wait...")
      Citizen.Wait(math.random(5000, 15000))
      if jailedTime >= 10 and hasRequestedTrial ~= true then
        updateTrialRequest(targetPedPermId, true)
        TriggerClientEvent("chatMessage", _source, "^1Your request for trial has been approved, and your jail time has been paused... The court case will start soon...")
        TriggerClientEvent("chatMessage", _source, "^1Once the court case starts, you will have 1 minutes to explain your charge(s) to the jury: ^2" .. jailedCharges .. "^1.")
        TriggerClientEvent("chatMessage", -1, "^1Jurors are needed at the courthouse for a court case. Be there within " .. JailConfig.courtStartTime .. "  minutes to enter the juror pool.")
        TriggerClientEvent("jnj:courtCaseStatus", _source, true)
        TriggerClientEvent("jnj:courtCaseStatusAll", -1, true)
        Citizen.Wait(1000 * 60 * 5)
        TriggerEvent("jnj:startCourtCase", _source)
      else
        TriggerClientEvent("chatMessage", _source, "^1Your request for trial has been disapproved.")
      end
    else
      TriggerClientEvent("chatMessage", _source, "^1You are not in jail, so you may not request a trial.")
    end
  end)
end)

RegisterCommand("jurorverdict", function(source, args, rawCommand)
  local _source = source
  local isJuror = inJurorPool(_source)
  local vote = string.lower(tostring(args[1]))
  if isJuror and timeToVerdict then
    if vote == "yes" then
      TriggerClientEvent("chatMessage", _source, "^1You have casted your descision. A verdict will be reached soon...")
    elseif vote == "no" then
      votes = votes + 1
      TriggerClientEvent("chatMessage", _source, "^1You have casted your descision. A verdict will be reached soon...")
    else
      TriggerClientEvent("chatMessage", _source, "^1You have not placed your descision correctly. Vote ^2yes ^1for ^2guilty, vote ^2no ^1for ^2not guilty^1. Correct syntax: ^2/jurorverdict yes/no")
    end
  elseif not isJuror then
    TriggerClientEvent("chatMessage", _source, "^1You are not a juror.")
  elseif not timeToVerdict then
    TriggerClientEvent("chatMessage", _source, "^1It is not time to reach a verdict.")
  end
end)

RegisterServerEvent("jnj:sendToJail")
AddEventHandler("jnj:sendToJail", function(targetPedId, jailTime, jailCharges)
  local _source = source
  if not GetPlayerName(targetPedId) then
    TriggerClientEvent("chatMessage", _source, "^2" .. targetPedId .. " ^1is an invalid player ID.")
  elseif isJailed(getPlayerID(targetPedId)) then
    local targetPedName = GetPlayerName(targetPedId)
    TriggerClientEvent("chatMessage", _source, "^2" .. targetPedName .. " ^1is already in jail.")
  else
    local officerName = GetPlayerName(_source)
    local targetPedName = GetPlayerName(targetPedId)
    local targetPedPermId = getPlayerID(targetPedId)
    table.insert(jailedPlayers, {targetPedPermId, jailTime, jailCharges, false})
    TriggerClientEvent("jnj:sendToJail", targetPedId, {jailTime, jailCharges, false})
    TriggerClientEvent("chatMessage", -1, "^2" .. officerName .. " ^1jailed ^2" .. targetPedName .. " ^1for ^2" .. jailTime .. " ^1minutes.")
  end
end)

RegisterServerEvent("jnj:releaseFromJail")
AddEventHandler("jnj:releaseFromJail", function(targetPedId)
  local _source = source
  if not GetPlayerName(targetPedId) then
    TriggerClientEvent("chatMessage", _source, "^2" .. targetPedId .. " ^1is an invalid player ID.")
  elseif isJailed(getPlayerID(targetPedId)) then
    local targetPedPermId = getPlayerID(targetPedId)
    local targetPedName = GetPlayerName(targetPedId)
    TriggerClientEvent("chatMessage", -1, "^2" .. targetPedName .. " ^1has finished their sentence and has been released from jail.")
    removedJailedPlayer(targetPedPermId)
    TriggerClientEvent("jnj:releaseFromJail", targetPedId)
  else
    TriggerClientEvent("chatMessage", _source, "^2" .. GetPlayerName(targetPedId) .. " ^1is not in jail.")
  end
end)

RegisterServerEvent("jnj:updateJailTime")
AddEventHandler("jnj:updateJailTime", function(newJailTime)
  local _source = source
  local targetPedPermId = getPlayerID(_source)
  updateJailTime(targetPedPermId, newJailTime)
end)

RegisterServerEvent("jnj:checkJailed")
AddEventHandler("jnj:checkJailed", function(newJailTime)
  local _source = source
  local targetPedPermId = getPlayerID(_source)
  local isJailedInfo = isJailed(targetPedPermId)
  if isJailedInfo then
    local jailTime = isJailedInfo[2]
    local jailCharges = isJailedInfo[3]
    TriggerClientEvent("jnj:sendToJail", _source, {jailTime, jailCharges})
    TriggerClientEvent("chatMessage", _source, "^1Welcome back. You have resumed your jail sentence at ^2" .. isJailedInfo[2] .. " ^1Minutes.")
  end
end)

Citizen.CreateThread(function()
  Citizen.Wait(0)
  RegisterServerEvent("jnj:startCourtCase")
  AddEventHandler("jnj:startCourtCase", function(targetPedId)
    local targetPedPermId = getPlayerID(targetPedId)
    local isJailedInfo = isJailed(targetPedPermId)
    local playerCount = #GetPlayers()
    local targetPedName = GetPlayerName(targetPedId)
    local jailTime = isJailedInfo[2]
    local jailCharges = isJailedInfo[3]
    if #jurors < 3 then
      jurors = {}
      TriggerClientEvent("jnj:courtCaseStatus", targetPedPermId, false)
      TriggerClientEvent("jnj:courtCaseStatusAll", -1, false)
      TriggerClientEvent("chatMessage", -1, "^1The court case has been cancelled due to juror availability.")
    else
      local jurorNumber = 3
      if playerCount >= 5 then
        jurorNumber = 5
        votesNeeded = 3
      end
      local confirmedJurors = {}
      for i = 1, jurorNumber do
        local juror = getJuror()
        table.insert(confirmedJurors, juror)
        TriggerClientEvent("chatMessage", juror, "^1You have been selected to participate in the jury for the court case. It will be starting soon...")
      end
      for i, unconfirmedJuror in ipairs(jurors) do
        TriggerClientEvent("chatMessage", unconfirmedJuror, "^1You have not made the final selection of the jury. You may now leave the courthouse.")
      end
      for i, juror in ipairs(confirmedJurors) do
        TriggerClientEvent("chatMessage", juror, "^2" .. targetPedName .. " ^1has been arrested for the following charge(s): ^2" .. jailCharges ..
        "^1, amounting to a total time of ^2" .. jailTime .. " ^1minutes. The arestee has requested a trial. You and the other jurors must reach a verdict to find the arestee ^2guilty ^1or ^2not guity^1.")
        TriggerClientEvent("chatMessage", juror, "^1The arestee will have 1 minute to explain their charges. You will not be able to comminucate with the jury or the arestee during this time." ..
        "Once the arestee has explained their charges, you will deliberate with the rest of the jurors for 1 minute.")
        TriggerClientEvent("jnj:teleportToCourt", juror, true, JailConfig.jurorLocations[i])
      end
      TriggerClientEvent("jnj:teleportToCourt", targetPedId, true, JailConfig.defendantLocation)
      Citizen.Wait(5000)
      for i, juror in ipairs(confirmedJurors) do
        TriggerClientEvent("chatMessage", juror, "^1The arestee will now explain the charges.")
      end
      TriggerClientEvent("jnj:teleportToCourt", targetPedId, false, JailConfig.defendantLocation)
      TriggerClientEvent("chatMessage", targetPedId, "^1The jury is ready to hear your explanation.")
      Citizen.Wait(1000 * 30)
      TriggerClientEvent("chatMessage", targetPedId, "^1You have 30 seconds left for your explaination.")
      Citizen.Wait(1000 * 30)
      TriggerClientEvent("jnj:teleportAwayCourt", targetPedId, JailConfig.prisonLocation)
      TriggerClientEvent("chatMessage", targetPedId, "^1The jury will now deliberate...")
      for i, juror in ipairs(confirmedJurors) do
        TriggerClientEvent("jnj:teleportToCourt", juror, false, JailConfig.jurorLocations[i])
        TriggerClientEvent("chatMessage", juror, "^1You must now deliberate for 1 minute with the rest of the jurors and reach a verdict.")
      end
      Citizen.Wait(1000 * 30)
      for i, juror in ipairs(confirmedJurors) do
        TriggerClientEvent("chatMessage", juror, "^1You have 30 seconds left to reach a verdict.")
      end
      Citizen.Wait(1000 * 30)
      timeToVerdict = true
      for i, juror in ipairs(confirmedJurors) do
        TriggerClientEvent("jnj:teleportToCourt", juror, true, JailConfig.jurorLocations[i])
        TriggerClientEvent("chatMessage", juror, "^1You must now cast your verdict.")
        TriggerClientEvent("chatMessage", juror, "^2/jurorverdict yes ^1 for ^2guilty^1.")
        TriggerClientEvent("chatMessage", juror, "^2/jurorverdict no ^1 for ^2not guilty^1.")
        TriggerClientEvent("chatMessage", juror, "^1You have 30 seconds to cast your verdict.")
      end
      Citizen.Wait(1000 * 30)
      timeToVerdict = false
      for i, juror in ipairs(confirmedJurors) do
        TriggerClientEvent("jnj:teleportAwayCourt", juror, JailConfig.courtEntraceLocation)
        TriggerClientEvent("chatMessage", juror, "^1Thank you for participating in our great justice system.")
      end
      if votes >= votesNeeded then
        TriggerEvent("jnj:releaseFromJail", targetPedId)
        TriggerClientEvent("chatMessage", -1, "^1In the case of ^2" .. targetPedName .. " ^1vs. the people of ^2" .. JailConfig.stateName ..
        " ^1the jury has found ^2" .. targetPedName .. " ^2not guilty ^1of all charges.")
      else
        TriggerClientEvent("chatMessage", -1, "^1In the case of ^2" .. targetPedName .. " ^1vs. the people of ^2" .. JailConfig.stateName ..
        " ^1the jury has found ^2" .. targetPedName .. " ^2guilty ^1of all charges.")
      end
      TriggerClientEvent("jnj:courtCaseStatusAll", -1, false)
      jurors = {}
    end
  end)
end)

RegisterServerEvent("jnj:requestJuror")
AddEventHandler("jnj:requestJuror", function(insideRange)
  local _source = source
  local targetPedPermId = getPlayerID(_source)
  local isJailedInfo = isJailed(targetPedPermId)
  if not isJailedInfo then
    if inJurorPool(_source) then
      removeJuror(_source)
      TriggerClientEvent("chatMessage", _source, "^1You been removed from the juror pool.")
    elseif not inJurorPool(_source) and insideRange then
      table.insert(jurors, _source)
      TriggerClientEvent("chatMessage", _source, "^1You have entered the juror pool. You will be notified soon if you will make it through the selection process. Do not leave the courthouse.")
    end
  end
end)
