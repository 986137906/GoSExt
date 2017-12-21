

        require "GamsteronOrbwalker"

-- A S H E /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
-- A S H E /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
-- A S H E /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

        if myHero.charName == "Ashe" then
        
                local MenuAshe_AsheGSO = MenuElement({type = MENU, id = "menuashegso", name = "Gamsteron Ashe 0.02", leftIcon = "https://i.imgur.com/KZMYXcH.png"})
                        MenuAshe_AsheGSO:MenuElement({id = "rdist", name = "use R if enemy distance < X", value = 500, min = 100, max = 1000, step = 50})
                        MenuAshe_AsheGSO:MenuElement({type = MENU, id = "combo", name = "Combo"})
                                MenuAshe_AsheGSO.combo:MenuElement({id = "qc", name = "UseQ", value = true})
                                MenuAshe_AsheGSO.combo:MenuElement({id = "wc", name = "UseW", value = true})
                                MenuAshe_AsheGSO.combo:MenuElement({id = "rcd", name = "UseR [enemy distance < X", value = true})
                                MenuAshe_AsheGSO.combo:MenuElement({id = "rci", name = "UseR [enemy IsImmobile]", value = true})
                        MenuAshe_AsheGSO:MenuElement({type = MENU, id = "harass", name = "Harass"})
                                MenuAshe_AsheGSO.harass:MenuElement({id = "qh", name = "UseQ", value = true})
                                MenuAshe_AsheGSO.harass:MenuElement({id = "wh", name = "UseW", value = true})
                                MenuAshe_AsheGSO.harass:MenuElement({id = "rhd", name = "UseR [enemy distance < X]", value = false})
                                MenuAshe_AsheGSO.harass:MenuElement({id = "rhi", name = "UseR [enemy IsImmobile]", value = false})
                        MenuAshe_AsheGSO:MenuElement({type = MENU, id = "block", name = "Block Orb"})
                                MenuAshe_AsheGSO.block:MenuElement({id = "blockW", name = "Block orb if use W for X ms", value = 300, min = 0, max = 500, step = 50})
                                MenuAshe_AsheGSO.block:MenuElement({id = "blockR", name = "Block orb if use R for X ms", value = 300, min = 0, max = 500, step = 50})

                local lastQ     = 0
                local lastW     = 0
                local lastR     = 0
                
                local function IsValidTarget_AsheGSO(range, x, z, unit)
                        if x*x+z*z<=range*range and not unit.dead and unit.isTargetable and unit.visible and unit.valid then
                                return true
                        end
                        return false
                end

                local function IsValidTarget2_AsheGSO(unit)
                        if not unit.dead and unit.isTargetable and unit.visible and unit.valid then
                                return true
                        end
                        return false
                end

                local function CountEnemies_AsheGSO(range, addBB)
                        local result = 0
                        local me = myHero.pos
                        for i = 1, Game.HeroCount() do
                                local hero = Game.Hero(i)
                                local he = hero.pos
                                local r = addBB and range + (hero.boundingRadius-30) or range
                                if hero.isEnemy and IsValidTarget_AsheGSO(r, he.x-me.x, he.z-me.z, hero) then
                                        result = result + 1
                                end
                        end
                        return result
                end

                local function GetEnemyHeroes_AsheGSO(range)
                        local result = {}
                        local me = myHero.pos
                        for i = 1, Game.HeroCount() do
                                local hero = Game.Hero(i)
                                local he = hero.pos
                                if hero.isEnemy and IsValidTarget_AsheGSO(range, he.x-me.x, he.z-me.z, hero) then
                                        result[#result + 1] = hero
                                end
                        end
                        return result
                end

                local function GetTarget_AsheGSO(range)
                        local t       = GetEnemyHeroes_AsheGSO(range)
                        local num     = 10000000
                        local target  = nil
                        for i = 1, #t do
                                local unit  = t[i]
                                local armor = unit.armor - myHero.armorPen
                                      armor = armor > 0 and myHero.bonusArmorPenPercent * armor or armor
                                local unithealth  = unit.health + ( 2 * armor ) - ( unit.attackSpeed * unit.totalDamage ) - ( 1.5 * unit.ap )
                                if unithealth < num then
                                        num     = unithealth
                                        target  = unit
                                end
                        end
                        return target
                end
                
                function IsImmobileTarget(unit)
                        for i = 0, unit.buffCount do
                                local buff = unit:GetBuff(i)
                                local type = buff.type
                                if buff and buff.count > 0 and (type == 5 or type == 11 or type == 29 or type == 24 or buff.name == "recall") then
                                        return true
                                end
                        end
                        return false
                end

                OnTickLogic_GSO(function()
                        local QReadyT = GetTickCount() > lastQ + 500
                        local QReady  = false
                        for i = 0, myHero.buffCount do
                                local buff = myHero:GetBuff(i)
                                if QReadyT and buff.count > 0 and buff.name:lower() == "asheqcastready" then
                                        QReady = true
                                        break
                                end
                        end
                        if QReady and CountEnemies_AsheGSO(myHero.range + myHero.boundingRadius, true) > 0 then
                                local mode = CurrentMode_GSO()
                                if (MenuAshe_AsheGSO.combo.qc:Value() and mode == "combo") or (MenuAshe_AsheGSO.harass.qh:Value() and mode == "harass") then
                                        Control.KeyDown(HK_Q)
                                        Control.KeyUp(HK_Q)
                                        lastQ = GetTickCount()
                                end
                        end
                end)

                ComHarLogicAA_GSO(function()
                        if GetTickCount() > lastW + 500 and Game.CanUseSpell(_W) == 0 then
                                local mode = CurrentMode_GSO()
                                if (MenuAshe_AsheGSO.combo.wc:Value() and mode == "combo") or (MenuAshe_AsheGSO.harass.wh:Value() and mode == "harass") then
                                        local target = GetTarget_AsheGSO(1200)
                                        if target ~= nil then
                                                local wPred = target:GetPrediction(2000,0.25)
                                                if wPred and wPred:ToScreen().onScreen and target:GetCollision(100,2000,0.25) == 0 then
                                                        local BlockW = MenuAshe_AsheGSO.block.blockW:Value() * 0.001
                                                        BlockAttack_GSO(true)
                                                        BlockMovement_GSO(true)
                                                        DelayAction(function()
                                                                BlockAttack_GSO(false)
                                                                BlockMovement_GSO(false)
                                                        end, BlockW)
                                                        local cPos = cursorPos
                                                        Control.SetCursorPos(wPred)
                                                        Control.KeyDown(HK_W)
                                                        Control.KeyUp(HK_W)
                                                        lastW = GetTickCount()
                                                        DelayAction(function()
                                                                Control.SetCursorPos(cPos.x, cPos.y)
                                                        end, 0.05)
                                                end
                                        end
                                end
                        end
                        if GetTickCount() > lastR + 500 and Game.CanUseSpell(_R) == 0 then
                                local BlockR    = MenuAshe_AsheGSO.block.blockR:Value() * 0.001
                                local RcomboD   = MenuAshe_AsheGSO.combo.rcd:Value()
                                local RcomboI   = MenuAshe_AsheGSO.combo.rci:Value()
                                local mode = CurrentMode_GSO()
                                local me = myHero.pos
                                if (RcomboD and mode == "combo") or (RharassD and mode == "harass") then
                                        local num = MenuAshe_AsheGSO.rdist:Value()
                                        num = num*num
                                        local t = nil
                                        for i = 1, Game.HeroCount() do
                                                local hero = Game.Hero(i)
                                                local he = hero.pos
                                                local x = he.x-me.x
                                                local z = he.z-me.z
                                                local distance = x*x+z*z
                                                if hero.isEnemy and IsValidTarget2_AsheGSO(hero) and distance < num then
                                                        num = distance
                                                        t = hero
                                                end
                                        end
                                        if t ~= nil then
                                                local rPred = t:GetPrediction(1600,0.25)
                                                if rPred and rPred:ToScreen().onScreen then
                                                        BlockAttack_GSO(true)
                                                        BlockMovement_GSO(true)
                                                        DelayAction(function()
                                                                BlockAttack_GSO(false)
                                                                BlockMovement_GSO(false)
                                                        end, BlockR)
                                                        local cPos = cursorPos
                                                        Control.SetCursorPos(rPred)
                                                        Control.KeyDown(HK_R)
                                                        Control.KeyUp(HK_R)
                                                        lastR = GetTickCount()
                                                        DelayAction(function()
                                                                Control.SetCursorPos(cPos.x, cPos.y)
                                                        end, 0.05)
                                                end
                                        end
                                end
                                local RharassD  = MenuAshe_AsheGSO.harass.rhd:Value()
                                local RharassI  = MenuAshe_AsheGSO.harass.rhi:Value()
                                if GetTickCount() > lastR + 500 and ((RcomboI and mode == "combo") or (RharassI and mode == "harass")) then
                                        local t = nil
                                        for i = 1, Game.HeroCount() do
                                                local hero = Game.Hero(i)
                                                local he = hero.pos
                                                if hero.isEnemy and IsValidTarget_AsheGSO(1000, he.x-me.x, he.z-me.z, hero) and IsImmobileTarget(hero) then
                                                        t = hero
                                                        break
                                                end
                                        end
                                        if t ~= nil then
                                                local rPred = t.pos
                                                if rPred and rPred:ToScreen().onScreen then
                                                        BlockAttack_GSO(true)
                                                        BlockMovement_GSO(true)
                                                        DelayAction(function()
                                                                BlockAttack_GSO(false)
                                                                BlockMovement_GSO(false)
                                                        end, BlockR)
                                                        local cPos = cursorPos
                                                        Control.SetCursorPos(rPred)
                                                        Control.KeyDown(HK_R)
                                                        Control.KeyUp(HK_R)
                                                        lastR = GetTickCount()
                                                        DelayAction(function()
                                                                Control.SetCursorPos(cPos.x, cPos.y)
                                                        end, 0.05)
                                                end
                                        end
                                end
                        end
                end)

                BonusDmgUnit_GSO(function(unit)
                        local dmg = myHero.totalDamage
                        local crit = 0.1 + myHero.critChance
                        for i = 0, unit.buffCount do
                                local buff = unit:GetBuff(i)
                                if buff.count > 0 and buff.name:lower() == "ashepassiveslow" then
                                        local aacompleteT = myHero.attackData.windUpTime + (math.sqrt((unit.pos.x-myHero.pos.x)^2 + (unit.pos.z-myHero.pos.z)^2) / myHero.attackData.projectileSpeed)
                                        if aacompleteT + 0.1 < buff.duration then
                                                return dmg * crit
                                        end
                                        --[[ buff.duration, example:
                                                print(buff.startTime.." "..buff.expireTime.." "..buff.duration.." "..Game.Timer())
                                                221.715438842277    223.71543884277      0.16038513183594           223.55505371094
                                                223,71543884277-223,55505371094=0,16038513183
                                          ]]
                                end
                        end
                        return 0
                end)

-- T W I T C H /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
-- T W I T C H /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
-- T W I T C H /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\

        elseif myHero.charName == "Twitch" then

                local MenuTwitch_GSO = MenuElement({type = MENU, id = "twitchgso", name = "GSO Twitch 0.01", leftIcon = "https://i.imgur.com/0gy25Yj.png"})
                        MenuTwitch_GSO:MenuElement({type = MENU, id = "combo", name = "Combo"})
                                MenuTwitch_GSO.combo:MenuElement({id = "wc", name = "UseW", value = true})
                                MenuTwitch_GSO.combo:MenuElement({id = "ec", name = "UseE", value = true})
                        MenuTwitch_GSO:MenuElement({type = MENU, id = "harass", name = "Harass"})
                                MenuTwitch_GSO.harass:MenuElement({id = "wh", name = "UseW", value = true})
                                MenuTwitch_GSO.harass:MenuElement({id = "eh", name = "UseE", value = true})

                local HeroCount_GSO = Game.HeroCount
                local Hero_GSO      = Game.Hero
                local lastW         = 0
                local lastE         = 0
                local Ebuffs        = {}
                local DelAc1        = nil

                local function IsValidTarget_GSO(range, unit, x, z)
                        if x*x+z*z<=range*range and not unit.dead and unit.isTargetable and unit.visible and unit.valid then
                                return true
                        end
                        return false
                end

                local function GetEnemyHeroes_GSO(range)
                        local result = {}
                        local me = myHero.pos
                        for i = 1, HeroCount_GSO() do
                                local hero = Hero_GSO(i)
                                local he = hero.pos
                                if hero.isEnemy and IsValidTarget_GSO(range + (hero.boundingRadius-30), hero, he.x-me.x, he.z-me.z) then
                                        result[#result + 1] = hero
                                end
                        end
                        return result
                end
                
                local function GetTargetTwitch_GSO(range)
                        local t       = GetEnemyHeroes_GSO(range)
                        local num     = 10000000
                        local target  = nil
                        for i = 1, #t do
                                local unit = t[i]
                                local armor = unit.armor - myHero.armorPen
                                      armor = armor > 0 and myHero.bonusArmorPenPercent * armor or armor
                                local unithealth  = unit.health + ( 2 * unit.armor ) - ( unit.attackSpeed * unit.totalDamage ) - ( 1.5 * unit.ap )
                                if unithealth < num then
                                        num     = unithealth
                                        target  = unit
                                end
                        end
                        return target
                end

                OnTickLogic_GSO(function()
                        if DelAc1 ~= nil and GetTickCount() - DelAc1[2] > DelAc1[3] then
                                DelAc1[1]()
                                DelAc1 = nil
                        end
                        local hcount = HeroCount_GSO()
                        for i = 1, hcount do
                                local target  = Hero_GSO(i)
                                local nID     = target.networkID
                                if not Ebuffs[nID] then
                                        Ebuffs[nID]={count=0,durT=0}
                                end
                                if target.isEnemy and not target.dead then
                                        local hasB = false
                                        local cB = Ebuffs[nID].count
                                        local dB = Ebuffs[nID].durT
                                        local Bcount = target.buffCount
                                        for i = 0, Bcount do
                                                local buff = target:GetBuff(i)
                                                if buff.count > 0 and buff.name:lower() == "twitchdeadlyvenom" then
                                                        hasB = true
                                                        if cB < 6 and buff.duration > dB then
                                                                Ebuffs[nID].count = cB + 1
                                                                Ebuffs[nID].durT = buff.duration
                                                        else
                                                                Ebuffs[nID].durT = buff.duration
                                                        end
                                                        break
                                                end
                                        end
                                        if not hasB then
                                                Ebuffs[nID].count = 0
                                                Ebuffs[nID].durT = 0
                                        end
                                        if GetTickCount() > lastE + 500 and Game.CanUseSpell(_E) == 0 and target.isTargetable and target.valid and Ebuffs[nID].count > 0 then
                                                local me = myHero.pos
                                                local he = target.pos
                                                local x = he.x-me.x
                                                local z = he.z-me.z
                                                if x*x+z*z<=1200*1200 then
                                                        local elvl = myHero:GetSpellData(_E).level
                                                        local basedmg = 5 + ( elvl * 15 )
                                                        local cstacks = Ebuffs[nID].count
                                                        local perstack = ( 10 + (5*elvl) ) * cstacks
                                                        local bonusAD = myHero.bonusDamage * 0.25 * cstacks
                                                        local bonusAP = myHero.ap * 0.2 * cstacks
                                                        local edmg = basedmg + perstack + bonusAD + bonusAP
                                                        local tarm = target.armor - myHero.armorPen
                                                        tarm = tarm > 0 and myHero.armorPenPercent * tarm or tarm
                                                        local DmgDealt = tarm > 0 and edmg * ( 100 / ( 100 + tarm ) ) or edmg * ( 2 - ( 100 / ( 100 + tarm ) ) )
                                                        local HPRegen = target.hpRegen * 3
                                                        local CanKill = target.health + target.shieldAD + HPRegen < DmgDealt
                                                        if CanKill then
                                                                Control.KeyDown(HK_E)
                                                                Control.KeyUp(HK_E)
                                                                lastE = GetTickCount()
                                                        end
                                                end
                                        end
                                end
                        end
                end)

                ComHarLogicAA_GSO(function()
                        if GetTickCount() > lastE + 500 and Game.CanUseSpell(_E) == 0 then
                                local mode = CurrentMode_GSO()
                                if (MenuTwitch_GSO.combo.ec:Value() and mode == "combo") or (MenuTwitch_GSO.harass.eh:Value() and mode == "harass") then
                                        local target = LastAttackTarget_GSO()
                                        if target ~= nil and not target.dead and target.isTargetable and target.valid then
                                                local nID = target.networkID
                                                if Ebuffs[nID] and Ebuffs[nID].count == 6 then
                                                        Control.KeyDown(HK_E)
                                                        Control.KeyUp(HK_E)
                                                        lastE = GetTickCount()
                                                end
                                        end
                                end
                        end
                        if GetTickCount() > lastW + 500 and Game.CanUseSpell(_W) == 0 and not CanAttack_GSO() and CanMove_GSO() and not IsAttacking_GSO() then
                                local mode = CurrentMode_GSO()
                                if (MenuTwitch_GSO.combo.wc:Value() and mode == "combo") or (MenuTwitch_GSO.harass.wh:Value() and mode == "harass") then
                                        local target = GetTargetTwitch_GSO(950)
                                        if target ~= nil then
                                                local wPred = target:GetPrediction(1400,0.25)
                                                if wPred and wPred:ToScreen().onScreen then
                                                        local cPos = cursorPos
                                                        Control.SetCursorPos(wPred)
                                                        Control.KeyDown(HK_W)
                                                        Control.KeyUp(HK_W)
                                                        lastW = GetTickCount()
                                                        DelAc1 = {function() Control.SetCursorPos(cPos.x, cPos.y) end, GetTickCount(), 50}
                                                end
                                        end
                                end
                        end
                end)
        else
                print("this hero is not supported!")
        end
