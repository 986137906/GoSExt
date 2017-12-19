

        if myHero.charName ~= "Ashe" then return end
        require "GamsteronOrbwalker"


--[------------------------------------------------------------------------------------------------------------------------------------------------------------]]


        local MenuAshe_AsheGSO = MenuElement({type = MENU, id = "menuashegso", name = "GSO Orb Addon - Ashe 0.01"})
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


--[------------------------------------------------------------------------------------------------------------------------------------------------------------]]


        local lastQ     = 0
        local lastW     = 0
        local lastR     = 0


--[------------------------------------------------------------------------------------------------------------------------------------------------------------]]


        local function IsValidTarget_AsheGSO(range, unit)
                local distance = math.sqrt((unit.pos.x-myHero.pos.x)^2 + (unit.pos.z-myHero.pos.z)^2)
                if distance < range and not unit.dead and unit.isTargetable and unit.visible and unit.valid then
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
                for i = 1, Game.HeroCount() do
                        local hero = Game.Hero(i)
                        local r = addBB and range + hero.boundingRadius or range
                        if hero.isEnemy and IsValidTarget_AsheGSO(r, hero) then
                                result = result + 1
                        end
                end
                return result
        end

        local function GetEnemyHeroes_AsheGSO(range)
                local result = {}
                for i = 1, Game.HeroCount() do
                        local hero = Game.Hero(i)
                        if hero.isEnemy and IsValidTarget_AsheGSO(range, hero) then
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


--[------------------------------------------------------------------------------------------------------------------------------------------------------------]]


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
                        if (RcomboD and mode == "combo") or (RharassD and mode == "harass") then
                                local num = MenuAshe_AsheGSO.rdist:Value()
                                local t = nil
                                for i = 1, Game.HeroCount() do
                                        local hero = Game.Hero(i)
                                        local distance = math.sqrt((hero.pos.x-myHero.pos.x)^2 + (hero.pos.z-myHero.pos.z)^2)
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
                                        if hero.isEnemy and IsValidTarget_AsheGSO(1000, hero) and IsImmobileTarget(hero) then
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
                                return dmg * crit
                        end
                end
                return 0
        end)


--[------------------------------------------------------------------------------------------------------------------------------------------------------------]]

