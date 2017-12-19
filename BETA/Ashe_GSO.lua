

        if myHero.charName ~= "Ashe" then return end
        require "GamsteronOrbwalker"


--[------------------------------------------------------------------------------------------------------------------------------------------------------------]]


        local MenuAshe_AsheGSO = MenuElement({type = MENU, id = "menuashegso", name = "GSO Orb Addon - Ashe"})
                MenuAshe_AsheGSO:MenuElement({type = MENU, id = "combo", name = "Combo"})
                        MenuAshe_AsheGSO.combo:MenuElement({id = "qc", name = "UseQ", value = true})
                        MenuAshe_AsheGSO.combo:MenuElement({id = "wc", name = "UseW", value = true})
                MenuAshe_AsheGSO:MenuElement({type = MENU, id = "harass", name = "Harass"})
                        MenuAshe_AsheGSO.harass:MenuElement({id = "qh", name = "UseQ", value = true})
                        MenuAshe_AsheGSO.harass:MenuElement({id = "wh", name = "UseW", value = true})


--[------------------------------------------------------------------------------------------------------------------------------------------------------------]]


        local lastQ     = 0
        local lastW     = 0
        local lastReset = 0


--[------------------------------------------------------------------------------------------------------------------------------------------------------------]]


        local function IsValidTarget_AsheGSO(range, unit)
                local distance = math.sqrt((unit.pos.x-myHero.pos.x)^2 + (unit.pos.z-myHero.pos.z)^2)
                if distance < range and not unit.dead and unit.isTargetable and unit.visible and unit.valid then
                        return true
                end
                return false
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
                local num     = 0
                local target  = nil
                for i = 1, #t do
                        local unit    = t[i]
                        local unithp  = unit.health * ( 100 / ( 100 + unit.armor ) )
                        if unithp > num then
                                num  = unithp
                                target = unit
                        end
                end
                return target
        end


--[------------------------------------------------------------------------------------------------------------------------------------------------------------]]

        --[[local aaticks = 0
        local timeraa = 0
        local changed = myHero.attackData.endTime]]
        OnTickLogic_GSO(function()
                --[[if myHero.attackData.endTime > changed then
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
                local QReadyT = GetTickCount() > lastQ + 500
                local QReady  = false
                local QResetT = GetTickCount() > lastReset + 4500
                local QReset  = false
                for i = 0, myHero.buffCount do
                        local buff = myHero:GetBuff(i)
                        local name = buff.name:lower()
                        if buff.count > 0 then
                                if QReadyT and name == "asheqcastready" then
                                        QReady = true
                                end
                                if QResetT and name == "asheqattack" then
                                        QReset = true
                                end
                        end
                end
                if QReset then
                        ResetAA_GSO()
                        lastReset = GetTickCount()
                end
                if QReady then
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
                                                local cPos = cursorPos
                                                Control.SetCursorPos(wPred)
                                                Control.KeyDown(HK_W)
                                                Control.KeyUp(HK_W)
                                                lastW = GetTickCount()
                                                DelayAction(function()
                                                        Control.SetCursorPos(cPos.x, cPos.y)
                                                end, 0.05)
                                                BlockAttack_GSO(true)
                                                DelayAction(function()
                                                        BlockAttack_GSO(false)
                                                end, 0.3)
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
                        if buff.count > 0 then
                                local name = buff.name:lower()
                                if name == "ashepassiveslow" then
                                        return dmg * crit
                                end
                        end
                end
                return 0
        end)


--[------------------------------------------------------------------------------------------------------------------------------------------------------------]]

