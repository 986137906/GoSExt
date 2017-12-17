require "GamsteronOrbwalker"
require "Eternal Prediction"

local MenuAshe_GSO = MenuElement({type = MENU, id = "menuashegso", name = "GSO Orb Addon - Ashe"})
        MenuAshe_GSO:MenuElement({type = MENU, id = "combo", name = "Combo"})
                MenuAshe_GSO.combo:MenuElement({id = "qc", name = "UseQ", value = true})
                MenuAshe_GSO.combo:MenuElement({id = "wc", name = "UseW", value = true})
        MenuAshe_GSO:MenuElement({type = MENU, id = "harass", name = "Harass"})
                MenuAshe_GSO.harass:MenuElement({id = "qh", name = "UseQ", value = true})
                MenuAshe_GSO.harass:MenuElement({id = "wh", name = "UseW", value = true})

AfterAttack_GSO(function(unit)
        local mode = GetStringCurrentMode_GSO()
        if ((MenuAshe_GSO.combo.qc:Value() and mode == "combo") or (MenuAshe_GSO.harass.qh:Value() and mode == "harass")) and Game.CanUseSpell(_Q) == 0 then
                Control.CastSpell(HK_Q)
                DelayAction(function()
                        ResetAA_GSO()
                end, 0.15)
        end
end)

function CastW_AsheGSO()
        local mode = GetStringCurrentMode_GSO()
        if ((MenuAshe_GSO.combo.wc:Value() and mode == "combo") or (MenuAshe_GSO.harass.wh:Value() and mode == "harass")) and Game.CanUseSpell(_W) == 0 then
                local heroNUM = 10000
                local Wtarget = nil
                local t = GetEnemyHeroes_GSO(1200, false)
                for i = 1, #t do
                        local unit        = t[i]
                        local unithealth  = unit.health * ( 100 / ( 100 + unit.armor ) )
                        if unithealth < heroNUM then
                                heroNUM = unithealth
                                Wtarget = unit
                        end
                end
                if Wtarget ~= nil then
                      local W = {delay = 0.25, range = 1200,speed = 2000}
                      local Wdata = {speed = W.speed, delay = W.delay ,range = W.range}
                      local Wspell = Prediction:SetSpell(Wdata, TYPE_LINE, true)
                      local pred = Wspell:GetPrediction(Wtarget,myHero.pos)
                      if pred == nil then return end
                      if pred and pred.hitChance >= 0.25 and pred:mCollision() == 0 and pred:hCollision() == 0 then
                              Control.CastSpell(HK_W, pred.castPos)
                      end
                end
        end
end

SetCastSpellAAFunc_GSO(function() CastW_AsheGSO() end)
