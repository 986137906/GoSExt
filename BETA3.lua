local lastaa = 0
local aawind = 0
local aaanim = 0
local lastmove = 0
local lasthitsoon = false
local DelayedActionAA = nil

local menu = MenuElement({id = "GSOMenu", name = "GamsteronOrb", type = MENU})
        menu:MenuElement({id = "ewin", name = "Lower Value = Faster KITE", value = 150, min = 0, max = 200, step = 25 });
        menu:MenuElement({id = "hum", name = "Humanizer Movement Delay", value = 200, min = 0, max = 300, step = 25 });
        menu:MenuElement({id = "combo", name = "Combo Key", key = string.byte(" ")})
        menu:MenuElement({id = "lane", name = "LaneClear Key", key = string.byte("V")})

function ValidTarget(range, unit)
      if unit.distance < range and unit.valid and not unit.dead and unit.isTargetable and unit.visible then
              return true
      end
      return false
end

function Gamsteron_Extended_Pos(from, to, s)
        local vecx = to.x - from.x
        local vecz = to.z - from.z
        local normalize1 = 1 / math.sqrt(vecx^2 + vecz^2)
        local normalize2 = { x = vecx * normalize1, z = vecz * normalize1 }
        return Vector(from.x + (normalize2.x * s), 0, from.z + (normalize2.z * s))
end

function GetAATarget(range)
        local t = nil
        num = 10000
        for i = 1, Game.HeroCount() do
                local unit = Game.Hero(i)
                if unit.isEnemy then
                        local armor = unit.armor
                        local hp = unit.health * (armor/(armor+100))
                        if ValidTarget(range+unit.boundingRadius, unit) then
                                if hp < num then
                                        num = hp
                                        t = unit
                                end
                        end
                end
        end
        return t
end

--[[
local WP = {}
local WP2 = {}]]
function GetHealthPrediction(unit, time)

        local result    = 0
        local unit_pos  = unit.pos
        local unit_id   = unit.handle
        local unit_ally = unit.isAlly and true or false
        
        for i = 1, Game.MinionCount() do
        
                local minion = Game.Minion(i)
                
                if ( ( unit_ally and minion.isEnemy ) or ( not unit_ally and minion.isAlly ) ) and unit.valid and not unit.dead and unit.isTargetable then
                
                        local minion_aadata     = minion.attackData
                        local minion_target     = minion_aadata.target
                        local minion_endT       = minion_aadata.endTime
                        
                        if minion_target == unit_id and not minion.pathing.hasMovePath and minion_endT > Game.Timer() then
                                
                                local checkT            = Game.Timer()
                                local minion_projT      = 0
                                local minion_pos        = minion.pos
                                local minion_ad         = math.floor(minion.totalDamage)
                                local minion_projspeed  = minion_aadata.projectileSpeed
                                local minion_animT      = minion_aadata.animationTime
                                local minion_windUpT    = minion_aadata.windUpTime
                                local minion_windDownT  = minion_animT - minion_windUpT
                        
                                if minion_projspeed > 0 then
                                
                                        minion_projT = math.sqrt((unit_pos.x-minion_pos.x)^2 + (unit_pos.z-minion_pos.z)^2) / minion_projspeed
                                        
                                end
                                
                                local aacompleteT = minion_endT + minion_projT - minion_windDownT
                                
                                if checkT < aacompleteT and aacompleteT - checkT < time + 0.2 then
                                
                                        result = result + minion_ad
                                        
                                end
                                
                                --[[ FILE
                                local minion_id = minion.handle
                                if not WP[minion_id] and unit.health > 150 then
                                        if Game.Timer() < aacompleteT then
                                                WP[minion_id] = { aacompleteT, unit.health, unit_id }
                                        end
                                elseif WP[minion_id] and unit_id == WP[minion_id][3] and Game.Timer() > WP[minion_id][1] + 0.075 then
                                        if unit.health > 0 then
                                                local dmgdealt = WP[minion_id][2]-unit.health
                                                table.insert(WP2, { minion_projspeed, unit.attackData.projectileSpeed, math.floor(dmgdealt), minion_ad })
                                        end
                                        WP[minion_id] = nil
                                end
                                ENDFILE ]]
                                
                        end
                        
                end
                
        end
        
        return result
        
end

function GetLaneMinion()
        for i = 1, Game.MinionCount() do
                local unit = Game.Minion(i)
                local unitID = unit.networkID
                if unit.isEnemy then
                        if ValidTarget(myHero.range+myHero.boundingRadius+unit.boundingRadius, unit) then
                                local dmgHP = myHero.totalDamage
                                local time = myHero.attackData.windUpTime + ( math.sqrt((unit.pos.x-myHero.pos.x)^2 + (unit.pos.z-myHero.pos.z)^2) / myHero.attackData.projectileSpeed )
                                local unitHP = unit.health - GetHealthPrediction(unit, time)
                                if unitHP < dmgHP then
                                        
                                        return unit
                                end
                        end
                end
        end
        return nil
end

function Orb(t)
        local animT = myHero.attackData.animationTime
        local windUpT = myHero.attackData.windUpTime
        local canmove = Game.Timer() > lastaa + windUpT + (menu.ewin:Value()*0.001) and Game.Timer() > lastmove + (menu.hum:Value()*0.001)
        local canattack = Game.Timer() > lastaa + animT + 0.03
        if t ~= nil and canattack then
                local cPos = cursorPos
                Control.SetCursorPos(t.pos)
                Control.mouse_event(0x0008)
                Control.mouse_event(0x0010)
                lastaa = Game.Timer()
                lastmove = 0
                DelayedActionAA = { execute = function() Control.SetCursorPos(cPos.x, cPos.y) end, time = Game.Timer(), delay = 0.05 }
        elseif canmove then
                Control.mouse_event(0x0008)
                Control.mouse_event(0x0010)
                lastmove = Game.Timer()
        end
end

--[[
function OnDraw()
        for i = 1, Game.MinionCount() do
                local unit = Game.Minion(i)
                Draw.Text("ID:       "..unit.handle, unit.toScreen.x, unit.toScreen.y)
                Draw.Text("TARGET:   "..unit.attackData.target, unit.toScreen.x, unit.toScreen.y+10)
                local text = unit.pathing.hasMovePath and "true" or "false"
                Draw.Text("ISMOVING: "..text, unit.toScreen.x, unit.toScreen.y+20)
                Draw.Text("HP1: "..unit.health, unit.toScreen.x, unit.toScreen.y+30)
                local time = myHero.attackData.windUpTime + 0.15 + ( math.sqrt((unit.pos.x-myHero.pos.x)^2 + (unit.pos.z-myHero.pos.z)^2) / myHero.attackData.projectileSpeed )
                Draw.Text("HP2: "..GetHealthPrediction(unit, time), unit.toScreen.x, unit.toScreen.y+40)
        end
        --local mPos = Gamsteron_Extended_Pos(mousePos, myHero.pos, -50)
        --Draw.Circle(Vector(mPos.x, mPos.y, mPos.z))
        --print(math.sqrt( (mPos.x-myHero.pos.x)^2 + (mPos.z-myHero.pos.z)^2))
end]]

--[[
local changed = myHero.attackData.endTime
local aaticks = 0
local timeraa = 0
local dirpath = SCRIPT_PATH]]

Callback.Add("Tick", function()
        --[[local tm = GetLaneMinion()
        local WP2cache = WP2
        local file = io.open(dirpath.."AAData.txt", "a+")
        for k, v in pairs(WP2cache) do
        
                local text = v[1]
                if v[1] == 0 then text = text.."    "
                elseif v[1] == 650 then text = text.."  "
                else text = text.." " end
                
                text = text..v[2]
                if v[2] == 0 then text = text.."    "
                elseif v[2] == 650 then text = text.."  "
                else text = text.." " end
                
                text = text..v[3]
                if math.abs(v[3]) < 10 then text = text.."    "
                elseif math.abs(v[3]) > 9 and math.abs(v[3]) < 100 then text = text.."   "
                elseif math.abs(v[3]) > 99 and math.abs(v[3]) < 1000 then text = text.."  "
                else text = text.." " end
                if v[3] < 0 then text = text:sub(1, -2) end
                
                text = text..v[4].."\n"
                file:write(text)
                table.remove(WP2, k)
                
        end
        file:close()
        
        if myHero.attackData.endTime > changed then
                if aaticks == 0 then
                        timeraa = Game.Timer()
                end
                aaticks = aaticks + 1
                if aaticks == 5 then
                        print(math.floor(1000*(Game.Timer()-timeraa)))
                        aaticks = 0
                end
                changed = myHero.attackData.endTime
        end]]
        if DelayedActionAA ~= nil and Game.Timer() - DelayedActionAA.time > DelayedActionAA.delay then
                DelayedActionAA.execute()
                DelayedActionAA = nil
        end
        if menu.combo:Value() then
                Orb(GetAATarget(myHero.range + myHero.boundingRadius))
        elseif menu.lane:Value() then
                Orb(GetLaneMinion())
        end
end)
