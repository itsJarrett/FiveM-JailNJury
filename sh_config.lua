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

JailConfig = {}
JailConfig = setmetatable(JailConfig, {})

jurors = {}
jailedPlayers = {}
JailConfig.jailFile = "jailed.json"

JailConfig.stateName = "San Andreas"

JailConfig.policePeds = {
  "s_m_y_hwaycop_01",
  "s_m_y_sheriff_01",
  "s_m_y_swat_01",
  "s_m_y_cop_01"
}

JailConfig.courtStartTime = 5

JailConfig.courtEntraceLocation = { x = 237.55, y = -406.18, z = 47.59 }
JailConfig.defendantLocation = { x = 218.19, y = -424.23, z = 55.677, h = 165.24 }
JailConfig.jurorLocations = {
  { x = 218.25, y = -429.33, z = 55.677, h = 337.87 },
  { x = 217.30, y = -428.98, z = 55.677, h = 337.87 },
  { x = 216.62, y = -428.70, z = 55.677, h = 337.87 },
  { x = 215.94, y = -428.47, z = 55.677, h = 337.87 },
  { x = 214.90, y = -428.11, z = 55.677, h = 348.87 }
}
JailConfig.prisonLocation = { x = 1727.49, y = 2538.06, z = 44.94 }
JailConfig.prisonEntraceLocation = { x = 1854.42, y = 2586.12, z = 45.05}

function shuffle(tbl)
  size = #tbl
  for i = size, 1, -1 do
    local rand = math.random(i)
    tbl[i], tbl[rand] = tbl[rand], tbl[i]
  end
  return tbl
end

function getPlayerID(source)
  local identifiers = GetPlayerIdentifiers(source)
  local player = getIdentifiant(identifiers)
  return player
end

function getIdentifiant(id)
    for _, v in ipairs(id) do
        return v
    end
end

function isPolice(modelHash)
  for i, policePed in ipairs(JailConfig.policePeds) do
    if modelHash == GetHashKey(policePed) then
      return true
    end
  end
  return false
end

function isJailed(permId)
  for i, jailedPlayer in ipairs(jailedPlayers) do
    if permId == jailedPlayer[1] then
      return jailedPlayer
    end
  end
  return false
end

function updateJailTime(permId, newTime)
  for i, jailedPlayer in ipairs(jailedPlayers) do
    if permId == jailedPlayer[1] then
      jailedPlayer[2] = newTime
    end
  end
end

function removedJailedPlayer(permId)
  for i, jailedPlayer in ipairs(jailedPlayers) do
    if permId == jailedPlayer[1] then
      table.remove(jailedPlayers, i)
    end
  end
end

function updateTrialRequest(permId, boolean)
  for i, jailedPlayer in ipairs(jailedPlayers) do
    if permId == jailedPlayer[1] then
      jailedPlayer[4] = boolean
    end
  end
end

function getJuror()
  shuffle(jurors)
  return jurors[1]
end

function inJurorPool(id)
  for i, juror in ipairs(jurors) do
    if id == juror then
      return true
    end
  end
  return false
end

function removeJuror(id)
  for i, juror in ipairs(jurors) do
    if id == juror then
      jurors[i] = nil
    end
  end
end
