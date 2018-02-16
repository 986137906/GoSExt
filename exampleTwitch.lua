require "GamsteronOrb"
------------------------------------------------------------------------------------------
local menu
local hasQBuff = false
local qBuffTime = 0
local lastW  = 0
local lastE  = 0
local eBuffs = {}
local asNoQ = myHero.attackSpeed
local boolRecall = true
local QASBuff = false
local QASTime = 0
Icons = {
    ["arrow"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png",
    ["circles"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/circles.png",
    ["timer"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/timer.png",
    ["twitch"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/twitch.png"
}
------------------------------------------------------------------------------------------
local getTick = 0
local wMinus = 0
local wMinuss = 0
local eMinus = 0
local eMinuss = 0
------------------------------------------------------------------------------------------
local function aaSpeed()
    local num1 = GetTickCount()-QASTime-(gsoSDK.Utils.maxPing*1000)
    if num1 > -150 and num1 < 1500 then
        return asNoQ
    end
    return myHero.attackSpeed
end
------------------------------------------------------------------------------------------
local function onMove(args)
    if wMinus < 250 or wMinuss < 250 or eMinus < 250 or eMinuss < 250 then
        args.Process = false
    end
end
------------------------------------------------------------------------------------------
local function onAttack(args)
    if wMinus < 450 or wMinuss < 450 or eMinus < 400 or eMinuss < 400 then
        args.Process = false
    end
    local num1 = 1350-(getTick-gsoSDK.Spells.lastQ)
    if num1 > -50 and num1 < (gsoSDK.Orb.windUpT*1000) + 250 then
        args.Process = false
    end
end
------------------------------------------------------------------------------------------
local function afterAttack(target)
    local isUnit = target and target.type == Obj_AI_Hero
    local isCombo = gsoSDK.Load.menu.orb.keys.combo:Value()
    local isHarass = gsoSDK.Load.menu.orb.keys.harass:Value()
    local stopifQBuff = false
    local num1 = 1350-(getTick-gsoSDK.Spells.lastQ)
    if num1 > -50 and num1 < 550 then
        stopifQBuff = true
    end
    -- USE W :
    local canWTime = wMinus > 1000 and wMinuss > 1000 and eMinus > 700 and eMinuss > 700
    local isComboW = isCombo and menu.wset.combo:Value()
    local isHarassW = isHarass and menu.wset.harass:Value()
    local stopWIfR = menu.wset.stopult:Value() and GetTickCount() < gsoSDK.Spells.lastR + 5450
    local stopWIfQ = menu.wset.stopq:Value() and hasQBuff
    local isWReady = (isComboW or isHarassW) and canWTime == true and Game.CanUseSpell(_W) == 0 and not stopWIfR and not stopWIfQ and not stopifQBuff
    if isWReady and gsoSDK.Vars._canUseSpell() then
        local wTarget = isUnit and target or gsoSDK.TS:_getTarget(950, false, false)
        if wTarget then
            print("castW IN")
        end
    end
    -- USE E :
    local canETime = wMinus > 350 and wMinuss > 350 and eMinus > 1000 and eMinuss > 1000
    local isComboE = isCombo and menu.eset.combo:Value()
    local isHarassE = isHarass and menu.eset.harass:Value()
    local isEReady = (isComboE or isHarassE) and canETime and Game.CanUseSpell(_E) == 0 and not stopifQBuff
    if isEReady and gsoSDK.Vars._canUseSpell() then
        print("castE IN")
        local xStacks   = menu.eset.stacks:Value()
        local xEnemies  = menu.eset.enemies:Value()
        local countE    = 0
        for i = 1, #gsoSDK.OB.enemyHeroes do
            local hero = gsoSDK.OB.enemyHeroes[i]
            if gsoSDK.Utils:_getDistance(myHero.pos, hero.pos) < 1200 and gsoSDK.Utils:_valid(hero, false) then
                local nID = hero.networkID
                if eBuffs[nID] and eBuffs[nID].count >= xStacks then
                    countE = countE + 1
                end
            end
        end
        if countE >= xEnemies then
            Control.KeyDown(HK_E)
            Control.KeyUp(HK_E)
            lastE = GetTickCount()
        end
    end
end
------------------------------------------------------------------------------------------
local function keyPress(target)
    local isUnit = target and target.type == Obj_AI_Hero
    if not isUnit and gsoSDK.Vars._canMove() then
        local isCombo = gsoSDK.Load.menu.orb.keys.combo:Value()
        local isHarass = gsoSDK.Load.menu.orb.keys.harass:Value()
        local stopifQBuff = false
        local num1 = 1350-(getTick-gsoSDK.Spells.lastQ)
        if num1 > -50 and num1 < 550 then
            stopifQBuff = true
        end
        -- USE W :
        local canWTime = wMinus > 1000 and wMinuss > 1000 and eMinus > 700 and eMinuss > 700
        local isComboW = isCombo and menu.wset.combo:Value()
        local isHarassW = isHarass and menu.wset.harass:Value()
        local stopWIfR = menu.wset.stopult:Value() and GetTickCount() < gsoSDK.Spells.lastR + 5450
        local stopWIfQ = menu.wset.stopq:Value() and hasQBuff
        local isWReady = (isComboW or isHarassW) and canWTime == true and Game.CanUseSpell(_W) == 0 and not stopWIfR and not stopWIfQ and not stopifQBuff
        if isWReady and gsoSDK.Vars._canUseSpell() then
            local wTarget = isUnit and target or gsoSDK.TS:_getTarget(950, false, false)
            if wTarget then
                print("castW OUT")
            end
        end
        -- USE E :
        local canETime = wMinus > 350 and wMinuss > 350 and eMinus > 1000 and eMinuss > 1000
        local isComboE = isCombo and menu.eset.combo:Value()
        local isHarassE = isHarass and menu.eset.harass:Value()
        local isEReady = (isComboE or isHarassE) and canETime and Game.CanUseSpell(_E) == 0 and not stopifQBuff
        if isEReady and gsoSDK.Vars._canUseSpell() then
            print("castE OUT")
            local xStacks   = menu.eset.stacks:Value()
            local xEnemies  = menu.eset.enemies:Value()
            local countE    = 0
            for i = 1, #gsoSDK.OB.enemyHeroes do
                local hero = gsoSDK.OB.enemyHeroes[i]
                if gsoSDK.Utils:_getDistance(myHero.pos, hero.pos) < 1200 and gsoSDK.Utils:_valid(hero, false) then
                    local nID = hero.networkID
                    if eBuffs[nID] and eBuffs[nID].count >= xStacks then
                        countE = countE + 1
                    end
                end
            end
            if countE >= xEnemies then
                Control.KeyDown(HK_E)
                Control.KeyUp(HK_E)
                lastE = GetTickCount()
            end
        end
    end
end
------------------------------------------------------------------------------------------
local function tick()
    for i = 1, #gsoSDK.OB.enemyHeroes do
        local hero  = gsoSDK.OB.enemyHeroes[i]
        local nID   = hero.networkID
        if not eBuffs[nID] then
            eBuffs[nID] = { count = 0, durT = 0 }
        end
        if not hero.dead then
            local hasB = false
            local cB = eBuffs[nID].count
            local dB = eBuffs[nID].durT
            for i = 0, hero.buffCount do
                local buff = hero:GetBuff(i)
                if buff and buff.count > 0 and buff.name:lower() == "twitchdeadlyvenom" then
                    hasB = true
                    if cB < 6 and buff.duration > dB then
                        eBuffs[nID].count = cB + 1
                        eBuffs[nID].durT = buff.duration
                    else
                        eBuffs[nID].durT = buff.duration
                    end
                    break
                end
            end
            if not hasB then
                eBuffs[nID].count = 0
                eBuffs[nID].durT = 0
            end
        end
    end
    
    -- E KS :
    local canETime = wMinus > 350 and wMinuss > 350 and eMinus > 1000 and eMinuss > 1000
    local isEReady = canETime and Game.CanUseSpell(_E) == 0
    if isEReady then
        for i = 1, #gsoSDK.OB.enemyHeroes do
            local hero  = gsoSDK.OB.enemyHeroes[i]
            local nID   = hero.networkID
            if eBuffs[nID] and eBuffs[nID].count > 0 and gsoSDK.Utils:_valid(hero, false) and gsoSDK.Utils:_getDistance(myHero.pos, hero.pos) < 1200 then
                local elvl = myHero:GetSpellData(_E).level
                local basedmg = 5 + ( elvl * 15 )
                local cstacks = eBuffs[nID].count
                local perstack = ( 10 + (5*elvl) ) * cstacks
                local bonusAD = myHero.bonusDamage * 0.25 * cstacks
                local bonusAP = myHero.ap * 0.2 * cstacks
                local edmg = basedmg + perstack + bonusAD + bonusAP
                local tarm = hero.armor - myHero.armorPen
                      tarm = tarm > 0 and myHero.armorPenPercent * tarm or tarm
                local DmgDealt = tarm > 0 and edmg * ( 100 / ( 100 + tarm ) ) or edmg * ( 2 - ( 100 / ( 100 - tarm ) ) )
                local HPRegen = hero.hpRegen * 1.5
                if hero.health + hero.shieldAD + HPRegen < DmgDealt then
                    Control.KeyDown(HK_E)
                    Control.KeyUp(HK_E)
                    lastE = GetTickCount()
                end
            end
        end
    end
end
------------------------------------------------------------------------------------------
function OnTick()
    getTick = GetTickCount() - (gsoSDK.Utils.maxPing*1000)
    wMinus = getTick - lastW
    wMinuss = getTick - gsoSDK.Spells.lastW
    eMinus = getTick - lastE
    eMinuss = getTick - gsoSDK.Spells.lastE
    if GetTickCount() - gsoSDK.Spells.lastQ < 500 then
        asNoQ = myHero.attackSpeed
    end
    local boolRecall2 = menu.qset.recallkey:Value()
    if boolRecall2 == boolRecall then
        Control.KeyDown(HK_Q)
        Control.KeyUp(HK_Q)
        Control.KeyDown(string.byte("B"))
        Control.KeyUp(string.byte("B"))
        boolRecall = not boolRecall2
    end
    local hasQBuff = false
    local QASBuff = false
    for i = 0, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        local buffName = buff and buff.name or nil
        if buffName and buff.count > 0 and buff.duration > 0 then
            if buffName == "globalcamouflage" or buffName == "TwitchHideInShadows" then
                hasQBuff = true
                qBuffTime = GetTickCount() + (buff.duration*1000)
                break
            end
            if buffName == "twitchhideinshadowsbuff" then
                QASBuff = true
                QASTime = GetTickCount() + (buff.duration*1000)
            end
        end
    end
    hasQBuff = hasQBuff
    QASBuff = QASBuff
end
------------------------------------------------------------------------------------------
function OnDraw()
    if not menu.draws.enable:Value() then return end
    local mePos = myHero.pos
    if menu.draws.wenable:Value() then
        Draw.Circle(mePos, 950, 1, menu.draws.wcolor:Value())
    end
    if menu.draws.eenable:Value() then
        Draw.Circle(mePos, 1200, 1, menu.draws.ecolor:Value())
    end
    if menu.draws.enablet:Value() and GetTickCount() < gsoSDK.Spells.lastQ + 16000 then
        local mePos2D = mePos:To2D()
        local posX = mePos2D.x - 50
        local posY = mePos2D.y
        local num1 = math.floor(1350+gsoSDK.Spells.qLatency-(GetTickCount()-gsoSDK.Spells.lastQ))
        if num1 > 1 then
            local str1 = tostring(num1)
            local str2 = ""
            for i = 1, #str1 do
                if #str1 <=2 then
                    str2 = 0
                    break
                end
                local char1 = i <= #str1-2 and str1:sub(i,i) or "0"
                str2 = str2..char1
            end
            Draw.Text(str2, 50, posX+50, posY-15, menu.draws.colort:Value())
        elseif hasQBuff then
            local extraQTime = 1000*myHero:GetSpellData(_Q).level
            local num2 = math.floor(qBuffTime-GetTickCount()+gsoSDK.Spells.qLatency)
            if num2 > 1 then
                local str1 = tostring(num2)
                local str2 = ""
                for i = 1, #str1 do
                    if #str1 <=2 then
                        str2 = 0
                        break
                    end
                    local char1 = i <= #str1-2 and str1:sub(i,i) or "0"
                    str2 = str2..char1
                end
                Draw.Text(str2, 50, posX+50, posY-15, menu.draws.colort:Value())
                if menu.draws.invenable:Value() then
                    Draw.Circle(mePos, 500, 1, menu.draws.invcolor:Value())
                end
                if menu.draws.notenable:Value() then
                    Draw.Circle(mePos, 800, 1, menu.draws.notcolor:Value())
                end
            end
        end
    end
end
------------------------------------------------------------------------------------------
function OnLoad()
    gsoSDK.Vars:_setAASpeed(function() return aaSpeed() end)
    gsoSDK.Vars:_setOnMove(function(args) onMove(args) end)
    gsoSDK.Vars:_setOnAttack(function(args) onAttack(args) end)
    gsoSDK.Vars:_setAfterAttack(function(target) afterAttack(target) end)
    gsoSDK.Vars:_setOnKeyPress(function(target) keyPress(target) end)
    gsoSDK.Vars:_setOnTick(function() tick() end)
    gsoSDK.Vars:_setBonusDmg(function() return 3 end)
    menu = MenuElement({name = "Twitch", id = "gsotwitch", type = MENU, leftIcon = Icons["twitch"] })
        menu:MenuElement({name = "Q settings", id = "qset", type = MENU })
            menu.qset:MenuElement({id = "recallkey", name = "Invisible Recall Key", key = string.byte("T"), value = false, toggle = true})
            menu.qset:MenuElement({id = "note1", name = "Note: Key should be diffrent than recall key", type = SPACE})
        menu:MenuElement({name = "W settings", id = "wset", type = MENU })
            menu.wset:MenuElement({id = "stopq", name = "Stop if Q invisible", value = true})
            menu.wset:MenuElement({id = "stopult", name = "Stop if R", value = true})
            menu.wset:MenuElement({id = "combo", name = "Use W Combo", value = true})
            menu.wset:MenuElement({id = "harass", name = "Use W Harass", value = false})
        menu:MenuElement({name = "E settings", id = "eset", type = MENU })
            menu.eset:MenuElement({id = "combo", name = "Use E Combo", value = true})
            menu.eset:MenuElement({id = "harass", name = "Use E Harass", value = false})
            menu.eset:MenuElement({id = "stacks", name = "X stacks", value = 6, min = 1, max = 6, step = 1 })
            menu.eset:MenuElement({id = "enemies", name = "X enemies", value = 1, min = 1, max = 5, step = 1 })
        menu:MenuElement({name = "Drawings", id = "draws", type = MENU })
            menu.draws:MenuElement({id = "enable", name = "Enable", value = true})
            menu.draws:MenuElement({id = "timer", name = "Q Timer", leftIcon = Icons["timer"], icon = Icons["arrow"], type = SPACE,
                onclick = function()
                    menu.draws.enablet:Hide()
                    menu.draws.colort:Hide()
                    menu.draws.note1:Hide()
                    menu.draws.note2:Hide()
                end
            })
            menu.draws:MenuElement({id = "note1", name = "", type = SPACE})
            menu.draws:MenuElement({id = "enablet", name = "Enable", value = true})
            menu.draws:MenuElement({id = "colort", name = "Color", color = Draw.Color(200, 65, 255, 100)})
            menu.draws:MenuElement({id = "note2", name = "", type = SPACE})
            menu.draws:MenuElement({id = "circles1", name = "Circles", leftIcon = Icons["circles"], icon = Icons["arrow"], type = SPACE,
                onclick = function()
                    menu.draws.invenable:Hide()
                    menu.draws.notenable:Hide()
                    menu.draws.invcolor:Hide()
                    menu.draws.notcolor:Hide()
                    menu.draws.wenable:Hide()
                    menu.draws.wcolor:Hide()
                    menu.draws.eenable:Hide()
                    menu.draws.ecolor:Hide()
                    menu.draws.note3:Hide()
                    menu.draws.note4:Hide()
                    menu.draws.note5:Hide()
                    menu.draws.note6:Hide()
                    menu.draws.note7:Hide()
                end
            })
            menu.draws:MenuElement({id = "note3", name = "", type = SPACE})
            menu.draws:MenuElement({id = "invenable", name = "Q Invisible Enable", value = true})
            menu.draws:MenuElement({id = "invcolor", name = "Q Invisible Color ", color = Draw.Color(200, 255, 0, 0)})
            menu.draws:MenuElement({id = "note4", name = "", type = SPACE})
            menu.draws:MenuElement({id = "notenable", name = "Q Notification Enable", value = true})
            menu.draws:MenuElement({id = "notcolor", name = "Q Notification Color", color = Draw.Color(200, 188, 77, 26)})
            menu.draws:MenuElement({id = "note5", name = "", type = SPACE})
            menu.draws:MenuElement({id = "wenable", name = "W Enable", value = true})
            menu.draws:MenuElement({id = "wcolor", name = "W Color", color = Draw.Color(255, 71, 70, 70)})
            menu.draws:MenuElement({id = "note6", name = "", type = SPACE})
            menu.draws:MenuElement({id = "eenable", name = "E Enable", value = true})
            menu.draws:MenuElement({id = "ecolor", name = "E Color", color = Draw.Color(255, 66, 79, 122)})
            menu.draws:MenuElement({id = "note7", name = "", type = SPACE})
    menu.draws.note1:Hide(true)
    menu.draws.note2:Hide(true)
    menu.draws.note3:Hide(true)
    menu.draws.note4:Hide(true)
    menu.draws.note5:Hide(true)
    menu.draws.note6:Hide(true)
    menu.draws.note7:Hide(true)
    menu.draws.enablet:Hide(true)
    menu.draws.colort:Hide(true) 
    menu.draws.invenable:Hide(true)
    menu.draws.notenable:Hide(true)
    menu.draws.invcolor:Hide(true)
    menu.draws.notcolor:Hide(true)
    menu.draws.wenable:Hide(true)
    menu.draws.wcolor:Hide(true)
    menu.draws.eenable:Hide(true)
    menu.draws.ecolor:Hide(true)
    menu.qset.recallkey:Value(false)
end
