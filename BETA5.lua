local gso_menu = MenuElement({id = "GSOMenu", name = "GamsteronOrb", type = MENU})
        gso_menu:MenuElement({id = "gso_ewin", name = "Lower Value = Faster KITE", value = 150, min = 100, max = 225, step = 25 })
        gso_menu:MenuElement({id = "gso_lcs", name = "Higher Value = Faster Last Hit React", value = 125, min = 0, max = 300, step = 25 })
        gso_menu:MenuElement({id = "gso_hum", name = "Humanizer Movement Delay", value = 225, min = 125, max = 300, step = 25 })
        gso_menu:MenuElement({id = "gso_combo", name = "Combo Key", key = string.byte(" ")})
        gso_menu:MenuElement({id = "gso_har", name = "Harrass Key", key = string.byte("C")})
        gso_menu:MenuElement({id = "gso_lhit", name = "LastHit Key", key = string.byte("X")})
        gso_menu:MenuElement({id = "gso_lane", name = "LaneClear Key", key = string.byte("V")})


local gso_lastaa            = 0
local gso_lastmove          = 0
local gso_DelayedActionAA   = nil

local gso_sqrt              = math.sqrt
local gso_floor             = math.floor
local gso_heroAAdata        = myHero.attackData
local gso_herowindUpT       = gso_heroAAdata.windUpTime
local gso_heroanimT         = gso_heroAAdata.animationTime
local gso_heroprojS         = gso_heroAAdata.projectileSpeed
local gso_heroAArange       = myHero.range + myHero.boundingRadius
local gso_heropos           = myHero.pos
local gso_heroposX          = gso_heropos.x
local gso_heroposZ          = gso_heropos.z
local gso_heroAD            = myHero.totalDamage
local gso_menuewin          = gso_menu.gso_ewin:Value() * 0.001
local gso_menuhum           = gso_menu.gso_hum:Value()  * 0.001
local gso_menulcs           = gso_menu.gso_lcs:Value()  * 0.001

function Gamsteron_Extended_Pos(gso_from, gso_to, gso_s)
        local gso_vecx = gso_to.x - gso_from.x
        local gso_vecz = gso_to.z - gso_from.z
        local gso_normalize1 = 1 / gso_sqrt(gso_vecx^2 + gso_vecz^2)
        local gso_normalize2 = { x = gso_vecx * gso_normalize1, z = gso_vecz * gso_normalize1 }
        return Vector(gso_from.x + (gso_normalize2.x * gso_s), 0, gso_from.z + (gso_normalize2.z * gso_s))
end

function GetHealthPrediction(gso_unit, gso_time)
        local gso_result    = 0
        local gso_unitpos   = gso_unit.pos
        local gso_unitid    = gso_unit.handle
        for i = 1, Game.MinionCount() do
                local gso_minion = Game.Minion(i)
                if gso_minion.attackData.target == gso_unitid then
                        local gso_checkT            = Game.Timer()
                        local gso_minion_pos        = gso_minion.pos
                        local gso_minion_aadata     = gso_minion.attackData
                        local gso_minion_projspeed  = gso_minion_aadata.projectileSpeed
                        local gso_minion_animT      = gso_minion_aadata.animationTime
                        local gso_minion_projT      = gso_minion_projspeed > 0 and gso_sqrt((gso_unitpos.x-gso_minion_pos.x)^2 + (gso_unitpos.z-gso_minion_pos.z)^2) / gso_minion_projspeed or 0
                        local gso_aacompleteT       = gso_minion_aadata.endTime + gso_minion_projT - ( gso_minion_animT - gso_minion_aadata.windUpTime )
                        gso_aacompleteT = gso_checkT < gso_aacompleteT and gso_aacompleteT or gso_aacompleteT + gso_minion_animT
                        if gso_aacompleteT - gso_checkT < gso_time + gso_menulcs then
                                local gso_minion_ad = gso_floor(gso_minion.totalDamage*0.8)
                                gso_result = gso_result + gso_minion_ad
                                for j = 1, 5 do
                                        gso_aacompleteT = gso_aacompleteT + gso_minion_animT
                                        if gso_checkT < gso_aacompleteT and gso_aacompleteT - gso_checkT < gso_time + gso_menulcs then
                                                gso_result = gso_result + gso_minion_ad
                                        else
                                                break
                                        end
                                end
                        end
                end
        end
        return gso_result
end

Callback.Add("Tick", function()

        if gso_DelayedActionAA ~= nil and Game.Timer() - gso_DelayedActionAA.time > gso_DelayedActionAA.delay then
                gso_DelayedActionAA.execute()
                gso_DelayedActionAA = nil
        end
        
        gso_heroAAdata    = myHero.attackData
        gso_herowindUpT   = gso_heroAAdata.windUpTime
        gso_heroanimT     = gso_heroAAdata.animationTime
        gso_heroprojS     = gso_heroAAdata.projectileSpeed
        gso_heroAArange   = myHero.range + myHero.boundingRadius
        gso_heropos       = myHero.pos
        gso_gso_heroposX  = gso_heropos.x
        gso_gso_heroposZ  = gso_heropos.z
        gso_heroAD        = myHero.totalDamage
        gso_menuewin      = gso_menu.gso_ewin:Value() * 0.001
        gso_menuhum       = gso_menu.gso_hum:Value() * 0.001
        gso_menulcs       = gso_menu.gso_lcs:Value() * 0.001
        local gso_combo   = gso_menu.gso_combo:Value()
        local gso_lane    = gso_menu.gso_lane:Value()
        local gso_lasthit = gso_menu.gso_lhit:Value()
        local gso_harrass = gso_menu.gso_har:Value()
        
        if gso_combo or gso_lane or gso_lasthit or gso_harrass then
        
                local gso_AAtarget          = nil
                local gso_AAlanetarget      = nil
                local gso_AAkillablesoon    = nil
                local gso_heroNUM           = 10000
                local gso_lasthitNUM        = 10000
                local gso_laneclearNUM      = 10000
                
                if gso_combo then
                        for i = 1, Game.HeroCount() do
                                local gso_unit    = Game.Hero(i)
                                local gso_unitpos = gso_unit.pos
                                if gso_unit.isEnemy and gso_unit.health > 0 and gso_sqrt((gso_unitpos.x-gso_gso_heroposX)^2 + (gso_unitpos.z-gso_gso_heroposZ)^2) < gso_heroAArange + gso_unit.boundingRadius then
                                        local gso_unitarmor   = gso_unit.armor
                                        local gso_unithealth  = gso_unit.health * ( gso_unitarmor / ( gso_unitarmor + 100 ) )
                                        if gso_unithealth < gso_heroNUM then
                                                gso_heroNUM = gso_unithealth
                                                gso_AAtarget = gso_unit
                                        end
                                end
                        end
                elseif gso_lane then
                        for i = 1, Game.MinionCount() do
                                local gso_unit = Game.Minion(i)
                                if gso_unit.isEnemy and gso_unit.handle and gso_unit.health > 0 then
                                        local gso_unitpos  = gso_unit.pos
                                        local gso_distance = gso_sqrt((gso_unitpos.x-gso_gso_heroposX)^2 + (gso_unitpos.z-gso_gso_heroposZ)^2)
                                        if gso_distance < gso_heroAArange + gso_unit.boundingRadius then
                                                local gso_unitHP = gso_unit.health
                                                if gso_unitHP < gso_heroAD and gso_unitHP < gso_lasthitNUM then
                                                        gso_AAtarget = gso_unit
                                                        gso_lasthitNUM = gso_unitHP
                                                else
                                                        local gso_aacompleteT = gso_herowindUpT + ( gso_distance / gso_heroprojS )
                                                        gso_unitHP = gso_unitHP - GetHealthPrediction(gso_unit, gso_aacompleteT)
                                                        if gso_unitHP < gso_heroAD and gso_unitHP < gso_lasthitNUM then
                                                                gso_AAtarget = gso_unit
                                                                gso_lasthitNUM = gso_unitHP
                                                        else
                                                                gso_unitHP = gso_unitHP - GetHealthPrediction(gso_unit, 3 * gso_heroanimT)
                                                                if gso_unitHP < gso_heroAD then
                                                                        gso_AAkillablesoon = gso_unit
                                                                elseif gso_unitHP < gso_laneclearNUM then
                                                                        gso_laneclearNUM = gso_unitHP
                                                                        gso_AAlanetarget = gso_unit
                                                                end
                                                        end
                                                end
                                        end
                                end
                        end
                        if gso_AAtarget == nil and gso_AAkillablesoon == nil then
                                gso_AAtarget = gso_AAlanetarget
                        end
                elseif gso_harrass then
                        for i = 1, Game.MinionCount() do
                                local gso_unit = Game.Minion(i)
                                if gso_unit.isEnemy and gso_unit.handle and gso_unit.health > 0 then
                                        local gso_unitpos  = gso_unit.pos
                                        local gso_distance = gso_sqrt((gso_unitpos.x-gso_gso_heroposX)^2 + (gso_unitpos.z-gso_gso_heroposZ)^2)
                                        if gso_distance < gso_heroAArange + gso_unit.boundingRadius then
                                                local gso_unitHP = gso_unit.health
                                                if gso_unitHP < gso_heroAD and gso_unitHP < gso_lasthitNUM then
                                                        gso_AAtarget = gso_unit
                                                        gso_lasthitNUM = gso_unitHP
                                                else
                                                        local gso_aacompleteT = gso_herowindUpT + ( gso_distance / gso_heroprojS )
                                                        gso_unitHP = gso_unitHP - GetHealthPrediction(gso_unit, gso_aacompleteT)
                                                        if gso_unitHP < gso_heroAD and gso_unitHP < gso_lasthitNUM then
                                                                gso_AAtarget = gso_unit
                                                                gso_lasthitNUM = gso_unitHP
                                                        else
                                                                gso_unitHP = gso_unitHP - GetHealthPrediction(gso_unit, 3 * gso_heroanimT)
                                                                if gso_unitHP < gso_heroAD then
                                                                        gso_AAkillablesoon = gso_unit
                                                                end
                                                        end
                                                end
                                        end
                                end
                        end
                        if gso_AAtarget == nil and gso_AAkillablesoon == nil then
                                for i = 1, Game.HeroCount() do
                                        local gso_unit    = Game.Hero(i)
                                        local gso_unitpos = gso_unit.pos
                                        if gso_unit.isEnemy and gso_unit.health > 0 and gso_sqrt((gso_unitpos.x-gso_gso_heroposX)^2 + (gso_unitpos.z-gso_gso_heroposZ)^2) < gso_heroAArange + gso_unit.boundingRadius then
                                                local gso_unitarmor   = gso_unit.armor
                                                local gso_unithealth  = gso_unit.health * ( gso_unitarmor / ( gso_unitarmor + 100 ) )
                                                if gso_unithealth < gso_heroNUM then
                                                        gso_heroNUM = gso_unithealth
                                                        gso_AAtarget = gso_unit
                                                end
                                        end
                                end
                        end
                elseif gso_lasthit then
                        for i = 1, Game.MinionCount() do
                                local gso_unit = Game.Minion(i)
                                if gso_unit.isEnemy and gso_unit.handle and gso_unit.health > 0 then
                                        local gso_unitpos  = gso_unit.pos
                                        local gso_distance = gso_sqrt((gso_unitpos.x-gso_gso_heroposX)^2 + (gso_unitpos.z-gso_gso_heroposZ)^2)
                                        if gso_distance < gso_heroAArange + gso_unit.boundingRadius then
                                                local gso_unitHP      = gso_unit.health
                                                if gso_unitHP < gso_heroAD and gso_unitHP < gso_lasthitNUM then
                                                        gso_AAtarget = gso_unit
                                                        gso_lasthitNUM = gso_unitHP
                                                else
                                                        local gso_aacompleteT = gso_herowindUpT + ( gso_distance / gso_heroprojS )
                                                        gso_unitHP = gso_unitHP - GetHealthPrediction(gso_unit, gso_aacompleteT)
                                                        if gso_unitHP < gso_heroAD and gso_unitHP < gso_lasthitNUM then
                                                                gso_AAtarget = gso_unit
                                                                gso_lasthitNUM = gso_unitHP
                                                        end
                                                end
                                        end
                                end
                        end
                end
                
                local gso_canmove = Game.Timer() > gso_lastaa + gso_herowindUpT + gso_menuewin and Game.Timer() > gso_lastmove + gso_menuhum
                local gso_canattack = Game.Timer() > gso_lastaa + gso_heroanimT + 0.03
                if gso_AAtarget ~= nil and gso_canattack then
                        local gso_cPos = cursorPos
                        Control.SetCursorPos(gso_AAtarget.pos)
                        Control.mouse_event(0x0008)
                        Control.mouse_event(0x0010)
                        gso_lastaa = Game.Timer()
                        gso_lastmove = 0
                        gso_DelayedActionAA = { execute = function() Control.SetCursorPos(gso_cPos.x, gso_cPos.y) end, time = Game.Timer(), delay = 0.055 }
                elseif gso_canmove then
                        Control.mouse_event(0x0008)
                        Control.mouse_event(0x0010)
                        gso_lastmove = Game.Timer()
                end
        end
end)
