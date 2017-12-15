local Menu_GSO = MenuElement({id = "menugso", name = "GamsteronOrb", type = MENU})
        Menu_GSO:MenuElement({id = "ewin", name = "Lower Value = Faster KITE", value = 200, min = 0, max = 300, step = 25 })
        Menu_GSO:MenuElement({id = "lcs", name = "Higher Value = Faster Last Hit React", value = 100, min = 0, max = 200, step = 25 })
        Menu_GSO:MenuElement({id = "hum", name = "Humanizer Movement Delay", value = 225, min = 0, max = 300, step = 25 })
        Menu_GSO:MenuElement({id = "combo", name = "Combo Key", key = string.byte(" ")})
        Menu_GSO:MenuElement({id = "har", name = "Harrass Key", key = string.byte("C")})
        Menu_GSO:MenuElement({id = "lhit", name = "LastHit Key", key = string.byte("X")})
        Menu_GSO:MenuElement({id = "lane", name = "LaneClear Key", key = string.byte("V")})

local MinionCount_GSO 			= Game.MinionCount;
local Minion_GSO 				    = Game.Minion;
local HeroCount_GSO 			  = Game.HeroCount;
local Hero_GSO 				      = Game.Hero;

local LastAA_GSO            = 0
local LastMove_GSO          = 0
local DelayedActionAA_GSO   = nil
local DelayedActionMove_GSO = nil

local HeroTeam_GSO          = myHero.team
local EnemyTeam_GSO         = HeroTeam_GSO == 100 and 200 or 100
local Sqrt_GSO              = math.sqrt
local Floor_GSO             = math.floor
local HeroAAdata_GSO        = myHero.attackData
local HerowindUpT_GSO       = HeroAAdata_GSO.windUpTime
local HeroanimT_GSO         = HeroAAdata_GSO.animationTime
local HeroProjS_GSO         = HeroAAdata_GSO.projectileSpeed
local HeroAArange_GSO       = myHero.range + myHero.boundingRadius
local HeroPos_GSO           = myHero.pos
local HeroPosX_GSO          = HeroPos_GSO.x
local HeroPosZ_GSO          = HeroPos_GSO.z
local HeroAD_GSO            = myHero.totalDamage
local MenuEwin_GSO          = Menu_GSO.ewin:Value() * 0.001
local MenuHum_GSO           = Menu_GSO.hum:Value()  * 0.001
local MenuLcs_GSO           = Menu_GSO.lcs:Value()  * 0.001

function IsValidTarget_GSO(range, unit, sourcePosX, sourcePosZ)
        local type      = unit.type
        local isUnit    = type == Obj_AI_Hero or type == Obj_AI_Minion or type == Obj_AI_Turret
        local isValid   = isUnit and unit.valid or true
        if math.sqrt((unit.pos.x-sourcePosX)^2 + (unit.pos.z-sourcePosZ)^2) < range and not unit.dead and unit.isTargetable and unit.visible and isValid then
                return true
        end
        return false
end

function GetAllyMinions_GSO(range)
        local result = {}
        for i = 1, MinionCount_GSO() do
                local minion = Minion_GSO(i)
                local isotherminion = minion.maxHealth <= 6
                local ismonster = minion.team == 300
                if minion.isAlly and not isotherminion and not ismonster and IsValidTarget_GSO(range, minion, HeroPosX_GSO, HeroPosZ_GSO) then
                        result[#result + 1] = minion
                end
        end
        return result
end

function GetEnemyMinions_GSO(range)
        local result = {}
        for i = 1, MinionCount_GSO() do
                local minion = Minion_GSO(i)
                local isotherminion = minion.maxHealth <= 6
                local ismonster = minion.team == 300
                if minion.isEnemy and not isotherminion and not ismonster and IsValidTarget_GSO(range + minion.boundingRadius, minion, HeroPosX_GSO, HeroPosZ_GSO) then
                        result[#result + 1] = minion
                end
        end
        return result
end

function GetAllEnemyMinions_GSO(range)
        local result = {}
        for i = 1, MinionCount_GSO() do
                local minion = Minion_GSO(i)
                if minion.team ~= HeroTeam_GSO and IsValidTarget_GSO(range, minion, HeroPosX_GSO, HeroPosZ_GSO) then
                        result[#result + 1] = minion
                end
        end
        return result
end

function GetEnemyHeroes_GSO(range)
        local result = {}
        for i = 1, HeroCount_GSO() do
                local hero = Hero_GSO(i)
                if hero.team == EnemyTeam_GSO and IsValidTarget_GSO(range + minion.boundingRadius, minion, HeroPosX_GSO, HeroPosZ_GSO) then
                        result[#result + 1] = hero
                end
        end
        return result
end

function LocalExtendedPos(from, to, s)
        local vecx = to.x - from.x
        local vecz = to.z - from.z
        local normalize1 = 1 / Sqrt_GSO(vecx^2 + vecz^2)
        local normalize2 = { x = vecx * normalize1, z = vecz * normalize1 }
        return Vector(from.x + (normalize2.x * s), 0, from.z + (normalize2.z * s))
end

function GetHealthPrediction(unit, time)
        local result    = 0
        local unitpos   = unit.pos
        local unitid    = unit.handle
				local t = GetAllyMinions_GSO(2000)
				for i = 1, #t do
                local minion = t[i]
                if minion.attackData.target == unitid then
                        local checkT            = Game.Timer()
                        local minion_pos        = minion.pos
                        local minion_aadata     = minion.attackData
                        local minion_projspeed  = minion_aadata.projectileSpeed
                        local minion_animT      = minion_aadata.animationTime
                        local minion_projT      = minion_projspeed > 0 and Sqrt_GSO((unitpos.x-minion_pos.x)^2 + (unitpos.z-minion_pos.z)^2) / minion_projspeed or 0
                        local aacompleteT       = minion_aadata.endTime + minion_projT - ( minion_animT - minion_aadata.windUpTime )
                        aacompleteT = checkT < aacompleteT and aacompleteT or aacompleteT + minion_animT
                        if aacompleteT - checkT < time + MenuLcs_GSO then
                                local minion_ad = Floor_GSO(minion.totalDamage*0.8)
                                result = result + minion_ad
                                for j = 1, 5 do
                                        aacompleteT = aacompleteT + minion_animT
                                        if checkT < aacompleteT and aacompleteT - checkT < time + MenuLcs_GSO then
                                                result = result + minion_ad
                                        else
                                                break
                                        end
                                end
                        end
                end
        end
        return result
end

Callback.Add("Tick", function()

        if DelayedActionAA_GSO ~= nil and Game.Timer() - DelayedActionAA_GSO[2] > DelayedActionAA_GSO[3] then
                DelayedActionAA_GSO[1]()
                DelayedActionAA_GSO = nil
        end

        if DelayedActionMove_GSO ~= nil and Game.Timer() - DelayedActionMove_GSO[2] > DelayedActionMove_GSO[3] then
                DelayedActionMove_GSO[1]()
                DelayedActionMove_GSO = nil
        end
        
        HeroAAdata_GSO    = myHero.attackData
        HerowindUpT_GSO   = HeroAAdata_GSO.windUpTime
        HeroanimT_GSO     = HeroAAdata_GSO.animationTime
        HeroProjS_GSO     = HeroAAdata_GSO.projectileSpeed
        HeroAArange_GSO   = myHero.range + myHero.boundingRadius
        HeroPos_GSO       = myHero.pos
        HeroPosX_GSO      = HeroPos_GSO.x
        HeroPosZ_GSO      = HeroPos_GSO.z
        HeroAD_GSO        = myHero.totalDamage
        MenuEwin_GSO      = Menu_GSO.ewin:Value() * 0.001
        MenuHum_GSO       = Menu_GSO.hum:Value() * 0.001
        MenuLcs_GSO       = Menu_GSO.lcs:Value() * 0.001
        
        local combo       = Menu_GSO.combo:Value()
        local lane        = Menu_GSO.lane:Value()
        local lasthit     = Menu_GSO.lhit:Value()
        local harrass     = Menu_GSO.har:Value()
        
        if combo or lane or lasthit or harrass then
        
                local AAtarget          = nil
                local AAlanetarget      = nil
                local AAkillablesoon    = nil
                local heroNUM           = 10000
                local lasthitNUM        = 10000
                local laneclearNUM      = 10000
                
                if combo then
                        local t = GetEnemyHeroes_GSO(HeroAArange_GSO)
                        for i = 1, #t do
                                local unit        = t[i]
                                local unithealth  = unit.health * ( 100 / ( 100 + unit.armor ) )
                                if unithealth < heroNUM then
                                        heroNUM  = unithealth
                                        AAtarget = unit
                                end
                        end
                elseif lane then
                        local t = GetEnemyMinions_GSO(HeroAArange_GSO)
                        for i = 1, #t do
                                local unit = t[i]
                                local unitpos  = unit.pos
                                local unitHP = unit.health
                                if unitHP < HeroAD_GSO and unitHP < lasthitNUM then
                                        AAtarget = unit
                                        lasthitNUM = unitHP
                                else
                                        local aacompleteT = HerowindUpT_GSO + ( Sqrt_GSO((unitpos.x-HeroPosX_GSO)^2 + (unitpos.z-HeroPosZ_GSO)^2) / HeroProjS_GSO )
                                        unitHP = unitHP - GetHealthPrediction(unit, aacompleteT)
                                        if unitHP < HeroAD_GSO and unitHP < lasthitNUM then
                                                AAtarget = unit
                                                lasthitNUM = unitHP
                                        else
                                                unitHP = unitHP - GetHealthPrediction(unit, 3 * HeroanimT_GSO)
                                                if unitHP < HeroAD_GSO then
                                                        AAkillablesoon = unit
                                                elseif unitHP < laneclearNUM then
                                                        laneclearNUM = unitHP
                                                        AAlanetarget = unit
                                                end
                                        end
                                end
                        end
                        if AAtarget == nil and AAkillablesoon == nil then
                                AAtarget = AAlanetarget
                        end
                elseif harrass then
                        local t = GetEnemyMinions_GSO(HeroAArange_GSO)
                        for i = 1, #t do
                                local unit      = t[i]
                                local unitpos   = unit.pos
                                local unitHP    = unit.health
                                if unitHP < HeroAD_GSO and unitHP < lasthitNUM then
                                        AAtarget   = unit
                                        lasthitNUM = unitHP
                                else
                                        local aacompleteT = HerowindUpT_GSO + ( Sqrt_GSO((unitpos.x-HeroPosX_GSO)^2 + (unitpos.z-HeroPosZ_GSO)^2) / HeroProjS_GSO )
                                        unitHP            = unitHP - GetHealthPrediction(unit, aacompleteT)
                                        if unitHP < HeroAD_GSO and unitHP < lasthitNUM then
                                                AAtarget   = unit
                                                lasthitNUM = unitHP
                                        else
                                                unitHP = unitHP - GetHealthPrediction(unit, 3 * HeroanimT_GSO)
                                                if unitHP < HeroAD_GSO then
                                                        AAkillablesoon = unit
                                                end
                                        end
                                end
                        end
                        if AAtarget == nil and AAkillablesoon == nil then
                                local t = GetEnemyHeroes_GSO(HeroAArange_GSO)
                                for i = 1, #t do
                                        local unit        = t[i]
                                        local unithealth  = unit.health * ( 100 / ( 100 + unit.armor ) )
                                        if unithealth < heroNUM then
                                                heroNUM  = unithealth
                                                AAtarget = unit
                                        end
                                end
                        end
                elseif lasthit then
                        local t = GetEnemyMinions_GSO(HeroAArange_GSO)
                        for i = 1, #t do
                                local unit      = t[i]
                                local unitpos   = unit.pos
                                local unitHP    = unit.health
                                if unitHP < HeroAD_GSO and unitHP < lasthitNUM then
                                        AAtarget   = unit
                                        lasthitNUM = unitHP
                                else
                                        local aacompleteT = HerowindUpT_GSO + ( Sqrt_GSO((unitpos.x-HeroPosX_GSO)^2 + (unitpos.z-HeroPosZ_GSO)^2) / HeroProjS_GSO )
                                        unitHP            = unitHP - GetHealthPrediction(unit, aacompleteT)
                                        if unitHP < HeroAD_GSO and unitHP < lasthitNUM then
                                                AAtarget   = unit
                                                lasthitNUM = unitHP
                                        end
                                end
                        end
                end
                
                local canmove = Game.Timer() > LastAA_GSO + HerowindUpT_GSO + MenuEwin_GSO and Game.Timer() > LastMove_GSO + MenuHum_GSO
                local canattack = Game.Timer() > LastAA_GSO + HeroanimT_GSO + 0.03
                if AAtarget ~= nil and canattack then
                        local cPos = cursorPos
                        Control.SetCursorPos(AAtarget.pos)
                        Control.mouse_event(0x0008)
                        Control.mouse_event(0x0010)
                        LastAA_GSO = Game.Timer()
                        LastMove_GSO = 0
                        DelayedActionAA_GSO = { function() Control.SetCursorPos(cPos.x, cPos.y) end, Game.Timer(), 0.1 }
                elseif canmove then
                        --[[
                        local cPos = cursorPos
                        local num = 1
                        local pos = nil
                        for i = 1, 15 do
                                local count = 0
                                local mPos = LocalExtendedPos(mousePos, HeroPos_GSO, -50*i)
                                local t1 = GetAllEnemyMinions_GSO(2000)
                                for i = 1, #t1 do
                                        local unit = t1[i]
                                        local unitpos = unit.pos
                                        if Sqrt_GSO((mPos.x-unitpos.x)^2 + (mPos.z-unitpos.z)^2) < unit.boundingRadius + 100 then
                                                count = 1
                                                break
                                        end
                                end
                                local t2 = GetEnemyHeroes_GSO(2000)
                                for i = 1, #t2 do
                                        local unit = t2[i]
                                        local unitpos = unit.pos
                                        if Sqrt_GSO((mPos.x-unitpos.x)^2 + (mPos.z-unitpos.z)^2) < unit.boundingRadius + 100 then
                                                count = 1
                                                break
                                        end
                                end
                                if count == 0 then
                                        num = i
                                        pos = Vector(mPos.x, 0, mPos.z)
                                        break
                                end
                        end
                        if num > 1 then Control.SetCursorPos(pos) end
                        ]]
                        Control.mouse_event(0x0008)
                        Control.mouse_event(0x0010)
                        --if num > 1 then DelayedActionMove_GSO = { function() Control.SetCursorPos(cPos.x, cPos.y) end, Game.Timer(), 0.05 } end
                        LastMove_GSO = Game.Timer()
                end
        end
end)
