
local GetTickCount = GetTickCount
local Game = Game
local myHero = myHero
local Control = Control
local mathSqrt = math.sqrt
local Vector = Vector
local Draw = Draw
local gsoAIO = {
  Vars = nil,
  Dmg = nil,
  Items = nil,
  Spells = nil,
  Utils = nil,
  OB = nil,
  TS = nil,
  Farm = nil,
  TPred = nil,
  Orb = nil,
  Load = nil
}

--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------VARIABLES---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoVars"
function __gsoVars:__init()
    self.version = "0.59"
    self.hName = myHero.charName
    self.meTristana = self.hName == "Tristana"
    self.loaded = true
    self.Icons = {
        ["arrow"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/arrow.png",
        ["ashe"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ashe.png",
        ["botrk"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/botrk.png",
        ["draven"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/draven.png",
        ["draws"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/draws.png",
        ["ezreal"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ezreal.png",
        ["gsoaio"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/gsoaio.png",
        ["item"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/item.png",
        ["kog"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/kog.png",
        ["orb"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/orb.png",
        ["sivir"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/sivir.png",
        ["teemo"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/teemo.png",
        ["timer"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/timer.png",
        ["tristana"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/tristana.png",
        ["ts"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ts.png",
        ["twitch"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/twitch.png",
        ["vayne"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/vayne.png"
    }
    print(self.Icons["arrow"])
    self.supportedChampions = {
      ["Ashe"] = true,
      ["KogMaw"] = true,
      ["Twitch"] = true,
      --["Draven"] = true,
      ["Ezreal"] = true,
      ["Vayne"] = true,
      ["Teemo"] = true,
      ["Sivir"] = true,
      ["Tristana"] = true
    }
    if not self.supportedChampions[self.hName] == true then
        self.loaded = false
        print("gamsteronAIO "..self.version.." | hero not supported !")
    end
    self._aaSpeed       = function() return myHero.attackSpeed end
    self._champMenu     = function() return 0 end
    self._bonusDmg      = function() return 0 end
    self._bonusDmgUnit  = function() return 0 end
    self._onTick        = function() return 0 end
    self._mousePos      = function() return nil end
    self._canMove       = function() return true end
    self._canAttack     = function() return true end
end
function __gsoVars:_setAASpeed(func) self._aaSpeed = func end
function __gsoVars:_setChampMenu(func) self._champMenu = func end
function __gsoVars:_setBonusDmg(func) self._bonusDmg = func end
function __gsoVars:_setBonusDmgUnit(func) self._bonusDmgUnit = func end
function __gsoVars:_setOnTick(func) self._onTick = func end
function __gsoVars:_setMousePos(func) self._mousePos = func end
function __gsoVars:_setCanMove(func) self._canMove = func end
function __gsoVars:_setCanAttack(func) self._canAttack = func end

gsoAIO.Vars = __gsoVars()
if gsoAIO.Vars.loaded == false then
    return
end





--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------DAMAGE---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoDmg"

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------INIT----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoDmg:__init()
    
    
    
    --[[ ---------------- ]]
    --[[   BASE DAMAGES   ]]
    --[[ ---------------- ]]
    
    self.Damages =
    {
        ["Tristana"] =
        {
            --   E
            e =
            {
                dmgAP =
                    function()
                        return 25 + ( 25 * myHero:GetSpellData(_E).level ) + ( 0.25 * myHero.ap )
                    end,
                dmgAD =
                    function(stacks)
                        local elvl = myHero:GetSpellData(_E).level
                        local meDmg = myHero.totalDamage
                        local meAP = myHero.ap
                        local stacksDmg = 0
                        local baseDmg = 50 + ( 10 * elvl ) + ( ( 0.4 + ( 0.1 * elvl ) ) * meDmg ) + ( 0.5 * meAP )
                        if stacks > 0 then
                            local stackDmg = 15 + ( 3 * elvl ) + ( ( 0.12 + ( 0.03 * elvl ) ) * meDmg ) + ( 0.15 * meAP )
                            stacksDmg = stacks * stackDmg
                        end
                        return baseDmg + stacksDmg
                    end,
                dmgType = "mixed"
            },
            
            --   R
            r =
            {
                dmgAP =
                    function()
                        return 200 + ( 100 * myHero:GetSpellData(_R).level ) + myHero.ap
                    end,
                dmgType = "ap"
            }
        }
    }
    
    --[[ ------------------ ]]
    --[[   CALC DMG AP/AD   ]]
    --[[ ------------------ ]]
    self.CalcDmg =
        function(unit, dmg, isAP)
            if unit == nil or dmg == nil or isAP == nil then return 0 end
            if dmg > 0 then
                local def = isAP and unit.magicResist - myHero.magicPen or unit.armor - myHero.armorPen
                if def > 0 then
                    def = isAP and myHero.magicPenPercent * def or myHero.bonusArmorPenPercent * def
                end
                local result = def > 0 and dmg * ( 100 / ( 100 + def ) ) or dmg * ( 2 - ( 100 / ( 100 - def ) ) )
                local unitShield = isAP and unit.shieldAP or 0
                result = result - unitShield
                return result < 0 and 0 or result
            else
                return 0
            end
        end
    
    --[[ ---------------- ]]
    --[[   PREDICTED HP   ]]
    --[[ ---------------- ]]
    
    self.PredHP =
        function(unit, spellData)
            
            if unit == nil or spellData == nil then return 0 end
            
            --[[ spell data ]]
            local dmgAP = spellData.dmgAP and spellData.dmgAP or 0
            local dmgAD = spellData.dmgAD and spellData.dmgAD or 0
            local dmgTrue = spellData.dmgTrue and spellData.dmgTrue or 0
            local dmgType = spellData.dmgType and spellData.dmgType or ""
            
            --[[ ad damage ]]
            if dmgType == "ad" then
                return self.CalcDmg(unit, dmgAD, false) - unit.shieldAD
            end

            --[[ ap damage ]]
            if dmgType == "ap" then
                return self.CalcDmg(unit, dmgAP, true) - unit.shieldAD
            end

            --[[ true damage ]]
            if dmgType == "true" then
                return dmgTrue - unit.shieldAD
            end

            --[[ mixed damage ]]
            if dmgType == "mixed" then
                return self.CalcDmg(unit, dmgAP, true) + self.CalcDmg(unit, dmgAD, false) - unit.shieldAD
            end
            
            --[[ wrong damage type ]]
            return 0
        end
end





--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------ITEMS-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoItems"
function __gsoItems:__init()
    self.itemList = {
        [3144] = { i = nil, hk = nil },
        [3153] = { i = nil, hk = nil }
    }
    self.lastBotrk = 0
    self.performance = 0
    Callback.Add('Tick', function() self:_tick() end)
end
function __gsoItems:_botrk()
    if GetTickCount() < self.lastBotrk + 1000 then return nil end
    local itmSlot1 = self.itemList[3144].i
    local itmSlot2 = self.itemList[3153].i
    if itmSlot1 and myHero:GetSpellData(itmSlot1).currentCd == 0 then
        return self.itemList[3144].hk
    elseif itmSlot2 and myHero:GetSpellData(itmSlot2).currentCd == 0 then
        return self.itemList[3153].hk
    end
    return nil
end
function __gsoItems:_tick()
    local getTick = GetTickCount()
    if getTick > self.performance + 500 then
        self.performance = GetTickCount()
        local t = { ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6 }
        local t2 = { [3153] = 0, [3144] = 0 }
        for i = 1, #t do
            local item = t[i]
            local itemID = myHero:GetItemData(item).itemID
            local t2Item = t2[itemID]
            if t2Item then
                t2[itemID] = t2Item + 1
            end
            if self.itemList[itemID] then
                self.itemList[itemID].i = item
                local t3 = { HK_ITEM_1, HK_ITEM_2, HK_ITEM_3, HK_ITEM_4, HK_ITEM_5, HK_ITEM_6 }
                self.itemList[itemID].hk = t3[i]
            end
        end
        for k,v in pairs(self.itemList) do
            local itm = self.itemList[k]
            if t2[k] == 0 and (itm.i or itm.hk) then
                self.itemList[k].i = nil
                self.itemList[k].hk = nil
            end
        end
    end
end





--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------SPELLS---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoSpells"

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------init----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoSpells:__init()
    self.lastQ    = 0
    self.lastW    = 0
    self.lastE    = 0
    self.lastR    = 0
    self.qLatency = 0
    self.wLatency = 0
    self.eLatency = 0
    self.rLatency = 0
    self.delayedSpell = {}
    Callback.Add('WndMsg', function(msg, wParam) self:_onWndMsg(msg, wParam) end)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------onwndmsg--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoSpells:_onWndMsg(msg, wParam)
    local getTick = GetTickCount()
    local isKey = gsoAIO.Load.menu.orb.keys.combo:Value() or gsoAIO.Load.menu.orb.keys.harass:Value() or gsoAIO.Load.menu.orb.keys.laneClear:Value() or gsoAIO.Load.menu.orb.keys.lastHit:Value()
    if Game.CanUseSpell(_Q) == 0 and wParam == HK_Q and getTick > self.lastQ + 1000 then
        self.lastQ = getTick
        self.qLatency = Game.Latency()*1.1
        if isKey and not self.delayedSpell[0] then
            self.delayedSpell[0] = { function() gsoAIO.Utils:_castAgain(wParam) end, getTick }
        end
    elseif Game.CanUseSpell(_W) == 0 and wParam == HK_W and getTick > self.lastW + 1000 then
        self.lastW = getTick
        self.wLatency = Game.Latency()*1.1
        if isKey and not self.delayedSpell[1] then
            self.delayedSpell[1] = { function() gsoAIO.Utils:_castAgain(wParam) end, getTick }
        end
    elseif Game.CanUseSpell(_E) == 0 and wParam == HK_E and getTick > self.lastE + 1000 then
        self.lastE = getTick
        self.eLatency = Game.Latency()*1.1
        if isKey and not self.delayedSpell[2] then
            self.delayedSpell[2] = { function() gsoAIO.Utils:_castAgain(wParam) end, getTick }
        end
    elseif Game.CanUseSpell(_R) == 0 and wParam == HK_R and getTick > self.lastR + 1000 then
        self.lastR = getTick
        self.rLatency = Game.Latency()*1.1
        if isKey and not self.delayedSpell[3] then
            self.delayedSpell[3] = { function() gsoAIO.Utils:_castAgain(wParam) end, getTick }
        end
    end
end





--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------UTILS----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoUtils"

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------init----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoUtils:__init()
    self.delayedActions = {}
    self.eBuffTarget = nil
    self.undyingBuffs = {
        ["zhonyasringshield"] = true
    }
    self.Priorities = {
        ["Aatrox"] = 3, ["Ahri"] = 2, ["Akali"] = 2, ["Alistar"] = 5, ["Amumu"] = 5, ["Anivia"] = 2, ["Annie"] = 2, ["Ashe"] = 1, ["AurelionSol"] = 2, ["Azir"] = 2,
        ["Bard"] = 3, ["Blitzcrank"] = 5, ["Brand"] = 2, ["Braum"] = 5, ["Caitlyn"] = 1, ["Camille"] = 3, ["Cassiopeia"] = 2, ["Chogath"] = 5, ["Corki"] = 1,
        ["Darius"] = 4, ["Diana"] = 2, ["DrMundo"] = 5, ["Draven"] = 1, ["Ekko"] = 2, ["Elise"] = 3, ["Evelynn"] = 2, ["Ezreal"] = 1, ["Fiddlesticks"] = 3, ["Fiora"] = 3,
        ["Fizz"] = 2, ["Galio"] = 5, ["Gangplank"] = 2, ["Garen"] = 5, ["Gnar"] = 5, ["Gragas"] = 4, ["Graves"] = 2, ["Hecarim"] = 4, ["Heimerdinger"] = 3, ["Illaoi"] =  3,
        ["Irelia"] = 3, ["Ivern"] = 5, ["Janna"] = 4, ["JarvanIV"] = 3, ["Jax"] = 3, ["Jayce"] = 2, ["Jhin"] = 1, ["Jinx"] = 1, ["Kalista"] = 1, ["Karma"] = 2, ["Karthus"] = 2,
        ["Kassadin"] = 2, ["Katarina"] = 2, ["Kayle"] = 2, ["Kayn"] = 2, ["Kennen"] = 2, ["Khazix"] = 2, ["Kindred"] = 2, ["Kled"] = 4, ["KogMaw"] = 1, ["Leblanc"] = 2,
        ["LeeSin"] = 3, ["Leona"] = 5, ["Lissandra"] = 2, ["Lucian"] = 1, ["Lulu"] = 3, ["Lux"] = 2, ["Malphite"] = 5, ["Malzahar"] = 3, ["Maokai"] = 4, ["MasterYi"] = 1,
        ["MissFortune"] = 1, ["MonkeyKing"] = 3, ["Mordekaiser"] = 2, ["Morgana"] = 3, ["Nami"] = 3, ["Nasus"] = 4, ["Nautilus"] = 5, ["Nidalee"] = 2, ["Nocturne"] = 2,
        ["Nunu"] = 4, ["Olaf"] = 4, ["Orianna"] = 2, ["Ornn"] = 4, ["Pantheon"] = 3, ["Poppy"] = 4, ["Quinn"] = 1, ["Rakan"] = 3, ["Rammus"] = 5, ["RekSai"] = 4,
        ["Renekton"] = 4, ["Rengar"] = 2, ["Riven"] = 2, ["Rumble"] = 2, ["Ryze"] = 2, ["Sejuani"] = 4, ["Shaco"] = 2, ["Shen"] = 5, ["Shyvana"] = 4, ["Singed"] = 5,
        ["Sion"] = 5, ["Sivir"] = 1, ["Skarner"] = 4, ["Sona"] = 3, ["Soraka"] = 3, ["Swain"] = 3, ["Syndra"] = 2, ["TahmKench"] = 5, ["Taliyah"] = 2, ["Talon"] = 2,
        ["Taric"] = 5, ["Teemo"] = 2, ["Thresh"] = 5, ["Tristana"] = 1, ["Trundle"] = 4, ["Tryndamere"] = 2, ["TwistedFate"] = 2, ["Twitch"] = 1, ["Udyr"] = 4, ["Urgot"] = 4,
        ["Varus"] = 1, ["Vayne"] = 1, ["Veigar"] = 2, ["Velkoz"] = 2, ["Vi"] = 4, ["Viktor"] = 2, ["Vladimir"] = 3, ["Volibear"] = 4, ["Warwick"] = 4, ["Xayah"] = 1,
        ["Xerath"] = 2, ["XinZhao"] = 3, ["Yasuo"] = 2, ["Yorick"] = 4, ["Zac"] = 5, ["Zed"] = 2, ["Ziggs"] = 2, ["Zilean"] = 3, ["Zoe"] = 2, ["Zyra"] = 2
    }
    Callback.Add('Tick', function() self:_tick() end)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------tick----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoUtils:_tick()
    for i = 1, #gsoAIO.Utils.delayedActions do
        local dAction = gsoAIO.Utils.delayedActions[i]
        if os.clock() > dAction.endTime then
            dAction.func()
            gsoAIO.Utils.delayedActions[i] = nil
            --print("ok")
        end
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------get distance-------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoUtils:_getDistance(a, b)
  local x = a.x - b.x
  local z = a.z - b.z
  return mathSqrt(x * x + z * z)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------point on line segment-------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoUtils:_pointOnLineSegment(x, z, ax, az, bx, bz)
    local bxax = bx - ax
    local bzaz = bz - az
    local t = ((x - ax) * bxax + (z - az) * bzaz) / (bxax * bxax + bzaz * bzaz)
    if t < 0 then return false
    elseif t > 1 then return false
    else return true
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|----------------------immortal---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoUtils:_isImmortal(unit, orb)
    local unitHPPercent = 100 * unit.health / unit.maxHealth
    if self.undyingBuffs["JaxCounterStrike"] ~= nil then    self.undyingBuffs["JaxCounterStrike"] = orb end
    if self.undyingBuffs["kindredrnodeathbuff"] ~= nil then self.undyingBuffs["kindredrnodeathbuff"] = unitHPPercent < 10 end
    if self.undyingBuffs["UndyingRage"] ~= nil then         self.undyingBuffs["UndyingRage"] = unitHPPercent < 15 end
    if self.undyingBuffs["ChronoShift"] ~= nil then         self.undyingBuffs["ChronoShift"] = unitHPPercent < 15; self.undyingBuffs["chronorevive"] = unitHPPercent < 15 end
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 then
            local undyingBuff = self.undyingBuffs[buff.name]
            if undyingBuff and undyingBuff == true then
                return true
            end
        end
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------valid-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoUtils:_valid(unit, orb)
    if not unit or self:_isImmortal(unit, orb) then
        return false
    end
    if not unit.dead and unit.isTargetable and unit.visible and unit.valid then
        return true
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|----------------------cast again-------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoUtils:_castAgain(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------immobile----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoUtils:_isImmobile(unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 then
            local bType = buff.type
            if bType == 5 or bType == 11 or bType == 29 or bType == 24 or buff.name == "recall" then
                return true
            end
        end
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|----------------------near unit--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoUtils:_nearUnit(pos, id)
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local unit = gsoAIO.OB.enemyHeroes[i]
        if id ~= unit.networkID and self:_getDistance(pos, unit.pos) < unit.boundingRadius then
            return true
        end
    end
    for i = 1, #gsoAIO.OB.enemyMinions do
        local unit = gsoAIO.OB.enemyMinions[i]
        if self:_getDistance(pos, unit.pos) < unit.boundingRadius then
            return true
        end
    end
    for i = 1, #gsoAIO.OB.enemyTurrets do
        local unit = gsoAIO.OB.enemyTurrets[i]
        if self:_getDistance(pos, unit.pos) < unit.boundingRadius then
            return true
        end
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------get buff count-----------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoUtils:_buffCount(unit, bName)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == bName then
            return buff.count
        end
    end
    return 0
end

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------check if has buff----------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoUtils:_hasBuff(unit, bName)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == bName then
            return true
        end
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|----------------------is ready---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoUtils:_isReady(spell)
    return gsoAIO.Orb.dActionsC == 0 and Game.CanUseSpell(spell) == 0
end





--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------OBJECT MANAGER------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoOB"

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------init---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoOB:__init()
    self.allyMinions  = {}
    self.enemyMinions = {}
    self.enemyHeroes  = {}
    self.enemyTurrets = {}
    self.meTeam       = myHero.team
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------tick---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoOB:_tick()
    local mePos = myHero.pos
    for i=1, #self.allyMinions do self.allyMinions[i]=nil end
    for i=1, #self.enemyMinions do self.enemyMinions[i]=nil end
    for i=1, #self.enemyHeroes do self.enemyHeroes[i]=nil end
    for i=1, #self.enemyTurrets do self.enemyTurrets[i]=nil end
    for i = 1, Game.MinionCount() do
        local minion = Game.Minion(i)
        if minion and gsoAIO.Utils:_getDistance(mePos, minion.pos) < 2000 and not minion.dead and minion.isTargetable and minion.visible and minion.valid and not minion.isImmortal then
            if minion.team ~= self.meTeam then
                self.enemyMinions[#self.enemyMinions+1] = minion
            else
                self.allyMinions[#self.allyMinions+1] = minion
            end
        end
    end
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if hero and hero.team ~= self.meTeam and gsoAIO.Utils:_getDistance(mePos, hero.pos) < 10000 and not hero.dead and hero.isTargetable and hero.visible and hero.valid then
            self.enemyHeroes[#self.enemyHeroes+1] = hero
        end
    end
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        if turret and turret.team ~= self.meTeam and gsoAIO.Utils:_getDistance(mePos, turret.pos) < 2000 and not turret.dead and turret.isTargetable and turret.visible and turret.valid and not turret.isImmortal then
            self.enemyTurrets[#self.enemyTurrets+1] = turret
        end
    end
end





--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|------------------TARGET SELECTOR------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoTS"

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------init---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTS:__init()
    self.apDmg = false
    self.isTeemo = false
    self.isBlinded = false
    self.loadedChamps = false
    self.lastTarget = nil
    self.lastFound = -10000000
    self.selectedTarget = nil
    self.lastSelTick = 0
    self.LHTimers     = {
        [0] = { tick = 0, id = 0 },
        [1] = { tick = 0, id = 0 },
        [2] = { tick = 0, id = 0 },
        [3] = { tick = 0, id = 0 },
        [4] = { tick = 0, id = 0 }
    }
    Callback.Add('Draw', function() self:_draw() end)
    Callback.Add('WndMsg', function(msg, wParam) self:_onWndMsg(msg, wParam) end)
    Callback.Add('Tick', function() self:_tick() end)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|----------------------get target-------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTS:_getTarget(_range, orb, changeRange)
    if gsoAIO.Load.menu.ts.selected.only:Value() == true and gsoAIO.Utils:_valid(self.selectedTarget, true) then
        return self.selectedTarget
    end
    local result  = nil
    local num     = 10000000
    local mode    = gsoAIO.Load.menu.ts.Mode:Value()
    local prioT  = { 10000000, 10000000 }
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local unit = gsoAIO.OB.enemyHeroes[i]
        local unitID = unit.networkID
        local canTrist = gsoAIO.Vars.meTristana and gsoAIO.Load.menu.ts.tristE.enable:Value() and gsoAIO.Utils.eBuffTarget and gsoAIO.Utils.eBuffTarget.stacks >= gsoAIO.Load.menu.ts.tristE.stacks:Value() and unitID == gsoAIO.Utils.eBuffTarget.id
        local range = changeRange == true and _range + myHero.boundingRadius + unit.boundingRadius - 30 or _range
        local distance = gsoAIO.Utils:_getDistance(myHero.pos, unit.pos)
        if gsoAIO.Utils:_valid(unit, orb) and distance < range then
            if gsoAIO.Load.menu.ts.selected.enable:Value() and self.selectedTarget and unitID == self.selectedTarget.networkID then
                return self.selectedTarget
            elseif canTrist then
                return unit
            elseif mode == 1 then
                local unitName = unit.charName
                local priority = 6
                if unitName ~= nil then
                    priority = gsoAIO.Load.menu.ts.priority[unitName] and gsoAIO.Load.menu.ts.priority[unitName]:Value() or priority
                end
                local calcNum = 1
                if priority == 1 then
                    calcNum = 1
                elseif priority == 2 then
                    calcNum = 1.15
                elseif priority == 3 then
                    calcNum = 1.3
                elseif priority == 4 then
                    calcNum = 1.45
                elseif priority == 5 then
                    calcNum = 1.6
                elseif priority == 6 then
                    calcNum = 1.75
                end
                local def = self.apDmg == true and unit.magicResist - myHero.magicPen or unit.armor - myHero.armorPen
                def = def * calcNum
                if def > 0 then
                      def = self.apDmg == true and myHero.magicPenPercent * def or myHero.bonusArmorPenPercent * def
                end
                local hpE = unit.health
                hpE = hpE * calcNum
                hpE = hpE * ( ( 100 + def ) / 100 )
                hpE = hpE - (unit.totalDamage*unit.attackSpeed*2) - unit.ap
                if hpE < num then
                    num     = hpE
                    result  = unit
                end
            elseif mode == 2 then
                if distance < num then
                    num = distance
                    result = unit
                end
            elseif mode == 3 then
                local hpE = unit.health
                if hpE < num then
                    num = hpE
                    result = unit
                end
            elseif mode == 4 then
                local unitName = unit.charName
                local hpE = unit.health - (unit.totalDamage*unit.attackSpeed*2) - unit.ap
                local priority = 6
                if unitName ~= nil then
                    priority = gsoAIO.Load.menu.ts.priority[unitName] and gsoAIO.Load.menu.ts.priority[unitName]:Value() or priority
                end
                if priority == prioT[1] and hpE < prioT[2] then
                    prioT[2] = hpE
                    result = unit
                elseif priority < prioT[1] then
                    prioT[1] = priority
                    prioT[2] = hpE
                    result = unit
                end
            end
        end
    end
    return result
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------orbwalker combo----------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTS:_comboT()
    local target = self:_getTarget(myHero.range, true, true)
    if target then
        self.lastTarget = target
        return target
    else
        self.lastTarget = nil
        return nil
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------orbwalker lasthit--------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTS:_lastHitT()
    local result  = nil
    local min     = 10000000
    for i = 1, #gsoAIO.Farm.lastHit do
        local eMinionLH = gsoAIO.Farm.lastHit[i]
        local minion	= eMinionLH[1]
        local hp		= eMinionLH[2]
        local checkT = Game.Timer() < self.LHTimers[0].tick
        local mHandle = minion.handle
        if (not checkT or (checkT and self.LHTimers[0].id ~= mHandle)) and hp < min then
            min = hp
            result = minion
            self.LHTimers[4].tick = Game.Timer() + 0.75
            self.LHTimers[4].id = mHandle
        end
    end
    return result
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------orbwalker turret---------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTS:_getTurret()
    local result = nil
    for i=1, #gsoAIO.OB.enemyTurrets do
        local turret = gsoAIO.OB.enemyTurrets[i]
        local range = myHero.range + myHero.boundingRadius + turret.boundingRadius - 30
        if gsoAIO.Utils:_getDistance(myHero.pos, turret.pos) < range then
            result = turret
            break
        end
    end
    return result
end

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------orbwalker laneclear--------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTS:_laneClearT()
    local result	= self:_lastHitT()
    if not result then
        result = self:_comboT()
        if not result and #gsoAIO.Farm.almostLH == 0 and gsoAIO.Farm.shouldWait == false then
            result = self:_getTurret()
            if not result then
                local min = 10000000
                for i = 1, #gsoAIO.Farm.laneClear do
                    local minion = gsoAIO.Farm.laneClear[i]
                    local hp     = minion.health
                    if hp < min then
                        min = hp
                        result = minion
                    end
                end
            end
        end
    end
    return result
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------orbwalker harass---------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTS:_harassT()
    local result = self:_lastHitT()
    return result == nil and self:_comboT() or result
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------draw---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTS:_draw()
    if gsoAIO.Load.menu.ts.selected.draw.enable:Value() == true and gsoAIO.Utils:_valid(self.selectedTarget, true) then
        Draw.Circle(self.selectedTarget.pos, gsoAIO.Load.menu.ts.selected.draw.radius:Value(), gsoAIO.Load.menu.ts.selected.draw.width:Value(), gsoAIO.Load.menu.ts.selected.draw.color:Value())
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------tick---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTS:_tick()
    
    --[[ check if myHero is blinded by teemo's Q ]]
    if gsoAIO.TS.isTeemo == true then
        self.isBlinded = gsoAIO.Utils:_hasBuff(myHero, "blindingdart")
    end
    
    --[[ load champions ]]
    if self.loadedChamps == false then
        for i = 1, Game.HeroCount() do
            local hero = Game.Hero(i)
            if hero.team ~= gsoAIO.OB.meTeam then
                local eName = hero.charName
                if eName and #eName > 0 and not gsoAIO.Load.menu.ts.priority[eName] then
                    self.lastFound = Game.Timer()
                    local priority = gsoAIO.Utils.Priorities[eName] ~= nil and gsoAIO.Utils.Priorities[eName] or 5
                    gsoAIO.Load.menu.ts.priority:MenuElement({ id = eName, name = eName, value = priority, min = 1, max = 5, step = 1 })
                    if eName == "Teemo" then          self.isTeemo = true
                    elseif eName == "Kayle" then      gsoAIO.Utils.undyingBuffs["JudicatorIntervention"] = true
                    elseif eName == "Taric" then      gsoAIO.Utils.undyingBuffs["TaricR"] = true
                    elseif eName == "Kindred" then    gsoAIO.Utils.undyingBuffs["kindredrnodeathbuff"] = true
                    elseif eName == "Zilean" then     gsoAIO.Utils.undyingBuffs["ChronoShift"] = true; gsoAIO.Utils.undyingBuffs["chronorevive"] = true
                    elseif eName == "Tryndamere" then gsoAIO.Utils.undyingBuffs["UndyingRage"] = true
                    elseif eName == "Jax" then        gsoAIO.Utils.undyingBuffs["JaxCounterStrike"] = true
                    elseif eName == "Fiora" then      gsoAIO.Utils.undyingBuffs["FioraW"] = true
                    elseif eName == "Aatrox" then     gsoAIO.Utils.undyingBuffs["aatroxpassivedeath"] = true
                    elseif eName == "Vladimir" then   gsoAIO.Utils.undyingBuffs["VladimirSanguinePool"] = true
                    elseif eName == "KogMaw" then     gsoAIO.Utils.undyingBuffs["KogMawIcathianSurprise"] = true
                    elseif eName == "Karthus" then    gsoAIO.Utils.undyingBuffs["KarthusDeathDefiedBuff"] = true
                    end
                end
            end
        end
        if Game.Timer() > self.lastFound + 5 and Game.Timer() < self.lastFound + 10 then
            self.loadedChamps = true
        end
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------onwndmsg--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTS:_onWndMsg(msg, wParam)
    local getTick = GetTickCount()
    if msg == WM_LBUTTONDOWN and gsoAIO.Load.menu.ts.selected.enable:Value() == true then
        if getTick > self.lastSelTick + 100 and getTick > gsoAIO.Spells.lastQ + 250 and getTick > gsoAIO.Spells.lastW + 250 and getTick > gsoAIO.Spells.lastE + 250 and getTick > gsoAIO.Spells.lastR + 250 then 
            local num = 10000000
            local enemy = nil
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                local heroPos = hero.pos
                if gsoAIO.Utils:_valid(hero, true) and gsoAIO.Utils:_getDistance(myHero.pos, heroPos) < 10000 then
                    local distance = gsoAIO.Utils:_getDistance(heroPos, mousePos)
                    if distance < 150 and distance < num then
                        enemy = hero
                        num = distance
                    end
                end
            end
            if enemy ~= nil then
                self.selectedTarget = enemy
            else
                self.selectedTarget = nil
            end
            self.lastSelTick = GetTickCount()
        end
    end
end






--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------FARM-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoFarm"

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------init---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoFarm:__init()
    self.aaDmg          = myHero.totalDamage
    self.lastHit        = {}
    self.almostLH       = {}
    self.laneClear      = {}
    self.aAttacks       = {}
    self.shouldWaitT    = 0
    self.shouldWait     = false
end
function __gsoFarm:_tick()
    self.aaDmg   = myHero.totalDamage + gsoAIO.Vars._bonusDmg()
    if self.shouldWait == true and Game.Timer() > self.shouldWaitT + 0.5 then
        self.shouldWait = false
    end
    self:_setActiveAA()
    self:_handleActiveAA()
    self:_setEnemyMinions()
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------predicted pos------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoFarm:_predPos(speed, pPos, unit)
    local unitPath = unit.pathing
    if unitPath.hasMovePath == true then
        local uPos    = unit.pos
        local ePos    = unitPath.endPos
        local distUP  = gsoAIO.Utils:_getDistance(pPos, uPos)
        local distEP  = gsoAIO.Utils:_getDistance(pPos, ePos)
        local unitMS  = unit.ms
        if distEP > distUP then
            return uPos:Extended(ePos, 50+(unitMS*(distUP / (speed - unitMS))))
        else
            return uPos:Extended(ePos, 50+(unitMS*(distUP / (speed + unitMS))))
        end
    end
    return unit.pos
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------predicted hp-------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoFarm:_possibleDmg(eMin, time)
    local result = 0
    for i = 1, #gsoAIO.OB.allyMinions do
        local aMin = gsoAIO.OB.allyMinions[i]
        local aaData  = aMin.attackData
        local aDmg    = (aMin.totalDamage*(1+aMin.bonusDamagePercent))
        if aaData.target == eMin.handle then
            local endT    = aaData.endTime
            local animT   = aaData.animationTime
            local windUpT = aaData.windUpTime
            local pSpeed  = aaData.projectileSpeed
            local pFlyT   = pSpeed > 0 and gsoAIO.Utils:_getDistance(aMin.pos, eMin.pos) / pSpeed or 0
            local pStartT = endT - animT
            local pEndT   = pStartT + pFlyT + windUpT
            local checkT  = Game.Timer()
            pEndT         = pEndT > checkT and pEndT or pEndT + animT + pFlyT
            while pEndT - checkT < time do
                result = result + aDmg
                pEndT = pEndT + animT + pFlyT
            end
        end
    end
    return result
end

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------set enemy minions----------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoFarm:_setEnemyMinions()
    for i=1, #self.lastHit do self.lastHit[i]=nil end
    for i=1, #self.almostLH do self.almostLH[i]=nil end
    for i=1, #self.laneClear do self.laneClear[i]=nil end
    local mLH = gsoAIO.Load.menu.orb.delays.lhDelay:Value()*0.001
    for i = 1, #gsoAIO.OB.enemyMinions do
        local eMinion = gsoAIO.OB.enemyMinions[i]
        local eMinion_handle	= eMinion.handle
        local distance = gsoAIO.Utils:_getDistance(myHero.pos, eMinion.pos)
        if distance < myHero.range + myHero.boundingRadius + eMinion.boundingRadius - 30 then
            local eMinion_health	= eMinion.health
            local myHero_aaData		= myHero.attackData
            local myHero_pFlyTime	= myHero_aaData.windUpTime + (distance / myHero_aaData.projectileSpeed) + 0.125 + mLH
            for k1,v1 in pairs(self.aAttacks) do
                for k2,v2 in pairs(self.aAttacks[k1]) do
                    if v2.canceled == false and eMinion_handle == v2.to.handle then
                        local checkT	= Game.Timer()
                        local pEndTime	= v2.startTime + v2.pTime
                        if pEndTime > checkT and  pEndTime - checkT < myHero_pFlyTime - mLH then
                            eMinion_health = eMinion_health - v2.dmg
                        end
                    end
                end
            end
            local myHero_dmg = self.aaDmg + gsoAIO.Vars._bonusDmgUnit(eMinion)
            if eMinion_health - myHero_dmg < 0 then
                self.lastHit[#self.lastHit+1] = { eMinion, eMinion_health }
            else
                if eMinion.health - self:_possibleDmg(eMinion, myHero.attackData.animationTime*3) - myHero_dmg < 0 then
                    self.shouldWait = true
                    self.shouldWaitT = Game.Timer()
                    self.almostLH[#self.almostLH+1] = eMinion
                else
                    self.laneClear[#self.laneClear+1] = eMinion
                end
            end
        end
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------active attacks-----------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoFarm:_setActiveAA()
    for i = 1, #gsoAIO.OB.allyMinions do
        local aMinion = gsoAIO.OB.allyMinions[i]
        local aHandle	= aMinion.handle
        local aAAData	= aMinion.attackData
        if aAAData.endTime > Game.Timer() then
            for i = 1, #gsoAIO.OB.enemyMinions do
                local eMinion = gsoAIO.OB.enemyMinions[i]
                local eHandle	= eMinion.handle
                if eHandle == aAAData.target then
                    local checkT		= Game.Timer()
                    -- p -> projectile
                    local pSpeed  = aAAData.projectileSpeed
                    local aMPos   = aMinion.pos
                    local eMPos   = eMinion.pos
                    local pFlyT		= pSpeed > 0 and gsoAIO.Utils:_getDistance(aMPos, eMPos) / pSpeed or 0
                    local pStartT	= aAAData.endTime - aAAData.windDownTime
                    if not self.aAttacks[aHandle] then
                      self.aAttacks[aHandle] = {}
                    end
                    local aaID = aAAData.endTime
                    if checkT < pStartT + pFlyT then
                        if pSpeed > 0 then
                            if checkT > pStartT then
                                if not self.aAttacks[aHandle][aaID] then
                                    self.aAttacks[aHandle][aaID] = {
                                        canceled  = false,
                                        speed     = pSpeed,
                                        startTime = pStartT,
                                        pTime     = pFlyT,
                                        pos       = aMPos:Extended(eMPos, pSpeed*(checkT-pStartT)),
                                        from      = aMinion,
                                        fromPos   = aMPos,
                                        to        = eMinion,
                                        dmg       = (aMinion.totalDamage*(1+aMinion.bonusDamagePercent))-eMinion.flatDamageReduction
                                    }
                                end
                            elseif aMinion.pathing.hasMovePath == true then
                              --print("attack canceled")
                              self.aAttacks[aHandle][aaID] = {
                                  canceled  = true,
                                  from      = aMinion
                              }
                            end
                          elseif not self.aAttacks[aHandle][aaID] then
                              self.aAttacks[aHandle][aaID] = {
                                  canceled  = false,
                                  speed     = pSpeed,
                                  startTime = pStartT - aAAData.windUpTime,
                                  pTime     = aAAData.windUpTime,
                                  pos       = aMPos,
                                  from      = aMinion,
                                  fromPos   = aMPos,
                                  to        = eMinion,
                                  dmg       = (aMinion.totalDamage*(1+aMinion.bonusDamagePercent))-eMinion.flatDamageReduction
                              }
                          end
                    end
                    break
                end
            end
        end
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------handle active attacks------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoFarm:_handleActiveAA()
    local aAttacks2 = self.aAttacks
    for k1,v1 in pairs(aAttacks2) do
        local count		= 0
        local checkT	= Game.Timer()
        for k2,v2 in pairs(aAttacks2[k1]) do
            count = count + 1
            if v2.speed == 0 and (not v2.from or v2.from.dead) then
                --print("dead")
                self.aAttacks[k1] = nil
                break
            end
            if v2.canceled == false then
                local ranged = v2.speed > 0
                if ranged == true then
                    self.aAttacks[k1][k2].pTime = gsoAIO.Utils:_getDistance(v2.fromPos, self:_predPos(v2.speed, v2.pos, v2.to)) / v2.speed
                end
                if checkT > v2.startTime + self.aAttacks[k1][k2].pTime - (Game.Latency()*0.0015) - 0.034 or not v2.to or v2.to.dead then
                    self.aAttacks[k1][k2] = nil
                elseif ranged == true then
                    self.aAttacks[k1][k2].pos = v2.fromPos:Extended(v2.to.pos, (checkT-v2.startTime)*v2.speed)
                end
            end
        end
        if count == 0 then
            --print("no active attacks")
            self.aAttacks[k1] = nil
        end
    end
end





-- http://gamingonsteroids.com/user/198940-trus/
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------TRUS PREDICTION-------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoTPred"

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------init---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTPred:CutWaypoints(Waypoints, distance, unit)
    local result = {}
    local remaining = distance
    if distance > 0 then
        for i = 1, #Waypoints -1 do
            local A, B = Waypoints[i], Waypoints[i + 1]
            if A and B then 
                local dist = self:GetDistance(A, B)
                if dist >= remaining then
                    result[1] = Vector(A) + remaining * (Vector(B) - Vector(A)):Normalized()

                    for j = i + 1, #Waypoints do
                        result[j - i + 1] = Waypoints[j]
                    end
                    remaining = 0
                    break
                else
                    remaining = remaining - dist
                end
            end
        end
    else
        local A, B = Waypoints[1], Waypoints[2]
        result = Waypoints
        result[1] = Vector(A) - distance * (Vector(B) - Vector(A)):Normalized()
    end
    return result
end
function __gsoTPred:VectorMovementCollision(startPoint1, endPoint1, v1, startPoint2, v2, delay)
    local sP1x, sP1y, eP1x, eP1y, sP2x, sP2y = startPoint1.x, startPoint1.z, endPoint1.x, endPoint1.z, startPoint2.x, startPoint2.z
    local d, e = eP1x-sP1x, eP1y-sP1y
    local dist, t1, t2 = mathSqrt(d*d+e*e), nil, nil
    local S, K = dist~=0 and v1*d/dist or 0, dist~=0 and v1*e/dist or 0
    local function GetCollisionPoint(t) return t and {x = sP1x+S*t, y = sP1y+K*t} or nil end
    if delay and delay~=0 then sP1x, sP1y = sP1x+S*delay, sP1y+K*delay end
    local r, j = sP2x-sP1x, sP2y-sP1y
    local c = r*r+j*j
    if dist>0 then
        if v1 == math.huge then
            local t = dist/v1
            t1 = v2*t>=0 and t or nil
        elseif v2 == math.huge then
            t1 = 0
        else
            local a, b = S*S+K*K-v2*v2, -r*S-j*K
            if a==0 then 
                if b==0 then --c=0->t variable
                    t1 = c==0 and 0 or nil
                else --2*b*t+c=0
                    local t = -c/(2*b)
                    t1 = v2*t>=0 and t or nil
                end
            else --a*t*t+2*b*t+c=0
                local sqr = b*b-a*c
                if sqr>=0 then
                    local nom = mathSqrt(sqr)
                    local t = (-nom-b)/a
                    t1 = v2*t>=0 and t or nil
                    t = (nom-b)/a
                    t2 = v2*t>=0 and t or nil
                end
            end
        end
    elseif dist==0 then
        t1 = 0
    end
    return t1, GetCollisionPoint(t1), t2, GetCollisionPoint(t2), dist
end
function __gsoTPred:GetCurrentWayPoints(object)
    local result = {}
    local objectPos = object.pos
    if object.pathing.hasMovePath then
        local objectPath = object.pathing
        table.insert(result, Vector(objectPos.x,objectPos.y, objectPos.z))
        for i = objectPath.pathIndex, objectPath.pathCount do
            path = object:GetPath(i)
            table.insert(result, Vector(path.x, path.y, path.z))
        end
    else
        table.insert(result, object and Vector(objectPos.x,objectPos.y, objectPos.z) or Vector(objectPos.x,objectPos.y, objectPos.z))
    end
    return result
end
function __gsoTPred:GetDistanceSqr(p1, p2)
    if not p1 or not p2 then return 999999999 end
    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end
function __gsoTPred:GetDistance(p1, p2)
    return mathSqrt(self:GetDistanceSqr(p1, p2))
end
function __gsoTPred:GetWaypointsLength(Waypoints)
    local result = 0
    for i = 1, #Waypoints -1 do
        result = result + self:GetDistance(Waypoints[i], Waypoints[i + 1])
    end
    return result
end
function __gsoTPred:CanMove(unit, delay)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i);
        if buff and buff.count > 0 and buff.duration>=delay then
            if (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11) then
                return false -- block everything
            end
        end
    end
    return true
end
function __gsoTPred:IsImmobile(unit, delay, radius, speed, from, spelltype)
    local unitPos = unit.pos
    local ExtraDelay = speed == math.huge and 0 or from and unit and unitPos and (self:GetDistance(from, unitPos) / speed)
    if (self:CanMove(unit, delay + ExtraDelay) == false) then
        return true
    end
    return false
end
function __gsoTPred:CalculateTargetPosition(unit, delay, radius, speed, from, spelltype)
    local Waypoints = {}
    local unitPos = unit.pos
    local Position, CastPosition = Vector(unitPos), Vector(unitPos)
    local t
    Waypoints = self:GetCurrentWayPoints(unit)
    local Waypointslength = self:GetWaypointsLength(Waypoints)
    local movementspeed = unit.pathing.isDashing and unit.pathing.dashSpeed or unit.ms
    if #Waypoints == 1 then
        Position, CastPosition = Vector(Waypoints[1].x, Waypoints[1].y, Waypoints[1].z), Vector(Waypoints[1].x, Waypoints[1].y, Waypoints[1].z)
        return Position, CastPosition
    elseif (Waypointslength - delay * movementspeed + radius) >= 0 then
        local tA = 0
        Waypoints = self:CutWaypoints(Waypoints, delay * movementspeed - radius)
        if speed ~= math.huge then
            for i = 1, #Waypoints - 1 do
                local A, B = Waypoints[i], Waypoints[i+1]
                if i == #Waypoints - 1 then
                    B = Vector(B) + radius * Vector(B - A):Normalized()
                end

                local t1, p1, t2, p2, D = self:VectorMovementCollision(A, B, movementspeed, Vector(from.x,from.y,from.z), speed)
                local tB = tA + D / movementspeed
                t1, t2 = (t1 and tA <= t1 and t1 <= (tB - tA)) and t1 or nil, (t2 and tA <= t2 and t2 <= (tB - tA)) and t2 or nil
                t = t1 and t2 and math.min(t1, t2) or t1 or t2
                if t then
                    CastPosition = t==t1 and Vector(p1.x, 0, p1.y) or Vector(p2.x, 0, p2.y)
                    break
                end
                tA = tB
            end
        else
            t = 0
            CastPosition = Vector(Waypoints[1].x, Waypoints[1].y, Waypoints[1].z)
        end
        if t then
            if (self:GetWaypointsLength(Waypoints) - t * movementspeed - radius) >= 0 then
                Waypoints = self:CutWaypoints(Waypoints, radius + t * movementspeed)
                Position = Vector(Waypoints[1].x, Waypoints[1].y, Waypoints[1].z)
            else
                Position = CastPosition
            end
        elseif unit.type ~= myHero.type then
            CastPosition = Vector(Waypoints[#Waypoints].x, Waypoints[#Waypoints].y, Waypoints[#Waypoints].z)
            Position = CastPosition
        end
    elseif unit.type ~= myHero.type then
        CastPosition = Vector(Waypoints[#Waypoints].x, Waypoints[#Waypoints].y, Waypoints[#Waypoints].z)
        Position = CastPosition
    end
    return Position, CastPosition
end
function __gsoTPred:VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
    return pointSegment, pointLine, isOnSegment
end
function __gsoTPred:CheckCol(unit, minion, Position, delay, radius, range, speed, from, draw)
    if unit.networkID == minion.networkID then 
        return false
    end
    local waypoints = self:GetCurrentWayPoints(minion)
    local minionPos = minion.pos
    local MPos, CastPosition = #waypoints == 1 and Vector(minionPos) or self:CalculateTargetPosition(minion, delay, radius, speed, from, "line")
    if from and MPos and self:GetDistanceSqr(from, MPos) <= (range)^2 and self:GetDistanceSqr(from, minionPos) <= (range + 100)^2 then
        local buffer = (#waypoints > 1) and 8 or 0 
        if minion.type == myHero.type then
            buffer = buffer + minion.boundingRadius
        end
        if #waypoints > 1 then
            local proj1, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(from, Position, Vector(MPos))
            if proj1 and isOnSegment and (self:GetDistanceSqr(MPos, proj1) <= (minion.boundingRadius + radius + buffer) ^ 2) then
                return true
            end
        end
        local proj2, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(from, Position, Vector(minionPos))
        if proj2 and isOnSegment and (self:GetDistanceSqr(minionPos, proj2) <= (minion.boundingRadius + radius + buffer) ^ 2) then
            return true
        end
    end
end
function __gsoTPred:CheckMinionCollision(unit, Position, delay, radius, range, speed, from)
    Position = Vector(Position)
    from = from and Vector(from) or myHero.pos
    for i = 1, #gsoAIO.OB.enemyMinions do
        local minion = gsoAIO.OB.enemyMinions[i]
        if minion and not minion.dead and minion.isTargetable and minion.visible and minion.valid and self:CheckCol(unit, minion, Position, delay, radius, range, speed, from, draw) then
            return true
        end
    end
    return false
end
function __gsoTPred:isSlowed(unit, delay, speed, from)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i);
        if buff and from and buff.count > 0 and buff.duration>=(delay + self:GetDistance(unit.pos, from) / speed) then
            if (buff.type == 10) then
                return true
            end
        end
    end
    return false
end
function __gsoTPred:GetBestCastPosition(unit, delay, radius, range, speed, from, collision, spelltype)
    range = range and range - 4 or math.huge
    radius = radius == 0 and 1 or radius - 4
    speed = speed and speed or math.huge
    local mePos = myHero.pos
    local hePos = unit.pos
    if not from then
        from = Vector(mePos)
    end
    local IsFromMyHero = self:GetDistanceSqr(from, mePos) < 50*50 and true or false
    delay = delay + (0.07 + Game.Latency() / 2000)
    local Position, CastPosition = self:CalculateTargetPosition(unit, delay, radius, speed, from, spelltype)
    local HitChance = 1
    if (self:IsImmobile(unit, delay, radius, speed, from, spelltype)) then
        HitChance = 5
    end
    Waypoints = self:GetCurrentWayPoints(unit)
    if (#Waypoints == 1) then
        HitChance = 2
    end
    if self:isSlowed(unit, delay, speed, from) then
        HitChance = 2
    end
    if (unit.activeSpell and unit.activeSpell.valid) then
        HitChance = 2
    end
    if self:GetDistance(mePos, hePos) < 250 then
        HitChance = 2
        Position, CastPosition = self:CalculateTargetPosition(unit, delay*0.5, radius, speed*2, from, spelltype)
        Position = CastPosition
    end
    local angletemp = Vector(from):AngleBetween(Vector(hePos), Vector(CastPosition))
    if angletemp > 60 then
        HitChance = 1
    elseif angletemp < 30 then
        HitChance = 2
    end
    --[[Out of range]]
    if IsFromMyHero then
        if (spelltype == "line" and self:GetDistanceSqr(from, Position) >= range * range) then
            HitChance = 0
        end
        if (spelltype == "circular" and (self:GetDistanceSqr(from, Position) >= (range + radius)*(range + radius))) then
            HitChance = 0
        end
        if from and Position and (self:GetDistanceSqr(from, Position) > range * range) then
            HitChance = 0
        end
    end
    radius = radius*2
    if collision and HitChance > 0 then
        if collision and self:CheckMinionCollision(unit, hePos, delay, radius, range, speed, from) then
            HitChance = -1
        elseif self:CheckMinionCollision(unit, Position, delay, radius, range, speed, from) then
            HitChance = -1
        elseif self:CheckMinionCollision(unit, CastPosition, delay, radius, range, speed, from) then
            HitChance = -1
        end
    end
    if not CastPosition or not Position then
        HitChance = -1
    end
    return CastPosition, HitChance, Position
end






--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------ORBWALKER----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoOrb"

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------init---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoOrb:__init()
    
    --[[ move if stop holding orb key ]]
    self.lastKey      = 0
    
    --[[ orbwalker ]]
    self.canMove      = true
    self.canAA        = true
    self.aaReset      = false
    self.lAttack      = 0
    self.lMove        = 0
    
    --[[ delayed actions ]]
    self.dActionsC    = 0
    self.dActions     = {}
    
    --[[ attack data ]]
    self.baseAASpeed  = 0
    self.baseWindUp   = 0
    self.windUpT      = myHero.attackData.windUpTime
    self.animT        = myHero.attackData.animationTime
    
    --[[ callbacks ]]
    Callback.Add('Tick', function() self:_tick() end)
    Callback.Add('Draw', function() self:_draw() end)
    Callback.Add('WndMsg', function(msg, wParam) self:_onWndMsg(msg, wParam) end)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|----------------------orbwalker--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoOrb:_orb(unit)
    
    --[[ use botrk ]]
    if self.dActionsC == 0 and gsoAIO.Load.menu.orb.keys.combo:Value() and gsoAIO.Load.menu.gsoitem.botrk:Value() and gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, false) then
        local botrkHK = gsoAIO.Items:_botrk()
        if botrkHK then
            local targetPos = gsoAIO.TS.lastTarget.pos
            if gsoAIO.Utils:_getDistance(myHero.pos, targetPos) < 550 then
                local cPos = cursorPos
                Control.SetCursorPos(targetPos)
                Control.KeyDown(botrkHK)
                Control.KeyUp(botrkHK)
                gsoAIO.Items.lastBotrk = GetTickCount()
                self.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                self.dActionsC = self.dActionsC + 1
                return
            end
        end
    end
    
    --[[ > 2.5 attack speed ]]
    local aaSpeed = gsoAIO.Vars._aaSpeed() * self.baseAASpeed
          aaSpeed = aaSpeed > 2.5 and 2.5 or aaSpeed
    self.animT    = 1 / aaSpeed
    self.windUpT  = (self.animT * self.baseWindUp) + (gsoAIO.Load.menu.orb.delays.windup:Value() * 0.001) + 0.09
    self.animT    = self.animT + 0.01
    
    --[[ check if can attack | move ]]
    self.canAA      = os.clock() > self.lAttack + self.animT and gsoAIO.Vars._canAttack() and not gsoAIO.TS.isBlinded
    self.canMove    = os.clock() > self.lAttack + self.windUpT
    
    --[[ attack | move ]]
    if self.dActionsC == 0 then
        if unit ~= nil and (self.canAA or self.aaReset) then
            if ExtLibEvade and ExtLibEvade.Evading then return end
            local cPos = cursorPos
            Control.SetCursorPos(unit.pos)
            Control.KeyDown(HK_TCO)
            Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
            Control.mouse_event(MOUSEEVENTF_RIGHTUP)
            Control.KeyUp(HK_TCO)
            self.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            self.dActionsC = self.dActionsC + 1
            self.aaReset = false
            self.lAttack = os.clock()
            self.lMove = 0
            if gsoAIO.Vars.meTristana and gsoAIO.Utils.eBuffTarget and gsoAIO.Utils.eBuffTarget.id == unit.networkID then
                gsoAIO.Utils.eBuffTarget.stacks = gsoAIO.Utils.eBuffTarget.stacks + 1
                if gsoAIO.Utils.eBuffTarget.stacks == 5 then
                    gsoAIO.Utils.delayedActions[#gsoAIO.Utils.delayedActions+1] = { func = function() gsoAIO.Utils.eBuffTarget = nil end, endTime = os.clock() + self.windUpT + (gsoAIO.Utils:_getDistance(myHero.pos, unit.pos) / 2000) }
                end
            end
        elseif self.canMove and os.clock() > self.lMove + (gsoAIO.Load.menu.orb.delays.humanizer:Value()*0.001) and self.dActionsC == 0 then
            local mPos = gsoAIO.Vars._mousePos()
            if mPos ~= nil then
                if ExtLibEvade and ExtLibEvade.Evading then return end
                if Control.IsKeyDown(2) then self.lastKey = GetTickCount() end
                local cPos = cursorPos
                Control.SetCursorPos(mPos)
                Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
                Control.mouse_event(MOUSEEVENTF_RIGHTUP)
                self.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                self.dActionsC = self.dActionsC + 1
                self.lMove = os.clock()
            else
                if ExtLibEvade and ExtLibEvade.Evading then return end
                if Control.IsKeyDown(2) then self.lastKey = GetTickCount() end
                Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
                Control.mouse_event(MOUSEEVENTF_RIGHTUP)
                self.lMove = os.clock()
            end
        end
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|----------------------onwndmsg---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoOrb:_onWndMsg(msg, wParam)
    if wParam == HK_TCO then
        self.lAttack = os.clock()
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------tick----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--[[local e = myHero.attackData.endTime+1
local c = 0
local t = 0]]
function __gsoOrb:_tick()
    
    --[[ test orbwalker dmg
    local aaData = myHero.attackData
    local ee = aaData.endTime
    if ee > e then
        e = ee
        if c == 0 then
            t = os.clock()
        end
        c = c + 1
        if c == 5 then
            print(os.clock()-t)
            c = 0
            t = 0
        end
    end]]
    
    --[[ disable when evading ]]
    if ExtLibEvade and ExtLibEvade.Evading then return end
    
    --[[ handle objects ]]
    gsoAIO.OB:_tick()
    
    --[[ handle farm ]]
    gsoAIO.Farm:_tick()
    
    --[[ champion's tick ]]
    gsoAIO.Vars._onTick()
    
    --[[ handle delayed actions ]]
    local dActions = self.dActions
    local cDActions = 0
    for k,v in pairs(dActions) do
        cDActions = cDActions + 1
        if not v[3] and GetTickCount() - k > v[2] then
            v[1]()
            v[3] = true
        elseif v[3] and GetTickCount() - k > v[2] + 25 then
            self.dActions[k] = nil
        end
    end
    self.dActionsC = cDActions
    
    --[[ orbwalker ]]
    local ck      = gsoAIO.Load.menu.orb.keys.combo:Value()
    local hk      = gsoAIO.Load.menu.orb.keys.harass:Value()
    local lhk     = gsoAIO.Load.menu.orb.keys.lastHit:Value()
    local lck     = gsoAIO.Load.menu.orb.keys.laneClear:Value()
    if Game.IsChatOpen() == false and (ck or hk or lhk or lck) then
        local AAtarget = nil
        if ck then
            AAtarget = gsoAIO.TS:_comboT()
        elseif hk then
            AAtarget = gsoAIO.TS:_harassT()
        elseif lhk then
            AAtarget = gsoAIO.TS:_lastHitT()
        elseif lck then
            AAtarget = gsoAIO.TS:_laneClearT()
        end
        if ExtLibEvade then
            if not ExtLibEvade.Evading then
                self:_orb(AAtarget)
            end
        else
            self:_orb(AAtarget)
        end
    elseif self.dActionsC == 0 and GetTickCount() < self.lastKey + 1000 then
        Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
        --print("ok")
        self.lastKey = 0
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------draw----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoOrb:_draw()
    if not gsoAIO.Load.menu.orb.draw.enable:Value() then return end
    local mePos = myHero.pos
    if gsoAIO.Load.menu.orb.draw.me.enable:Value() and not myHero.dead and mePos:ToScreen().onScreen then
        Draw.Circle(mePos, myHero.range + myHero.boundingRadius + 35, gsoAIO.Load.menu.orb.draw.me.width:Value(), gsoAIO.Load.menu.orb.draw.me.color:Value())
    end
    if gsoAIO.Load.menu.orb.draw.he.enable:Value() then
        local countEH = #gsoAIO.OB.enemyHeroes
        for i = 1, countEH do
            local hero = gsoAIO.OB.enemyHeroes[i]
            local heroPos = hero.pos
            if gsoAIO.Utils:_getDistance(mePos, heroPos) < 2000 and heroPos:ToScreen().onScreen then
                Draw.Circle(heroPos, hero.range + hero.boundingRadius + 35, gsoAIO.Load.menu.orb.draw.he.width:Value(), gsoAIO.Load.menu.orb.draw.he.color:Value())
            end
        end
    end
    if gsoAIO.Load.menu.orb.draw.cpos.enable:Value() then
        Draw.Circle(mousePos, gsoAIO.Load.menu.orb.draw.cpos.radius:Value(), gsoAIO.Load.menu.orb.draw.cpos.width:Value(), gsoAIO.Load.menu.orb.draw.cpos.color:Value())
    end
end





--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------ASHE-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoAshe"

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------init---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoAshe:__init()
    self.lastQ = 0
    self.lastW = 0
    self.lastR = 0
    self.QEndTime = 0
    self.hasQBuff = false
    self.asNoQ = myHero.attackSpeed
    gsoAIO.Orb.baseAASpeed = 0.658
    gsoAIO.Orb.baseWindUp = 0.2192982
    gsoAIO.Vars:_setAASpeed(function() return self:_aaSpeed() end)
    gsoAIO.Vars:_setOnTick(function() self:_tick() end)
    gsoAIO.Vars:_setBonusDmg(function() return 3 end)
    gsoAIO.Vars:_setBonusDmgUnit(function(unit) return self:_dmgUnit(unit) end)
    gsoAIO.Vars:_setChampMenu(function() return self:_menu() end)
    gsoAIO.Vars:_setCanAttack(function() return self:_canAttack() end)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------menu---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoAshe:_menu()
    gsoAIO.Load.menu:MenuElement({id = "gsoashe", name = "Ashe", type = MENU, leftIcon = gsoAIO.Vars.Icons["ashe"] })
        gsoAIO.Load.menu.gsoashe:MenuElement({id = "rdist", name = "use R if enemy distance < X", value = 500, min = 250, max = 1000, step = 50})
        gsoAIO.Load.menu.gsoashe:MenuElement({id = "combo", name = "Combo", type = MENU})
            gsoAIO.Load.menu.gsoashe.combo:MenuElement({id = "qc", name = "UseQ", value = true})
            gsoAIO.Load.menu.gsoashe.combo:MenuElement({id = "wc", name = "UseW", value = true})
            gsoAIO.Load.menu.gsoashe.combo:MenuElement({id = "rcd", name = "UseR [enemy distance < X", value = true})
            gsoAIO.Load.menu.gsoashe.combo:MenuElement({id = "rci", name = "UseR [enemy IsImmobile]", value = true})
        gsoAIO.Load.menu.gsoashe:MenuElement({id = "harass", name = "Harass", type = MENU})
            gsoAIO.Load.menu.gsoashe.harass:MenuElement({id = "qh", name = "UseQ", value = true})
            gsoAIO.Load.menu.gsoashe.harass:MenuElement({id = "wh", name = "UseW", value = true})
            gsoAIO.Load.menu.gsoashe.harass:MenuElement({id = "rhd", name = "UseR [enemy distance < X]", value = false})
            gsoAIO.Load.menu.gsoashe.harass:MenuElement({id = "rhi", name = "UseR [enemy IsImmobile]", value = false})
end

--------------------|---------------------------------------------------------|--------------------
--------------------|----------------------aaSpeed----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoAshe:_aaSpeed()
    local num1 = self.QEndTime - GetTickCount()
    if num1 > -1000 and num1 < 500 then
        return self.asNoQ
    end
    return myHero.attackSpeed
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------canAA-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoAshe:_canAttack()
    local num1 = self.QEndTime - GetTickCount()
    if num1 > -150 and num1 < 100 then
        return false
    end
    local checkTick = GetTickCount()
    local qMinus = checkTick - self.lastQ
    local qMinuss = checkTick - gsoAIO.Spells.lastQ
    local wMinus = checkTick - self.lastW
    local wMinuss = checkTick - gsoAIO.Spells.lastW
    local rMinus = checkTick - self.lastR
    local rMinuss = checkTick - gsoAIO.Spells.lastR
    if qMinus > 200 and qMinuss > 200 and wMinus > 450 and wMinuss > 450 and rMinus > 450 and rMinuss > 450 then
        return true
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------cast spells--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoAshe:_castW()
    local target = gsoAIO.TS:_getTarget(1200, false, false)
    if target ~= nil then
        local mePos = myHero.pos
        local sW = { delay = 0.25, range = 1200, width = 75, speed = 2000, sType = "line", col = true }
        local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, mePos, sW.col, sW.sType)
        if HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(mePos, castpos) < sW.range and gsoAIO.Utils:_getDistance(target.pos, castpos) < 500 then
            local cPos = cursorPos
            Control.SetCursorPos(castpos)
            Control.KeyDown(HK_W)
            Control.KeyUp(HK_W)
            self.lastW = GetTickCount()
            gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
            return true
        end
    end
    return false
end
function __gsoAshe:_castRd()
    local mePos = myHero.pos
    local t = nil
    local menuDist = gsoAIO.Load.menu.gsoashe.rdist:Value()
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local hero = gsoAIO.OB.enemyHeroes[i]
        local distance = gsoAIO.Utils:_getDistance(mePos, hero.pos)
        if gsoAIO.Utils:_valid(hero, false) and distance < menuDist then
            menuDist = distance
            t = hero
        end
    end
    if t then
        local tPos = t.pos
        local sR = { delay = 0.25, range = 1500, width = 125, speed = 1600, sType = "line", col = false }
        local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(t, sR.delay, sR.width*0.5, sR.range, sR.speed, mePos, sR.col, sR.sType)
        if HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(t.pos, castpos) < 500 and gsoAIO.Utils:_pointOnLineSegment(castpos.x, castpos.z, tPos.x, tPos.z, mePos.x, mePos.z) then
            local cPos = cursorPos
            Control.SetCursorPos(castpos)
            Control.KeyDown(HK_R)
            Control.KeyUp(HK_R)
            self.lastR = GetTickCount()
            gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
            return true
        end
    end
    return false
end
function __gsoAshe:_castRi()
    local mePos = myHero.pos
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local hero = gsoAIO.OB.enemyHeroes[i]
        local heroPos = hero.pos
        if gsoAIO.Utils:_valid(hero, false) and gsoAIO.Utils:_getDistance(mePos, heroPos) < 1000 and gsoAIO.Utils:_isImmobile(hero) then
            local rPred = heroPos
            if rPred and rPred:ToScreen().onScreen then
                local cPos = cursorPos
                Control.SetCursorPos(rPred)
                Control.KeyDown(HK_R)
                Control.KeyUp(HK_R)
                self.lastR = GetTickCount()
                gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                return true
            end
        end
    end
    return false
end



--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------tick-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoAshe:_tick()
    
    --[[ ashe Q buff ]]
    local hasQBuff = false
    for i = 0, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        local buffName = buff and buff.name or nil
        if buffName and buff.count > 0 and buff.duration > 0 and buffName == "AsheQAttack" then
            hasQBuff = true
            self.QEndTime = GetTickCount() + (buff.duration*1000)
            break
        end
    end
    self.hasQBuff = hasQBuff
    
    --[[ cast spells ]]
    if os.clock() > gsoAIO.Orb.lAttack + gsoAIO.Orb.windUpT then
    
        --[[ check if spells are ready ]]
        local checkTick = GetTickCount()
        local qMinus = checkTick - self.lastQ
        local qMinuss = checkTick - gsoAIO.Spells.lastQ
        local wMinus = checkTick - self.lastW
        local wMinuss = checkTick - gsoAIO.Spells.lastW
        local rMinus = checkTick - self.lastR
        local rMinuss = checkTick - gsoAIO.Spells.lastR
        local canQTime = qMinus > 1000 and qMinuss > 1000 and wMinus > 350 and wMinuss > 350 and rMinus > 350 and rMinuss > 350
        local canWTime = qMinus > 450 and qMinuss > 450 and wMinus > 1000 and wMinuss > 1000 and rMinus > 700 and rMinuss > 700
        local canRTime = qMinus > 450 and qMinuss > 450 and wMinus > 650 and wMinuss > 650 and rMinus > 1000 and rMinuss > 1000
        local isCombo = gsoAIO.Load.menu.orb.keys.combo:Value()
        local isHarass = gsoAIO.Load.menu.orb.keys.harass:Value()
        local isComboQ = isCombo and gsoAIO.Load.menu.gsoashe.combo.qc:Value()
        local isHarassQ = isHarass and gsoAIO.Load.menu.gsoashe.harass.qh:Value()
        local isComboW = isCombo and gsoAIO.Load.menu.gsoashe.combo.wc:Value()
        local isHarassW = isHarass and gsoAIO.Load.menu.gsoashe.harass.wh:Value()
        local isComboRd = isCombo and gsoAIO.Load.menu.gsoashe.combo.rcd:Value()
        local isHarassRd = isHarass and gsoAIO.Load.menu.gsoashe.harass.rhd:Value()
        local isComboRi = isCombo and gsoAIO.Load.menu.gsoashe.combo.rci:Value()
        local isHarassRi = isHarass and gsoAIO.Load.menu.gsoashe.harass.rhi:Value()
        local isQReady = (isComboQ or isHarassQ) and canQTime == true and gsoAIO.Utils:_isReady(_Q) == true
        local isWReady = (isComboW or isHarassW) and canWTime == true and gsoAIO.Utils:_isReady(_W) == true
        local isRdReady = (isComboRd or isHarassRd) and canRTime == true and gsoAIO.Utils:_isReady(_R) == true
        local isRiReady = (isComboRi or isHarassRi) and canRTime == true and gsoAIO.Utils:_isReady(_R) == true
        
        if isQReady or isWReady or isRdReady or isRiReady then
            
            --[[ check enemies in aa range ]]
            local mePos = myHero.pos
            local meRange = myHero.range + myHero.boundingRadius - 30
            local enemiesCount = 0
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                if gsoAIO.Utils:_valid(hero, true) and gsoAIO.Utils:_getDistance(mePos, hero.pos) < meRange + hero.boundingRadius then
                    enemiesCount = enemiesCount + 1
                end
            end
            
            --[[ spells after/before if enemy is in aa range ]]
            local afterBefore = os.clock() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT*0.75
            
            --[[ spells if enemy is out of aa range ]]
            local outOfAARange = not gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, true) and enemiesCount == 0
            
            --[[ cast spells ]]
            if afterBefore or outOfAARange then
                if isRiReady and self:_castRi() then
                    return
                end
                if isRdReady and self:_castRd() then
                    return
                end
                if isWReady and self:_castW() then
                    return
                end
            end
            if isQReady and os.clock() > gsoAIO.Orb.lAttack + gsoAIO.Orb.animT*0.5 and os.clock() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT*0.7 then
                self.asNoQ = myHero.attackSpeed
                Control.KeyDown(HK_Q)
                Control.KeyUp(HK_Q)
                self.lastQ = GetTickCount()
            end
        end
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------bonus dmg-------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoAshe:_dmgUnit(unit)
    local dmg = myHero.totalDamage
    local crit = 0.1 + myHero.critChance
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == "ashepassiveslow" then
            local aacompleteT = myHero.attackData.windUpTime + (gsoAIO.Utils:_getDistance(myHero.pos, unit.pos) / myHero.attackData.projectileSpeed)
            if aacompleteT + 0.1 < buff.duration then
                return dmg * crit
            end
        end
    end
    return 0
end





--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------TWITCH-------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoTwitch"

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------init---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTwitch:__init()
    self.hasQBuff = false
    self.qBuffTime = 0
    self.lastW  = 0
    self.lastE  = 0
    self.eBuffs = {}
    self.asNoQ = myHero.attackSpeed
    self.boolRecall = true
    self.QASBuff = false
    self.QASTime = 0
    gsoAIO.Orb.baseAASpeed = 0.679
    gsoAIO.Orb.baseWindUp = 0.2019159
    gsoAIO.Vars:_setOnTick(function() self:_tick() end)
    gsoAIO.Vars:_setBonusDmg(function() return 3 end)
    gsoAIO.Vars:_setChampMenu(function() return self:_menu() end)
    gsoAIO.Vars:_setCanAttack(function() return self:_canAttack() end)
    gsoAIO.Vars:_setAASpeed(function() return self:_aaSpeed() end)
    Callback.Add('Draw', function() self:_draw() end)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|----------------------aaSpeed----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTwitch:_aaSpeed()
    local num1 = self.QASTime-GetTickCount()
    if num1 > -1000 and num1 < 500 then
        return self.asNoQ
    end
    return myHero.attackSpeed
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------canAA-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTwitch:_canAttack()
    local num1 = 1350+gsoAIO.Spells.qLatency-(GetTickCount()-gsoAIO.Spells.lastQ)
    if num1 > -50 and num1 < (gsoAIO.Orb.windUpT*1000) + 250 then
        return false
    end
    local num2 = self.QASTime-GetTickCount()
    if num2 > -150 and num2 < 100 then
        return false
    end
    local checkTick = GetTickCount()
    local qMinuss = checkTick - gsoAIO.Spells.lastQ
    local wMinus = checkTick - self.lastW
    local wMinuss = checkTick - gsoAIO.Spells.lastW
    local eMinus = checkTick - self.lastE
    local eMinuss = checkTick - gsoAIO.Spells.lastE
    local rMinuss = checkTick - gsoAIO.Spells.lastR
    if wMinus > 450 and wMinuss > 450 and eMinus > 400 and eMinuss > 400 then
        return true
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------menu---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTwitch:_menu()
    gsoAIO.Load.menu:MenuElement({name = "Twitch", id = "gsotwitch", type = MENU, leftIcon = gsoAIO.Vars.Icons["twitch"] })
        gsoAIO.Load.menu.gsotwitch:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gsoAIO.Load.menu.gsotwitch.qset:MenuElement({id = "recallkey", name = "Invisible Recall Key", key = string.byte("T"), value = false, toggle = true})
            gsoAIO.Load.menu.gsotwitch.qset:MenuElement({id = "note1", name = "Note: Key should be diffrent than recall key", type = SPACE})
        gsoAIO.Load.menu.gsotwitch:MenuElement({name = "W settings", id = "wset", type = MENU })
            gsoAIO.Load.menu.gsotwitch.wset:MenuElement({id = "stopq", name = "Stop if Q invisible", value = true})
            gsoAIO.Load.menu.gsotwitch.wset:MenuElement({id = "stopult", name = "Stop if R", value = true})
            gsoAIO.Load.menu.gsotwitch.wset:MenuElement({id = "combo", name = "Use W Combo", value = true})
            gsoAIO.Load.menu.gsotwitch.wset:MenuElement({id = "harass", name = "Use W Harass", value = false})
        gsoAIO.Load.menu.gsotwitch:MenuElement({name = "E settings", id = "eset", type = MENU })
            gsoAIO.Load.menu.gsotwitch.eset:MenuElement({id = "combo", name = "Use E Combo", value = true})
            gsoAIO.Load.menu.gsotwitch.eset:MenuElement({id = "harass", name = "Use E Harass", value = false})
            gsoAIO.Load.menu.gsotwitch.eset:MenuElement({id = "stacks", name = "X stacks", value = 6, min = 1, max = 6, step = 1 })
            gsoAIO.Load.menu.gsotwitch.eset:MenuElement({id = "enemies", name = "X enemies", value = 1, min = 1, max = 5, step = 1 })
        gsoAIO.Load.menu.gsotwitch:MenuElement({name = "Drawings", id = "draws", type = MENU })
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "enable", name = "Enable", value = true})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "timer", name = "Q Timer", leftIcon = gsoAIO.Vars.Icons["timer"], icon = gsoAIO.Vars.Icons["arrow"], type = SPACE,
                onclick = function()
                    gsoAIO.Load.menu.gsotwitch.draws.enablet:Hide()
                    gsoAIO.Load.menu.gsotwitch.draws.colort:Hide()
                    gsoAIO.Load.menu.gsotwitch.draws.note1:Hide()
                    gsoAIO.Load.menu.gsotwitch.draws.note2:Hide()
                end
            })
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "note1", name = "", type = SPACE})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "enablet", name = "Enable", value = true})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "colort", name = "Color", color = Draw.Color(200, 65, 255, 100)})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "note2", name = "", type = SPACE})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "circles1", name = "Circles", leftIcon = gsoAIO.Vars.Icons["draws"], icon = gsoAIO.Vars.Icons["arrow"], type = SPACE,
                onclick = function()
                    gsoAIO.Load.menu.gsotwitch.draws.invenable:Hide()
                    gsoAIO.Load.menu.gsotwitch.draws.notenable:Hide()
                    gsoAIO.Load.menu.gsotwitch.draws.invcolor:Hide()
                    gsoAIO.Load.menu.gsotwitch.draws.notcolor:Hide()
                    gsoAIO.Load.menu.gsotwitch.draws.wenable:Hide()
                    gsoAIO.Load.menu.gsotwitch.draws.wcolor:Hide()
                    gsoAIO.Load.menu.gsotwitch.draws.eenable:Hide()
                    gsoAIO.Load.menu.gsotwitch.draws.ecolor:Hide()
                    gsoAIO.Load.menu.gsotwitch.draws.note3:Hide()
                    gsoAIO.Load.menu.gsotwitch.draws.note4:Hide()
                    gsoAIO.Load.menu.gsotwitch.draws.note5:Hide()
                    gsoAIO.Load.menu.gsotwitch.draws.note6:Hide()
                    gsoAIO.Load.menu.gsotwitch.draws.note7:Hide()
                end
            })
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "note3", name = "", type = SPACE})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "invenable", name = "Q Invisible Enable", value = true})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "invcolor", name = "Q Invisible Color ", color = Draw.Color(200, 255, 0, 0)})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "note4", name = "", type = SPACE})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "notenable", name = "Q Notification Enable", value = true})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "notcolor", name = "Q Notification Color", color = Draw.Color(200, 188, 77, 26)})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "note5", name = "", type = SPACE})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "wenable", name = "W Enable", value = true})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "wcolor", name = "W Color", color = Draw.Color(255, 71, 70, 70)})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "note6", name = "", type = SPACE})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "eenable", name = "E Enable", value = true})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "ecolor", name = "E Color", color = Draw.Color(255, 66, 79, 122)})
            gsoAIO.Load.menu.gsotwitch.draws:MenuElement({id = "note7", name = "", type = SPACE})
gsoAIO.Load.menu.gsotwitch.draws.note1:Hide(true)
gsoAIO.Load.menu.gsotwitch.draws.note2:Hide(true)
gsoAIO.Load.menu.gsotwitch.draws.note3:Hide(true)
gsoAIO.Load.menu.gsotwitch.draws.note4:Hide(true)
gsoAIO.Load.menu.gsotwitch.draws.note5:Hide(true)
gsoAIO.Load.menu.gsotwitch.draws.note6:Hide(true)
gsoAIO.Load.menu.gsotwitch.draws.note7:Hide(true)
gsoAIO.Load.menu.gsotwitch.draws.enablet:Hide(true)
gsoAIO.Load.menu.gsotwitch.draws.colort:Hide(true) 
gsoAIO.Load.menu.gsotwitch.draws.invenable:Hide(true)
gsoAIO.Load.menu.gsotwitch.draws.notenable:Hide(true)
gsoAIO.Load.menu.gsotwitch.draws.invcolor:Hide(true)
gsoAIO.Load.menu.gsotwitch.draws.notcolor:Hide(true)
gsoAIO.Load.menu.gsotwitch.draws.wenable:Hide(true)
gsoAIO.Load.menu.gsotwitch.draws.wcolor:Hide(true)
gsoAIO.Load.menu.gsotwitch.draws.eenable:Hide(true)
gsoAIO.Load.menu.gsotwitch.draws.ecolor:Hide(true)
gsoAIO.Load.menu.gsotwitch.qset.recallkey:Value(false)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------draw---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTwitch:_draw()
    if not gsoAIO.Load.menu.gsotwitch.draws.enable:Value() then return end
    local mePos = myHero.pos
    if gsoAIO.Load.menu.gsotwitch.draws.wenable:Value() then
        Draw.Circle(mePos, 950, 1, gsoAIO.Load.menu.gsotwitch.draws.wcolor:Value())
    end
    if gsoAIO.Load.menu.gsotwitch.draws.eenable:Value() then
        Draw.Circle(mePos, 1200, 1, gsoAIO.Load.menu.gsotwitch.draws.ecolor:Value())
    end
    if gsoAIO.Load.menu.gsotwitch.draws.enablet:Value() and GetTickCount() < gsoAIO.Spells.lastQ + 16000 then
        local mePos2D = mePos:To2D()
        local posX = mePos2D.x - 50
        local posY = mePos2D.y
        local num1 = math.floor(1350+gsoAIO.Spells.qLatency-(GetTickCount()-gsoAIO.Spells.lastQ))
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
            Draw.Text(str2, 50, posX+50, posY-15, gsoAIO.Load.menu.gsotwitch.draws.colort:Value())
        elseif self.hasQBuff then
            local extraQTime = 1000*myHero:GetSpellData(_Q).level
            local num2 = math.floor(self.qBuffTime-GetTickCount()+gsoAIO.Spells.qLatency)
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
                Draw.Text(str2, 50, posX+50, posY-15, gsoAIO.Load.menu.gsotwitch.draws.colort:Value())
                if gsoAIO.Load.menu.gsotwitch.draws.invenable:Value() then
                    Draw.Circle(mePos, 500, 1, gsoAIO.Load.menu.gsotwitch.draws.invcolor:Value())
                end
                if gsoAIO.Load.menu.gsotwitch.draws.notenable:Value() then
                    Draw.Circle(mePos, 800, 1, gsoAIO.Load.menu.gsotwitch.draws.notcolor:Value())
                end
            end
        end
    end
    --
end

--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------cast spells-------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTwitch:_castW()
    local target = gsoAIO.TS:_getTarget(950, false, false)
    if target ~= nil then
        local mePos = myHero.pos
        local sW = { delay = 0.25, range = 950, width = 275, speed = 1400, sType = "circular", col = false }
        local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, mePos, sW.col, sW.sType)
        if HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(mePos, castpos) < sW.range and gsoAIO.Utils:_getDistance(target.pos, castpos) < 500 then
            local cPos = cursorPos
            Control.SetCursorPos(castpos)
            Control.KeyDown(HK_W)
            Control.KeyUp(HK_W)
            self.lastW = GetTickCount()
            gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
            return true
        end
    end
    return false
end
function __gsoTwitch:_castE()
    local xStacks   = gsoAIO.Load.menu.gsotwitch.eset.stacks:Value()
    local xEnemies  = gsoAIO.Load.menu.gsotwitch.eset.enemies:Value()
    local countE    = 0
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local hero = gsoAIO.OB.enemyHeroes[i]
        if gsoAIO.Utils:_getDistance(myHero.pos, hero.pos) < 1200 and gsoAIO.Utils:_valid(hero, false) then
            local nID = hero.networkID
            if self.eBuffs[nID] and self.eBuffs[nID].count >= xStacks then
                countE = countE + 1
            end
        end
    end
    if countE >= xEnemies then
        Control.KeyDown(HK_E)
        Control.KeyUp(HK_E)
        self.lastE = GetTickCount()
        return true
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------tick----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTwitch:_tick()
    
    --[[ recall key ]]
    local boolRecall = gsoAIO.Load.menu.gsotwitch.qset.recallkey:Value()
    if boolRecall == self.boolRecall then
        Control.KeyDown(HK_Q)
        Control.KeyUp(HK_Q)
        Control.KeyDown(string.byte("B"))
        Control.KeyUp(string.byte("B"))
        self.boolRecall = not boolRecall
        --print("ok")
    end
    
    --[[ twitch Q buff ]]
    local hasQBuff = false
    local QASBuff = false
    for i = 0, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        local buffName = buff and buff.name or nil
        if buffName and buff.count > 0 and buff.duration > 0 then
            if buffName == "globalcamouflage" or buffName == "TwitchHideInShadows" then
                hasQBuff = true
                self.qBuffTime = GetTickCount() + (buff.duration*1000)
                break
            end
            if buffName == "twitchhideinshadowsbuff" then
                QASBuff = true
                self.QASTime = GetTickCount() + (buff.duration*1000)
            end
        end
    end
    self.hasQBuff = hasQBuff
    self.QASBuff = QASBuff
    
    --[[ handle E buffs ]]
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local hero  = gsoAIO.OB.enemyHeroes[i]
        local nID   = hero.networkID
        if not self.eBuffs[nID] then
            self.eBuffs[nID] = { count = 0, durT = 0 }
        end
        if not hero.dead then
            local hasB = false
            local cB = self.eBuffs[nID].count
            local dB = self.eBuffs[nID].durT
            for i = 0, hero.buffCount do
                local buff = hero:GetBuff(i)
                if buff and buff.count > 0 and buff.name:lower() == "twitchdeadlyvenom" then
                    hasB = true
                    if cB < 6 and buff.duration > dB then
                        self.eBuffs[nID].count = cB + 1
                        self.eBuffs[nID].durT = buff.duration
                    else
                        self.eBuffs[nID].durT = buff.duration
                    end
                    break
                end
            end
            if not hasB then
                self.eBuffs[nID].count = 0
                self.eBuffs[nID].durT = 0
            end
        end
    end
    
    --[[ custom attack speed]]
    if GetTickCount() - gsoAIO.Spells.lastQ < 500 then
        self.asNoQ = myHero.attackSpeed
    end
    
    --[[ cast spells ]]
    if os.clock() > gsoAIO.Orb.lAttack + gsoAIO.Orb.windUpT then
        
        --[[ check if spells are ready ]]
        local checkTick = GetTickCount()
        local wMinus = checkTick - self.lastW
        local wMinuss = checkTick - gsoAIO.Spells.lastW
        local eMinus = checkTick - self.lastE
        local eMinuss = checkTick - gsoAIO.Spells.lastE
        local canWTime = wMinus > 1000 and wMinuss > 1000 and eMinus > 700 and eMinuss > 700
        local canETime = wMinus > 350 and wMinuss > 350 and eMinus > 1000 and eMinuss > 1000
        local isCombo = gsoAIO.Load.menu.orb.keys.combo:Value()
        local isHarass = gsoAIO.Load.menu.orb.keys.harass:Value()
        local isComboW = isCombo and gsoAIO.Load.menu.gsotwitch.wset.combo:Value()
        local isHarassW = isHarass and gsoAIO.Load.menu.gsotwitch.wset.harass:Value()
        local isComboE = isCombo and gsoAIO.Load.menu.gsotwitch.eset.combo:Value()
        local isHarassE = isHarass and gsoAIO.Load.menu.gsotwitch.eset.harass:Value()
        local stopWIfR = gsoAIO.Load.menu.gsotwitch.wset.stopult:Value() and GetTickCount() < gsoAIO.Spells.lastR + 5450
        local stopWIfQ = gsoAIO.Load.menu.gsotwitch.wset.stopq:Value() and self.hasQBuff
        local stopifQBuff = false
        local num1 = 1350+gsoAIO.Spells.qLatency-(GetTickCount()-gsoAIO.Spells.lastQ)
        if num1 > 100 and num1 < 550 then
            stopifQBuff = true
        end
        local isWReady = (isComboW or isHarassW) and canWTime == true and gsoAIO.Utils:_isReady(_W) and not stopWIfR and not stopWIfQ and not stopifQBuff
        local isEReady = canETime == true and gsoAIO.Utils:_isReady(_E) and not stopifQBuff
        
        --[[ combo/harass ]]
        if isWReady or ( isEReady and (isComboE or isHarassE) ) then
        
            --[[ check enemies in aa range ]]
            local mePos = myHero.pos
            local meRange = myHero.range + myHero.boundingRadius - 30
            local enemiesCount = 0
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                if gsoAIO.Utils:_valid(hero, true) and gsoAIO.Utils:_getDistance(mePos, hero.pos) < meRange + hero.boundingRadius then
                    enemiesCount = enemiesCount + 1
                end
            end
            
            --[[ spells after/before if enemy is in aa range ]]
            local afterBefore = os.clock() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT*0.75
            
            --[[ spells if enemy is out of aa range ]]
            local outOfAARange = not gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, true) and enemiesCount == 0
            
            --[[ cast spells ]]
            if afterBefore or outOfAARange then
                if isEReady and (isComboE or isHarassE) and self:_castE() then
                    return
                end
                if isWReady and self:_castW() then
                    return
                end
            end
        end
        
        --[[ E ks ]]
        if isEReady then
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero  = gsoAIO.OB.enemyHeroes[i]
                local nID   = hero.networkID
                if self.eBuffs[nID] and self.eBuffs[nID].count > 0 and gsoAIO.Utils:_valid(hero, false) and gsoAIO.Utils:_getDistance(myHero.pos, hero.pos) < 1200 then
                    local elvl = myHero:GetSpellData(_E).level
                    local basedmg = 5 + ( elvl * 15 )
                    local cstacks = self.eBuffs[nID].count
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
                        self.lastE = GetTickCount()
                        return
                    end
                end
            end
        end
    end
end





--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------KOGMAW-------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoKogMaw"

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------init----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoKogMaw:__init()
    gsoAIO.TS.apDmg = true
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.WBuffTime = 0
    self.hasWBuff = false
    gsoAIO.Orb.baseAASpeed = 0.665
    gsoAIO.Orb.baseWindUp = 0.1662234
    gsoAIO.Vars:_setBonusDmg(function() return 3 end)
    gsoAIO.Vars:_setOnTick(function() self:_tick() end)
    gsoAIO.Vars:_setChampMenu(function() return self:_menu() end)
    gsoAIO.Vars:_setCanAttack(function() return self:_canAttack() end)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------canAA-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoKogMaw:_canAttack()
    local checkTick = GetTickCount()
    local qMinus = checkTick - self.lastQ
    local qMinuss = checkTick - gsoAIO.Spells.lastQ
    local eMinus = checkTick - self.lastE
    local eMinuss = checkTick - gsoAIO.Spells.lastE
    local rMinus = checkTick - self.lastR
    local rMinuss = checkTick - gsoAIO.Spells.lastR
    if qMinus > 450 and qMinuss > 450 and eMinus > 450 and eMinuss > 450 and rMinus > 450 and rMinuss > 450 then
        return true
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------menu----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoKogMaw:_menu()
    gsoAIO.Load.menu:MenuElement({name = "Kog'Maw", id = "gsokog", type = MENU, leftIcon = gsoAIO.Vars.Icons["kog"] })
        gsoAIO.Load.menu.gsokog:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gsoAIO.Load.menu.gsokog.qset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsokog.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoAIO.Load.menu.gsokog:MenuElement({name = "W settings", id = "wset", type = MENU })
            gsoAIO.Load.menu.gsokog.wset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsokog.wset:MenuElement({id = "harass", name = "Harass", value = false})
            gsoAIO.Load.menu.gsokog.wset:MenuElement({id = "stopq", name = "Stop Q if has W buff", value = false})
            gsoAIO.Load.menu.gsokog.wset:MenuElement({id = "stope", name = "Stop E if has W buff", value = false})
            gsoAIO.Load.menu.gsokog.wset:MenuElement({id = "stopr", name = "Stop R if has W buff", value = false})
        gsoAIO.Load.menu.gsokog:MenuElement({name = "E settings", id = "eset", type = MENU })
            gsoAIO.Load.menu.gsokog.eset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsokog.eset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoAIO.Load.menu.gsokog:MenuElement({name = "R settings", id = "rset", type = MENU })
            gsoAIO.Load.menu.gsokog.rset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsokog.rset:MenuElement({id = "harass", name = "Harass", value = false})
            gsoAIO.Load.menu.gsokog.rset:MenuElement({id = "stack", name = "Stop at x stacks", value = 3, min = 1, max = 9, step = 1 })
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------cast spells--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoKogMaw:_castQ()
    local target = gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, false) and gsoAIO.TS.lastTarget or gsoAIO.TS:_getTarget(1175, false, false)
    if target then
        local mePos = myHero.pos
        local sQ = { delay = 0.25, range = 1175, width = 70, speed = 1650, sType = "line", col = true }
        local castpos,HitChance,pos = gsoAIO.TPred:GetBestCastPosition(target, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, mePos, sQ.col, sQ.sType)
        if HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(mePos, castpos) < sQ.range and gsoAIO.Utils:_getDistance(target.pos, castpos) < 500 then
            local cPos = cursorPos
            Control.SetCursorPos(castpos)
            Control.KeyDown(HK_Q)
            Control.KeyUp(HK_Q)
            self.lastQ = GetTickCount()
            gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
            return true
        end
    end
    return false
end
function __gsoKogMaw:_castE()
    local target = gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, false) and gsoAIO.TS.lastTarget or gsoAIO.TS:_getTarget(1280, false, false)
    if target then
        local mePos = myHero.pos
        local sE = { delay = 0.25, range = 1280, width = 120, speed = 1350, sType = "line", col = false }
        local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(target, sE.delay, sE.width*0.5, sE.range, sE.speed, mePos, sE.col, sE.sType)
        if HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(mePos, castpos) < sE.range and gsoAIO.Utils:_getDistance(target.pos, castpos) < 500 then
            local cPos = cursorPos
            Control.SetCursorPos(castpos)
            Control.KeyDown(HK_E)
            Control.KeyUp(HK_E)
            self.lastE = GetTickCount()
            gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
            return true
        end
    end
    return false
end
function __gsoKogMaw:_castR()
    local sR = { delay = 1.2, range = 0, width = 225, speed = math.maxinteger, sType = "circular", col = false }
    sR.range = 900 + ( 300 * myHero:GetSpellData(_R).level )
    local target = gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, false) and gsoAIO.TS.lastTarget or gsoAIO.TS:_getTarget(sR.range + (sR.width*0.5), false, false)
    if target then
        local mePos = myHero.pos
        local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(target, sR.delay, sR.width*0.5, sR.range, sR.speed, mePos, sR.col, sR.sType)
        if HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(mePos, castpos) < sR.range and gsoAIO.Utils:_getDistance(target.pos, castpos) < 500 then
            local cPos = cursorPos
            Control.SetCursorPos(castpos)
            Control.KeyDown(HK_R)
            Control.KeyUp(HK_R)
            self.lastR = GetTickCount()
            gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
            return true
        end
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------tick-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoKogMaw:_tick()
    
    --[[ kog W buff ]]
    local hasWBuff = false
    for i = 0, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        local buffName = buff and buff.name or nil
        if buffName and buff.count > 0 and buff.duration > 0 then
            if buffName == "KogMawBioArcaneBarrage" then
                hasWBuff = true
                self.WBuffTime = GetTickCount() + (buff.duration*1000)
                break
            end
        end
    end
    self.hasWBuff = hasWBuff
    
    --[[ cast spells ]]
    if os.clock() > gsoAIO.Orb.lAttack + gsoAIO.Orb.windUpT then
        
        --[[ check if spells are ready ]]
        local checkTick = GetTickCount()
        local qMinus = checkTick - self.lastQ
        local qMinuss = checkTick - gsoAIO.Spells.lastQ
        local wMinus = checkTick - self.lastW
        local wMinuss = checkTick - gsoAIO.Spells.lastW
        local eMinus = checkTick - self.lastE
        local eMinuss = checkTick - gsoAIO.Spells.lastE
        local rMinus = checkTick - self.lastR
        local rMinuss = checkTick - gsoAIO.Spells.lastR
        local canQTime = qMinus > 1000 and qMinuss > 1000 and eMinus > 650 and eMinuss > 650 and rMinus > 650 and rMinuss > 650
        local canWTime = qMinus > 550 and qMinuss > 550 and wMinus > 1000 and wMinuss > 1000 and eMinus > 550 and eMinuss > 550 and rMinus > 550 and rMinuss > 550
        local canETime = qMinus > 650 and qMinuss > 650 and eMinus > 1000 and eMinuss > 1000 and rMinus > 650 and rMinuss > 650
        local canRTime = qMinus > 650 and qMinuss > 650 and eMinus > 650 and eMinuss > 650 and rMinus > 1000 and rMinuss > 1000
        local isCombo = gsoAIO.Load.menu.orb.keys.combo:Value()
        local isHarass = gsoAIO.Load.menu.orb.keys.harass:Value()
        local isComboQ = isCombo and gsoAIO.Load.menu.gsokog.qset.combo:Value()
        local isHarassQ = isHarass and gsoAIO.Load.menu.gsokog.qset.harass:Value()
        local isComboW = isCombo and gsoAIO.Load.menu.gsokog.wset.combo:Value()
        local isHarassW = isHarass and gsoAIO.Load.menu.gsokog.wset.harass:Value()
        local isComboE = isCombo and gsoAIO.Load.menu.gsokog.eset.combo:Value()
        local isHarassE = isHarass and gsoAIO.Load.menu.gsokog.eset.harass:Value()
        local isComboR = isCombo and gsoAIO.Load.menu.gsokog.rset.combo:Value()
        local isHarassR = isHarass and gsoAIO.Load.menu.gsokog.rset.harass:Value()
        local rStacks = gsoAIO.Utils:_buffCount(myHero, "kogmawlivingartillerycost") < gsoAIO.Load.menu.gsokog.rset.stack:Value()
        local stopQIfW = gsoAIO.Load.menu.gsokog.wset.stopq:Value() and self.hasWBuff
        local stopEIfW = gsoAIO.Load.menu.gsokog.wset.stope:Value() and self.hasWBuff
        local stopRIfW = gsoAIO.Load.menu.gsokog.wset.stopr:Value() and self.hasWBuff
        local isQReady = (isComboQ or isHarassQ) and canQTime and gsoAIO.Utils:_isReady(_Q) and not stopQIfW
        local isWReady = (isComboW or isHarassW) and canWTime and gsoAIO.Utils:_isReady(_W)
        local isEReady = (isComboE or isHarassE) and canETime and gsoAIO.Utils:_isReady(_E) and not stopEIfW
        local isRReady = (isComboR or isHarassR) and canRTime and gsoAIO.Utils:_isReady(_R) and rStacks and not stopRIfW
        
        --[[ combo/harass ]]
        local mePos = myHero.pos
        if isWReady then
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                local wRange = 610 + ( 20 * myHero:GetSpellData(_W).level ) + myHero.boundingRadius + hero.boundingRadius
                if gsoAIO.Utils:_valid(hero, true) and gsoAIO.Utils:_getDistance(mePos, hero.pos) < wRange then
                    Control.KeyDown(HK_W)
                    Control.KeyUp(HK_W)
                    self.lastW = GetTickCount()
                    return
                end
            end
        end
        if isQReady or isEReady or isRReady then
            
            --[[ check enemies in aa range ]]
            local meRange = myHero.range
            if Game.CanUseSpell(_W) == 0 or wMinus < 1000 then
                meRange = 610 + ( 20 * myHero:GetSpellData(_W).level )
            end
            local enemiesCount = 0
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                if gsoAIO.Utils:_valid(hero, true) and gsoAIO.Utils:_getDistance(mePos, hero.pos) < meRange + myHero.boundingRadius + hero.boundingRadius then
                    enemiesCount = enemiesCount + 1
                end
            end
            
            --[[ spells after/before if enemy is in aa range ]]
            local afterBefore = os.clock() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT*0.75
            
            --[[ spells if enemy is out of aa range ]]
            local outOfAARange = not gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, true) and enemiesCount == 0
            
            --[[ cast spells ]]
            if afterBefore or outOfAARange then
                if isQReady and self:_castQ() then
                    return
                end
                if isEReady and self:_castE() then
                    return
                end
                if isRReady and self:_castR() then
                    return
                end
            end
        end
    end
end





--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------DRAVEN----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoDraven"

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------init----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoDraven:__init()
    self.qParticles = {}
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.lMove = 0
    gsoAIO.Orb.baseAASpeed = 0.679
    gsoAIO.Orb.baseWindUp = 0.21 -- ???
        print(myHero.attackData.windUpTime/myHero.attackData.animationTime)
    gsoAIO.Vars:_setBonusDmg(function() return 3 end)
    gsoAIO.Vars:_setOnTick(function() self:_tick() end)
    gsoAIO.Vars:_setMousePos(function() return self:_setMousePos() end)
    gsoAIO.Vars:_setChampMenu(function() return self:_menu() end)
    Callback.Add('Draw', function() self:_draw() end)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------menu----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoDraven:_menu()
    gsoAIO.Load.menu:MenuElement({name = "Draven", id = "gsodraven", type = MENU, leftIcon = gsoAIO.Vars.Icons["draven"] })
        gsoAIO.Load.menu.gsodraven:MenuElement({name = "AXE settings", id = "aset", type = MENU })
            gsoAIO.Load.menu.gsodraven.aset:MenuElement({id = "catch", name = "Catch axes", value = true})
            gsoAIO.Load.menu.gsodraven.aset:MenuElement({id = "catcht", name = "stop under turret", value = true})
            gsoAIO.Load.menu.gsodraven.aset:MenuElement({id = "catcho", name = "[combo] stop if no enemy in range", value = true})
            gsoAIO.Load.menu.gsodraven.aset:MenuElement({name = "Distance", id = "dist", type = MENU })
                gsoAIO.Load.menu.gsodraven.aset.dist:MenuElement({id = "mode", name = "Axe Mode", value = 1, drop = {"closest to mousePos", "closest to heroPos"} })
                gsoAIO.Load.menu.gsodraven.aset.dist:MenuElement({id = "duration", name = "extra axe duration time", value = -300, min = -300, max = 0, step = 10 })
                gsoAIO.Load.menu.gsodraven.aset.dist:MenuElement({id = "stopmove", name = "axePos in distance < X | Hold radius", value = 100, min = 75, max = 125, step = 5 })
                gsoAIO.Load.menu.gsodraven.aset.dist:MenuElement({id = "cdist", name = "max distance from axePos to cursorPos", value = 750, min = 500, max = 1500, step = 50 })
                gsoAIO.Load.menu.gsodraven.aset.dist:MenuElement({id = "hdist", name = "max distance from axePos to heroPos", value = 500, min = 250, max = 750, step = 50 })
                gsoAIO.Load.menu.gsodraven.aset.dist:MenuElement({id = "enemyq", name = "stop if axe is near enemy - X dist", value = 125, min = 0, max = 250, step = 5 })
                gsoAIO.Load.menu.gsodraven.aset.dist:MenuElement({id = "enemyhero", name = "stop if hero is near enemy - X dist", value = 250, min = 0, max = 500, step = 5 })
            gsoAIO.Load.menu.gsodraven.aset:MenuElement({name = "Draw", id = "draw", type = MENU })
                gsoAIO.Load.menu.gsodraven.aset.draw:MenuElement({name = "Enable",  id = "enable", value = true})
                gsoAIO.Load.menu.gsodraven.aset.draw:MenuElement({name = "Good", id = "good", type = MENU })
                    gsoAIO.Load.menu.gsodraven.aset.draw.good:MenuElement({name = "Color",  id = "color", color = Draw.Color(255, 49, 210, 0)})
                    gsoAIO.Load.menu.gsodraven.aset.draw.good:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
                    gsoAIO.Load.menu.gsodraven.aset.draw.good:MenuElement({name = "Radius",  id = "radius", value = 170, min = 50, max = 300, step = 10})
                gsoAIO.Load.menu.gsodraven.aset.draw:MenuElement({name = "Bad", id = "bad", type = MENU })
                    gsoAIO.Load.menu.gsodraven.aset.draw.bad:MenuElement({name = "Color",  id = "color", color = Draw.Color(255, 153, 0, 0)})
                    gsoAIO.Load.menu.gsodraven.aset.draw.bad:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
                    gsoAIO.Load.menu.gsodraven.aset.draw.bad:MenuElement({name = "Radius",  id = "radius", value = 170, min = 50, max = 300, step = 10})
        gsoAIO.Load.menu.gsodraven:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gsoAIO.Load.menu.gsodraven.qset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsodraven.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoAIO.Load.menu.gsodraven:MenuElement({name = "W settings", id = "wset", type = MENU })
            gsoAIO.Load.menu.gsodraven.wset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsodraven.wset:MenuElement({id = "harass", name = "Harass", value = false})
            gsoAIO.Load.menu.gsodraven.wset:MenuElement({id = "hdist", name = "max enemy distance", value = 750, min = 500, max = 2000, step = 50 })
        gsoAIO.Load.menu.gsodraven:MenuElement({name = "E settings", id = "eset", type = MENU })
            gsoAIO.Load.menu.gsodraven.eset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsodraven.eset:MenuElement({id = "harass", name = "Harass", value = false})
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------cast spells--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoDraven:_castE()
    local target = gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, false) and gsoAIO.TS.lastTarget or gsoAIO.TS:_getTarget(1050, false, false)
    if target then
        local sE = { delay = 0.25, range = 1050, width = 150, speed = 1400, sType = "line", col = false }
        local mePos = myHero.pos
        local targetPos = target.pos
        local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(target, sE.delay, sE.width*0.5, sE.range, sE.speed, mePos, sE.col, sE.sType)
        local distToPred = gsoAIO.Utils:_getDistance(mePos, castpos)
        local distToTarget = gsoAIO.Utils:_getDistance(mePos, targetPos)
        local isOnLine = gsoAIO.Utils:_pointOnLineSegment(castpos.x, castpos.z, mePos.x, mePos.z, targetPos.x, targetPos.z)
        if HitChance > 0 and castpos:ToScreen().onScreen and distToPred < sE.range and distToPred > 125 and distToTarget > 125 and gsoAIO.Utils:_getDistance(targetPos, castpos) < 250 and isOnLine then
            local cPos = cursorPos
            Control.SetCursorPos(castpos)
            Control.KeyDown(HK_E)
            Control.KeyUp(HK_E)
            self.lastE = GetTickCount()
            gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            gsoAIO.Orb.enableAA = false
            gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
            return true
        end
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------tick-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoDraven:_tick()
    
    --[[ enable aa after spells ]]
    local checkTick = GetTickCount()
    local qMinus = checkTick - self.lastQ
    local wMinus = checkTick - self.lastW
    local eMinus = checkTick - self.lastE
    local botrkMinus = checkTick - gsoAIO.Items.lastBotrk
    if gsoAIO.Orb.enableAA == false and wMinus > 200 and eMinus > 350 and botrkMinus > 75 then
        gsoAIO.Orb.enableAA = true
    end
    
    --[[ handle axes ]]
    local mePos = myHero.pos
    for i = 1, Game.ParticleCount() do
        local particle = Game.Particle(i)
        if particle then
            local particlePos = particle.pos
            if gsoAIO.Utils:_getDistance(mePos, particlePos) < 500 and particle.name == "Draven_Base_Q_reticle" then
                local particleID = particle.handle
                if not self.qParticles[particleID] then
                    self.qParticles[particleID] = { pos = particlePos, tick = GetTickCount(), success = false, active = false }
                    gsoAIO.Orb.lMove = 0
                end
            end
        end
    end
    for k,v in pairs(self.qParticles) do
        local timerMinus = GetTickCount() - v.tick
        local numMenu = 1200 + gsoAIO.Load.menu.gsodraven.aset.dist.duration:Value()
        if not v.success and timerMinus > numMenu then
            self.qParticles[k].success = true
            gsoAIO.Orb.lMove = 0
        end
        if timerMinus > numMenu and timerMinus < numMenu + 100 then
            gsoAIO.Orb.lMove = 0
        end
        if timerMinus > 2000 then
            self.qParticles[k] = nil
        end
    end
    
    --[[ cast spells ]]
    if os.clock() > gsoAIO.Orb.lAttack + gsoAIO.Orb.windUpT then
        
        --[[ check if spells are ready ]]
        local isCombo = gsoAIO.Load.menu.orb.keys.combo:Value()
        local isHarass = gsoAIO.Load.menu.orb.keys.harass:Value()
        local isComboQ = isCombo and gsoAIO.Load.menu.gsodraven.qset.combo:Value()
        local isHarassQ = isHarass and gsoAIO.Load.menu.gsodraven.qset.harass:Value()
        local isComboW = isCombo and gsoAIO.Load.menu.gsodraven.wset.combo:Value()
        local isHarassW = isHarass and gsoAIO.Load.menu.gsodraven.wset.harass:Value()
        local isComboE = isCombo and gsoAIO.Load.menu.gsodraven.eset.combo:Value()
        local isHarassE = isHarass and gsoAIO.Load.menu.gsodraven.eset.harass:Value()
        local isQReady = (isComboQ or isHarassQ) and qMinus > 1000 and wMinus > 100 and eMinus > 350 and Game.CanUseSpell(_Q) == 0
        local isWReady = (isComboW or isHarassW) and wMinus > 1000 and eMinus > 350 and Game.CanUseSpell(_W) == 0
        local isEReady = (isComboE or isHarassE) and gsoAIO.Orb.dActionsC == 0 and wMinus > 100 and eMinus > 1000 and Game.CanUseSpell(_E) == 0
        
        --[[ combo/harass ]]
        if isQReady or isWReady or isEReady then
            
            --[[ check enemies in aa range ]]
            local mePos = myHero.pos
            local meRange = myHero.range + myHero.boundingRadius
            local enemiesCount = 0
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                if gsoAIO.Utils:_valid(hero, true) and gsoAIO.Utils:_getDistance(mePos, hero.pos) < meRange + hero.boundingRadius then
                    enemiesCount = enemiesCount + 1
                end
            end
            
            --[[ spells after/before if enemy is in aa range ]]
            local afterBefore = os.clock() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT
            
            --[[ spells if enemy is out of aa range ]]
            local outOfAARange = not gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, true) and enemiesCount == 0
            
            if isQReady and not outOfAARange and os.clock() > gsoAIO.Orb.lAttack + gsoAIO.Orb.animT*0.5 then
                Control.KeyDown(HK_Q)
                Control.KeyUp(HK_Q)
                self.lastQ = GetTickCount()
                return
            end
            
            --[[ cast spells ]]
            if afterBefore or outOfAARange then
                if isWReady then
                    Control.KeyDown(HK_W)
                    Control.KeyUp(HK_W)
                    self.lastW = GetTickCount()
                    gsoAIO.Orb.enableAA = false
                    return
                end
                if isEReady and self:_castE() then
                    return
                end
            end
        end
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------set mouse pos------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoDraven:_setMousePos()
    local qPos = nil
    local canCatch    = gsoAIO.Load.menu.gsodraven.aset.catch:Value()
    local stopCatchT  = gsoAIO.Load.menu.gsodraven.aset.catcht:Value()
    local stopCatchO  = gsoAIO.Load.menu.gsodraven.aset.catcho:Value()
    local stopmove    = gsoAIO.Load.menu.gsodraven.aset.dist.stopmove:Value()
    local kID         = nil
    if canCatch then
        local qMode = gsoAIO.Load.menu.gsodraven.aset.dist.mode:Value()
        local hdist = gsoAIO.Load.menu.gsodraven.aset.dist.hdist:Value()
        local cdist = gsoAIO.Load.menu.gsodraven.aset.dist.cdist:Value()
        local num = 1000000000
        for k,v in pairs(self.qParticles) do
            if not v.success then
                local mePos = myHero.pos
                local distanceToHero = gsoAIO.Utils:_getDistance(v.pos, mePos)
                local distanceToMouse = gsoAIO.Utils:_getDistance(v.pos, mousePos)
                if distanceToHero < hdist and distanceToMouse < cdist then
                    local canContinue = true
                    local eQMenu = gsoAIO.Load.menu.gsodraven.aset.dist.enemyq:Value()
                    local eHeroMenu = gsoAIO.Load.menu.gsodraven.aset.dist.enemyhero:Value()
                    if eQMenu > 0 then
                        local cEM = #gsoAIO.OB.enemyMinions
                        for i = 1, cEM do
                            local minion = gsoAIO.OB.enemyMinions[i]
                            if gsoAIO.Utils:_getDistance(v.pos, minion.pos) < eQMenu then
                                canContinue = false
                                break
                            end
                        end
                    end
                    local countInRange = 0
                    local cEH = #gsoAIO.OB.enemyHeroes
                    local isCombo = gsoAIO.Load.menu.orb.keys.combo:Value()
                    for i = 1, cEH do
                        local hero = gsoAIO.OB.enemyHeroes[i]
                        local heroPos = hero.pos
                        if eQMenu > 0 and gsoAIO.Utils:_getDistance(v.pos, heroPos) < eQMenu then
                            canContinue = false
                            break
                        end
                        local distToHero = gsoAIO.Utils:_getDistance(mePos, heroPos)
                        if eHeroMenu > 0 and distToHero < eHeroMenu then
                            canContinue = false
                            break
                        end
                        if isCombo and stopCatchO and distToHero < myHero.range + myHero.boundingRadius then
                            countInRange = countInRange + 1
                        end
                    end
                    if isCombo and stopCatchO and countInRange == 0 then
                        canContinue = false
                    end
                    if canContinue then
                        self.qParticles[k].active = true
                        if qMode == 1 and distanceToMouse < num then
                            qPos = v.pos
                            num = distanceToMouse
                            kID = k
                        elseif qMode == 2 and distanceToHero < num then
                            qPos = v.pos
                            num = distanceToHero
                            kID = k
                        end
                    else
                        self.qParticles[k].active = false
                        if GetTickCount() > v.tick + 250 then
                            gsoAIO.Orb.lMove = 0
                        end
                    end
                else
                    self.qParticles[k].active = false
                end
            end
        end
    end
    if qPos ~= nil then
        qPos = qPos:Extended(mousePos, stopmove)
        if stopCatchT then
            local cET = #gsoAIO.OB.enemyTurrets
            for i=1, cET do
                local turret = gsoAIO.OB.enemyTurrets[i]
                if gsoAIO.Utils:_getDistance(qPos, turret.pos) < 775 + turret.boundingRadius then
                    self.qParticles[kID].active = false
                    return nil
                end
            end
        end
    end
    return qPos
end

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------draw-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoDraven:_draw()
    if gsoAIO.Load.menu.gsodraven.aset.catch:Value() and gsoAIO.Load.menu.gsodraven.aset.draw.enable:Value() then
        for k,v in pairs(self.qParticles) do
            if not v.success then
                if v.active then
                    Draw.Circle(v.pos, gsoAIO.Load.menu.gsodraven.aset.draw.good.radius:Value(), gsoAIO.Load.menu.gsodraven.aset.draw.good.width:Value(), gsoAIO.Load.menu.gsodraven.aset.draw.good.color:Value())
                else
                    Draw.Circle(v.pos, gsoAIO.Load.menu.gsodraven.aset.draw.bad.radius:Value(), gsoAIO.Load.menu.gsodraven.aset.draw.bad.width:Value(), gsoAIO.Load.menu.gsodraven.aset.draw.bad.color:Value())
                end
            end
        end
    end
end





--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------EZREAL----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoEzreal"

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------init---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoEzreal:__init()
    self.res          = Game.Resolution()
    self.resX         = self.res.x
    self.resY         = self.res.y
    self.lastQ        = 0
    self.lastW        = 0
    self.lastE        = 0
    self.shouldWaitT  = 0
    self.shouldWait   = false
    gsoAIO.Orb.baseAASpeed = 0.625
    gsoAIO.Orb.baseWindUp = 0.18838652
    gsoAIO.Vars:_setOnTick(function() self:_tick() end)
    gsoAIO.Vars:_setBonusDmg(function() return 3 end)
    gsoAIO.Vars:_setChampMenu(function() return self:_menu() end)
    Callback.Add('Draw', function() self:_draw() end)
    gsoAIO.Vars:_setCanAttack(function() return self:_canAttack() end)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------canAA-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoEzreal:_canAttack()
    local getTick = GetTickCount()
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.Spells.lastQ
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.Spells.lastW
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.Spells.lastE
    local rMinuss = getTick - gsoAIO.Spells.lastR
    if qMinus > 450 and qMinuss > 450 and wMinus > 450 and wMinuss > 450 and eMinus > 550 and eMinuss > 550 and rMinuss > 1200 then
        return true
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------menu---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoEzreal:_menu()
    gsoAIO.Load.menu:MenuElement({name = "Ezreal", id = "gsoezreal", type = MENU, leftIcon = gsoAIO.Vars.Icons["ezreal"] })
        gsoAIO.Load.menu.gsoezreal:MenuElement({name = "Auto Q", id = "autoq", type = MENU })
            gsoAIO.Load.menu.gsoezreal.autoq:MenuElement({id = "enable", name = "Enable", value = true, key = string.byte("T"), toggle = true})
            gsoAIO.Load.menu.gsoezreal.autoq:MenuElement({id = "mana", name = "Q Auto min. mana percent", value = 50, min = 0, max = 100, step = 1 })
            gsoAIO.Load.menu.gsoezreal.autoq:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            gsoAIO.Load.menu.gsoezreal.autoq:MenuElement({id = "draw", name = "Draw Text", value = true})
            gsoAIO.Load.menu.gsoezreal.autoq:MenuElement({name = "Text Settings", id = "textset", type = MENU })
                gsoAIO.Load.menu.gsoezreal.autoq.textset:MenuElement({id = "size", name = "Text Size", value = 25, min = 1, max = 64, step = 1 })
                gsoAIO.Load.menu.gsoezreal.autoq.textset:MenuElement({id = "custom", name = "Custom Position", value = false})
                gsoAIO.Load.menu.gsoezreal.autoq.textset:MenuElement({id = "posX", name = "Text Position Width", value = self.resX * 0.5 - 150, min = 1, max = self.resX, step = 1 })
                gsoAIO.Load.menu.gsoezreal.autoq.textset:MenuElement({id = "posY", name = "Text Position Height", value = self.resY * 0.5, min = 1, max = self.resY, step = 1 })
        gsoAIO.Load.menu.gsoezreal:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gsoAIO.Load.menu.gsoezreal.qset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            gsoAIO.Load.menu.gsoezreal.qset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsoezreal.qset:MenuElement({id = "harass", name = "Harass", value = false})
            gsoAIO.Load.menu.gsoezreal.qset:MenuElement({id = "laneclear", name = "LaneClear", value = false})
            gsoAIO.Load.menu.gsoezreal.qset:MenuElement({id = "lasthit", name = "LastHit", value = true})
            gsoAIO.Load.menu.gsoezreal.qset:MenuElement({id = "qlh", name = "Q LastHit min. mana percent", value = 10, min = 0, max = 100, step = 1 })
            gsoAIO.Load.menu.gsoezreal.qset:MenuElement({id = "qlc", name = "Q LaneClear min. mana percent", value = 50, min = 0, max = 100, step = 1 })
        gsoAIO.Load.menu.gsoezreal:MenuElement({name = "W settings", id = "wset", type = MENU })
            gsoAIO.Load.menu.gsoezreal.wset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            gsoAIO.Load.menu.gsoezreal.wset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsoezreal.wset:MenuElement({id = "harass", name = "Harass", value = false})
end

--------------------|---------------------------------------------------------|--------------------
--------------------|----------------------q combo----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoEzreal:_castQCombo()
    local target = gsoAIO.TS:_getTarget(1150, true, false)
    if target ~= nil then
        local sQ = { delay = 0.25, range = 1150, width = 60, speed = 2000, sType = "line", col = true }
        local mePos = myHero.pos
        local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(target, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, mePos, sQ.col, sQ.sType)
        local distMeToPredPos = gsoAIO.Utils:_getDistance(mePos, castpos)
        local distUnitToPredPos = gsoAIO.Utils:_getDistance(target.pos, castpos)
        if HitChance > gsoAIO.Load.menu.gsoezreal.qset.hitchance:Value()-1 and castpos:ToScreen().onScreen and distMeToPredPos < sQ.range and distUnitToPredPos < 500 then
            local cPos = cursorPos
            Control.SetCursorPos(castpos)
            Control.KeyDown(HK_Q)
            Control.KeyUp(HK_Q)
            self.lastQ = GetTickCount()
            gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
            return true
        end
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------q auto----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoEzreal:_autoQ()
    local manaPercent = 100 * myHero.mana / myHero.maxMana
    local isAutoQ = gsoAIO.Load.menu.gsoezreal.autoq.enable:Value() and manaPercent > gsoAIO.Load.menu.gsoezreal.autoq.mana:Value()
    local meRange = myHero.range + myHero.boundingRadius
    if isAutoQ then
        for i = 1, #gsoAIO.OB.enemyHeroes do
            local unit = gsoAIO.OB.enemyHeroes[i]
            local unitPos = unit.pos
            local mePos = myHero.pos
            local distance = gsoAIO.Utils:_getDistance(mePos, unitPos)
            if gsoAIO.Utils:_valid(unit, true) and distance < 1150 then
                local sQ = { delay = 0.25, range = 1150, width = 60, speed = 2000, sType = "line", col = true }
                local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(unit, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, mePos, sQ.col, sQ.sType)
                local distMeToPredPos = gsoAIO.Utils:_getDistance(mePos, castpos)
                local distUnitToPredPos = gsoAIO.Utils:_getDistance(unitPos, castpos)
                if HitChance > gsoAIO.Load.menu.gsoezreal.autoq.hitchance:Value()-1 and castpos:ToScreen().onScreen and distMeToPredPos < sQ.range and distUnitToPredPos < 500 then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    Control.KeyDown(HK_Q)
                    Control.KeyUp(HK_Q)
                    self.lastQ = GetTickCount()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    return true
                end
            end
        end
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------send q key--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoEzreal:_castQ(t, tPos, mePos)
    local sQ = { delay = 0.25, range = 1150, width = 60, speed = 2000, sType = "line", col = true }
    local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(t, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, mePos, sQ.col, sQ.sType)
    local distMeToPredPos = gsoAIO.Utils:_getDistance(mePos, castpos)
    local distUnitToPredPos = gsoAIO.Utils:_getDistance(tPos, castpos)
    if HitChance > gsoAIO.Load.menu.gsoezreal.qset.hitchance:Value()-1 and castpos:ToScreen().onScreen and distMeToPredPos < sQ.range and distUnitToPredPos < 500 then
        local cPos = cursorPos
        Control.SetCursorPos(castpos)
        Control.KeyDown(HK_Q)
        Control.KeyUp(HK_Q)
        self.lastQ = GetTickCount()
        gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
        gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
        return true
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------q farm----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoEzreal:_castQFarm()
    local meRange = myHero.range + myHero.boundingRadius
    local manaPercent = 100 * myHero.mana / myHero.maxMana
    local isLH = gsoAIO.Load.menu.gsoezreal.qset.lasthit:Value() and (gsoAIO.Load.menu.orb.keys.lastHit:Value() or gsoAIO.Load.menu.orb.keys.harass:Value())
    local isLC = gsoAIO.Load.menu.gsoezreal.qset.laneclear:Value() and gsoAIO.Load.menu.orb.keys.laneClear:Value()
    if isLH or isLC then
        local canLH = manaPercent > gsoAIO.Load.menu.gsoezreal.qset.qlh:Value()
        local canLC = manaPercent > gsoAIO.Load.menu.gsoezreal.qset.qlc:Value()
        if not canLH and not canLC then return end
        if self.shouldWait == true and Game.Timer() > self.shouldWaitT + 0.5 then
            self.shouldWait = false
        end
        local almostLH = false
        local laneClearT = {}
        local lastHitT = {}
        
        -- [[ set enemy minions ]]
        local mLH = gsoAIO.Load.menu.orb.delays.lhDelay:Value()*0.001
        for i = 1, #gsoAIO.OB.enemyMinions do
            local eMinion = gsoAIO.OB.enemyMinions[i]
            local eMinion_handle	= eMinion.handle
            local eMinion_health	= eMinion.health
            local myHero_aaData		= myHero.attackData
            local myHero_pFlyTime	= gsoAIO.Utils:_getDistance(myHero.pos, eMinion.pos) / 2000
            for k1,v1 in pairs(gsoAIO.Farm.aAttacks) do
                for k2,v2 in pairs(gsoAIO.Farm.aAttacks[k1]) do
                    if v2.canceled == false and eMinion_handle == v2.to.handle then
                        local checkT	= Game.Timer()
                        local pEndTime	= v2.startTime + v2.pTime
                        if pEndTime > checkT and  pEndTime - checkT < myHero_pFlyTime - mLH then
                            eMinion_health = eMinion_health - v2.dmg
                        end
                    end
                end
            end
            local myHero_dmg = ((25 * myHero:GetSpellData(_Q).level) - 10) + (1.1 * myHero.totalDamage) + (0.4 * myHero.ap)
            if eMinion_health - myHero_dmg < 0 then
                lastHitT[#lastHitT+1] = eMinion
            else
                if eMinion.health - gsoAIO.Farm:_possibleDmg(eMinion, 2.5) - myHero_dmg < 0 then
                    almostLH = true
                    self.shouldWait = true
                    self.shouldWaitT = Game.Timer()
                else
                    laneClearT[#laneClearT+1] = eMinion
                end
            end
        end

        -- [[ lasthit ]]
        if isLH and canLH then
            local canCheckT = false
            for i = 1, #lastHitT do
                local unit = lastHitT[i]
                local unitPos = unit.pos
                local mePos = myHero.pos
                local checkT = Game.Timer() < gsoAIO.TS.LHTimers[4].tick
                local mHandle = unit.handle
                if not checkT or (checkT and gsoAIO.TS.LHTimers[4].id ~= mHandle) then
                    if gsoAIO.Utils:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                        canCheckT = true
                        break
                    end
                end
            end
            if not canCheckT or (canCheckT and os.clock() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT) then
                for i = 1, #lastHitT do
                    local minion = lastHitT[i]
                    local minionPos = minion.pos
                    local mePos = myHero.pos
                    local checkT = Game.Timer() < gsoAIO.TS.LHTimers[4].tick
                    local mHandle = minion.handle
                    if not checkT or (checkT and gsoAIO.TS.LHTimers[4].id ~= mHandle) then
                        local distance = gsoAIO.Utils:_getDistance(mePos, minionPos)
                        if distance < 1150 and self:_castQ(minion, minionPos, mePos) then
                            gsoAIO.TS.LHTimers[0].tick = Game.Timer() + 0.75
                            gsoAIO.TS.LHTimers[0].id = mHandle
                            return
                        end
                    end
                end
            end

        -- [[ laneclear ]]
        elseif isLC and canLC then

            local canCheckT = false
            for i = 1, #lastHitT do
                local unit = lastHitT[i]
                local unitPos = unit.pos
                local mePos = myHero.pos
                local checkT = Game.Timer() < gsoAIO.TS.LHTimers[4].tick
                local mHandle = unit.handle
                if not checkT or (checkT and gsoAIO.TS.LHTimers[4].id ~= mHandle) then
                    if gsoAIO.Utils:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                        canCheckT = true
                        break
                    end
                end
            end
            if not canCheckT or (canCheckT and os.clock() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT) then
                for i = 1, #lastHitT do
                    local minion = lastHitT[i]
                    local minionPos = minion.pos
                    local mePos = myHero.pos
                    local checkT = Game.Timer() < gsoAIO.TS.LHTimers[4].tick
                    local mHandle = minion.handle
                    if not checkT or (checkT and gsoAIO.TS.LHTimers[4].id ~= mHandle) then
                        local distance = gsoAIO.Utils:_getDistance(mePos, minionPos)
                        if distance < 1150 and self:_castQ(minion, minionPos, mePos) then
                            gsoAIO.TS.LHTimers[0].tick = Game.Timer() + 0.75
                            gsoAIO.TS.LHTimers[0].id = mHandle
                            return
                        end
                    end
                end
            end
            if not almostLH and not self.shouldWait then
                canCheckT = false
                for i = 1, #gsoAIO.OB.enemyHeroes do
                    local unit = gsoAIO.OB.enemyHeroes[i]
                    local unitPos = unit.pos
                    local mePos = myHero.pos
                    if gsoAIO.Utils:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                        canCheckT = true
                        break
                    end
                end
                if not canCheckT or (canCheckT and os.clock() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT) then
                    for i = 1, #gsoAIO.OB.enemyHeroes do
                        local unit = gsoAIO.OB.enemyHeroes[i]
                        local unitPos = unit.pos
                        local mePos = myHero.pos
                        local distance = gsoAIO.Utils:_getDistance(mePos, unitPos)
                        if gsoAIO.Utils:_valid(unit, true) and distance < 1150 and self:_castQ(unit, unitPos, mePos) then return end
                    end
                end
                canCheckT = false
                for i = 1, #laneClearT do
                    local unit = laneClearT[i]
                    local unitPos = unit.pos
                    local mePos = myHero.pos
                    if gsoAIO.Utils:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                        canCheckT = true
                        break
                    end
                end
                if not canCheckT or (canCheckT and os.clock() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT) then
                    for i = 1, #laneClearT do
                        local minion = laneClearT[i]
                        local minionPos = minion.pos
                        local mePos = myHero.pos
                        local distance = gsoAIO.Utils:_getDistance(myHero.pos, minionPos)
                        if distance < 1150 and self:_castQ(minion, minionPos, mePos) then return end
                    end
                end
            end
        end
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------w combo---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoEzreal:_castW()
    local target = gsoAIO.TS:_getTarget(1000, false, false)
    if target ~= nil then
        local mePos = myHero.pos
        local sW = { delay = 0.25, range = 1150, width = 80, speed = 1550, sType = "line", col = false }
        local castpos,HitChance, pos = gsoAIO.TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, mePos, sW.col, sW.sType)
        local distMeToPredPos = gsoAIO.Utils:_getDistance(mePos, castpos)
        local distUnitToPredPos = gsoAIO.Utils:_getDistance(target.pos, castpos)
        if HitChance > gsoAIO.Load.menu.gsoezreal.wset.hitchance:Value()-1 and castpos:ToScreen().onScreen and distMeToPredPos < sW.range and distUnitToPredPos < 500 then
            local cPos = cursorPos
            Control.SetCursorPos(castpos)
            Control.KeyDown(HK_W)
            Control.KeyUp(HK_W)
            self.lastW = GetTickCount()
            gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
            return
        end
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------e manual--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoEzreal:_castE()
    local dActions = gsoAIO.Spells.delayedSpell
    for k,v in pairs(dActions) do
        if k == 2 then
            if gsoAIO.Orb.dActionsC == 0 then
                v[1]()
                gsoAIO.Orb.dActions[GetTickCount()] = { function() return 0 end, 50 }
                gsoAIO.Orb.enableAA = false
                gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                self.lastE = GetTickCount()
                gsoAIO.Spells.delayedSpell[k] = nil
                break
            end
            if GetTickCount() - v[2] > 125 then
                gsoAIO.Spells.delayedSpell[k] = nil
            end
            break
        end
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------tick----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoEzreal:_tick()
    
    --[[ manual E ]]
    local getTick = GetTickCount()
    if getTick - self.lastE > 1000 and Game.CanUseSpell(_E) == 0 then
        self:_castE()
    end
    
    --[[ cast spells ]]
    if os.clock() > gsoAIO.Orb.lAttack + gsoAIO.Orb.windUpT then
        
        --[[ check if spells are ready ]]
        local qMinus = getTick - self.lastQ
        local qMinuss = getTick - gsoAIO.Spells.lastQ
        local wMinus = getTick - self.lastW
        local wMinuss = getTick - gsoAIO.Spells.lastW
        local eMinus = getTick - self.lastE
        local eMinuss = getTick - gsoAIO.Spells.lastE
        local rMinuss = getTick - gsoAIO.Spells.lastR
        local canQTime = qMinus > 1000 and qMinuss > 1000 and wMinus > 450 and wMinuss > 450 and eMinus > 650 and eMinuss > 650 and rMinuss > 1500
        local canWTime = qMinus > 650 and qMinuss > 650 and wMinus > 1000 and wMinuss > 1000 and eMinus > 650 and eMinuss > 650 and rMinuss > 1500
        local canETime = qMinus > 350 and qMinuss > 350 and wMinus > 350 and wMinuss > 350 and eMinus > 1000 and eMinuss > 1000 and rMinuss > 1500
        local canRTime = qMinus > 350 and qMinuss > 350 and wMinus > 350 and wMinuss > 350 and eMinus > 650 and eMinuss > 650 and rMinuss > 2000
        local isCombo = gsoAIO.Load.menu.orb.keys.combo:Value()
        local isHarass = gsoAIO.Load.menu.orb.keys.harass:Value()
        local isComboQ = isCombo and gsoAIO.Load.menu.gsoezreal.qset.combo:Value()
        local isHarassQ = isHarass and gsoAIO.Load.menu.gsoezreal.qset.harass:Value()
        local isComboW = isCombo and gsoAIO.Load.menu.gsoezreal.wset.combo:Value()
        local isHarassW = isHarass and gsoAIO.Load.menu.gsoezreal.wset.harass:Value()
        local isQReady = canQTime and gsoAIO.Utils:_isReady(_Q)
        local isQReadyCombo = isQReady and (isComboQ or isHarassQ)
        local isWReady = (isComboW or isHarassW) and canWTime and gsoAIO.Utils:_isReady(_W)
        
        --[[ check enemies in aa range ]]
        local mePos = myHero.pos
        local meRange = myHero.range + myHero.boundingRadius
        local enemiesCount = 0
        for i = 1, #gsoAIO.OB.enemyHeroes do
            local hero = gsoAIO.OB.enemyHeroes[i]
            if gsoAIO.Utils:_valid(hero, true) and gsoAIO.Utils:_getDistance(mePos, hero.pos) < meRange + hero.boundingRadius then
                enemiesCount = enemiesCount + 1
            end
        end
        
        --[[ spells after/before if enemy is in aa range ]]
        local afterBefore = os.clock() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT*0.75
        
        --[[ spells if enemy is out of aa range ]]
        local outOfAARange = not gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, true) and enemiesCount == 0
        
        --[[ cast spells ]]
        if afterBefore or outOfAARange then
            if isQReady and not isQReadyCombo and self:_autoQ() then
                return
            end
            if isQReadyCombo and self:_castQCombo() then
                return
            end
            if isWReady and self:_castW() then
                return
            end
        end
        
        --[[ q farm ]]
        if isQReady then self:_castQFarm() end
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------draw-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoEzreal:_draw()
    if gsoAIO.Load.menu.gsoezreal.autoq.draw:Value() then
        local mePos = myHero.pos:To2D()
        local isCustom = gsoAIO.Load.menu.gsoezreal.autoq.textset.custom:Value()
        local posX = isCustom and gsoAIO.Load.menu.gsoezreal.autoq.textset.posX:Value() or mePos.x - 50
        local posY = isCustom and gsoAIO.Load.menu.gsoezreal.autoq.textset.posY:Value() or mePos.y
        if gsoAIO.Load.menu.gsoezreal.autoq.enable:Value() then
            Draw.Text("Auto Q Enabled", gsoAIO.Load.menu.gsoezreal.autoq.textset.size:Value(), posX, posY, Draw.Color(255, 000, 255, 000)) 
        else
            Draw.Text("Auto Q Disabled", gsoAIO.Load.menu.gsoezreal.autoq.textset.size:Value(), posX, posY, Draw.Color(255, 255, 000, 000)) 
        end
    end
end





--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------VAYNE---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoVayne"

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------init----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoVayne:__init()
    require "MapPositionGOS"
    self.lastQ = 0
    self.lastE = 0
    self.lastReset = 0
    gsoAIO.Orb.baseAASpeed = 0.658
    gsoAIO.Orb.baseWindUp = 0.1754385
    gsoAIO.Vars:_setBonusDmg(function() return 3 end)
    gsoAIO.Vars:_setOnTick(function() self:_tick() end)
    gsoAIO.Vars:_setChampMenu(function() return self:_menu() end)
    gsoAIO.Vars:_setCanAttack(function() return self:_canAttack() end)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------canAA-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoVayne:_canAttack()
    local checkTick = GetTickCount()
    local qMinus = checkTick - self.lastQ
    local qMinuss = checkTick - gsoAIO.Spells.lastQ
    local eMinus = checkTick - self.lastE
    local eMinuss = checkTick - gsoAIO.Spells.lastE
    if qMinus > 450 and qMinuss > 450 and eMinus > 650 and eMinuss > 650 then
        return true
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------menu----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoVayne:_menu()
    gsoAIO.Load.menu:MenuElement({name = "Vayne", id = "gsovayne", type = MENU, leftIcon = gsoAIO.Vars.Icons["vayne"] })
        gsoAIO.Load.menu.gsovayne:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gsoAIO.Load.menu.gsovayne.qset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsovayne.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoAIO.Load.menu.gsovayne:MenuElement({name = "E settings", id = "eset", type = MENU })
            gsoAIO.Load.menu.gsovayne.eset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsovayne.eset:MenuElement({id = "harass", name = "Harass", value = false})
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------cast spells--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoVayne:_castQ()
    local mePos = myHero.pos
    local meRange = myHero.range + myHero.boundingRadius
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local hero = gsoAIO.OB.enemyHeroes[i]
        local heroPos = hero.pos
        local distToMouse = gsoAIO.Utils:_getDistance(mePos, mousePos)
        local distToHero = gsoAIO.Utils:_getDistance(mePos, heroPos)
        local distToEndPos = gsoAIO.Utils:_getDistance(mePos, hero.pathing.endPos)
        local extRange
        if distToEndPos > distToHero then
            extRange = distToMouse > 200 and 200 or distToMouse
        else
            extRange = distToMouse > 300 and 300 or distToMouse
        end
        local extPos = mePos + (mousePos-mePos):Normalized() * extRange
        local distEnemyToExt = gsoAIO.Utils:_getDistance(extPos, heroPos)
        if gsoAIO.Utils:_valid(hero, true) and distEnemyToExt < meRange + hero.boundingRadius - 30 then
            Control.KeyDown(HK_Q)
            Control.KeyUp(HK_Q)
            self.lastQ = GetTickCount()
            return
        end
    end
end
function __gsoVayne:_checkWall(from, to)
    local pos1 = to + (to-from):Normalized() * 50
    local pos2 = pos1 + (to-from):Normalized() * 425
    local point1 = Point(pos1.x, pos1.z)
    local point2 = Point(pos2.x, pos2.z)
    if (MapPosition:inWall(point1) and MapPosition:inWall(point2)) or MapPosition:intersectsWall(LineSegment(point1, point2)) then
        return true
    end
    return false
end
function __gsoVayne:_castE()
    local mePos = myHero.pos
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local hero = gsoAIO.OB.enemyHeroes[i]
        local heroPos = hero.pos
        if gsoAIO.Utils:_valid(hero, true) and gsoAIO.Utils:_getDistance(mePos, heroPos) < 650 then
            local ePred = hero:GetPrediction(2000,0.15)
            local distance = gsoAIO.Utils:_getDistance(ePred, heroPos)
            if ePred and distance < 500 and not gsoAIO.Utils:_nearUnit(heroPos, hero.networkID) and self:_checkWall(mePos, ePred) and self:_checkWall(mePos, heroPos) then
                Control.KeyDown(83)
                Control.KeyUp(83)
                local cPos = cursorPos
                Control.SetCursorPos(heroPos)
                Control.KeyDown(HK_E)
                Control.KeyUp(HK_E)
                self.lastE = GetTickCount()
                gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                return true
            end
        end
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------tick-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoVayne:_tick()
    
    local getTick = GetTickCount()
    --[[ reset aa ]]
    for i = 0, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        if buff and buff.count > 0 and buff.name == "vaynetumblebonus" and os.clock() > self.lastReset + 1.2 and buff.duration > 5.8 and getTick - self.lastQ > 450 and getTick - gsoAIO.Spells.lastQ > 450 then
            self.lastReset = os.clock()
            gsoAIO.Orb.aaReset = true
        end
    end
    
    --[[ cast spells ]]
    if os.clock() > gsoAIO.Orb.lAttack + gsoAIO.Orb.windUpT then
    
        --[[ check if spells are ready ]]
        local qMinus = getTick - self.lastQ
        local qMinuss = getTick - gsoAIO.Spells.lastQ
        local eMinus = getTick - self.lastE
        local eMinuss = getTick - gsoAIO.Spells.lastE
        local canQTime = qMinus > 1000 and qMinuss > 1000 and eMinus > 650 and eMinuss > 650
        local canETime = qMinus > 450 and qMinuss > 450 and eMinus > 1000 and eMinuss > 1000
        local isCombo = gsoAIO.Load.menu.orb.keys.combo:Value()
        local isHarass = gsoAIO.Load.menu.orb.keys.harass:Value()
        local isComboQ = isCombo and gsoAIO.Load.menu.gsovayne.qset.combo:Value()
        local isHarassQ = isHarass and gsoAIO.Load.menu.gsovayne.qset.harass:Value()
        local isComboE = isCombo and gsoAIO.Load.menu.gsovayne.eset.combo:Value()
        local isHarassE = isHarass and gsoAIO.Load.menu.gsovayne.eset.harass:Value()
        local isQReady = (isComboQ or isHarassQ) and canQTime and gsoAIO.Utils:_isReady(_Q)
        local isEReady = (isComboE or isHarassE) and canETime and gsoAIO.Utils:_isReady(_E)
        
        if isQReady or isEReady then
            
            --[[ check enemies in aa range ]]
            local mePos = myHero.pos
            local meRange = myHero.range + myHero.boundingRadius - 30
            local enemiesCount = 0
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                if gsoAIO.Utils:_valid(hero, true) and gsoAIO.Utils:_getDistance(mePos, hero.pos) < meRange + hero.boundingRadius then
                    enemiesCount = enemiesCount + 1
                end
            end
            
            --[[ spells after/before if enemy is in aa range ]]
            local afterBefore = os.clock() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT*0.75
            
            --[[ spells if enemy is out of aa range ]]
            local outOfAARange = not gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, true) and enemiesCount == 0
            
            --[[ cast spells ]]
            if isEReady and (afterBefore or outOfAARange) and self:_castE() then
                return
            end
            if isQReady and (afterBefore or outOfAARange) then
                self:_castQ()
            end
        end
    end
end





--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------TEEMO---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoTeemo"

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------init----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTeemo:__init()
    self.lastQ = 0
    self.lastW = 0
    gsoAIO.Orb.baseAASpeed = 0.69
    gsoAIO.Orb.baseWindUp = 0.215743
    gsoAIO.Vars:_setBonusDmg(function() return 3 end)
    gsoAIO.Vars:_setOnTick(function() self:_tick() end)
    gsoAIO.Vars:_setChampMenu(function() return self:_menu() end)
    gsoAIO.Vars:_setCanAttack(function() return self:_canAttack() end)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------canAA-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTeemo:_canAttack()
    local getTick = GetTickCount()
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.Spells.lastQ
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.Spells.lastW
    local rMinuss = getTick - gsoAIO.Spells.lastR
    if qMinus > 450 and qMinuss > 450 and wMinus > 50 and wMinuss > 50 and rMinuss > 700 then
        return true
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------menu----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTeemo:_menu()
    gsoAIO.Load.menu:MenuElement({name = "Teemo", id = "gsoteemo", type = MENU, leftIcon = gsoAIO.Vars.Icons["teemo"] })
        gsoAIO.Load.menu.gsoteemo:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gsoAIO.Load.menu.gsoteemo.qset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsoteemo.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoAIO.Load.menu.gsoteemo:MenuElement({name = "W settings", id = "wset", type = MENU })
            gsoAIO.Load.menu.gsoteemo.wset:MenuElement({id = "mindist", name = "Min. distance to enemy", value = 850, min = 680, max = 1250, step = 10 })
            gsoAIO.Load.menu.gsoteemo.wset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsoteemo.wset:MenuElement({id = "harass", name = "Harass", value = false})
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------cast spells--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTeemo:_castQ()
    local target = gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, false) and gsoAIO.TS.lastTarget or gsoAIO.TS:_getTarget(680, false, false)
    local tPos = target and target.pos or nil
    if tPos and not gsoAIO.Utils:_nearUnit(tPos, target.networkID) then
        local cPos = cursorPos
        Control.SetCursorPos(target.pos)
        Control.KeyDown(HK_Q)
        Control.KeyUp(HK_Q)
        self.lastQ = GetTickCount()
        gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
        gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
        return true
    end
    return false
end
function __gsoTeemo:_castW()
    local mePos = myHero.pos
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local hero = gsoAIO.OB.enemyHeroes[i]
        local heroPos = hero.pos
        if gsoAIO.Utils:_getDistance(mePos, heroPos) < gsoAIO.Load.menu.gsoteemo.wset.mindist:Value() then
            Control.KeyDown(HK_W)
            Control.KeyUp(HK_W)
            self.lastW = GetTickCount()
            return true
        end
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------tick-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTeemo:_tick()
    
    --[[ cast spells ]]
    if os.clock() > gsoAIO.Orb.lAttack + gsoAIO.Orb.windUpT then
    
        --[[ check if spells are ready ]]
        local getTick = GetTickCount()
        local qMinus = getTick - self.lastQ
        local qMinuss = getTick - gsoAIO.Spells.lastQ
        local wMinus = getTick - self.lastW
        local wMinuss = getTick - gsoAIO.Spells.lastW
        local rMinuss = getTick - gsoAIO.Spells.lastR
        local canQTime = qMinus > 1000 and qMinuss > 1000 and rMinuss > 1050
        local canWTime = qMinus > 50 and qMinuss > 50 and wMinus > 1000 and wMinuss > 1000 and rMinuss > 50
        local isCombo = gsoAIO.Load.menu.orb.keys.combo:Value()
        local isHarass = gsoAIO.Load.menu.orb.keys.harass:Value()
        local isComboQ = isCombo and gsoAIO.Load.menu.gsoteemo.qset.combo:Value()
        local isHarassQ = isHarass and gsoAIO.Load.menu.gsoteemo.qset.harass:Value()
        local isComboW = isCombo and gsoAIO.Load.menu.gsoteemo.wset.combo:Value()
        local isHarassW = isHarass and gsoAIO.Load.menu.gsoteemo.wset.harass:Value()
        local isQReady = (isComboQ or isHarassQ) and canQTime and gsoAIO.Utils:_isReady(_Q)
        local isWReady = (isComboW or isHarassW) and canWTime and gsoAIO.Utils:_isReady(_W)
        
        --[[ combo harass ]]
        if isQReady or isWReady then
            
            --[[ check enemies in aa range ]]
            local mePos = myHero.pos
            local meRange = myHero.range + myHero.boundingRadius
            local enemiesCount = 0
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                if gsoAIO.Utils:_valid(hero, true) and gsoAIO.Utils:_getDistance(mePos, hero.pos) < meRange + hero.boundingRadius then
                    enemiesCount = enemiesCount + 1
                end
            end
            
            --[[ spells after/before if enemy is in aa range ]]
            local afterBefore = os.clock() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT*0.75
            
            --[[ spells if enemy is out of aa range ]]
            local outOfAARange = not gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, true) and enemiesCount == 0
            
            --[[ cast spells ]]
            if afterBefore or outOfAARange then
                if isQReady and self:_castQ() then
                    return
                end
                if isWReady and self:_castW() then
                    return
                end
            end
        end
    end
end






--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------SIVIR---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoSivir"

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------init----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoSivir:__init()
    self.lastQ = 0
    self.lastW = 0
    self.lastReset = 0
    gsoAIO.Orb.baseAASpeed = 0.625
    gsoAIO.Orb.baseWindUp = 0.1199999
    gsoAIO.Vars:_setBonusDmg(function() return 3 end)
    gsoAIO.Vars:_setOnTick(function() self:_tick() end)
    gsoAIO.Vars:_setChampMenu(function() return self:_menu() end)
    gsoAIO.Vars:_setCanAttack(function() return self:_canAttack() end)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------canAA-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoSivir:_canAttack()
    local getTick = GetTickCount()
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.Spells.lastQ
    if qMinus > 350 and qMinuss > 350 then
        return true
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------menu----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoSivir:_menu()
    gsoAIO.Load.menu:MenuElement({name = "Sivir", id = "gsosivir", type = MENU, leftIcon = gsoAIO.Vars.Icons["sivir"] })
        gsoAIO.Load.menu.gsosivir:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gsoAIO.Load.menu.gsosivir.qset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsosivir.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoAIO.Load.menu.gsosivir:MenuElement({name = "W settings", id = "wset", type = MENU })
            gsoAIO.Load.menu.gsosivir.wset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsosivir.wset:MenuElement({id = "harass", name = "Harass", value = false})
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------cast spells--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoSivir:_castQ()
    local target = gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, false) and gsoAIO.TS.lastTarget or gsoAIO.TS:_getTarget(1250, false, false)
    if target then
        local sQ = { delay = 0.25, range = 1250, width = 60, speed = 1350, sType = "line", col = false }
        local mePos = myHero.pos
        local castpos,HitChance,pos = gsoAIO.TPred:GetBestCastPosition(target, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, mePos, sQ.col, sQ.sType)
        if HitChance > 0 and castpos:ToScreen().onScreen and gsoAIO.Utils:_getDistance(mePos, castpos) < sQ.range and gsoAIO.Utils:_getDistance(target.pos, castpos) < 500 then
            local cPos = cursorPos
            Control.SetCursorPos(castpos)
            Control.KeyDown(HK_Q)
            Control.KeyUp(HK_Q)
            self.lastQ = GetTickCount()
            gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
            return true
        end
    end
    return false
end
function __gsoSivir:_castW()
    local mePos = myHero.pos
    local meRange = myHero.range + myHero.boundingRadius - 30
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local hero = gsoAIO.OB.enemyHeroes[i]
        local heroPos = hero.pos
        if gsoAIO.Utils:_getDistance(mePos, heroPos) < meRange + hero.boundingRadius then
            Control.KeyDown(HK_W)
            Control.KeyUp(HK_W)
            self.lastW = GetTickCount()
            return true
        end
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------tick-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoSivir:_tick()
    
    --[[ reset aa ]]
    for i = 0, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        if buff and buff.count > 0 and buff.name == "SivirWMarker" and os.clock() > self.lastReset + 3 and buff.duration > 3 then
            self.lastReset = os.clock()
            gsoAIO.Orb.aaReset = true
        end
    end
    
    --[[ cast spells ]]
    if os.clock() > gsoAIO.Orb.lAttack + gsoAIO.Orb.windUpT then
    
        --[[ check if spells are ready ]]
        local getTick = GetTickCount()
        local qMinus = getTick - self.lastQ
        local wMinus = getTick - self.lastW
        local isCombo = gsoAIO.Load.menu.orb.keys.combo:Value()
        local isHarass = gsoAIO.Load.menu.orb.keys.harass:Value()
        local isComboQ = isCombo and gsoAIO.Load.menu.gsosivir.qset.combo:Value()
        local isHarassQ = isHarass and gsoAIO.Load.menu.gsosivir.qset.harass:Value()
        local isComboW = isCombo and gsoAIO.Load.menu.gsosivir.wset.combo:Value()
        local isHarassW = isHarass and gsoAIO.Load.menu.gsosivir.wset.harass:Value()
        local isQReady = (isComboQ or isHarassQ) and qMinus > 1000 and wMinus > 500 and os.clock() > self.lastReset + 0.25 and gsoAIO.Utils:_isReady(_Q)
        local isWReady = (isComboW or isHarassW) and qMinus > 350 and wMinus > 1000 and gsoAIO.Utils:_isReady(_W)
        
        --[[ combo/harass ]]
        if isQReady or isWReady then
            
            --[[ check enemies in aa range ]]
            local mePos = myHero.pos
            local meRange = myHero.range + myHero.boundingRadius
            local enemiesCount = 0
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                if gsoAIO.Utils:_valid(hero, true) and gsoAIO.Utils:_getDistance(mePos, hero.pos) < meRange + hero.boundingRadius then
                    enemiesCount = enemiesCount + 1
                end
            end
            
            --[[ spells after/before if enemy is in aa range ]]
            local afterBefore = os.clock() < gsoAIO.Orb.lAttack + gsoAIO.Orb.animT*0.75
            
            --[[ spells if enemy is out of aa range ]]
            local outOfAARange = not gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, true) and enemiesCount == 0
            
            --[[ cast spells ]]
            if afterBefore or outOfAARange then
                if isWReady and not outOfAARange and self:_castW() then
                    return
                end
                if isQReady and self:_castQ() then
                    return
                end
            end
        end
    end
end





--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------TRISTANA--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoTristana"

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------init----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTristana:__init()
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    self.eBuffs = {}
    self.eData = gsoAIO.Dmg.Damages["Tristana"].e
    self.rData = gsoAIO.Dmg.Damages["Tristana"].r
    self.getEData =
        function(stacks)
            return
            {
                dmgAP = self.eData.dmgAP(),
                dmgAD = self.eData.dmgAD(stacks),
                dmgType = self.eData.dmgType
            }
        end
    self.getRData =
        function()
            return
            {
                dmgAP = self.rData.dmgAP(),
                dmgType = self.rData.dmgType
            }
        end
    gsoAIO.Orb.baseAASpeed = 0.656
    gsoAIO.Orb.baseWindUp = 0.1480066
    gsoAIO.Vars:_setBonusDmg(function() return 3 end)
    gsoAIO.Vars:_setOnTick(function() self:_tick() end)
    gsoAIO.Vars:_setChampMenu(function() return self:_menu() end)
    gsoAIO.Vars:_setCanAttack(function() return self:_canAttack() end)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------canAA-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTristana:_canAttack()
    local getTick = GetTickCount()
    local qMinus = getTick - self.lastQ
    local qMinuss = getTick - gsoAIO.Spells.lastQ
    local wMinus = getTick - self.lastW
    local wMinuss = getTick - gsoAIO.Spells.lastW
    local eMinus = getTick - self.lastE
    local eMinuss = getTick - gsoAIO.Spells.lastE
    local rMinus = getTick - self.lastR
    local rMinuss = getTick - gsoAIO.Spells.lastR
    if Game.CanUseSpell(_E) ~= 0 and qMinus > 50 and qMinuss > 50 and wMinus > 1050 and wMinuss > 1050 and eMinus > 200 and eMinuss > 200 and rMinus > 300 and rMinuss > 300 then
        return true
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------menu----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTristana:_menu()
    gsoAIO.Load.menu:MenuElement({name = "Tristana", id = "gsotristana", type = MENU, leftIcon = gsoAIO.Vars.Icons["tristana"] })
        gsoAIO.Load.menu.gsotristana:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gsoAIO.Load.menu.gsotristana.qset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsotristana.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoAIO.Load.menu.gsotristana:MenuElement({name = "E settings", id = "eset", type = MENU })
            gsoAIO.Load.menu.gsotristana.eset:MenuElement({id = "combo", name = "Combo", value = true})
            gsoAIO.Load.menu.gsotristana.eset:MenuElement({id = "harass", name = "Harass", value = false})
        gsoAIO.Load.menu.gsotristana:MenuElement({name = "R settings", id = "rset", type = MENU })
            gsoAIO.Load.menu.gsotristana.rset:MenuElement({id = "ks", name = "KS", value = true})
            gsoAIO.Load.menu.gsotristana.rset:MenuElement({id = "kse", name = "KS only E + R", value = false})
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------cast spells--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTristana:_castW()
    local dActions = gsoAIO.Spells.delayedSpell
    for k,v in pairs(dActions) do
        if k == 1 then
            if gsoAIO.Orb.dActionsC == 0 then
                v[1]()
                gsoAIO.Orb.dActions[GetTickCount()] = { function() return 0 end, 50 }
                gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                self.lastW = GetTickCount()
                gsoAIO.Spells.delayedSpell[k] = nil
                break
            end
            if GetTickCount() - v[2] > 125 then
                gsoAIO.Spells.delayedSpell[k] = nil
            end
            break
        end
    end
end
function __gsoTristana:_rKS()
    local mePos = myHero.pos
    local meRange = myHero.range + ( myHero.boundingRadius * 0.5 )
    if gsoAIO.Utils.eBuffTarget then
        local unit = gsoAIO.Utils.eBuffTarget.unit
        local stacks = gsoAIO.Utils.eBuffTarget.stacks
        local unitPos = unit and unit.pos or nil
        if unitPos and gsoAIO.Utils:_valid(unit, false) and gsoAIO.Utils:_getDistance(unitPos, mePos) < meRange + ( unit.boundingRadius * 0.5 ) and not gsoAIO.Utils:_nearUnit(unitPos, unit.networkID) and gsoAIO.Dmg.PredHP(unit, self.getRData()) + gsoAIO.Dmg.PredHP(unit, self.getEData(stacks)) > unit.health + (unit.hpRegen * 2) then
            local cPos = cursorPos
            Control.SetCursorPos(unitPos)
            Control.KeyDown(HK_R)
            Control.KeyUp(HK_R)
            self.lastR = GetTickCount()
            gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
            gsoAIO.Utils.eBuffTarget = nil
            return true
        end
    end
    if not gsoAIO.Load.menu.gsotristana.rset.kse:Value() then
        for i = 1, #gsoAIO.OB.enemyHeroes do
            local unit  = gsoAIO.OB.enemyHeroes[i]
            local unitPos = unit and unit.pos or nil
            if unitPos and gsoAIO.Utils:_valid(unit, false) and gsoAIO.Utils:_getDistance(unitPos, mePos) < meRange + ( unit.boundingRadius * 0.5 ) and not gsoAIO.Utils:_nearUnit(unitPos, unit.networkID) and gsoAIO.Dmg.PredHP(unit, self.getRData()) > unit.health + (unit.hpRegen * 2) then
                local cPos = cursorPos
                Control.SetCursorPos(unitPos)
                Control.KeyDown(HK_R)
                Control.KeyUp(HK_R)
                self.lastR = GetTickCount()
                gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                return true
            end
        end
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------tick-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoTristana:_tick()
    
    --[[ handle E buffs ]]
    for i = 1, #gsoAIO.OB.enemyHeroes do
        local hero  = gsoAIO.OB.enemyHeroes[i]
        for i = 0, hero.buffCount do
            local buff = hero:GetBuff(i)
            if buff and buff.count > 0 and buff.duration > 1 and buff.name:lower() == "tristanaechargesound" and gsoAIO.Utils.eBuffTarget and not gsoAIO.Utils.eBuffTarget.endTime then
                gsoAIO.Utils.eBuffTarget.endTime = Game.Timer() + buff.duration - Game.Latency()*0.0015 - 0.034
                --print("ok")
            end
        end
    end
    if gsoAIO.Utils.eBuffTarget and gsoAIO.Utils.eBuffTarget.endTime and Game.Timer() > gsoAIO.Utils.eBuffTarget.endTime then
        gsoAIO.Utils.eBuffTarget = nil
        --print("ok")
    end
    
    --[[ manual W ]]
    local getTick = GetTickCount()
    if getTick - self.lastW > 1000 and Game.CanUseSpell(_W) == 0 then
        self:_castW()
    end
    
    --[[ cast spells ]]
    if os.clock() > gsoAIO.Orb.lAttack + gsoAIO.Orb.windUpT then
        
        --[[ check if spells are ready ]]
        local qMinus = getTick - self.lastQ
        local qMinuss = getTick - gsoAIO.Spells.lastQ
        local wMinus = getTick - self.lastW
        local wMinuss = getTick - gsoAIO.Spells.lastW
        local eMinus = getTick - self.lastE
        local eMinuss = getTick - gsoAIO.Spells.lastE
        local rMinus = getTick - self.lastR
        local rMinuss = getTick - gsoAIO.Spells.lastR
        local canQTime = qMinus > 1000 and qMinuss > 1000 and wMinus > 1050 and wMinuss > 1050 and eMinus > 50 and eMinuss > 50 and rMinus > 600 and rMinuss > 600
        local canETime = qMinus > 50 and qMinuss > 50 and wMinus > 1050 and wMinuss > 1050 and eMinus > 1000 and eMinuss > 1000 and rMinus > 600 and rMinuss > 600
        local canRTime = qMinus > 50 and qMinuss > 50 and wMinus > 1050 and wMinuss > 1050 and eMinus > 450 and eMinuss > 450 and rMinus > 1000 and rMinuss > 1000
        local isCombo = gsoAIO.Load.menu.orb.keys.combo:Value()
        local isHarass = gsoAIO.Load.menu.orb.keys.harass:Value()
        local isComboQ = isCombo and gsoAIO.Load.menu.gsotristana.qset.combo:Value()
        local isHarassQ = isHarass and gsoAIO.Load.menu.gsotristana.qset.harass:Value()
        local isComboE = isCombo and gsoAIO.Load.menu.gsotristana.eset.combo:Value()
        local isHarassE = isHarass and gsoAIO.Load.menu.gsotristana.eset.harass:Value()
        local isQReady = (isComboQ or isHarassQ) and canQTime and gsoAIO.Utils:_isReady(_Q)
        local isEReady = (isComboE or isHarassE) and canETime and gsoAIO.Utils:_isReady(_E)
        local isKSR = (isCombo or isHarass) and gsoAIO.Load.menu.gsotristana.rset.ks:Value()
        local isRReady = isKSR and canRTime and gsoAIO.Utils:_isReady(_R)
        
        --[[ KS R ]]
        if isRReady and self:_rKS() then
            return
        end
        
        --[[ combo/harass ]]
        if isQReady or isEReady then
            
            --[[ check enemies in aa range ]]
            local mePos = myHero.pos
            local meRange = myHero.range + myHero.boundingRadius
            local enemiesCount = 0
            for i = 1, #gsoAIO.OB.enemyHeroes do
                local hero = gsoAIO.OB.enemyHeroes[i]
                if gsoAIO.Utils:_valid(hero, true) and gsoAIO.Utils:_getDistance(mePos, hero.pos) < meRange + hero.boundingRadius then
                    enemiesCount = enemiesCount + 1
                end
            end
            
            --[[ spells if enemy is out of aa range ]]
            local outOfAARange = not gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, true) and enemiesCount == 0
            
            --[[ cast Q ]]
            if isQReady and not outOfAARange then
                Control.KeyDown(HK_Q)
                Control.KeyUp(HK_Q)
                self.lastQ = GetTickCount()
            end
            
            --[[ cast E ]]
            if isEReady and not outOfAARange then
                local targetPos = gsoAIO.Utils:_valid(gsoAIO.TS.lastTarget, true) == true and gsoAIO.TS.lastTarget.pos or nil
                if targetPos and not gsoAIO.Utils:_nearUnit(targetPos, gsoAIO.TS.lastTarget.networkID) and gsoAIO.Utils:_getDistance(targetPos, myHero.pos) < myHero.range + myHero.boundingRadius + gsoAIO.TS.lastTarget.boundingRadius - 30 then
                    local cPos = cursorPos
                    Control.SetCursorPos(targetPos)
                    Control.KeyDown(HK_E)
                    Control.KeyUp(HK_E)
                    self.lastE = GetTickCount()
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
                    gsoAIO.Utils.eBuffTarget = { id = gsoAIO.TS.lastTarget.networkID, stacks = 1, unit = gsoAIO.TS.lastTarget }
                end
            end
        end
    end
end





--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------ONLOAD----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
class "__gsoLoad"

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------init-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoLoad:__init()
    self.menu = MenuElement({name = "Gamsteron AIO", id = "gamsteronaio", type = MENU, leftIcon = gsoAIO.Vars.Icons["gsoaio"] })
    Callback.Add('Load', function() self:_load() end)
end

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------load-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoLoad:_load()
    self.menu:MenuElement({name = "Target Selector", id = "ts", type = MENU, leftIcon = gsoAIO.Vars.Icons["ts"] })
        self.menu.ts:MenuElement({ id = "Mode", name = "Mode", value = 1, drop = { "Auto", "Closest", "Least Health", "Least Priority" } })
        if gsoAIO.Vars.meTristana then
            self.menu.ts:MenuElement({ id = "tristE", name = "Tristana E Target", type = MENU })
                self.menu.ts.tristE:MenuElement({ id = "enable", name = "Enable", value = true })
                self.menu.ts.tristE:MenuElement({ id = "stacks", name = "Min. Stacks", value = 3, min = 1, max = 4})
        end
        self.menu.ts:MenuElement({ id = "priority", name = "Priorities", type = MENU })
        self.menu.ts:MenuElement({ id = "selected", name = "Selected Target", type = MENU })
            self.menu.ts.selected:MenuElement({ id = "enable", name = "Enable", value = true })
            self.menu.ts.selected:MenuElement({ id = "only", name = "Only Selected Target", value = false })
            self.menu.ts.selected:MenuElement({name = "Draw",  id = "draw", type = MENU})
                self.menu.ts.selected.draw:MenuElement({name = "Enable",  id = "enable", value = true})
                self.menu.ts.selected.draw:MenuElement({name = "Color",  id = "color", color = Draw.Color(255, 204, 0, 0)})
                self.menu.ts.selected.draw:MenuElement({name = "Width",  id = "width", value = 3, min = 1, max = 10})
                self.menu.ts.selected.draw:MenuElement({name = "Radius",  id = "radius", value = 150, min = 1, max = 300})
    self.menu:MenuElement({name = "Orbwalker", id = "orb", type = MENU, leftIcon = gsoAIO.Vars.Icons["orb"] })
        self.menu.orb:MenuElement({name = "Delays", id = "delays", type = MENU})
            self.menu.orb.delays:MenuElement({name = "extra WindUp", id = "windup", value = 0, min = -30, max = 50, step = 1 })
            self.menu.orb.delays:MenuElement({name = "lasthit delay", id = "lhDelay", value = 0, min = 0, max = 50, step = 1 })
            self.menu.orb.delays:MenuElement({name = "Humanizer", id = "humanizer", value = 200, min = 0, max = 300, step = 10 })
        self.menu.orb:MenuElement({name = "Keys", id = "keys", type = MENU})
            self.menu.orb.keys:MenuElement({name = "Combo Key", id = "combo", key = string.byte(" ")})
            self.menu.orb.keys:MenuElement({name = "Harass Key", id = "harass", key = string.byte("C")})
            self.menu.orb.keys:MenuElement({name = "LastHit Key", id = "lastHit", key = string.byte("X")})
            self.menu.orb.keys:MenuElement({name = "LaneClear Key", id = "laneClear", key = string.byte("V")})
        self.menu.orb:MenuElement({name = "Drawings", id = "draw", type = MENU})
            self.menu.orb.draw:MenuElement({name = "Enable", id = "enable", value = true})
            self.menu.orb.draw:MenuElement({name = "MyHero attack range", id = "me", type = MENU})
                self.menu.orb.draw.me:MenuElement({name = "Enable",  id = "enable", value = true})
                self.menu.orb.draw.me:MenuElement({name = "Color",  id = "color", color = Draw.Color(150, 49, 210, 0)})
                self.menu.orb.draw.me:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
            self.menu.orb.draw:MenuElement({name = "Enemy attack range", id = "he", type = MENU})
                self.menu.orb.draw.he:MenuElement({name = "Enable",  id = "enable", value = true})
                self.menu.orb.draw.he:MenuElement({name = "Color",  id = "color", color = Draw.Color(150, 255, 0, 0)})
                self.menu.orb.draw.he:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
            self.menu.orb.draw:MenuElement({name = "Cursor Posistion",  id = "cpos", type = MENU})
                self.menu.orb.draw.cpos:MenuElement({name = "Enable",  id = "enable", value = true})
                self.menu.orb.draw.cpos:MenuElement({name = "Color",  id = "color", color = Draw.Color(150, 153, 0, 76)})
                self.menu.orb.draw.cpos:MenuElement({name = "Width",  id = "width", value = 5, min = 1, max = 10})
                self.menu.orb.draw.cpos:MenuElement({name = "Radius",  id = "radius", value = 250, min = 1, max = 300})
    self.menu:MenuElement({name = "Items", id = "gsoitem", type = MENU, leftIcon = gsoAIO.Vars.Icons["item"] })
        self.menu.gsoitem:MenuElement({id = "botrk", name = "        botrk", value = true, leftIcon = gsoAIO.Vars.Icons["botrk"] })
    
    gsoAIO.Dmg = __gsoDmg()
    gsoAIO.Items = __gsoItems()
    gsoAIO.Spells = __gsoSpells()
    gsoAIO.Utils = __gsoUtils()
    gsoAIO.OB = __gsoOB()
    gsoAIO.TS = __gsoTS()
    gsoAIO.Farm = __gsoFarm()
    gsoAIO.TPred = __gsoTPred()
    gsoAIO.Orb = __gsoOrb()
    if _G.Orbwalker then
        GOS.BlockMovement = true
        GOS.BlockAttack = true
        _G.Orbwalker.Enabled:Value(false)
    end
    if _G.SDK and _G.SDK.Orbwalker then
        _G.SDK.Orbwalker:SetMovement(false)
        _G.SDK.Orbwalker:SetAttack(false)
    end
    if _G.EOW then
        _G.EOW:SetMovements(false)
        _G.EOW:SetAttacks(false)
    end
    if gsoAIO.Vars.hName == "Ashe" then
        __gsoAshe()
    elseif gsoAIO.Vars.hName == "Twitch" then
        __gsoTwitch()
    elseif gsoAIO.Vars.hName == "KogMaw" then
        __gsoKogMaw()
    elseif gsoAIO.Vars.hName == "Draven" then
        --__gsoDraven()
    elseif gsoAIO.Vars.hName == "Ezreal" then
        __gsoEzreal()
    elseif gsoAIO.Vars.hName == "Vayne" then
        __gsoVayne()
    elseif gsoAIO.Vars.hName == "Teemo" then
        __gsoTeemo()
    elseif gsoAIO.Vars.hName == "Sivir" then
        __gsoSivir()
    elseif gsoAIO.Vars.hName == "Tristana" then
        __gsoTristana()
    end
    gsoAIO.Vars._champMenu()
    print("gamsteronAIO "..gsoAIO.Vars.version.." | loaded!")
end

gsoAIO.Load = __gsoLoad()
