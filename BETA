local lastaa = 0
local aawind = 0
local aaanim = 0
local lastmove = 0
local incomingAA = {}
local incomingAAnear = {}
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

function OnDraw()
    --local mPos = Gamsteron_Extended_Pos(mousePos, myHero.pos, -50)
		--Draw.Circle(Vector(mPos.x, mPos.y, mPos.z))
		--print(math.sqrt( (mPos.x-myHero.pos.x)^2 + (mPos.z-myHero.pos.z)^2))
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

function IncomingAAFunc()
        for i = 1, Game.MinionCount() do
                local unit = Game.Minion(i)
                local unitID = unit.networkID
                if unit.isAlly and not unit.pathing.hasMovePath then
                        if ValidTarget(math.huge, unit) then
                                if not incomingAA[unitID] then incomingAA[unitID] = { dmg = 0, windupT = 0, winddownT = 0, animT = 0, endT = 0, projSpeed = 0, targetPos = nil, targetID = 0 } end
                                incomingAA[unitID].dmg = unit.totalDamage
                                incomingAA[unitID].windupT = unit.attackData.windUpTime
                                incomingAA[unitID].winddownT = unit.attackData.windDownTime
                                incomingAA[unitID].animT = unit.attackData.animationTime
                                incomingAA[unitID].endT = unit.attackData.endTime
                                incomingAA[unitID].projSpeed = unit.attackData.projectileSpeed
                                incomingAA[unitID].targetPos = unit.attackData.target.pos
                                incomingAA[unitID].targetID = unit.attackData.target.networkID
                                if unit.distance < 1500 then
                                        incomingAAnear[unitID] = incomingAA[unitID]
                                end
                        elseif incomingAA[unitID] then
                                incomingAA[unitID] = nil
                                incomingAAnear[unitID] = nil
                        end
                end
        end
end

function HPPrediction(id)
        local dmg = 0
        local heroaaT = myHero.attackData.windUpTime + 0.15
        for i = 1, Game.MinionCount() do
                local unit = Game.Minion(i)
                local unitID = unit.networkID
                if incomingAAnear[unitID] and incomingAAnear[unitID].targetID == id then
                        local targetPos = incomingAAnear[unitID].targetPos
                        heroaaT = heroaaT + ( math.sqrt((targetPos.x-myHero.pos.x)^2 + (targetPos.z-myHero.pos.z)^2) / myHero.attackData.projectileSpeed )
                        
                end
        end
end

function GetLaneMinion()
        
        for i = 1, Game.MinionCount() do
                local unit = Game.Minion(i)
                local unitID = unit.networkID
                if unit.isEnemy then
                        if ValidTarget(myHero.range+myHero.boundingRadius+unit.boundingRadius + 250, unit) then
                                local dmgHP = 0
                                local unitHP = unit.health - HPPrediction(unitID)
                                local armor = unit.armor - myHero.armorPen
                                if armor <= 0 then dmgHP = myHero.totalDamage
                                else dmgHP = myHero.totalDamage * (armor/(armor+100)) end
                                if unitHP < dmgHP then
                                        return unit
                                end
                        end
                end
        end
        
        return nil
end

function Orb(t)
        local endT = myHero.attackData.endTime
        local animT = myHero.attackData.animationTime
        local windUpT = myHero.attackData.windUpTime
        local windDownT = animT - windUpT
        local canmove = Game.Timer() > lastaa + windUpT + (menu.ewin:Value()*0.001) and Game.Timer() > lastmove + (menu.hum:Value()*0.001)
        local canattack = Game.Timer() > lastaa + animT + 0.05
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

local changed = myHero.attackData.endTime
local aaticks = 0
local timeraa = 0

Callback.Add("Tick", function()
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
        end
        if DelayedActionAA ~= nil and Game.Timer() - DelayedActionAA.time > DelayedActionAA.delay then
                DelayedActionAA.execute()
                DelayedActionAA = nil
        end
        if menu.combo:Value() then
                Orb(GetAATarget(myHero.range + myHero.boundingRadius))
        elseif menu.lane:Value() then
                IncomingAAFunc()
                Orb(GetLaneMinion())
        end
end)
