if myHero.charName ~= "Ashe" then return end

require "GamsteronOrbwalker"

local MenuAshe_GSO = MenuElement({type = MENU, id = "menuashegso", name = "GSO Orb Addon - Ashe"})
        MenuAshe_GSO:MenuElement({type = MENU, id = "combo", name = "Combo"})
                MenuAshe_GSO.combo:MenuElement({id = "qc", name = "UseQ", value = true})
                MenuAshe_GSO.combo:MenuElement({id = "wc", name = "UseW", value = true})
        MenuAshe_GSO:MenuElement({type = MENU, id = "harass", name = "Harass"})
                MenuAshe_GSO.harass:MenuElement({id = "qh", name = "UseQ", value = true})
                MenuAshe_GSO.harass:MenuElement({id = "wh", name = "UseW", value = true})

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
        local mode = GetStringCurrentMode_GSO()
        if (MenuAshe_GSO.combo.qc:Value() and mode == "combo") or (MenuAshe_GSO.harass.qh:Value() and mode == "harass") then
                if GetTickCount() < lastQ + 500 then return end
                if Game.CanUseSpell(_Q) == 0 or QStacks >= 4 then
                        lastQ = GetTickCount()
                        DelayAction(function()
                                CastSpell_GSO(HK_Q)
                                DelayAction(function()
                                        ResetAA_GSO()
                                end, 0.05)
                        end, 0.15)
                end
        end
end)

local lastW = 0
function useW()
        if GetTickCount() < lastW + 500 or QStacks > 2 then return end
        if Game.CanUseSpell(_W) ~= 0 then return end
        local W = { delay = 0.25, speed = 2000, width = 100, range = 1200 }
        local target = GetTarget_GSO(W.range, false, false)
        if target == nil then return end
        local wPred = target:GetPrediction(2000,0.25)
        if not wPred or not wPred:ToScreen().onScreen then return end
        if target:GetCollision(100,2000,0.25) > 0 then return end
        CastSpell_GSO(HK_W, wPred)
        lastW = GetTickCount()
end

SetCastSpellAAFunc_GSO(function() useW() end)
SetCastSpellFunc_GSO(function() QStacks = CheckQStacks() + 1 end)
