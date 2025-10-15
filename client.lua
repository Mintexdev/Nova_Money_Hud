local Framework = Config.Framework
local PlayerID = GetPlayerServerId(PlayerId())

local ESX, QBCore
local cash, bank = 0, 0

CreateThread(function()
    if Framework == "esx" then
        ESX = exports["es_extended"]:getSharedObject()
        while not ESX.IsPlayerLoaded() do Wait(500) end
    elseif Framework == "qb" then
        QBCore = exports['qb-core']:GetCoreObject()
        while not QBCore.Functions.GetPlayerData().money do Wait(500) end
    end
    UpdateHUD()
    StartAutoRefresh()
end)

function StartAutoRefresh()
    CreateThread(function()
        while true do
            Wait(Config.UpdateInterval)
            UpdateHUD()
        end
    end)
end

function UpdateHUD()
    if Framework == "esx" then
        local playerData = ESX.GetPlayerData()
        cash, bank = 0, 0
        for _, acc in pairs(playerData.accounts) do
            if acc.name == "money" then cash = acc.money end
            if acc.name == "bank" then bank = acc.money end
        end
    elseif Framework == "qb" then
        local playerData = QBCore.Functions.GetPlayerData()
        cash = playerData.money and playerData.money.cash or 0
        bank = playerData.money and playerData.money.bank or 0
    end

    SendNUIMessage({
        action = 'update',
        id = Config.ShowID and PlayerID or nil,
        cash = Config.ShowCash and cash or nil,
        bank = Config.ShowBank and bank or nil,
        config = {
            position = Config.Position,
            background = Config.BackgroundColor,
            border = Config.BorderColors
        }
    })
end

if Framework == "esx" then
    RegisterNetEvent('esx:setAccountMoney', function(account)
        if account.name == 'money' then
            cash = account.money
        elseif account.name == 'bank' then
            bank = account.money
        end
        UpdateHUD()
    end)

    RegisterNetEvent('esx:playerLoaded', function()
        Wait(1000)
        UpdateHUD()
    end)
elseif Framework == "qb" then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        Wait(1000)
        UpdateHUD()
    end)

    RegisterNetEvent('QBCore:Player:SetPlayerData', function()
        UpdateHUD()
    end)
end
