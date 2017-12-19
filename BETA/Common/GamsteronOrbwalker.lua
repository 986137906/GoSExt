

                    -- [[  S T A R T  .  M E N U  ]]


        local Menu_GSO = MenuElement({type = MENU, id = "menugso", name = "Gamsteron Orbwalker 0.01"})

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
                        Menu_GSO.farm:MenuElement({id = "lcs", name = "LastHit Delay", value = 50, min = 0, max = 200, step = 25 })


--[------------------------------------------------------------------------------------------------------------------------------------------------------------]]


                    -- [[  S T A R T  .  V A R S  ]]

        local LastMove_GSO          = 0
        local LastKeyPress_GSO      = 0
        local OtherOrbTimer_GSO     = GetTickCount()
        local CanCheckOrb_GSO       = false
        local EOWLoaded_GSO         = false
        local IcyLoaded_GSO         = false
        local DelayedActionAA_GSO   = nil

        local Sqrt_GSO              = math.sqrt
        local Floor_GSO             = math.floor
        local MinionCount_GSO       = Game.MinionCount
        local Minion_GSO            = Game.Minion
        local HeroCount_GSO         = Game.HeroCount
        local Hero_GSO              = Game.Hero


--[------------------------------------------------------------------------------------------------------------------------------------------------------------]]


                    -- [[  S T A R T  .  G L O B A L  ]]

        local LocalAfterAttack_GSO = {}
        function AfterAttack_GSO(arg)
                LocalAfterAttack_GSO[#LocalAfterAttack_GSO + 1] = arg
        end
        local LocalBeforeAttack_GSO = {}
        function BeforeAttack_GSO(arg)
                LocalBeforeAttack_GSO[#LocalBeforeAttack_GSO + 1] = arg
        end
        local LocalCurrentMode_GSO = "none"
        function CurrentMode_GSO()
                return LocalCurrentMode_GSO
        end
        local LocalCanMove_GSO = true
        function CanMove_GSO()
                return LocalCanMove_GSO
        end
        local LocalCanAttack_GSO = true
        function CanAttack_GSO()
                return LocalCanAttack_GSO
        end
        local LocalBlockMove_GSO = false
        function BlockMovement_GSO(boolean)
                LocalBlockMove_GSO = boolean
        end
        local LocalBlockAttack_GSO = false
        function BlockAttack_GSO(boolean)
                LocalBlockAttack_GSO = boolean
        end
        local LocalLastAA_GSO = 0
        function LastAATick_GSO()
                return LocalLastAA_GSO
        end
        function ResetAA_GSO()
                LocalLastAA_GSO = 0
        end
        local function LocalAttackRange_GSO()
                return myHero.range
        end
        function AttackRange_GSO(func)
                LocalAttackRange_GSO = func
        end
        local function LocalBonusDmg_GSO()
                return 0
        end
        function BonusDmg_GSO(func)
                LocalBonusDmg_GSO = func
        end
        local function LocalBonusDmgUnit_GSO(unit)
                return 0
        end
        function BonusDmgUnit_GSO(func)
                LocalBonusDmgUnit_GSO = func
        end
        local function LocalCanAttackAdd_GSO()
                return true
        end
        function CanAttackAdd_GSO(func)
                LocalCanAttackAdd_GSO = func
        end
        local function LocalYourGetTarget_GSO()
                return nil
        end
        function YourGetTarget_GSO(func)
                LocalYourGetTarget_GSO = func
        end
        local function LocalComHarLogicAA_GSO()
        end
        function ComHarLogicAA_GSO(func)
                LocalComHarLogicAA_GSO = func
        end
        local function LocalComHarLogic_GSO()
        end
        function ComHarLogic_GSO(func)
                LocalComHarLogic_GSO = func
        end
        local function LocalOnTickLogic_GSO()
        end
        function OnTickLogic_GSO(func)
                LocalOnTickLogic_GSO = func
        end
        local function LocalGetWindUpAA_GSO()
                return myHero.attackData.windUpTime
        end
        function GetWindUpAA_GSO(func)
                LocalGetWindUpAA_GSO = func
        end
        local function LocalGetAnimationAA_GSO()
                return myHero.attackData.animationTime
        end
        function GetAnimationAA_GSO(func)
                LocalGetAnimationAA_GSO = func
        end
        local function LocalGetProjSpeedAA_GSO()
                return myHero.attackData.projectileSpeed
        end
        function GetProjSpeedAA_GSO(func)
                LocalGetProjSpeedAA_GSO = func
        end


--[------------------------------------------------------------------------------------------------------------------------------------------------------------]]


                    -- [[  S T A R T  .  F U N C T I O N S  ]]

        local function IsValidTarget_GSO(range, unit, sourcePos)
                local type      = unit.type
                local isUnit    = type == Obj_AI_Hero or type == Obj_AI_Minion or type == Obj_AI_Turret
                local isValid   = isUnit and unit.valid or true
                if math.sqrt((unit.pos.x-sourcePos.x)^2 + (unit.pos.z-sourcePos.z)^2) < range and not unit.dead and unit.isTargetable and unit.visible and isValid then
                        return true
                end
                return false
        end

        local function GetAllyMinions_GSO(range)
                local result = {}
                for i = 1, MinionCount_GSO() do
                        local minion = Minion_GSO(i)
                        if minion.isAlly and IsValidTarget_GSO(range, minion, myHero.pos) then
                                result[#result + 1] = minion
                        end
                end
                return result
        end

        local function GetEnemyMinions_GSO(range)
                local result = {}
                for i = 1, MinionCount_GSO() do
                        local minion = Minion_GSO(i)
                        local isotherminion = minion.maxHealth <= 6
                        if minion.isEnemy and not isotherminion and IsValidTarget_GSO(range + minion.boundingRadius, minion, myHero.pos) then
                                result[#result + 1] = minion
                        end
                end
                return result
        end

        local function GetEnemyHeroes_GSO(range)
                local result = {}
                for i = 1, HeroCount_GSO() do
                        local hero = Hero_GSO(i)
                        if hero.isEnemy and IsValidTarget_GSO(range + hero.boundingRadius, hero, myHero.pos) then
                                result[#result + 1] = hero
                        end
                end
                return result
        end

        local function GetHealthPrediction_GSO(unit, time)
                local result    = 0
                local unitpos   = unit.pos
                local unitid    = unit.handle
                local t         = GetAllyMinions_GSO(2000)
                local menulcs   = 0.001 * (200 - Menu_GSO.farm.lcs:Value())
                for i = 1, #t do
                        local minion = t[i]
                        if minion.attackData.target == unitid then
                                local minion_pos        = minion.pos
                                local minion_aadata     = minion.attackData
                                local minion_projspeed  = minion_aadata.projectileSpeed
                                local minion_animT      = minion_aadata.animationTime
                                local minion_projT      = minion_projspeed > 0 and Sqrt_GSO((unitpos.x-minion_pos.x)^2 + (unitpos.z-minion_pos.z)^2) / minion_projspeed or 0
                                local aacompleteT       = minion_aadata.endTime + minion_projT - ( minion_animT - minion_aadata.windUpTime )
                                local checkT            = Game.Timer()
                                aacompleteT             = checkT < aacompleteT and aacompleteT or aacompleteT + minion_animT
                                if aacompleteT - checkT < time + menulcs then
                                        local minion_ad = Floor_GSO(minion.totalDamage*0.8)
                                        result = result + minion_ad
                                        for j = 1, 5 do
                                                aacompleteT = aacompleteT + minion_animT
                                                if checkT < aacompleteT and aacompleteT - checkT < time + menulcs then
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
        
        local function DisableOrbwalkers_GSO()
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
                elseif GetTickCount() > OtherOrbTimer_GSO + 3000 then
                        if _G.EOWLoaded then
                                EOWLoaded_GSO = true
                        end
                        if _G.SDK and _G.SDK.Orbwalker then
                                IcyLoaded_GSO = true
                        end
                        print("GamsteronOrbwalker 0.01 Loaded!")
                        CanCheckOrb_GSO = true
                end
        end
        
        local function SetMode_GSO(combo, harass, lane, lasthit)
                if combo then
                        LocalCurrentMode_GSO = "combo"
                elseif lane then
                        LocalCurrentMode_GSO = "laneclear"
                elseif harass then
                        LocalCurrentMode_GSO = "harass"
                elseif lasthit then
                        LocalCurrentMode_GSO = "lasthit"
                else
                        LocalCurrentMode_GSO = "none"
                end
        end
        
        local function GetTarget_GSO(combo, lane, harass, lasthit)
                local AAtarget          = nil
                local AAlanetarget      = nil
                local AAmaxlanetarget   = nil
                local AAkillablesoon    = nil
                local heroNUM           = 10000
                local lasthitNUM        = 10000
                local laneclearNUM      = 10000
                local lanemaxNUM        = 0
                local HeroAD_GSO        = myHero.totalDamage + LocalBonusDmg_GSO()
                if combo then
                        local tfunc = LocalYourGetTarget_GSO()
                        if tfunc ~= nil then
                                AAtarget = tfunc
                        else
                                local t = GetEnemyHeroes_GSO(LocalAttackRange_GSO() + myHero.boundingRadius)
                                for i = 1, #t do
                                        local unit        = t[i]
                                        local unithealth  = unit.health + ( 2 * unit.armor ) - ( unit.attackSpeed * unit.totalDamage ) - ( 1.5 * unit.ap )
                                        if unithealth < heroNUM then
                                                heroNUM  = unithealth
                                                AAtarget = unit
                                        end
                                end
                        end
                elseif lane then
                        local t = GetEnemyMinions_GSO(LocalAttackRange_GSO() + myHero.boundingRadius)
                        for i = 1, #t do
                                local unit          = t[i]
                                local unitpos       = unit.pos
                                local aacompleteT   = LocalGetWindUpAA_GSO() + (Sqrt_GSO((unitpos.x-myHero.pos.x)^2 + (unitpos.z-myHero.pos.z)^2) / LocalGetProjSpeedAA_GSO())
                                local unitHP        = unit.health - GetHealthPrediction_GSO(unit, aacompleteT)
                                local heroad        = LocalBonusDmgUnit_GSO(unit) + HeroAD_GSO
                                if unitHP < heroad and unitHP < lasthitNUM then
                                        AAtarget = unit
                                        lasthitNUM = unitHP
                                else
                                        unitHP = unitHP - GetHealthPrediction_GSO(unit, 3 * LocalGetAnimationAA_GSO())
                                        if unitHP < heroad then
                                                AAkillablesoon = unit
                                        else
                                                if unitHP < laneclearNUM then
                                                        laneclearNUM = unitHP
                                                        AAlanetarget = unit
                                                end
                                                if unitHP > lanemaxNUM then
                                                        lanemaxNUM = unitHP
                                                        AAmaxlanetarget = unit
                                                end
                                        end
                                end
                        end
                        if AAtarget == nil and AAkillablesoon == nil and AAlanetarget ~= nil then
                                if laneclearNUM < (LocalBonusDmgUnit_GSO(AAlanetarget) + HeroAD_GSO) * 2 then
                                        local pos = AAlanetarget.pos
                                        local canaa = true
                                        for i = 1, MinionCount_GSO() do
                                                local minion = Minion_GSO(i)
                                                if minion.isAlly and IsValidTarget_GSO(minion.range + 200, AAlanetarget, pos) then
                                                        canaa = false
                                                        break
                                                end
                                        end
                                        if canaa then
                                                AAtarget = AAlanetarget
                                        elseif AAmaxlanetarget ~= nil then
                                                AAtarget = AAmaxlanetarget
                                        end
                                else
                                        AAtarget = AAlanetarget
                                end
                        end
                elseif harass then
                        local t = GetEnemyMinions_GSO(LocalAttackRange_GSO() + myHero.boundingRadius)
                        for i = 1, #t do
                                local unit          = t[i]
                                local unitpos       = unit.pos
                                local aacompleteT   = LocalGetWindUpAA_GSO() + (Sqrt_GSO((unitpos.x-myHero.pos.x)^2 + (unitpos.z-myHero.pos.z)^2) / LocalGetProjSpeedAA_GSO())
                                local unitHP        = unit.health - GetHealthPrediction_GSO(unit, aacompleteT)
                                local heroad        = LocalBonusDmgUnit_GSO(unit) + HeroAD_GSO
                                if unitHP < heroad and unitHP < lasthitNUM then
                                        AAtarget = unit
                                        lasthitNUM = unitHP
                                else
                                        unitHP = unitHP - GetHealthPrediction_GSO(unit, 3 * LocalGetAnimationAA_GSO())
                                        if unitHP < heroad then
                                                AAkillablesoon = unit
                                        end
                                end
                        end
                        if AAtarget == nil and AAkillablesoon == nil then
                                local t = GetEnemyHeroes_GSO(LocalAttackRange_GSO() + myHero.boundingRadius)
                                for i = 1, #t do
                                        local unit        = t[i]
                                        local unithealth  = unit.health + ( 2 * unit.armor ) - ( unit.attackSpeed * unit.totalDamage ) - ( 1.5 * unit.ap )
                                        if unithealth < heroNUM then
                                                heroNUM  = unithealth
                                                AAtarget = unit
                                        end
                                end
                        end
                elseif lasthit then
                        local t = GetEnemyMinions_GSO(LocalAttackRange_GSO() + myHero.boundingRadius)
                        for i = 1, #t do
                                local unit          = t[i]
                                local unitpos       = unit.pos
                                local aacompleteT   = LocalGetWindUpAA_GSO() + (Sqrt_GSO((unitpos.x-myHero.pos.x)^2 + (unitpos.z-myHero.pos.z)^2) / LocalGetProjSpeedAA_GSO())
                                local unitHP        = unit.health - GetHealthPrediction_GSO(unit, aacompleteT)
                                local heroad        = LocalBonusDmgUnit_GSO(unit) + HeroAD_GSO
                                if unitHP < heroad and unitHP < lasthitNUM then
                                        AAtarget = unit
                                        lasthitNUM = unitHP
                                end
                        end
                end
                return AAtarget
        end
        
        local function Orb_GSO(AAtarget, extraWindUp)
                local checkT        = GetTickCount()
                LocalCanAttack_GSO  = LocalCanAttackAdd_GSO() and checkT > LocalLastAA_GSO + (LocalGetAnimationAA_GSO()*1000) + 125
                LocalCanMove_GSO    = checkT > LocalLastAA_GSO + (LocalGetWindUpAA_GSO()*1000) + extraWindUp
                if LocalCanAttack_GSO and not LocalBlockAttack_GSO and AAtarget ~= nil then
                        for i = 1, #LocalBeforeAttack_GSO do
                                LocalBeforeAttack_GSO[i](AAtarget)
                        end
                        local cPos = cursorPos
                        Control.SetCursorPos(AAtarget.pos)
                        Control.KeyDown(HK_TCO)
                        Control.KeyUp(HK_TCO)
                        Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
                        Control.mouse_event(MOUSEEVENTF_RIGHTUP)
                        LocalLastAA_GSO = GetTickCount()
                        LastMove_GSO = 0
                        DelayedActionAA_GSO = { function() Control.SetCursorPos(cPos.x, cPos.y) end, GetTickCount(), Menu_GSO.attack.setc:Value() }
                        --[[DelayAction(function()
                                Control.SetCursorPos(cPos.x, cPos.y)
                        end, Menu_GSO.attack.setc:Value() * 0.001)]]
                        DelayAction(function()
                                for i = 1, #LocalAfterAttack_GSO do
                                        LocalAfterAttack_GSO[i](AAtarget)
                                end
                        end, LocalGetWindUpAA_GSO() + (extraWindUp*0.001))
                elseif LocalCanMove_GSO and not LocalBlockMove_GSO and GetTickCount() > LastMove_GSO + Menu_GSO.move.hum:Value() then
                        Control.mouse_event(0x0008)
                        Control.mouse_event(0x0010)
                        LastMove_GSO = GetTickCount()
                end
        end
        
        local function DoDevFunc_GSO(AAtarget, extraWindUp, combo, harass)
                if combo or harass then
                        local checkT = GetTickCount()
                        if DelayedActionAA_GSO == nil then
                                if AAtarget == true then
                                        if checkT > LocalLastAA_GSO + (LocalGetWindUpAA_GSO()*1000) + extraWindUp and not LocalCanAttack_GSO and checkT < LocalLastAA_GSO + (LocalGetAnimationAA_GSO()*700) + 125 then
                                                LocalComHarLogicAA_GSO()
                                        end
                                elseif checkT > LocalLastAA_GSO + (LocalGetWindUpAA_GSO()*1000) + extraWindUp then
                                        LocalComHarLogicAA_GSO()
                                end
                                LocalComHarLogic_GSO()
                        end
                end
        end


--[------------------------------------------------------------------------------------------------------------------------------------------------------------]]


        Callback.Add("WndMsg", function(msg, wParam)
                if LocalCurrentMode_GSO == "none" or GetTickCount() < LastKeyPress_GSO + 100 then return end
                local i = wParam
                if i == HK_Q or i == HK_W or i == HK_E or i == HK_R or i == HK_ITEM_1 or i == HK_ITEM_2 or i == HK_ITEM_3 or i == HK_ITEM_4 or i == HK_ITEM_5 or i == HK_ITEM_6 or i == HK_ITEM_7 or i == HK_SUMMONER_1 or i == HK_SUMMONER_2 then
                        LastKeyPress_GSO = GetTickCount()
                        Control.KeyDown(i)
                        Control.KeyUp(i)
                        Control.KeyDown(i)
                        Control.KeyUp(i)
                        Control.KeyDown(i)
                        Control.KeyUp(i)
                end
        end)

        Callback.Add("Tick", function()
                if DelayedActionAA_GSO ~= nil and GetTickCount() - DelayedActionAA_GSO[2] > DelayedActionAA_GSO[3] then
                        DelayedActionAA_GSO[1]()
                        DelayedActionAA_GSO = nil
                end
                if DelayedActionAA_GSO == nil then
                        LocalOnTickLogic_GSO()
                end
                local combo           = Menu_GSO.keys.combo:Value()
                local harass          = Menu_GSO.keys.har:Value()
                local lane            = Menu_GSO.keys.lane:Value()
                local lasthit         = Menu_GSO.keys.lhit:Value()
                local extraWindUp     = Menu_GSO.move.ewin:Value()
                SetMode_GSO(combo, harass, lane, lasthit)
                DisableOrbwalkers_GSO()
                if combo or lane or harass or lasthit then
                        local AAtarget = not LocalBlockAttack_GSO and GetTarget_GSO(combo, lane, harass, lasthit) or nil
                        Orb_GSO(AAtarget, extraWindUp)
                        DoDevFunc_GSO(AAtarget~=nil, extraWindUp, combo, harass)
                end
        end)


--[------------------------------------------------------------------------------------------------------------------------------------------------------------]]

