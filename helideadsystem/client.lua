local isDead = false

-- 死亡検知（baseevents または ESX/QB 対応）
AddEventHandler('baseevents:onPlayerDied', function()
    HandlePlayerDeathInHeli()
end)

-- 定期チェック（保険用）
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local playerPed = PlayerPedId()
        if IsEntityDead(playerPed) and not isDead then
            isDead = true
            HandlePlayerDeathInHeli()
        elseif not IsEntityDead(playerPed) then
            isDead = false
        end
    end
end)

function HandlePlayerDeathInHeli()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if not DoesEntityExist(vehicle) or not IsThisModelAHeli(GetEntityModel(vehicle)) then
        return
    end

    -- ドライバー（パイロット）だった場合の処理
    if GetPedInVehicleSeat(vehicle, -1) == playerPed then
        Citizen.CreateThread(function()
            -- エンジン強制停止
            SetVehicleEngineOn(vehicle, false, true, true)
            SetVehicleEngineHealth(vehicle, -100.0)  -- エンジン破損
            SetHeliBladesSpeed(vehicle, 0.0)         -- ローター速度を0に
            
            -- 自然下降（徐々に沈む）
            local descentSpeed = 0.0
            for i = 1, 300 do  -- 約15秒程度制御
                if not DoesEntityExist(vehicle) then break end
                
                local coords = GetEntityCoords(vehicle)
                local height = coords.z
                
                -- 地面に近づくまで徐々に下降
                if height > 5.0 then
                    descentSpeed = math.min(descentSpeed + 0.015, 1.5)  -- 徐々に加速
                    SetEntityVelocity(vehicle, 0.0, 0.0, -descentSpeed)
                    
                    -- 軽く回転を加えてリアリティ（オプション）
                    if math.random(1, 10) == 1 then
                        SetEntityAngularVelocity(vehicle, 0.0, 0.0, 0.3)
                    end
                else
                    SetVehicleOnGroundProperly(vehicle)
                    break
                end
                
                Citizen.Wait(50)
            end
            
            -- 最終的にエンジン完全オフ
            SetVehicleEngineOn(vehicle, false, false, false)
        end)
    end
end

-- モデルがヘリかどうかチェック
function IsThisModelAHeli(modelHash)
    return IsThisModelAHeli(modelHash)  -- ネイティブそのまま使える
end