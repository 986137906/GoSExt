        if myHero.charName ~= "Ashe" then return end

        require "GamsteronOrbwalker"

        local MenuAshe_AsheGSO = MenuElement({type = MENU, id = "menuashegso", name = "GSO Orb Addon - Ashe"})
                MenuAshe_AsheGSO:MenuElement({type = MENU, id = "combo", name = "Combo"})
                        MenuAshe_AsheGSO.combo:MenuElement({id = "qc", name = "UseQ", value = true})
                        MenuAshe_AsheGSO.combo:MenuElement({id = "wc", name = "UseW", value = true})
                MenuAshe_AsheGSO:MenuElement({type = MENU, id = "harass", name = "Harass"})
                        MenuAshe_AsheGSO.harass:MenuElement({id = "qh", name = "UseQ", value = true})
                        MenuAshe_AsheGSO.harass:MenuElement({id = "wh", name = "UseW", value = true})

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

        local QReadyT_AsheGSO   = 0
        local QResetT_AsheGSO   = 0
        OnTickLogic_GSO(function()
                local QReadyT = GetTickCount() > QReadyT_AsheGSO + 4500
                local QReady  = false
                local QResetT = GetTickCount() > QResetT_AsheGSO + 4500
                local QReset  = false
                for i = 0, myHero.buffCount do
                        local buff = myHero:GetBuff(i)
                        local name = buff.name:lower()
                        if buff.count > 0 then
                                if QReadyT and name == "asheqcastready" then
                                        QReady = true
                                end
                                if QResetT and name == "asheqattack" then
                                        QReset          = true
                                        QResetT_AsheGSO = GetTickCount()
                                end
                        end
                end
                if QReset then
                        ResetAA_GSO()
                end
                if QReady then
                        local mode = CurrentMode_GSO()
                        if (MenuAshe_AsheGSO.combo.qc:Value() and mode == "combo") or (MenuAshe_AsheGSO.harass.qh:Value() and mode == "harass") then
                                Control.KeyDown(HK_Q)
                                Control.KeyUp(HK_Q)
                                QReadyT_AsheGSO = GetTickCount()
                        end
                end
        end)

        local lastW_AsheGSO = 0
        local function useW_AsheGSO()
                local mode  = CurrentMode_GSO()
                local W     = { delay = 0.25, speed = 2000, width = 100, range = 1200 }
                if (MenuAshe_AsheGSO.combo.wc:Value() and mode == "combo") or (MenuAshe_AsheGSO.harass.wh:Value() and mode == "harass") then
                        if GetTickCount() > lastW_AsheGSO + 500 and QStacks <= 2 and Game.CanUseSpell(_W) == 0 then
                                local target = GetTarget_AsheGSO(W.range)
                                if target ~= nil then
                                        local wPred = target:GetPrediction(2000,0.25)
                                        if wPred and wPred:ToScreen().onScreen and target:GetCollision(100,2000,0.25) == 0 then
                                                local cPos = cursorPos
                                                Control.SetCursorPos(wPred)
                                                Control.KeyDown(HK_W)
                                                Control.KeyUp(HK_W)
                                                lastW_AsheGSO = GetTickCount()
                                                DelayAction(function()
                                                        Control.SetCursorPos(cPos.x, cPos.y)
                                                end, 0.075)
                                        end
                                end
                        end
                end
        end
        CastSpellAA_GSO(function() useW_AsheGSO() end)

        local function CheckPassiveDmg_AsheGSO(unit)
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
        BonusDmgUnit_GSO(function(unit) return CheckPassiveDmg_AsheGSO(unit) end)
