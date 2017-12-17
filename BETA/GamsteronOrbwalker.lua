local Menu_GSO = MenuElement({type = MENU, id = "menugso", name = "Gamsteron Orbwalker"})

        Menu_GSO:MenuElement({type = MENU, id = "keys", name = "Keys"})
                Menu_GSO.keys:MenuElement({id = "combo", name = "Combo Key", key = string.byte(" ")})
                Menu_GSO.keys:MenuElement({id = "har", name = "Harrass Key", key = string.byte("C")})
                Menu_GSO.keys:MenuElement({id = "lhit", name = "LastHit Key", key = string.byte("X")})
                Menu_GSO.keys:MenuElement({id = "lane", name = "LaneClear Key", key = string.byte("V")})
        
        Menu_GSO:MenuElement({type = MENU, id = "attack", name = "Attack"})
                Menu_GSO.attack:MenuElement({id = "setc", name = "Set cursorPos delay", value = 50, min = 50, max = 100, step = 5 })
        
        Menu_GSO:MenuElement({type = MENU, id = "move", name = "Movement"})
                Menu_GSO.move:MenuElement({id = "ewin", name = "Kite Delay", value = 150, min = 0, max = 200, step = 25 })
                Menu_GSO.move:MenuElement({id = "hum", name = "Humanizer Movement Delay", value = 225, min = 0, max = 300, step = 25 })
        
        Menu_GSO:MenuElement({type = MENU, id = "farm", name = "Farm"})
                Menu_GSO.farm:MenuElement({id = "wait", name = "LaneClear: Wait for allies attacks if enemy minion has low hp", value = false})
                Menu_GSO.farm:MenuElement({id = "lcs", name = "LastHit Delay", value = 50, min = 0, max = 200, step = 25 })
                Menu_GSO.farm:MenuElement({type = SPACE, id = "note1", name = "For Ping < 70, better value is 50-100"})
                Menu_GSO.farm:MenuElement({type = SPACE, id = "note2", name = "For Ping > 70, better value is 0-50"})
                Menu_GSO.farm:MenuElement({type = SPACE, id = "note3", name = "CPU throttling, better value is 0-50"})

local LastKeyPress_GSO      = 0
local OtherOrbTimer_GSO     = os.clock()
local CanCheckOrb_GSO       = false
local EOWLoaded_GSO         = false
local IcyLoaded_GSO         = false

local MinionCount_GSO       = Game.MinionCount
local Minion_GSO            = Game.Minion
local HeroCount_GSO         = Game.HeroCount
local Hero_GSO              = Game.Hero

local LastMove_GSO          = 0
local DelayedActionAA_GSO   = nil
local DelayedAction_GSO     = nil

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
local MenuEwin_GSO          = Menu_GSO.move.ewin:Value() * 0.001
local MenuHum_GSO           = Menu_GSO.move.hum:Value()  * 0.001
local MenuLcs_GSO           = ( 200 - Menu_GSO.farm.lcs:Value() )  * 0.001
local Menuscp_GSO           = Menu_GSO.attack.setc:Value() * 0.001
local Menuwaitm_GSO         = Menu_GSO.farm.wait:Value()

local AfterAttackC_GSO          = {}
function AfterAttack_GSO(arg)
        AfterAttackC_GSO[#AfterAttackC_GSO + 1] = arg
end
local BeforeAttackC_GSO         = {}
function BeforeAttack_GSO(arg)
        BeforeAttackC_GSO[#BeforeAttackC_GSO + 1] = arg
end
local CurrentMode_GSO       = "none"
function GetStringCurrentMode_GSO()
        return CurrentMode_GSO
end
local CanMove_GSO           = true
function GetBooleanCanMove_GSO()
        return CanMove_GSO
end
local CanAttack_GSO         = true
function GetBooleanCanAttack_GSO()
        return CanAttack_GSO
end
local BlockMovement_GSO     = false
function DisableMovement_GSO(boolean)
        BlockMovement_GSO = boolean
end
local BlockAttack_GSO       = false
function DisableAttack_GSO(boolean)
        BlockAttack_GSO = boolean
end
local LastAA_GSO            = 0
function GetIntLastAATick_GSO()
        return LastAA_GSO
end
function ResetAA_GSO()
        LastAA_GSO = 0
end
function GetHeroBonusDmg_GSO()
        return 0
end
function SetFuncBonusDamageForLastHit_GSO(func)
        GetHeroBonusDmg_GSO = func
end
function GetBonusBuffDmg_GSO(unit)
        return 0
end
function SetFuncUnitBonusDmgForLastHit_GSO(func)
        GetBonusBuffDmg_GSO = func
end
function GetBooleanCanAttack2_GSO()
        return true
end
function SetFuncCanAttack_GSO(func)
        GetBooleanCanAttack2_GSO = func
end
function GetTargetFunc_GSO()
        return nil
end
function SetTargetFunc_GSO(func)
        GetTargetFunc_GSO = func
end

AfterAttack_GSO(function(unit)
        if HeroAAdata_GSO.endTime < LastAA_GSO then
                LastAA_GSO = 0
        end
end)

function IsValidTarget_GSO(range, unit, sourcePosX, sourcePosZ)
        local type      = unit.type
        local isUnit    = type == Obj_AI_Hero or type == Obj_AI_Minion or type == Obj_AI_Turret
        local isValid   = isUnit and unit.valid or true
        if math.sqrt((unit.pos.x-sourcePosX)^2 + (unit.pos.z-sourcePosZ)^2) < range and not unit.dead and unit.isTargetable and unit.visible and isValid then
                return true
        end
        return false
end

function GetAllyMinions_GSO(range, addBB)
        local result = {}
        for i = 1, MinionCount_GSO() do
                local minion = Minion_GSO(i)
                local r = addBB == true and range + minion.boundingRadius or range
                local isotherminion = minion.maxHealth <= 6
                local ismonster = minion.team == 300
                if minion.isAlly and not isotherminion and not ismonster and IsValidTarget_GSO(r, minion, HeroPosX_GSO, HeroPosZ_GSO) then
                        result[#result + 1] = minion
                end
        end
        return result
end

function GetAllAllyMinions_GSO(range, addBB)
        local result = {}
        for i = 1, MinionCount_GSO() do
                local minion = Minion_GSO(i)
                local r = addBB == true and range + minion.boundingRadius or range
                if minion.isAlly and IsValidTarget_GSO(r, minion, HeroPosX_GSO, HeroPosZ_GSO) then
                        result[#result + 1] = minion
                end
        end
        return result
end

function GetEnemyMinions_GSO(range, addBB)
        local result = {}
        for i = 1, MinionCount_GSO() do
                local minion = Minion_GSO(i)
                local r = addBB == true and range + minion.boundingRadius or range
                local isotherminion = minion.maxHealth <= 6
                local ismonster = minion.team == 300
                if minion.isEnemy and not isotherminion and not ismonster and IsValidTarget_GSO(r, minion, HeroPosX_GSO, HeroPosZ_GSO) then
                        result[#result + 1] = minion
                end
        end
        return result
end

function GetAllEnemyMinions_GSO(range, addBB)
        local result = {}
        for i = 1, MinionCount_GSO() do
                local minion = Minion_GSO(i)
                local r = addBB == true and range + minion.boundingRadius or range
                if minion.team ~= HeroTeam_GSO and IsValidTarget_GSO(r, minion, HeroPosX_GSO, HeroPosZ_GSO) then
                        result[#result + 1] = minion
                end
        end
        return result
end

function GetEnemyHeroes_GSO(range, addBB)
        local result = {}
        for i = 1, HeroCount_GSO() do
                local hero = Hero_GSO(i)
                local r = addBB == true and range + hero.boundingRadius or range
                if hero.team == EnemyTeam_GSO and IsValidTarget_GSO(r, hero, HeroPosX_GSO, HeroPosZ_GSO) then
                        result[#result + 1] = hero
                end
        end
        return result
end

function GetAllyHeroes_GSO(range, addBB)
        local result = {}
        for i = 1, HeroCount_GSO() do
                local hero = Hero_GSO(i)
                local r = addBB == true and range + hero.boundingRadius or range
                if hero.team == HeroTeam_GSO and IsValidTarget_GSO(r, hero, HeroPosX_GSO, HeroPosZ_GSO) then
                        result[#result + 1] = hero
                end
        end
        return result
end

function ExtendedPos_GSO(from, to, s)
        local vecx = to.x - from.x
        local vecz = to.z - from.z
        local normalize1 = 1 / Sqrt_GSO(vecx^2 + vecz^2)
        local normalize2 = { x = vecx * normalize1, z = vecz * normalize1 }
        return Vector(from.x + (normalize2.x * s), 0, from.z + (normalize2.z * s))
end

function GetHealthPrediction_GSO(unit, time)
        local result    = 0
        local unitpos   = unit.pos
        local unitid    = unit.handle
        local t         = GetAllyMinions_GSO(2000, false)
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

Callback.Add("WndMsg", function(msg, wParam)
        local i = wParam
        if CurrentMode_GSO == "none" or Game.Timer() < LastKeyPress_GSO + 0.2 then return end
        if i == HK_Q or i == HK_W or i == HK_E or i == HK_R or i == HK_ITEM_1 or i == HK_ITEM_2 or i == HK_ITEM_3 or i == HK_ITEM_4 or i == HK_ITEM_5 or i == HK_ITEM_6 or i == HK_ITEM_7 or i == HK_SUMMONER_1 or i == HK_SUMMONER_2 or i == HK_LUS or i == HK_MENU then
                LastKeyPress_GSO = Game.Timer()
                Control.KeyDown(i)
                Control.KeyUp(i)
                Control.KeyDown(i)
                Control.KeyUp(i)
                Control.KeyDown(i)
                Control.KeyUp(i)
        end
end)

Callback.Add("Tick", function()
        
        GOS.BlockMovement = true
        GOS.BlockAttack = true
        
        if CanCheckOrb_GSO then
                if EOWLoaded_GSO then
                        EOW:SetMovements(false)
                        EOW:SetAttacks(false)
                end
                if IcyLoaded_GSO then
                        _G.SDK.Orbwalker:SetMovement(false)
                        _G.SDK.Orbwalker:SetAttack(false)
                end
        elseif os.clock() > OtherOrbTimer_GSO + 3 then
                if _G.EOWLoaded then
                        EOWLoaded_GSO = true
                end
                if _G.SDK and _G.SDK.Orbwalker then
                        IcyLoaded_GSO = true
                end
                CanCheckOrb_GSO = true
        end
        
        HeroAAdata_GSO    = myHero.attackData
        HerowindUpT_GSO   = HeroAAdata_GSO.windUpTime
        HeroanimT_GSO     = HeroAAdata_GSO.animationTime
        HeroProjS_GSO     = HeroAAdata_GSO.projectileSpeed
        HeroAArange_GSO   = myHero.range + myHero.boundingRadius
        HeroPos_GSO       = myHero.pos
        HeroPosX_GSO      = HeroPos_GSO.x
        HeroPosZ_GSO      = HeroPos_GSO.z
        HeroAD_GSO        = myHero.totalDamage + GetHeroBonusDmg_GSO()
        MenuEwin_GSO      = Menu_GSO.move.ewin:Value() * 0.001
        MenuHum_GSO       = Menu_GSO.move.hum:Value() * 0.001
        MenuLcs_GSO       = ( 200 - Menu_GSO.farm.lcs:Value() ) * 0.001
        Menuscp_GSO       = Menu_GSO.attack.setc:Value() * 0.001
        Menuwaitm_GSO     = Menu_GSO.farm.wait:Value()
        
        local combo       = Menu_GSO.keys.combo:Value()
        local lane        = Menu_GSO.keys.lane:Value()
        local lasthit     = Menu_GSO.keys.lhit:Value()
        local harass      = Menu_GSO.keys.har:Value()
        
        if DelayedActionAA_GSO ~= nil and Game.Timer() - DelayedActionAA_GSO[2] > DelayedActionAA_GSO[3] then
                DelayedActionAA_GSO[1]()
                DelayedActionAA_GSO = nil
        end
        
        if DelayedAction_GSO ~= nil and Game.Timer() - DelayedAction_GSO[2] > DelayedAction_GSO[3] then
                DelayedAction_GSO[1]()
                DelayedAction_GSO = nil
        end
        
        if combo or lane or lasthit or harass then
                
                local AAtarget          = nil
                local AAlanetarget      = nil
                local AAkillablesoon    = nil
                local heroNUM           = 10000
                local lasthitNUM        = 10000
                local laneclearNUM      = 10000
                
                if not BlockAttack_GSO then
                        
                        if combo then
                                CurrentMode_GSO = "combo"
                                local tfunc = GetTargetFunc_GSO()
                                if tfunc ~= nil then
                                        AAtarget = tfunc
                                else
                                        local t = GetEnemyHeroes_GSO(HeroAArange_GSO, true)
                                        for i = 1, #t do
                                                local unit        = t[i]
                                                local unithealth  = unit.health * ( 100 / ( 100 + unit.armor ) )
                                                if unithealth < heroNUM then
                                                        heroNUM  = unithealth
                                                        AAtarget = unit
                                                end
                                        end
                                end
                        elseif lane then
                                CurrentMode_GSO = "laneclear"
                                local t = GetEnemyMinions_GSO(HeroAArange_GSO, true)
                                for i = 1, #t do
                                        local unit          = t[i]
                                        local unitpos       = unit.pos
                                        local aacompleteT   = HerowindUpT_GSO + ( Sqrt_GSO((unitpos.x-HeroPosX_GSO)^2 + (unitpos.z-HeroPosZ_GSO)^2) / HeroProjS_GSO )
                                        local unitHP        = unit.health - GetHealthPrediction_GSO(unit, aacompleteT)
                                        local heroad        = GetBonusBuffDmg_GSO(unit) + HeroAD_GSO
                                        if unitHP < heroad and unitHP < lasthitNUM then
                                                AAtarget = unit
                                                lasthitNUM = unitHP
                                        else
                                                unitHP = unitHP - GetHealthPrediction_GSO(unit, 3 * HeroanimT_GSO)
                                                if unitHP < heroad then
                                                        AAkillablesoon = unit
                                                elseif unitHP < laneclearNUM then
                                                        laneclearNUM = unitHP
                                                        AAlanetarget = unit
                                                end
                                        end
                                end
                                if AAtarget == nil and AAkillablesoon == nil and AAlanetarget ~= nil then
                                        if Menuwaitm_GSO and laneclearNUM < (GetBonusBuffDmg_GSO(AAlanetarget) + HeroAD_GSO) * 1.5 then
                                                local pos = AAlanetarget.pos
                                                local canaa = true
                                                for i = 1, MinionCount_GSO() do
                                                        local minion = Minion_GSO(i)
                                                        if minion.isAlly and IsValidTarget_GSO(minion.range + 200, AAlanetarget, pos.x, pos.z) then
                                                                canaa = false
                                                                break
                                                        end
                                                end
                                                if canaa then
                                                        AAtarget = AAlanetarget
                                                end
                                        else
                                                AAtarget = AAlanetarget
                                        end
                                end
                        elseif harass then
                                CurrentMode_GSO = "harass"
                                local t = GetEnemyMinions_GSO(HeroAArange_GSO, true)
                                for i = 1, #t do
                                        local unit          = t[i]
                                        local unitpos       = unit.pos
                                        local aacompleteT   = HerowindUpT_GSO + ( Sqrt_GSO((unitpos.x-HeroPosX_GSO)^2 + (unitpos.z-HeroPosZ_GSO)^2) / HeroProjS_GSO )
                                        local unitHP        = unit.health - GetHealthPrediction_GSO(unit, aacompleteT)
                                        local heroad        = GetBonusBuffDmg_GSO(unit) + HeroAD_GSO
                                        if unitHP < heroad and unitHP < lasthitNUM then
                                                AAtarget = unit
                                                lasthitNUM = unitHP
                                        else
                                                unitHP = unitHP - GetHealthPrediction_GSO(unit, 3 * HeroanimT_GSO)
                                                if unitHP < heroad then
                                                        AAkillablesoon = unit
                                                end
                                        end
                                end
                                if AAtarget == nil and AAkillablesoon == nil then
                                        local tfunc = GetTargetFunc_GSO()
                                        if tfunc ~= nil then
                                                AAtarget = tfunc
                                        else
                                                local t = GetEnemyHeroes_GSO(HeroAArange_GSO, true)
                                                for i = 1, #t do
                                                        local unit        = t[i]
                                                        local unithealth  = unit.health * ( 100 / ( 100 + unit.armor ) )
                                                        if unithealth < heroNUM then
                                                                heroNUM  = unithealth
                                                                AAtarget = unit
                                                        end
                                                end
                                        end
                                end
                        elseif lasthit then
                                CurrentMode_GSO = "lasthit"
                                local t = GetEnemyMinions_GSO(HeroAArange_GSO, true)
                                for i = 1, #t do
                                        local unit          = t[i]
                                        local unitpos       = unit.pos
                                        local aacompleteT   = HerowindUpT_GSO + ( Sqrt_GSO((unitpos.x-HeroPosX_GSO)^2 + (unitpos.z-HeroPosZ_GSO)^2) / HeroProjS_GSO )
                                        local unitHP = unit.health - GetHealthPrediction_GSO(unit, aacompleteT)
                                        local heroad        = GetBonusBuffDmg_GSO(unit) + HeroAD_GSO
                                        if unitHP < heroad and unitHP < lasthitNUM then
                                                AAtarget = unit
                                                lasthitNUM = unitHP
                                        end
                                end
                        end
                else
                        if combo then
                                CurrentMode_GSO = "combo"
                        elseif lane then
                                CurrentMode_GSO = "laneclear"
                        elseif harass then
                                CurrentMode_GSO = "harass"
                        elseif lasthit then
                                CurrentMode_GSO = "lasthit"
                        end
                end
                
                local checkT    = Game.Timer()
                -- ?? HK_TCO -- Target Champions Only
                local IsCasting = checkT < LastKeyPress_GSO + 0.1 and true or ( Control.IsKeyDown(HK_Q) or Control.IsKeyDown(HK_W) or Control.IsKeyDown(HK_E) or Control.IsKeyDown(HK_R) or Control.IsKeyDown(HK_ITEM_1) or Control.IsKeyDown(HK_ITEM_2) or Control.IsKeyDown(HK_ITEM_3) or Control.IsKeyDown(HK_ITEM_4) or Control.IsKeyDown(HK_ITEM_5) or Control.IsKeyDown(HK_ITEM_6) or Control.IsKeyDown(HK_ITEM_7) or Control.IsKeyDown(HK_SUMMONER_1) or Control.IsKeyDown(HK_SUMMONER_2) or Control.IsKeyDown(HK_LUS) or Control.IsKeyDown(HK_MENU) )
                CanAttack_GSO   = GetBooleanCanAttack2_GSO() and not IsCasting and not BlockAttack_GSO and checkT > LastAA_GSO + HeroanimT_GSO + 0.03
                CanMove_GSO     = not IsCasting and not BlockMovement_GSO and checkT > LastAA_GSO + HerowindUpT_GSO + MenuEwin_GSO

                if CanAttack_GSO and AAtarget ~= nil then
                        for i = 1, #BeforeAttackC_GSO do
                                BeforeAttackC_GSO[i](AAtarget)
                        end
                        local cPos = cursorPos
                        Control.SetCursorPos(AAtarget.pos)
                        Control.mouse_event(0x0008)
                        Control.mouse_event(0x0010)
                        LastAA_GSO = Game.Timer()
                        LastMove_GSO = 0
                        DelayedActionAA_GSO = { function() Control.SetCursorPos(cPos.x, cPos.y) end, Game.Timer(), Menuscp_GSO }
                        DelayedAction_GSO =
                        {
                                function()
                                        for i = 1, #AfterAttackC_GSO do
                                                AfterAttackC_GSO[i](AAtarget)
                                        end
                                end,
                                Game.Timer(),
                                HerowindUpT_GSO + MenuEwin_GSO
                        }
                elseif CanMove_GSO and Game.Timer() > LastMove_GSO + MenuHum_GSO then
                        Control.mouse_event(0x0008)
                        Control.mouse_event(0x0010)
                        LastMove_GSO = Game.Timer()
                end
        else
                CurrentMode_GSO = "none"
        end
end)
