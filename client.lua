local isDead = false

-- 死亡イベント（baseevents 使用）
AddEventHandler('baseevents:onPlayerDied', function()
    HandlePlayerDeathInHeli()
end)

function HandlePlayerDeathInHeli()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if not DoesEntityExist(vehicle) then return end
    if GetPedInVehicleSeat(vehicle, -1) ~= playerPed then return end -- パイロットのみ
    
    local model = GetEntityModel(vehicle)
    if not IsThisModelAHeli(model) then
        return
    end

    Citizen.CreateThread(function()
        -- エンジン強制停止
        SetVehicleEngineOn(vehicle, false, true, true)
        SetVehicleEngineHealth(vehicle, -100.0)
        SetHeliBladesSpeed(vehicle, 0.0)
        
        local descentSpeed = 0.0
        local maxIterations = 300
        
        for i = 1, maxIterations do
            if not DoesEntityExist(vehicle) then break end
            
            local coords = GetEntityCoords(vehicle)
            if coords.z > 5.0 then
                descentSpeed = math.min(descentSpeed + 0.018, 1.8)
                SetEntityVelocity(vehicle, 0.0, 0.0, -descentSpeed)
            else
                SetVehicleOnGroundProperly(vehicle)
                break
            end
            Citizen.Wait(40)
        end
        SetVehicleEngineOn(vehicle, false, true, true)
    end)
end