local menu = MenuElement({id = "GSOMenu", name = "GamsteronOrb", type = MENU})
        menu:MenuElement({id = "combo", name = "Combo Key", key = string.byte(" ")})

function ValidTarget(range, enemy)
      if enemy.distance < range and enemy.valid and not enemy.dead and enemy.isTargetable and enemy.visible then
              return true
      end
      return false
end

function GetAATarget(range)
        local t = nil
        num = 10000
        for i = 1, Game.HeroCount() do
                local enemy = Game.Hero(i)
                if enemy.isEnemy then
                        local armor = enemy.armor
                        local hp = enemy.health * (armor/(armor+100))
                        if ValidTarget(range+enemy.boundingRadius, enemy) then
                                if hp < num then
                                        num = hp
                                        t = enemy
                                end
                        end
                end
        end
        return t
end

local lastaa = 0
local function Attack()
        local t = GetAATarget(myHero.range + myHero.boundingRadius)
        if t == nil or os.clock() < lastaa + myHero.attackData.animationTime then
                return
        end
        local mPos = mousePos
        Control.SetCursorPos(t.pos)
        Control.mouse_event(0x0008)
        Control.mouse_event(0x0010)
        lastaa = os.clock()
        DelayAction(function()
                Control.SetCursorPos(mPos)
        end,0.01)
end

local lastmove = 0
local function Move()
        if os.clock() < lastaa + myHero.attackData.windUpTime + 0.05 or os.clock() < lastmove + 0.2 then
                return
        end
        Control.mouse_event(0x0008)
        Control.mouse_event(0x0010)
        lastmove = os.clock()
end

Callback.Add("Tick", function()
        if menu.combo:Value() then
                Move()
                Attack()
        end
end)
