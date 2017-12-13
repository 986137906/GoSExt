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
--451-358=93 71dmg

local WP = {}
local WP2 = {}
function HPPrediction(enemyMinion)
        local dmg = 0
        for i = 1, Game.MinionCount() do
                local unit = Game.Minion(i)
                local unitID = unit.networkID
                if ValidTarget(10000, unit) and unit.isAlly and not unit.pathing.hasMovePath and unit.attackData.target == enemyMinion.handle then
                        local cancontinue = false
                        local unitdmg = unit.totalDamage
                        local unitaadata = unit.attackData
                        local endT = unitaadata.endTime
                        local animT = unitaadata.animationTime
                        local windUpT = unitaadata.windUpTime
                        local windDownT = animT - windUpT
                        local projSpeed = unitaadata.projectileSpeed
                        local enemyminionPos = enemyMinion.pos
                        local timetoaaHero = myHero.attackData.windUpTime + 0.15 + ( math.sqrt((enemyminionPos.x-myHero.pos.x)^2 + (enemyminionPos.z-myHero.pos.z)^2) / myHero.attackData.projectileSpeed )
                        local unitPos = unit.pos
                        local projT = 0
                        if projSpeed > 0 then projT = math.sqrt((enemyminionPos.x-unitPos.x)^2 + (enemyminionPos.z-unitPos.z)^2) / projSpeed end
                        local timetoaaMinion = windUpT + projT
                        if endT > Game.Timer() then
                                timetoaaMinion = timetoaaMinion - ( endT - Game.Timer() )
                                if timetoaaMinion < 0 then cancontinue = true end
                        end
                        if not cancontinue then
                                for j = 1, 5 do
                                        if timetoaaMinion < timetoaaHero then dmg = dmg + unitdmg
                                        else break end
                                        timetoaaMinion = timetoaaMinion + windUpT + projT + animT
                                end
                        end
                        
                        
                        if not WP[unitID] then
                                if endT > Game.Timer() then
                                        local aaT = windUpT + projT - ( endT - Game.Timer() )
                                        if aaT > 0 and aaT < 0.05 then
                                                WP[unitID]            = { aatime = 0, hp = 0 }
                                                WP[unitID].aatime     = Game.Timer() + ( unitaadata.windUpTime - aaT ) + projT
                                                WP[unitID].hp         = enemyMinion.health
                                        end
                                end
                        elseif Game.Timer() > WP[unitID].aatime + 0.15 then
                                local dmgdealt = WP[unitID].hp-enemyMinion.health
                                if dmgdealt > 0 then
                                        table.insert(WP2, { unit.name, enemyMinion.name, dmgdealt, unitdmg })
                                end
                                WP[unitID] = nil
                        end
                end
        end
        return dmg
end

function GetLaneMinion()
        for i = 1, Game.MinionCount() do
                local unit = Game.Minion(i)
                local unitID = unit.networkID
                if unit.isEnemy then
                        if ValidTarget(myHero.range+myHero.boundingRadius+unit.boundingRadius, unit) then
                                local dmgHP = 0
                                local unitHP = unit.health - HPPrediction(unit)
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

local canaa = true
local canmove = true
function Orb(t)
        local endT = myHero.attackData.endTime
        local animT = myHero.attackData.animationTime
        local windUpT = myHero.attackData.windUpTime
        if Game.Timer() > endT then
                if Game.Timer() > lastaa + ( animT * 0.7 ) then canaa = true end
        elseif Game.Timer() > endT - (animT - windUpT) then canmove = true end
        if t ~= nil and canaa then
                canaa = false
                canmove = false
                lastaa = Game.Timer()
                local cPos = cursorPos
                Control.SetCursorPos(t.pos)
                Control.mouse_event(0x0008)
                Control.mouse_event(0x0010)
                lastmove = 0
                DelayedActionAA = { execute = function() Control.SetCursorPos(cPos.x, cPos.y) end, time = Game.Timer(), delay = 0.05 }
        elseif canmove and Game.Timer() > lastmove + (menu.hum:Value()*0.001) then
                Control.mouse_event(0x0008)
                Control.mouse_event(0x0010)
                lastmove = Game.Timer()
        end


        --[[ GOOD
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
        end]]
end

local changed = myHero.attackData.endTime
local aaticks = 0
local timeraa = 0
Callback.Add("Tick", function()
        for k, v in pairs(WP2) do
                print(v(1))
                --print("from: "..k(1)..", to: "..k(2)..", dmg dealt: "..k(3)..", total minion dmg: "..k(4))
        end
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
                Orb(GetLaneMinion())
        end
end)
