        if myHero.charName ~= "Ashe" then return end

        require "GamsteronOrbwalker"

        local MenuAshe_GSO = MenuElement({type = MENU, id = "menuashegso", name = "GSO Orb Addon - Ashe"})
                MenuAshe_GSO:MenuElement({type = MENU, id = "combo", name = "Combo"})
                        MenuAshe_GSO.combo:MenuElement({id = "qc", name = "UseQ", value = true})
                        MenuAshe_GSO.combo:MenuElement({id = "wc", name = "UseW", value = true})
                MenuAshe_GSO:MenuElement({type = MENU, id = "harass", name = "Harass"})
                        MenuAshe_GSO.harass:MenuElement({id = "qh", name = "UseQ", value = true})
                        MenuAshe_GSO.harass:MenuElement({id = "wh", name = "UseW", value = true})

        local function IsValidTarget_GSO(range, unit)
                local distance = math.sqrt((unit.pos.x-myHero.pos.x)^2 + (unit.pos.z-myHero.pos.z)^2)
                if distance < range and not unit.dead and unit.isTargetable and unit.visible and unit.valid then
                        return true
                end
                return false
        end
        
        local function GetEnemyHeroes_GSO(range)
                local result = {}
                for i = 1, HeroCount_GSO() do
                        local hero = Hero_GSO(i)
                        if hero.isEnemy and IsValidTarget_GSO(range, hero) then
                                result[#result + 1] = hero
                        end
                end
                return result
        end
        
        local function GetTarget_Ashe(range)
                local t       = GetEnemyHeroes_GSO(range)
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

        local QStacks = 0
        function CheckQStacks()
                for i = 0, myHero.buffCount do
                        local buff = myHero:GetBuff(i)
                        if buff.count > 0 then
                                local name = buff.name:lower()
                                if name == "asheq" then
                                        return buff.count
                                end
                                if name == "asheqcastready" then
                                        return 4
                                end
                        end
                end
                return 0
        end

        local lastQ = 0
        AfterAttack_GSO(function(unit)
                local mode = CurrentMode_GSO()
                if (MenuAshe_GSO.combo.qc:Value() and mode == "combo") or (MenuAshe_GSO.harass.qh:Value() and mode == "harass") then
                        if GetTickCount() < lastQ + 500 then return end
                        if Game.CanUseSpell(_Q) == 0 or QStacks >= 4 then
                                DelayAction(function()
                                        Control.KeyDown(HK_Q)
                                        Control.KeyUp(HK_Q)
                                        ResetAA_GSO()
                                        lastQ = GetTickCount()
                                end, 0.1)
                        end
                end
        end)

        local lastW = 0
        function useW()
                local mode  = CurrentMode_GSO()
                local W     = { delay = 0.25, speed = 2000, width = 100, range = 1200 }
                if (MenuAshe_GSO.combo.wc:Value() and mode == "combo") or (MenuAshe_GSO.harass.wh:Value() and mode == "harass") then
                        if GetTickCount() > lastW + 500 and QStacks <= 2 and Game.CanUseSpell(_W) == 0 then
                                local target = GetTarget_Ashe(W.range)
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
                                                end, 0.075)
                                        end
                                end
                        end
                end
        end

        function CheckPassiveDmg(unit)
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
        end

        CastSpellAA_GSO(function() useW() end)
        CastSpell_GSO(function() QStacks = CheckQStacks() + 1 end)
        BonusDmgUnit_GSO(function(unit) return CheckPassiveDmg(unit) end)
