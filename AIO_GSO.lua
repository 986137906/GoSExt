
local GetTickCount = GetTickCount
local Game = Game
local myHero = myHero
local Control = Control
local mathSqrt = math.sqrt
local Vector = Vector
local Draw = Draw
local gso_menu
local _gso = {
  Vars = nil,
  Items = nil,
  OB = nil,
  TS = nil,
  Farm = nil,
  TPred = nil,
  Orb = nil
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
    self.version = "0.4986"
    self.hName = myHero.charName
    self.loaded = true
    self.supportedChampions = {
      ["Ashe"] = true,
      ["KogMaw"] = true,
      ["Twitch"] = true,
      ["Draven"] = true,
      ["Ezreal"] = true
    }
    if not self.supportedChampions[self.hName] == true then
        self.loaded = false
        print("gamsteronAIO "..self.version.." | hero not supported !")
    end
    self._onDraw        = {}
    self._champMenu     = function() return 0 end
    self._bonusDmg      = function() return 0 end
    self._bonusDmgUnit  = function() return 0 end
    self._onTick        = function() return 0 end
    self._castSpells    = function() return 0 end
    self._castSpellsAA  = function() return 0 end
    self._beforeAA      = function() return 0 end
    self._mousePos      = function() return nil end
    self._canMove       = function() return true end
    self._canAttack     = function() return true end
end
function __gsoVars:_setOnDraw(func) self._onDraw[#self._onDraw+1] = func end
function __gsoVars:_setChampMenu(func) self._champMenu = func end
function __gsoVars:_setBonusDmg(func) self._bonusDmg = func end
function __gsoVars:_setBonusDmgUnit(func) self._bonusDmgUnit = func end
function __gsoVars:_setOnTick(func) self._onTick = func end
function __gsoVars:_setCastSpells(func) self._castSpells = func end
function __gsoVars:_setCastSpellsAA(func) self._castSpellsAA = func end
function __gsoVars:_setBeforeAA(func) self._beforeAA = func end
function __gsoVars:_setMousePos(func) self._mousePos = func end
function __gsoVars:_setCanMove(func) self._canMove = func end
function __gsoVars:_setCanAttack(func) self._canAttack = func end

_gso.Vars = __gsoVars()
if _gso.Vars.loaded == false then
    return
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

function __gsoOB:_getDistance(a, b)
  local x = a.x - b.x
  local z = a.z - b.z
  return mathSqrt(x * x + z * z)
end

function __gsoOB:_tick()
    local mePos = myHero.pos
    for i=1, #self.allyMinions do self.allyMinions[i]=nil end
    for i=1, #self.enemyMinions do self.enemyMinions[i]=nil end
    for i=1, #self.enemyHeroes do self.enemyHeroes[i]=nil end
    for i=1, #self.enemyTurrets do self.enemyTurrets[i]=nil end
    for i = 1, Game.MinionCount() do
        local minion = Game.Minion(i)
        if minion and self:_getDistance(mePos, minion.pos) < 2000 and not minion.dead and minion.isTargetable and minion.visible and minion.valid then
            if minion.team ~= self.meTeam then
                self.enemyMinions[#self.enemyMinions+1] = minion
            else
                self.allyMinions[#self.allyMinions+1] = minion
            end
        end
    end
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if hero and hero.team ~= self.meTeam and self:_getDistance(mePos, hero.pos) < 10000 and not hero.dead and hero.isTargetable and hero.visible and hero.valid then
            self.enemyHeroes[#self.enemyHeroes+1] = hero
        end
    end
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        if turret and turret.team ~= self.meTeam and self:_getDistance(mePos, turret.pos) < 2000 and not turret.dead and turret.isTargetable and turret.visible and turret.valid then
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
    
    self.loadedChamps = false
    self.lastFound = -10000000
    
    self.undyingBuffs = { ["zhonyasringshield"] = true }
    
    self.Priorities = {
        ["Aatrox"] = 3,
        ["Ahri"] = 2,
        ["Akali"] = 2,
        ["Alistar"] = 5,
        ["Amumu"] = 5,
        ["Anivia"] = 2,
        ["Annie"] = 2,
        ["Ashe"] = 1,
        ["AurelionSol"] = 2,
        ["Azir"] = 2,
        ["Bard"] = 3,
        ["Blitzcrank"] = 5,
        ["Brand"] = 2,
        ["Braum"] = 5,
        ["Caitlyn"] = 1,
        ["Camille"] = 3,
        ["Cassiopeia"] = 2,
        ["Chogath"] = 5,
        ["Corki"] = 1,
        ["Darius"] = 4,
        ["Diana"] = 2,
        ["DrMundo"] = 5,
        ["Draven"] = 1,
        ["Ekko"] = 2,
        ["Elise"] = 3,
        ["Evelynn"] = 2,
        ["Ezreal"] = 1,
        ["Fiddlesticks"] = 3,
        ["Fiora"] = 3,
        ["Fizz"] = 2,
        ["Galio"] = 5,
        ["Gangplank"] = 2,
        ["Garen"] = 5,
        ["Gnar"] = 5,
        ["Gragas"] = 4,
        ["Graves"] = 2,
        ["Hecarim"] = 4,
        ["Heimerdinger"] = 3,
        ["Illaoi"] =  3,
        ["Irelia"] = 3,
        ["Ivern"] = 5,
        ["Janna"] = 4,
        ["JarvanIV"] = 3,
        ["Jax"] = 3,
        ["Jayce"] = 2,
        ["Jhin"] = 1,
        ["Jinx"] = 1,
        ["Kalista"] = 1,
        ["Karma"] = 2,
        ["Karthus"] = 2,
        ["Kassadin"] = 2,
        ["Katarina"] = 2,
        ["Kayle"] = 2,
        ["Kayn"] = 2,
        ["Kennen"] = 2,
        ["Khazix"] = 2,
        ["Kindred"] = 2,
        ["Kled"] = 4,
        ["KogMaw"] = 1,
        ["Leblanc"] = 2,
        ["LeeSin"] = 3,
        ["Leona"] = 5,
        ["Lissandra"] = 2,
        ["Lucian"] = 1,
        ["Lulu"] = 3,
        ["Lux"] = 2,
        ["Malphite"] = 5,
        ["Malzahar"] = 3,
        ["Maokai"] = 4,
        ["MasterYi"] = 1,
        ["MissFortune"] = 1,
        ["MonkeyKing"] = 3,
        ["Mordekaiser"] = 2,
        ["Morgana"] = 3,
        ["Nami"] = 3,
        ["Nasus"] = 4,
        ["Nautilus"] = 5,
        ["Nidalee"] = 2,
        ["Nocturne"] = 2,
        ["Nunu"] = 4,
        ["Olaf"] = 4,
        ["Orianna"] = 2,
        ["Ornn"] = 4,
        ["Pantheon"] = 3,
        ["Poppy"] = 4,
        ["Quinn"] = 1,
        ["Rakan"] = 3,
        ["Rammus"] = 5,
        ["RekSai"] = 4,
        ["Renekton"] = 4,
        ["Rengar"] = 2,
        ["Riven"] = 2,
        ["Rumble"] = 2,
        ["Ryze"] = 2,
        ["Sejuani"] = 4,
        ["Shaco"] = 2,
        ["Shen"] = 5,
        ["Shyvana"] = 4,
        ["Singed"] = 5,
        ["Sion"] = 5,
        ["Sivir"] = 1,
        ["Skarner"] = 4,
        ["Sona"] = 3,
        ["Soraka"] = 3,
        ["Swain"] = 3,
        ["Syndra"] = 2,
        ["TahmKench"] = 5,
        ["Taliyah"] = 2,
        ["Talon"] = 2,
        ["Taric"] = 5,
        ["Teemo"] = 2,
        ["Thresh"] = 5,
        ["Tristana"] = 1,
        ["Trundle"] = 4,
        ["Tryndamere"] = 2,
        ["TwistedFate"] = 2,
        ["Twitch"] = 1,
        ["Udyr"] = 4,
        ["Urgot"] = 4,
        ["Varus"] = 1,
        ["Vayne"] = 1,
        ["Veigar"] = 2,
        ["Velkoz"] = 2,
        ["Vi"] = 4,
        ["Viktor"] = 2,
        ["Vladimir"] = 3,
        ["Volibear"] = 4,
        ["Warwick"] = 4,
        ["Xayah"] = 1,
        ["Xerath"] = 2,
        ["XinZhao"] = 3,
        ["Yasuo"] = 2,
        ["Yorick"] = 4,
        ["Zac"] = 5,
        ["Zed"] = 2,
        ["Ziggs"] = 2,
        ["Zilean"] = 3,
        ["Zoe"] = 2,
        ["Zyra"] = 2
    }
    
    self.lastQ    = 0
    self.lastW    = 0
    self.lastE    = 0
    self.lastR    = 0
    
    self.delayedSpell = {}
    
    self.apDmg = false
    self.selectedTarget = nil
    self.lastSelTick = 0
    _gso.Vars:_setOnDraw(function() self:_draw() end)
    Callback.Add('WndMsg', function(msg, wParam)
        self:_onWndMsg(msg, wParam)
    end)
end

function __gsoTS:_isImmortal(unit, orb)
    local unitHPPercent = 100 * unit.health / unit.maxHealth
    if self.undyingBuffs["JaxCounterStrike"] ~= nil then    self.undyingBuffs["JaxCounterStrike"] = orb end
    if self.undyingBuffs["kindredrnodeathbuff"] ~= nil then self.undyingBuffs["kindredrnodeathbuff"] = unitHPPercent < 10 end
    if self.undyingBuffs["UndyingRage"] ~= nil then         self.undyingBuffs["UndyingRage"] = unitHPPercent < 15 end
    if self.undyingBuffs["ChronoShift"] ~= nil then         self.undyingBuffs["ChronoShift"] = unitHPPercent < 15; self.undyingBuffs["chronorevive"] = unitHPPercent < 15 end
    for i = 1, unit.buffCount do
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

function __gsoTS:_valid(unit, orb)
    if not unit or self:_isImmortal(unit, orb) then
        return false
    end
    if not unit.dead and unit.isTargetable and unit.visible and unit.valid then
        return true
    end
    return false
end

function __gsoTS:_isImmobile(unit)
    for i = 1, unit.buffCount do
        local buff = unit:GetBuff(i)
        local type = buff.type
        if buff and buff.count > 0 and (type == 5 or type == 11 or type == 29 or type == 24 or buff.name == "recall") then
            return true
        end
    end
    return false
end

function __gsoTS:_draw()
    if gso_menu.ts.selected.draw.enable:Value() == true and self.selectedTarget ~= nil then
        Draw.Circle(self.selectedTarget.pos, gso_menu.ts.selected.draw.radius:Value(), gso_menu.ts.selected.draw.width:Value(), gso_menu.ts.selected.draw.color:Value())
    end
end

function __gsoTS:_castAgain(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
end

function __gsoTS:_onWndMsg(msg, wParam)
    local getTick = GetTickCount()
    local isKey = gso_menu.orb.keys.combo:Value() or gso_menu.orb.keys.harass:Value() or gso_menu.orb.keys.laneClear:Value() or gso_menu.orb.keys.lastHit:Value()
    if wParam == HK_Q and getTick > self.lastQ + 500 then
        self.lastQ = getTick
        if isKey and not self.delayedSpell[0] then
            self.delayedSpell[0] = { function() self:_castAgain(wParam) end, getTick }
        end
    elseif wParam == HK_W and getTick > self.lastW + 500 then
        self.lastW = getTick
        if isKey and not self.delayedSpell[1] then
            self.delayedSpell[1] = { function() self:_castAgain(wParam) end, getTick }
        end
    elseif wParam == HK_E and getTick > self.lastE + 500 then
        self.lastE = getTick
        if isKey and not self.delayedSpell[2] then
            self.delayedSpell[2] = { function() self:_castAgain(wParam) end, getTick }
        end
    elseif wParam == HK_R and getTick > self.lastR + 500 then
        self.lastR = getTick
        if isKey and not self.delayedSpell[3] then
            self.delayedSpell[3] = { function() self:_castAgain(wParam) end, getTick }
        end
    elseif msg == WM_LBUTTONDOWN and gso_menu.ts.selected.enable:Value() == true then
        if getTick > self.lastSelTick + 100 and getTick > self.lastQ + 250 and getTick > self.lastW + 250 and getTick > self.lastE + 250 and getTick > self.lastR + 250 then 
            local num = 10000000
            local enemy = nil
            for i = 1, #_gso.OB.enemyHeroes do
                local hero = _gso.OB.enemyHeroes[i]
                local heroPos = hero.pos
                if self:_valid(hero, true) and _gso.OB:_getDistance(myHero.pos, heroPos) < 10000 then
                    local distance = _gso.OB:_getDistance(heroPos, mousePos)
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

function __gsoTS:_getTarget(_range, orb, changeRange)
    if gso_menu.ts.selected.only:Value() == true and self.selectedTarget ~= nil then
        return self.selectedTarget
    end
    local result  = nil
    local num     = 10000000
    local mode    = gso_menu.ts.Mode:Value()
    local prioT  = { 10000000, 10000000 }
    for i = 1, #_gso.OB.enemyHeroes do
        local unit = _gso.OB.enemyHeroes[i]
        local range = changeRange == true and _range + myHero.boundingRadius + unit.boundingRadius - 30 or _range
        local distance = _gso.OB:_getDistance(myHero.pos, unit.pos)
        if self:_valid(unit, orb) and distance < range then
            if gso_menu.ts.selected.enable:Value() == true and self.selectedTarget ~= nil and unit.networkID == self.selectedTarget.networkID then
                return self.selectedTarget
            elseif mode == 1 then
                local unitName = unit.charName
                local priority = 6
                if unitName ~= nil then
                    priority = gso_menu.ts.priority[unitName] and gso_menu.ts.priority[unitName]:Value() or priority
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
                    priority = gso_menu.ts.priority[unitName] and gso_menu.ts.priority[unitName]:Value() or priority
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
  
    self.latency        = Game.Latency() * 0.001
    self.aaDmg          = myHero.totalDamage
    
    self.lastHit        = {}
    self.almostLH       = {}
    self.laneClear      = {}
    
    self.aAttacks       = {}
    
    self.shouldWaitT    = 0
    self.shouldWait     = false
    
end

function __gsoFarm:_tick()
    
    self.latency = Game.Latency() * 0.001
    self.aaDmg   = myHero.totalDamage + _gso.Vars._bonusDmg()
    
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
        local distUP  = _gso.OB:_getDistance(pPos, uPos)
        local distEP  = _gso.OB:_getDistance(pPos, ePos)
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
    for i = 1, #_gso.OB.allyMinions do
        local aMin = _gso.OB.allyMinions[i]
        local aaData  = aMin.attackData
        local aDmg    = (aMin.totalDamage*(1+aMin.bonusDamagePercent))
        if aaData.target == eMin.handle then
            local endT    = aaData.endTime
            local animT   = aaData.animationTime
            local windUpT = aaData.windUpTime
            local pSpeed  = aaData.projectileSpeed
            local pFlyT   = pSpeed > 0 and _gso.OB:_getDistance(aMin.pos, eMin.pos) / pSpeed or 0
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

function __gsoFarm:_setEnemyMinions()
  
    local cLH = #self.lastHit
    for i=1, cLH do self.lastHit[i]=nil end
    
    local cALH = #self.almostLH
    for i=1, cALH do self.almostLH[i]=nil end
    
    local cLC = #self.laneClear
    for i=1, cLC do self.laneClear[i]=nil end
    
    local mLH = gso_menu.orb.delays.lhDelay:Value()*0.001
    for i = 1, #_gso.OB.enemyMinions do
        local eMinion = _gso.OB.enemyMinions[i]
        local eMinion_handle	= eMinion.handle
        local distance = _gso.OB:_getDistance(myHero.pos, eMinion.pos)
        if distance < myHero.range + myHero.boundingRadius + eMinion.boundingRadius - 30 then
            local eMinion_health	= eMinion.health
            local myHero_aaData		= myHero.attackData
            local myHero_pFlyTime	= myHero_aaData.windUpTime + (distance / myHero_aaData.projectileSpeed) + self.latency + 0.05 + mLH
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
            local myHero_dmg = self.aaDmg + _gso.Vars._bonusDmgUnit(eMinion)
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
    for i = 1, #_gso.OB.allyMinions do
        local aMinion = _gso.OB.allyMinions[i]
        local aHandle	= aMinion.handle
        local aAAData	= aMinion.attackData
        if aAAData.endTime > Game.Timer() then
            for i = 1, #_gso.OB.enemyMinions do
                local eMinion = _gso.OB.enemyMinions[i]
                local eHandle	= eMinion.handle
                if eHandle == aAAData.target then
                    local checkT		= Game.Timer()
                    -- p -> projectile
                    local pSpeed  = aAAData.projectileSpeed
                    local aMPos   = aMinion.pos
                    local eMPos   = eMinion.pos
                    local pFlyT		= pSpeed > 0 and _gso.OB:_getDistance(aMPos, eMPos) / pSpeed or 0
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
                    self.aAttacks[k1][k2].pTime = _gso.OB:_getDistance(v2.fromPos, self:_predPos(v2.speed, v2.pos, v2.to)) / v2.speed
                end
                if checkT > v2.startTime + self.aAttacks[k1][k2].pTime - self.latency - 0.02 or not v2.to or v2.to.dead then
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
    for i = 1, unit.buffCount do
        local buff = unit:GetBuff(i);
        if buff.count > 0 and buff.duration>=delay then
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
    for i = 1, #_gso.OB.enemyMinions do
        local minion = _gso.OB.enemyMinions[i]
        if minion and not minion.dead and minion.isTargetable and minion.visible and minion.valid and self:CheckCol(unit, minion, Position, delay, radius, range, speed, from, draw) then
            return true
        end
    end
    return false
end

function __gsoTPred:isSlowed(unit, delay, speed, from)
    for i = 1, unit.buffCount do
        local buff = unit:GetBuff(i);
        if from and buff.count > 0 and buff.duration>=(delay + self:GetDistance(unit.pos, from) / speed) then
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
    
    self.canAA        = true
    self.lAttack      = 0
    self.lMove        = 0
    
    self.isTeemo      = false
    self.isBlinded    = false
    self.lastTarget   = nil
    
    self.lastKey      = 0
    
    self.LHTimers     = { [0] = { tick = 0, id = 0 }, [1] = { tick = 0, id = 0 }, [2] = { tick = 0, id = 0 }, [3] = { tick = 0, id = 0 }, [4] = { tick = 0, id = 0 } }
    
    self.windUpT      = myHero.attackData.windUpTime
    self.animT        = myHero.attackData.animationTime
    self.endTime      = myHero.attackData.endTime
    
    self.dActions     = {}
    self.dActionsC    = 0
    
    Callback.Add('Tick', function() self:_tick() end)
    Callback.Add('Draw', function() self:_draw() end)
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------target selector----------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoOrb:_comboT()
    local target = _gso.TS:_getTarget(myHero.range, true, true)
    if target ~= nil then
        self.lastTarget = target
        return target
    else
        self.lastTarget = nil
        return nil
    end
end

function __gsoOrb:_lastHitT()
    local result  = nil
    local min     = 10000000
    for i = 1, #_gso.Farm.lastHit do
        local eMinionLH = _gso.Farm.lastHit[i]
        local minion	= eMinionLH[1]
        local hp		= eMinionLH[2]
        local checkT = Game.Timer() < self.LHTimers[0].tick
        local mHandle = minion.handle
        if not checkT or (checkT and self.LHTimers[0].id ~= mHandle) then
            if hp < min then
                min = hp
                result = minion
                self.LHTimers[4].tick = Game.Timer() + 0.75
                self.LHTimers[4].id = mHandle
            end
        end
    end
    return result
end

function __gsoOrb:_getTurret()
    local result = nil
        local cET = #_gso.OB.enemyTurrets
        for i=1, cET do
            local turret = _gso.OB.enemyTurrets[i]
            local range = myHero.range + myHero.boundingRadius + turret.boundingRadius - 30
            if _gso.OB:_getDistance(myHero.pos, turret.pos) < range then
                result = turret
                break
            end
        end
    return result
end

function __gsoOrb:_laneClearT()
    local result	= self:_lastHitT()
    if result == nil and #_gso.Farm.almostLH == 0 and _gso.Farm.shouldWait == false then
        result = self:_comboT()
        if result == nil then
            result = self:_getTurret()
            if result == nil then
                local min = 10000000
                local cLC = #_gso.Farm.laneClear
                for i = 1, cLC do
                    local minion = _gso.Farm.laneClear[i]
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

function __gsoOrb:_harassT()
    local result = self:_lastHitT()
    return result == nil and self:_comboT() or result
end



--------------------|---------------------------------------------------------|--------------------
--------------------|----------------------orbwalker--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoOrb:_orb(unit)
    
    local checkT = Game.Timer()
    local mHum    = gso_menu.orb.delays.humanizer:Value()*0.001
    
    local aaData = myHero.attackData
    local endTime = aaData.endTime
    self.animT = aaData.animationTime
    self.windUpT = aaData.windUpTime
    
    if endTime > self.endTime then
        self.endTime = endTime
    end
    
    local canMove = _gso.Vars._canMove() and checkT > self.lAttack + self.windUpT + (_gso.Farm.latency*0.5) + 0.025 + gso_menu.orb.delays.windup:Value()*0.001
    local canAA = _gso.Vars._canAttack() and self.isBlinded == false and self.canAA and canMove and checkT > self.endTime - 0.034 - (_gso.Farm.latency*1.5)
    local isTarget = unit ~= nil
    
    if self.dActionsC == 0 then
        if isTarget and canAA then
            if ExtLibEvade and ExtLibEvade.Evading then return end
            _gso.Vars._beforeAA()
            if not self.canAA then return end
            self.lAttack = checkT
            self.lMove = 0
            local cPos = cursorPos
            Control.SetCursorPos(unit.pos)
            if ExtLibEvade and ExtLibEvade.Evading then return end
            Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
            Control.mouse_event(MOUSEEVENTF_RIGHTUP)
            self.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            self.dActionsC = self.dActionsC + 1
        elseif canMove then
            if checkT > self.lMove + mHum and self.dActionsC == 0 then
                local mPos = _gso.Vars._mousePos()
                if ExtLibEvade and ExtLibEvade.Evading then return end
                if mPos ~= nil then
                    if ExtLibEvade and ExtLibEvade.Evading then return end
                    if Control.IsKeyDown(2) then self.lastKey = GetTickCount() end
                    local cPos = cursorPos
                    Control.SetCursorPos(mPos)
                    if ExtLibEvade and ExtLibEvade.Evading then return end
                    Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
                    Control.mouse_event(MOUSEEVENTF_RIGHTUP)
                    self.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    self.dActionsC = self.dActionsC + 1
                    self.lMove = checkT
                else
                    if ExtLibEvade and ExtLibEvade.Evading then return end
                    if Control.IsKeyDown(2) then self.lastKey = GetTickCount() end
                    Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
                    Control.mouse_event(MOUSEEVENTF_RIGHTUP)
                    self.lMove = checkT
                end
            end
        end
    end
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------check blind--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoOrb:_checkTeemoBlind()
    for i = 1, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        if buff and buff.count > 0 and buff.name == "BlindingDart" then
            return true
        end
    end
    return false
end



--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------tick----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function __gsoOrb:_tick()
    if ExtLibEvade and ExtLibEvade.Evading then return end
    if _gso.TS.loadedChamps == false then
        for i = 1, Game.HeroCount() do
            local hero = Game.Hero(i)
            if hero.team ~= _gso.OB.meTeam then
                local eName = hero.charName
                if eName and #eName > 0 and not gso_menu.ts.priority[eName] then
                    _gso.TS.lastFound = Game.Timer()
                    local priority = _gso.TS.Priorities[eName] ~= nil and _gso.TS.Priorities[eName] or 5
                    gso_menu.ts.priority:MenuElement({ id = eName, name = eName, value = priority, min = 1, max = 5, step = 1 })
                    if eName == "Teemo" then          self.isTeemo = true
                    elseif eName == "Kayle" then      _gso.TS.undyingBuffs["JudicatorIntervention"] = true
                    elseif eName == "Taric" then      _gso.TS.undyingBuffs["TaricR"] = true
                    elseif eName == "Kindred" then    _gso.TS.undyingBuffs["kindredrnodeathbuff"] = true
                    elseif eName == "Zilean" then     _gso.TS.undyingBuffs["ChronoShift"] = true; _gso.TS.undyingBuffs["chronorevive"] = true
                    elseif eName == "Tryndamere" then _gso.TS.undyingBuffs["UndyingRage"] = true
                    elseif eName == "Jax" then        _gso.TS.undyingBuffs["JaxCounterStrike"] = true
                    elseif eName == "Fiora" then      _gso.TS.undyingBuffs["FioraW"] = true
                    elseif eName == "Aatrox" then     _gso.TS.undyingBuffs["aatroxpassivedeath"] = true
                    elseif eName == "Vladimir" then   _gso.TS.undyingBuffs["VladimirSanguinePool"] = true
                    elseif eName == "KogMaw" then     _gso.TS.undyingBuffs["KogMawIcathianSurprise"] = true
                    elseif eName == "Karthus" then    _gso.TS.undyingBuffs["KarthusDeathDefiedBuff"] = true
                    end
                end
            end
        end
        if Game.Timer() > _gso.TS.lastFound + 5 and Game.Timer() < _gso.TS.lastFound + 10 then
            _gso.TS.loadedChamps = true
        end
    end
    
    if self.isTeemo == true then
        self.isBlinded = self:_checkTeemoBlind()
    end
    
    _gso.OB:_tick()
    _gso.Farm:_tick()
    
    local checkT  = Game.Timer()
    local ck      = gso_menu.orb.keys.combo:Value()
    local hk      = gso_menu.orb.keys.harass:Value()
    local lhk     = gso_menu.orb.keys.lastHit:Value()
    local lck     = gso_menu.orb.keys.laneClear:Value()
    
    _gso.Vars._onTick()
    
    local dActions = self.dActions
    local cDActions = 0
    for k,v in pairs(dActions) do
        cDActions = cDActions + 1
        if not v[3] and GetTickCount() - k > v[2] then
            v[1]()
            v[3] = true
        elseif v[3] and GetTickCount() - k > v[2] + 10 then
            self.dActions[k] = nil
        end
    end
    self.dActionsC = cDActions
    if self.dActionsC == 0 and Game.Timer() > self.lAttack + self.windUpT + 0.15 + _gso.Farm.latency + gso_menu.orb.delays.windup:Value()*0.001 then
        if ck and gso_menu.gsoitem.botrk:Value() and self.lastTarget then
            local botrkHK = _gso.Items:_botrk()
            if botrkHK then
                local targetPos = self.lastTarget.pos
                if _gso.OB:_getDistance(myHero.pos, targetPos) < 550 then
                    local cPos = cursorPos
                    Control.SetCursorPos(targetPos)
                    Control.KeyDown(botrkHK)
                    Control.KeyUp(botrkHK)
                    _gso.Items.lastBotrk = GetTickCount()
                    self.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    self.canAA = false
                    self.dActionsC = self.dActionsC + 1
                end
            end
        end
        _gso.Vars._castSpells()
        if self.dActionsC == 0 and checkT < self.lAttack + self.animT then
            _gso.Vars._castSpellsAA()
        end
    end
    if Game.IsChatOpen() == false and (ck or hk or lhk or lck) then
        local AAtarget = nil
        if ck then
            AAtarget = self:_comboT()
        elseif hk then
            AAtarget = self:_harassT()
        elseif lhk then
            AAtarget = self:_lastHitT()
        elseif lck then
            AAtarget = self:_laneClearT()
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
    for i = 1, #_gso.Vars._onDraw do
        _gso.Vars._onDraw[i]()
    end
    if not gso_menu.orb.draw.enable:Value() then return end
    local mePos = myHero.pos
    if gso_menu.orb.draw.me.enable:Value() and not myHero.dead and mePos:ToScreen().onScreen then
        Draw.Circle(mePos, myHero.range + myHero.boundingRadius + 35, gso_menu.orb.draw.me.width:Value(), gso_menu.orb.draw.me.color:Value())
    end
    if gso_menu.orb.draw.he.enable:Value() then
        local countEH = #_gso.OB.enemyHeroes
        for i = 1, countEH do
            local hero = _gso.OB.enemyHeroes[i]
            local heroPos = hero.pos
            if _gso.OB:_getDistance(mePos, heroPos) < 2000 and heroPos:ToScreen().onScreen then
                Draw.Circle(heroPos, hero.range + hero.boundingRadius + 35, gso_menu.orb.draw.he.width:Value(), gso_menu.orb.draw.he.color:Value())
            end
        end
    end
    if gso_menu.orb.draw.cpos.enable:Value() then
        Draw.Circle(mousePos, gso_menu.orb.draw.cpos.radius:Value(), gso_menu.orb.draw.cpos.width:Value(), gso_menu.orb.draw.cpos.color:Value())
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
    
    self.qBuffEndT = 0
    
    _gso.Vars:_setCastSpells(function() self:_castSpells() end)
    _gso.Vars:_setCastSpellsAA(function() self:_castSpellsAA() end)
    _gso.Vars:_setOnTick(function() self:_tick() end)
    _gso.Vars:_setBonusDmg(function() return self:_dmg() end)
    _gso.Vars:_setBonusDmgUnit(function(unit) return self:_dmgUnit(unit) end)
    _gso.Vars:_setCanMove(function() return self:_setCanMove() end)
    _gso.Vars:_setChampMenu(function() return self:_menu() end)
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------menu---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoAshe:_menu()
    gso_menu:MenuElement({id = "gsoashe", name = "Ashe", type = MENU, leftIcon = "https://i.imgur.com/WohLMsm.png"})
        gso_menu.gsoashe:MenuElement({id = "rdist", name = "use R if enemy distance < X", value = 500, min = 250, max = 1000, step = 50})
        gso_menu.gsoashe:MenuElement({id = "combo", name = "Combo", type = MENU})
            gso_menu.gsoashe.combo:MenuElement({id = "qc", name = "UseQ", value = true})
            gso_menu.gsoashe.combo:MenuElement({id = "wc", name = "UseW", value = true})
            gso_menu.gsoashe.combo:MenuElement({id = "rcd", name = "UseR [enemy distance < X", value = true})
            gso_menu.gsoashe.combo:MenuElement({id = "rci", name = "UseR [enemy IsImmobile]", value = true})
        gso_menu.gsoashe:MenuElement({id = "harass", name = "Harass", type = MENU})
            gso_menu.gsoashe.harass:MenuElement({id = "qh", name = "UseQ", value = true})
            gso_menu.gsoashe.harass:MenuElement({id = "wh", name = "UseW", value = true})
            gso_menu.gsoashe.harass:MenuElement({id = "rhd", name = "UseR [enemy distance < X]", value = false})
            gso_menu.gsoashe.harass:MenuElement({id = "rhi", name = "UseR [enemy IsImmobile]", value = false})
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------cast spells--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoAshe:_castSpells()
  
    local getTick = GetTickCount()
    
    local wMinus = getTick - self.lastW
    local rMinus = getTick - self.lastR
    
    local isCombo = gso_menu.orb.keys.combo:Value()
    local isHarass = gso_menu.orb.keys.harass:Value()
    
    local isComboW = isCombo and gso_menu.gsoashe.combo.wc:Value()
    local isHarassW = isHarass and gso_menu.gsoashe.harass.wh:Value()
    
    local isComboRd = isCombo and gso_menu.gsoashe.combo.rcd:Value()
    local isHarassRd = isHarass and gso_menu.gsoashe.harass.rhd:Value()
    
    local isComboRi = isCombo and gso_menu.gsoashe.combo.rcd:Value()
    local isHarassRi = isHarass and gso_menu.gsoashe.harass.rhd:Value()

    if rMinus > 2000 and wMinus > 350 and Game.CanUseSpell(_R) == 0 then
        local mePos = myHero.pos
        if isComboRd or isHarassRd then
            local t = nil
            local menuDist = gso_menu.gsoashe.rdist:Value()
            for i = 1, #_gso.OB.enemyHeroes do
                local hero = _gso.OB.enemyHeroes[i]
                local distance = _gso.OB:_getDistance(mePos, hero.pos)
                if _gso.TS:_valid(hero, false) and distance > 250 and distance < menuDist then
                    menuDist = distance
                    t = hero
                end
            end
            if t ~= nil then
                local sR = { delay = 0.25, range = 600, width = 125, speed = 1600, sType = "line", col = false }
                local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(t, sR.delay, sR.width*0.5, sR.range, sR.speed, mePos, sR.col, sR.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(mePos, castpos) < sR.range and _gso.OB:_getDistance(t.pos, castpos) < 500 then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    Control.KeyDown(HK_R)
                    Control.KeyUp(HK_R)
                    self.lastR = GetTickCount()
                    _gso.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    _gso.Orb.canAA = false
                    _gso.Orb.dActionsC = _gso.Orb.dActionsC + 1
                    return
                end
            end
        elseif isComboRi or isHarassRi then
            for i = 1, #_gso.OB.enemyHeroes do
                local hero = _gso.OB.enemyHeroes[i]
                local heroPos = hero.pos
                if _gso.TS:_valid(hero, false) and _gso.OB:_getDistance(mePos, heroPos) < 1000 and _gso.TS:_isImmobile(hero) then
                    local rPred = heroPos
                    if rPred and rPred:ToScreen().onScreen then
                        local cPos = cursorPos
                        Control.SetCursorPos(rPred)
                        Control.KeyDown(HK_R)
                        Control.KeyUp(HK_R)
                        self.lastR = GetTickCount()
                        _gso.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                        _gso.Orb.canAA = false
                        _gso.Orb.dActionsC = _gso.Orb.dActionsC + 1
                        return
                    end
                end
            end
        end
    end
    
    if wMinus > 2000 and rMinus > 350 and Game.CanUseSpell(_W) == 0 and (isComboW or isHarassW) then
        local aaTarget = _gso.TS:_getTarget(myHero.range, true, true)
        if aaTarget == nil then
            local target = _gso.TS:_getTarget(1200, false, false)
            if target ~= nil then
                local mePos = myHero.pos
                local sW = { delay = 0.25, range = 1200, width = 75, speed = 2000, sType = "line", col = true }
                local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, mePos, sW.col, sW.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(mePos, castpos) < sW.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    Control.KeyDown(HK_W)
                    Control.KeyUp(HK_W)
                    self.lastW = GetTickCount()
                    _gso.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    _gso.Orb.canAA = false
                    _gso.Orb.dActionsC = _gso.Orb.dActionsC + 1
                end
            end
        end
    end
end



--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------cast spells aa------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoAshe:_castSpellsAA()
  
    local getTick = GetTickCount()
    
    local qMinus = getTick - self.lastQ
    local wMinus = getTick - self.lastW
    local rMinus = getTick - self.lastR
    
    local isCombo = gso_menu.orb.keys.combo:Value()
    local isHarass = gso_menu.orb.keys.harass:Value()

    local isComboQ = isCombo and gso_menu.gsoashe.combo.qc:Value()
    local isHarassQ = isHarass and gso_menu.gsoashe.harass.qh:Value()
    
    local isComboW = isCombo and gso_menu.gsoashe.combo.wc:Value()
    local isHarassW = isHarass and gso_menu.gsoashe.harass.wh:Value()
    
    if (isComboQ or isHarassQ) and qMinus > 2000 then
        if Game.CanUseSpell(_Q) == 0 then
            Control.KeyDown(HK_Q)
            Control.KeyUp(HK_Q)
            self.lastQ = GetTickCount()
        end
    end
    
    if wMinus > 2000 and rMinus > 350 and Game.CanUseSpell(_W) == 0 and (isComboW or isHarassW) then
        local target = _gso.TS:_getTarget(1200, false, false)
        if target ~= nil then
            local mePos = myHero.pos
            local sW = { delay = 0.25, range = 1200, width = 150, speed = 2000, sType = "line", col = true }
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, mePos, sW.col, sW.sType)
            if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(mePos, castpos) < sW.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
                local cPos = cursorPos
                Control.SetCursorPos(castpos)
                Control.KeyDown(HK_W)
                Control.KeyUp(HK_W)
                self.lastW = GetTickCount()
                _gso.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                _gso.Orb.canAA = false
                _gso.Orb.dActionsC = _gso.Orb.dActionsC + 1
            end
        end
    end
end



--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------tick----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoAshe:_tick()
    
    --[[ ENABLE AA AFTER SPELLS ]]
    local checkTick = GetTickCount()
    local wMinus = checkTick - self.lastW
    local rMinus = checkTick - self.lastR
    local botrkMinus = checkTick - _gso.Items.lastBotrk
    if _gso.Orb.canAA == false and wMinus > 350 and rMinus > 350 and botrkMinus > 75 then
        _gso.Orb.canAA = true
    end
    
    --[[ RESET AA AFTER Q ]]
    local checkT = Game.Timer()
    if myHero:GetSpellData(_Q).level > 0 then
        for i = 1, myHero.buffCount do
            local buff = myHero:GetBuff(i)
            if buff and buff.count > 0 and buff.duration < 0.3 and buff.name:lower() == "asheqattack" then
                self.qBuffEndT = checkT
                break
            end
        end
    end

end



--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------set can move------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoAshe:_setCanMove()
    
    local result = true
    local checkT = Game.Timer()
    if checkT < self.qBuffEndT + _gso.Orb.windUpT + _gso.Orb.animT then
        result = checkT > _gso.Orb.endTime - (_gso.Orb.animT - _gso.Orb.windUpT)
    end
    return result
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------bonus dmg-------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoAshe:_dmg()
    return 3
end

function __gsoAshe:_dmgUnit(unit)
    local dmg = myHero.totalDamage
    local crit = 0.1 + myHero.critChance
    for i = 1, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == "ashepassiveslow" then
            local aacompleteT = myHero.attackData.windUpTime + (_gso.OB:_getDistance(myHero.pos, unit.pos) / myHero.attackData.projectileSpeed)
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
    
    self.lastW         = 0
    self.lastE         = 0
    self.eBuffs        = {}
    
    _gso.Vars:_setCastSpells(function() self:_castSpells() end)
    _gso.Vars:_setCastSpellsAA(function() self:_castSpellsAA() end)
    _gso.Vars:_setOnTick(function() self:_tick() end)
    _gso.Vars:_setBonusDmg(function() return self:_dmg() end)
    _gso.Vars:_setChampMenu(function() return self:_menu() end)
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------menu---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoTwitch:_menu()
    gso_menu:MenuElement({name = "Twitch", id = "gsotwitch", type = MENU, leftIcon = "https://i.imgur.com/tVpVF5L.png"})
        gso_menu.gsotwitch:MenuElement({name = "W settings", id = "wset", type = MENU })
            gso_menu.gsotwitch.wset:MenuElement({id = "stopult", name = "Stop if R", value = true})
            gso_menu.gsotwitch.wset:MenuElement({id = "combo", name = "Use W Combo", value = true})
            gso_menu.gsotwitch.wset:MenuElement({id = "harass", name = "Use W Harass", value = false})
        gso_menu.gsotwitch:MenuElement({name = "E settings", id = "eset", type = MENU })
            gso_menu.gsotwitch.eset:MenuElement({id = "combo", name = "Use E Combo", value = true})
            gso_menu.gsotwitch.eset:MenuElement({id = "harass", name = "Use E Harass", value = false})
            gso_menu.gsotwitch.eset:MenuElement({id = "stacks", name = "X stacks", value = 6, min = 1, max = 6, step = 1 })
            gso_menu.gsotwitch.eset:MenuElement({id = "enemies", name = "X enemies", value = 1, min = 1, max = 5, step = 1 })
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------cast spells--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoTwitch:_castSpells()
    
    local aaTarget = _gso.TS:_getTarget(myHero.range, true, true)
    if aaTarget ~= nil then
        return
    end
    
    self:_castSpellsAA()
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------cast spells aa------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoTwitch:_castSpellsAA()
    
    local getTick = GetTickCount()
    
    local wMinus = getTick - self.lastW
    local eMinus = getTick - self.lastE
    
    local isCombo = gso_menu.orb.keys.combo:Value()
    local isHarass = gso_menu.orb.keys.harass:Value()
    
    local isComboW = isCombo and gso_menu.gsotwitch.wset.combo:Value()
    local isHarassW = isHarass and gso_menu.gsotwitch.wset.harass:Value()
    
    local isComboE = isCombo and gso_menu.gsotwitch.eset.combo:Value()
    local isHarassE = isHarass and gso_menu.gsotwitch.eset.harass:Value()
    
    if eMinus > 1000 and wMinus > 350 and Game.CanUseSpell(_E) == 0 then
      
        --[[ KS ]]
        for i = 1, #_gso.OB.enemyHeroes do
            local hero  = _gso.OB.enemyHeroes[i]
            local nID   = hero.networkID
            if self.eBuffs[nID] and self.eBuffs[nID].count > 0 and _gso.TS:_valid(hero, false) and _gso.OB:_getDistance(myHero.pos, hero.pos) < 1200 then
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
                local CanKill = hero.health + hero.shieldAD + HPRegen < DmgDealt
                if CanKill then
                    Control.KeyDown(HK_E)
                    Control.KeyUp(HK_E)
                    self.lastE = GetTickCount()
                    _gso.Orb.canAA = false
                    return
                end
            end
        end
        
        --[[ COMBO/HARASS ]]
        if isComboE or isHarassE then 
            local xStacks   = gso_menu.gsotwitch.eset.stacks:Value()
            local xEnemies  = gso_menu.gsotwitch.eset.enemies:Value()
            local countE    = 0
            for i = 1, #_gso.OB.enemyHeroes do
                local hero = _gso.OB.enemyHeroes[i]
                if _gso.OB:_getDistance(myHero.pos, hero.pos) < 1200 and _gso.TS:_valid(hero, false) then
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
                _gso.Orb.canAA = false
                return
            end
        end
    end
    
    if (isComboW or isHarassW) and wMinus > 2000 and eMinus > 350 and Game.CanUseSpell(_W) == 0 then
        if gso_menu.gsotwitch.wset.stopult:Value() and GetTickCount() < _gso.TS.lastR + 5500 then
            return
        end
        local target = _gso.TS:_getTarget(950, false, false)
        if target ~= nil then
            local mePos = myHero.pos
            local sW = { delay = 0.25, range = 950, width = 275, speed = 1400, sType = "circular", col = false }
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, mePos, sW.col, sW.sType)
            if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(mePos, castpos) < sW.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
                local cPos = cursorPos
                Control.SetCursorPos(castpos)
                Control.KeyDown(HK_W)
                Control.KeyUp(HK_W)
                self.lastW = GetTickCount()
                _gso.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                _gso.Orb.canAA = false
                _gso.Orb.dActionsC = _gso.Orb.dActionsC + 1
            end
        end
    end
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------tick----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoTwitch:_tick()
    
    for i = 1, #_gso.OB.enemyHeroes do
        local hero  = _gso.OB.enemyHeroes[i]
        local nID   = hero.networkID
        if not self.eBuffs[nID] then
            self.eBuffs[nID] = { count = 0, durT = 0 }
        end
        if not hero.dead then
            local hasB = false
            local cB = self.eBuffs[nID].count
            local dB = self.eBuffs[nID].durT
            for i = 1, hero.buffCount do
                local buff = hero:GetBuff(i)
                if buff.count > 0 and buff.name:lower() == "twitchdeadlyvenom" then
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
    
    local checkTick = GetTickCount()
    
    local wMinus = checkTick - self.lastW
    local eMinus = checkTick - self.lastE
    local botrkMinus = checkTick - _gso.Items.lastBotrk
    if _gso.Orb.canAA == false and wMinus > 350 and eMinus > 350 and botrkMinus > 75 then
        _gso.Orb.canAA = true
    end
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------bonus dmg-------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoTwitch:_dmg()
    return 3
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

    _gso.TS.apDmg = true
    
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    
    _gso.Vars:_setCastSpells(function() self:_castSpells() end)
    _gso.Vars:_setCastSpellsAA(function() self:_castSpellsAA() end)
    _gso.Vars:_setBonusDmg(function() return self:_dmg() end)
    _gso.Vars:_setOnTick(function() self:_tick() end)
    _gso.Vars:_setChampMenu(function() return self:_menu() end)
end


--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------menu----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoKogMaw:_menu()
    gso_menu:MenuElement({name = "Kog'Maw", id = "gsokog", type = MENU, leftIcon = "https://i.imgur.com/PR2suYf.png"})
        gso_menu.gsokog:MenuElement({id = "onlast", name = "[combo] use spells on last attacked enemy", value = true})
        gso_menu.gsokog:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gso_menu.gsokog.qset:MenuElement({id = "combo", name = "Combo", value = true})
            gso_menu.gsokog.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gso_menu.gsokog:MenuElement({name = "W settings", id = "wset", type = MENU })
            gso_menu.gsokog.wset:MenuElement({id = "combo", name = "Combo", value = true})
            gso_menu.gsokog.wset:MenuElement({id = "harass", name = "Harass", value = false})
        gso_menu.gsokog:MenuElement({name = "E settings", id = "eset", type = MENU })
            gso_menu.gsokog.eset:MenuElement({id = "combo", name = "Combo", value = true})
            gso_menu.gsokog.eset:MenuElement({id = "harass", name = "Harass", value = false})
        gso_menu.gsokog:MenuElement({name = "R settings", id = "rset", type = MENU })
            gso_menu.gsokog.rset:MenuElement({id = "combo", name = "Combo", value = true})
            gso_menu.gsokog.rset:MenuElement({id = "harass", name = "Harass", value = false})
            gso_menu.gsokog.rset:MenuElement({id = "stack", name = "Stop at x stacks", value = 3, min = 1, max = 9, step = 1 })
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------buff manager-------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoKogMaw:_getBuffCount()
    local result = 0
    for i = 1, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == "kogmawlivingartillerycost" then
            return buff.count
        end
    end
    return result
end

function __gsoKogMaw:_hasBuff()
    local result = false
    for i = 1, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == "kogmawbioarcanebarrage" then
            return true
        end
    end
    return result
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------cast spells--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoKogMaw:_castSpells()
    
    local getTick = GetTickCount()
    
    local wMinus = getTick - self.lastW
    
    local isCombo   = gso_menu.orb.keys.combo:Value()
    local isHarass  = gso_menu.orb.keys.harass:Value()
    
    local isComboW   = isCombo and gso_menu.gsokog.wset.combo:Value()
    local isHarassW  = isHarass and gso_menu.gsokog.wset.harass:Value()
    
    if (isComboW or isHarassW) and wMinus > 1000 and Game.CanUseSpell(_W) == 0 then
        local isTarget = false
        for i = 1, #_gso.OB.enemyHeroes do
            local hero = _gso.OB.enemyHeroes[i]
            if _gso.TS:_valid(hero, true) and _gso.OB:_getDistance(myHero.pos, hero.pos) < 610 + ( 20 * myHero:GetSpellData(_W).level ) + myHero.boundingRadius + hero.boundingRadius then
                isTarget = true
                break
            end
        end
        if isTarget == true then
            Control.KeyDown(HK_W)
            Control.KeyUp(HK_W)
            self.lastW = GetTickCount()
            return
        end
    end
    
    if wMinus < 300 then
        return
    end
    
    local aaTarget = _gso.TS:_getTarget(myHero.range, true, true)
    if aaTarget ~= nil then
        return
    end
    
    self:_castSpellsAA()
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------cast spells aa------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoKogMaw:_castSpellsAA()
    
    local getTick = GetTickCount()
    
    local qMinus = getTick - self.lastQ
    local wMinus = getTick - self.lastW
    local eMinus = getTick - self.lastE
    local rMinus = getTick - self.lastR
    
    local isCombo = gso_menu.orb.keys.combo:Value()
    local isHarass = gso_menu.orb.keys.harass:Value()
    
    local isComboQ = isCombo and gso_menu.gsokog.qset.combo:Value()
    local isHarassQ = isHarass and gso_menu.gsokog.qset.harass:Value()
    
    local isComboE = isCombo and gso_menu.gsokog.eset.combo:Value()
    local isHarassE = isHarass and gso_menu.gsokog.eset.harass:Value()
    
    local isComboR = isCombo and gso_menu.gsokog.rset.combo:Value()
    local isHarassR = isHarass and gso_menu.gsokog.rset.harass:Value()
    
    local sQ = { delay = 0.25, range = 1175, width = 70, speed = 1650, sType = "line", col = true }
    local sE = { delay = 0.25, range = 1280, width = 120, speed = 1350, sType = "line", col = false }
    local sR = { delay = 1.2, range = 0, width = 225, speed = math.maxinteger, sType = "circular", col = false }
    
    if (isComboQ or isHarassQ) and qMinus > 2000 and eMinus > 400 and rMinus > 400 and Game.CanUseSpell(_Q) == 0 then
        local aaTarget = _gso.Orb.lastTarget
        local target = nil
        if gso_menu.gsokog.onlast:Value() and aaTarget ~= nil then
            target = aaTarget
        else
            target = _gso.TS:_getTarget(1175, false, false)
        end
        if target ~= nil then
            local mePos = myHero.pos
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, mePos, sQ.col, sQ.sType)
            if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(mePos, castpos) < sQ.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
                local cPos = cursorPos
                Control.SetCursorPos(castpos)
                Control.KeyDown(HK_Q)
                Control.KeyUp(HK_Q)
                self.lastQ = GetTickCount()
                _gso.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                _gso.Orb.canAA = false
                _gso.Orb.dActionsC = _gso.Orb.dActionsC + 1
                return
            end
        end
    end
    if (isComboE or isHarassE) and eMinus > 2000 and qMinus > 400 and rMinus > 400 and Game.CanUseSpell(_E) == 0 then
        local aaTarget = _gso.Orb.lastTarget
        local target = nil
        if gso_menu.gsokog.onlast:Value() and aaTarget ~= nil then
            target = aaTarget
        else
            target = _gso.TS:_getTarget(1280, false, false)
        end
        if target ~= nil then
            local mePos = myHero.pos
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sE.delay, sE.width*0.5, sE.range, sE.speed, mePos, sE.col, sE.sType)
            if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(mePos, castpos) < sE.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
                local cPos = cursorPos
                Control.SetCursorPos(castpos)
                Control.KeyDown(HK_E)
                Control.KeyUp(HK_E)
                self.lastE = GetTickCount()
                _gso.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                _gso.Orb.canAA = false
                _gso.Orb.dActionsC = _gso.Orb.dActionsC + 1
                return
            end
        end
    end
    if (isComboR or isHarassR) and rMinus > 700 and qMinus > 400 and eMinus > 400 and Game.CanUseSpell(_R) == 0 and self:_getBuffCount() < gso_menu.gsokog.rset.stack:Value() then
        sR.range = 900 + ( 300 * myHero:GetSpellData(_R).level )
        local aaTarget = _gso.Orb.lastTarget
        local target = nil
        if gso_menu.gsokog.onlast:Value() and aaTarget ~= nil then
            target = aaTarget
        else
            target = _gso.TS:_getTarget(sR.range + (sR.width*0.5), false, false)
        end
        if target ~= nil then
            local mePos = myHero.pos
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sR.delay, sR.width*0.5, sR.range, sR.speed, mePos, sR.col, sR.sType)
            if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(mePos, castpos) < sR.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
                local cPos = cursorPos
                Control.SetCursorPos(castpos)
                Control.KeyDown(HK_R)
                Control.KeyUp(HK_R)
                self.lastR = GetTickCount()
                _gso.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                _gso.Orb.canAA = false
                _gso.Orb.dActionsC = _gso.Orb.dActionsC + 1
            end
        end
    end
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------tick-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoKogMaw:_tick()
    
    local checkT = GetTickCount()
    
    local qMinus = checkT - self.lastQ
    local eMinus = checkT - self.lastE
    local rMinus = checkT - self.lastR
    local botrkMinus = checkTick - _gso.Items.lastBotrk
    
    if _gso.Orb.canAA == false and qMinus > 350 and eMinus > 350 and rMinus > 350 and botrkMinus > 75 then
        _gso.Orb.canAA = true
    end
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------bonus dmg-------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoKogMaw:_dmg()
    return 3
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
    
    _gso.Vars:_setCastSpells(function() self:_castSpells() end)
    _gso.Vars:_setCastSpellsAA(function() self:_castSpellsAA() end)
    _gso.Vars:_setBonusDmg(function() return self:_dmg() end)
    _gso.Vars:_setOnTick(function() self:_tick() end)
    _gso.Vars:_setMousePos(function() return self:_setMousePos() end)
    _gso.Vars:_setOnDraw(function() self:_draw() end)
    _gso.Vars:_setBeforeAA(function() self:_setBeforeAA() end)
    _gso.Vars:_setChampMenu(function() return self:_menu() end)
end


--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------menu----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoDraven:_menu()
    gso_menu:MenuElement({name = "Draven", id = "gsodraven", type = MENU, leftIcon = "https://i.imgur.com/U13x6xb.png"})
        gso_menu.gsodraven:MenuElement({name = "AXE settings", id = "aset", type = MENU })
            gso_menu.gsodraven.aset:MenuElement({id = "catch", name = "Catch axes", value = true})
            gso_menu.gsodraven.aset:MenuElement({id = "catcht", name = "stop under turret", value = true})
            gso_menu.gsodraven.aset:MenuElement({id = "catcho", name = "[combo] stop if no enemy in range", value = true})
            gso_menu.gsodraven.aset:MenuElement({name = "Distance", id = "dist", type = MENU })
                gso_menu.gsodraven.aset.dist:MenuElement({id = "mode", name = "Axe Mode", value = 1, drop = {"closest to mousePos", "closest to heroPos"} })
                gso_menu.gsodraven.aset.dist:MenuElement({id = "duration", name = "extra axe duration time", value = -300, min = -300, max = 0, step = 10 })
                gso_menu.gsodraven.aset.dist:MenuElement({id = "stopmove", name = "axePos in distance < X | Hold radius", value = 100, min = 75, max = 125, step = 5 })
                gso_menu.gsodraven.aset.dist:MenuElement({id = "cdist", name = "max distance from axePos to cursorPos", value = 750, min = 500, max = 1500, step = 50 })
                gso_menu.gsodraven.aset.dist:MenuElement({id = "hdist", name = "max distance from axePos to heroPos", value = 500, min = 250, max = 750, step = 50 })
                gso_menu.gsodraven.aset.dist:MenuElement({id = "enemyq", name = "stop if axe is near enemy - X dist", value = 125, min = 0, max = 250, step = 5 })
                gso_menu.gsodraven.aset.dist:MenuElement({id = "enemyhero", name = "stop if hero is near enemy - X dist", value = 250, min = 0, max = 500, step = 5 })
            gso_menu.gsodraven.aset:MenuElement({name = "Draw", id = "draw", type = MENU })
                gso_menu.gsodraven.aset.draw:MenuElement({name = "Enable",  id = "enable", value = true})
                gso_menu.gsodraven.aset.draw:MenuElement({name = "Good", id = "good", type = MENU })
                    gso_menu.gsodraven.aset.draw.good:MenuElement({name = "Color",  id = "color", color = Draw.Color(255, 49, 210, 0)})
                    gso_menu.gsodraven.aset.draw.good:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
                    gso_menu.gsodraven.aset.draw.good:MenuElement({name = "Radius",  id = "radius", value = 170, min = 50, max = 300, step = 10})
                gso_menu.gsodraven.aset.draw:MenuElement({name = "Bad", id = "bad", type = MENU })
                    gso_menu.gsodraven.aset.draw.bad:MenuElement({name = "Color",  id = "color", color = Draw.Color(255, 153, 0, 0)})
                    gso_menu.gsodraven.aset.draw.bad:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
                    gso_menu.gsodraven.aset.draw.bad:MenuElement({name = "Radius",  id = "radius", value = 170, min = 50, max = 300, step = 10})
        gso_menu.gsodraven:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gso_menu.gsodraven.qset:MenuElement({id = "combo", name = "Combo", value = true})
            gso_menu.gsodraven.qset:MenuElement({id = "harass", name = "Harass", value = false})
        gso_menu.gsodraven:MenuElement({name = "W settings", id = "wset", type = MENU })
            gso_menu.gsodraven.wset:MenuElement({id = "combo", name = "Combo", value = true})
            gso_menu.gsodraven.wset:MenuElement({id = "harass", name = "Harass", value = false})
            gso_menu.gsodraven.wset:MenuElement({id = "hdist", name = "max enemy distance", value = 750, min = 500, max = 2000, step = 50 })
        gso_menu.gsodraven:MenuElement({name = "E settings", id = "eset", type = MENU })
            gso_menu.gsodraven.eset:MenuElement({id = "combo", name = "Combo", value = true})
            gso_menu.gsodraven.eset:MenuElement({id = "harass", name = "Harass", value = false})
end




--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------cast spells--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoDraven:_castSpells()
    
    local getTick = GetTickCount()

    local qMinus = getTick - self.lastQ
    local wMinus = getTick - self.lastW
    local eMinus = getTick - self.lastE

    local isCombo = gso_menu.orb.keys.combo:Value()
    local isHarass = gso_menu.orb.keys.harass:Value()

    local isComboW = isCombo and gso_menu.gsodraven.wset.combo:Value()
    local isHarassW = isHarass and gso_menu.gsodraven.wset.harass:Value()

    local isComboE = isCombo and gso_menu.gsodraven.eset.combo:Value()
    local isHarassE = isHarass and gso_menu.gsodraven.eset.harass:Value()

    local isWReady = (isComboW or isHarassW) and wMinus > 1000 and qMinus > 250 and eMinus > 250 and Game.CanUseSpell(_W) == 0
    local isEReady = (isComboE or isHarassE) and eMinus > 2000 and qMinus > 250 and eMinus > 250 and Game.CanUseSpell(_E) == 0
    
    if isWReady or isEReady then
        local aaTarget = _gso.TS:_getTarget(myHero.range, true, true)
        if aaTarget == nil then
            if isWReady then
                local wTarget = _gso.TS:_getTarget(gso_menu.gsodraven.wset.hdist:Value(), false, false)
                if wTarget ~= nil then
                    Control.KeyDown(HK_W)
                    Control.KeyUp(HK_W)
                    self.lastW = GetTickCount()
                    _gso.Orb.canAA = false
                    return
                end
            end
            if isEReady then
                local target = _gso.TS:_getTarget(1050, false, false)
                if target ~= nil then
                    local sE = { delay = 0.25, range = 1050, width = 150, speed = 1400, sType = "line", col = false }
                    local mePos = myHero.pos
                    local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sE.delay, sE.width*0.5, sE.range, sE.speed, mePos, sE.col, sE.sType)
                    if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(mePos, castpos) < sE.range and _gso.OB:_getDistance(target.pos, castpos) < 250 then
                        local cPos = cursorPos
                        Control.SetCursorPos(castpos)
                        Control.KeyDown(HK_E)
                        Control.KeyUp(HK_E)
                        self.lastE = GetTickCount()
                        _gso.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                        _gso.Orb.canAA = false
                        _gso.Orb.dActionsC = _gso.Orb.dActionsC + 1
                    end
                end
            end
        end
    end
end



--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------cast spells aa------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoDraven:_castSpellsAA()
  
    local getTick = GetTickCount()
    
    local qMinus = getTick - self.lastQ
    local wMinus = getTick - self.lastW
    local eMinus = getTick - self.lastE
    
    local isCombo = gso_menu.orb.keys.combo:Value()
    local isHarass = gso_menu.orb.keys.harass:Value()

    local isComboQ = isCombo and gso_menu.gsodraven.qset.combo:Value()
    local isHarassQ = isHarass and gso_menu.gsodraven.qset.harass:Value()
    
    local isComboW = isCombo and gso_menu.gsodraven.wset.combo:Value()
    local isHarassW = isHarass and gso_menu.gsodraven.wset.harass:Value()
    
    local isComboE = isCombo and gso_menu.gsodraven.eset.combo:Value()
    local isHarassE = isHarass and gso_menu.gsodraven.eset.harass:Value()
    
    if (isComboQ or isHarassQ) and qMinus > 1000 and wMinus > 250 and eMinus > 250 and Game.CanUseSpell(_Q) == 0 then
        Control.KeyDown(HK_Q)
        Control.KeyUp(HK_Q)
        self.lastQ = GetTickCount()
    end
    
    if (isComboW or isHarassW) and wMinus > 1000 and qMinus > 250 and eMinus > 250 and Game.CanUseSpell(_W) == 0 then
        Control.KeyDown(HK_W)
        Control.KeyUp(HK_W)
        self.lastW = GetTickCount()
        _gso.Orb.canAA = false
    end
    
    if (isComboE or isHarassE) and eMinus > 2000 and qMinus > 250 and eMinus > 250 and Game.CanUseSpell(_E) == 0 then
        local target = _gso.TS:_getTarget(1100, false, false)
        if target ~= nil then
            local sE = { delay = 0.25, range = 1050, width = 150, speed = 1400, sType = "line", col = false }
            local mePos = myHero.pos
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sE.delay, sE.width*0.5, sE.range, sE.speed, mePos, sE.col, sE.sType)
            if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(mePos, castpos) < sE.range and _gso.OB:_getDistance(target.pos, castpos) < 250 then
                local cPos = cursorPos
                Control.SetCursorPos(castpos)
                Control.KeyDown(HK_E)
                Control.KeyUp(HK_E)
                self.lastE = GetTickCount()
                _gso.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                _gso.Orb.canAA = false
                _gso.Orb.dActionsC = _gso.Orb.dActionsC + 1
            end
        end
    end
end




--------------------|---------------------------------------------------------|--------------------
--------------------|----------------------before aa--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoDraven:_setBeforeAA()
  
    local getTick = GetTickCount()
    
    local qMinus = getTick - self.lastQ
    local wMinus = getTick - self.lastW
    local eMinus = getTick - self.lastE
    
    local isCombo = gso_menu.orb.keys.combo:Value()
    local isHarass = gso_menu.orb.keys.harass:Value()

    local isComboQ = isCombo and gso_menu.gsodraven.qset.combo:Value()
    local isHarassQ = isHarass and gso_menu.gsodraven.qset.harass:Value()
    
    if (isComboQ or isHarassQ) and qMinus > 1000 and wMinus > 250 and eMinus > 250 and Game.CanUseSpell(_Q) == 0 then
        Control.KeyDown(HK_Q)
        Control.KeyUp(HK_Q)
        self.lastQ = GetTickCount()
    end
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------tick-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoDraven:_tick()
  
    local checkT = GetTickCount()
    
    local wMinus = checkT - self.lastW
    local eMinus = checkT - self.lastE
    local botrkMinus = checkTick - _gso.Items.lastBotrk
    
    if _gso.Orb.canAA == false and wMinus > 100 and eMinus > 350 and botrkMinus > 75 then
        _gso.Orb.canAA = true
    end
    
    local mePos = myHero.pos
    for i = 1, Game.ParticleCount() do
        local particle = Game.Particle(i)
        if particle then
            local particlePos = particle.pos
            if _gso.OB:_getDistance(mePos, particlePos) < 500 and particle.name == "Draven_Base_Q_reticle" then
                local particleID = particle.handle
                if not self.qParticles[particleID] then
                    self.qParticles[particleID] = { pos = particlePos, tick = GetTickCount(), success = false, active = false }
                    _gso.Orb.lMove = 0
                end
            end
        end
    end
    
    for k,v in pairs(self.qParticles) do
        local timerMinus = GetTickCount() - v.tick
        local numMenu = 1200 + gso_menu.gsodraven.aset.dist.duration:Value()
        if not v.success and timerMinus > numMenu then
            self.qParticles[k].success = true
            _gso.Orb.lMove = 0
        end
        if timerMinus > numMenu and timerMinus < numMenu + 100 then
            _gso.Orb.lMove = 0
        end
        if timerMinus > 2000 then
            self.qParticles[k] = nil
        end
    end
    
end


--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------set mouse pos------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoDraven:_setMousePos()
    
    local qPos = nil
    local canCatch    = gso_menu.gsodraven.aset.catch:Value()
    local stopCatchT  = gso_menu.gsodraven.aset.catcht:Value()
    local stopCatchO  = gso_menu.gsodraven.aset.catcho:Value()
    local stopmove    = gso_menu.gsodraven.aset.dist.stopmove:Value()
    local kID         = nil
    if canCatch then
        local qMode = gso_menu.gsodraven.aset.dist.mode:Value()
        local hdist = gso_menu.gsodraven.aset.dist.hdist:Value()
        local cdist = gso_menu.gsodraven.aset.dist.cdist:Value()
        local num = 1000000000
        for k,v in pairs(self.qParticles) do
            if not v.success then
                local mePos = myHero.pos
                local distanceToHero = v.pos:DistanceTo(mePos)
                local distanceToMouse = v.pos:DistanceTo(mousePos)
                if distanceToHero < hdist and distanceToMouse < cdist then
                    local canContinue = true
                    local eQMenu = gso_menu.gsodraven.aset.dist.enemyq:Value()
                    local eHeroMenu = gso_menu.gsodraven.aset.dist.enemyhero:Value()
                    if eQMenu > 0 then
                        local cEM = #_gso.OB.enemyMinions
                        for i = 1, cEM do
                            local minion = _gso.OB.enemyMinions[i]
                            if _gso.OB:_getDistance(v.pos, minion.pos) < eQMenu then
                                canContinue = false
                                break
                            end
                        end
                    end
                    local countInRange = 0
                    local cEH = #_gso.OB.enemyHeroes
                    local isCombo = gso_menu.orb.keys.combo:Value()
                    for i = 1, cEH do
                        local hero = _gso.OB.enemyHeroes[i]
                        local heroPos = hero.pos
                        if eQMenu > 0 and _gso.OB:_getDistance(v.pos, heroPos) < eQMenu then
                            canContinue = false
                            break
                        end
                        local distToHero = _gso.OB:_getDistance(mePos, heroPos)
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
                            _gso.Orb.lMove = 0
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
            local cET = #_gso.OB.enemyTurrets
            for i=1, cET do
                local turret = _gso.OB.enemyTurrets[i]
                if _gso.OB:_getDistance(qPos, turret.pos) < 775 + turret.boundingRadius then
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
    
    if gso_menu.gsodraven.aset.catch:Value() and gso_menu.gsodraven.aset.draw.enable:Value() then
        for k,v in pairs(self.qParticles) do
            if not v.success then
                if v.active then
                    Draw.Circle(v.pos, gso_menu.gsodraven.aset.draw.good.radius:Value(), gso_menu.gsodraven.aset.draw.good.width:Value(), gso_menu.gsodraven.aset.draw.good.color:Value())
                else
                    Draw.Circle(v.pos, gso_menu.gsodraven.aset.draw.bad.radius:Value(), gso_menu.gsodraven.aset.draw.bad.width:Value(), gso_menu.gsodraven.aset.draw.bad.color:Value())
                end
            end
        end
    end
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------bonus dmg-------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoDraven:_dmg()
    return 3
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
    
    self.res    = Game.Resolution()
    self.resX   = self.res.x
    self.resY   = self.res.y
    
    self.lastQ    = 0
    self.lastW    = 0
    self.lastE    = 0
    self.delayedE = nil
    
    self.shouldWaitT    = 0
    self.shouldWait     = false
    
    _gso.Vars:_setCastSpells(function() self:_castSpells() end)
    _gso.Vars:_setCastSpellsAA(function() self:_castSpellsAA() end)
    _gso.Vars:_setOnTick(function() self:_tick() end)
    _gso.Vars:_setBonusDmg(function() return self:_dmg() end)
    _gso.Vars:_setOnDraw(function() self:_draw() end)
    _gso.Vars:_setChampMenu(function() return self:_menu() end)
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------menu---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoEzreal:_menu()
    gso_menu:MenuElement({name = "Ezreal", id = "gsoezreal", type = MENU, leftIcon = "https://i.imgur.com/OURoL03.png"})
        gso_menu.gsoezreal:MenuElement({name = "Auto Q", id = "autoq", type = MENU })
            gso_menu.gsoezreal.autoq:MenuElement({id = "enable", name = "Enable", value = true, key = string.byte("T"), toggle = true})
            gso_menu.gsoezreal.autoq:MenuElement({id = "mana", name = "Q Auto min. mana percent", value = 50, min = 0, max = 100, step = 1 })
            gso_menu.gsoezreal.autoq:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            gso_menu.gsoezreal.autoq:MenuElement({id = "draw", name = "Draw Text", value = true})
            gso_menu.gsoezreal.autoq:MenuElement({name = "Text Settings", id = "textset", type = MENU })
                gso_menu.gsoezreal.autoq.textset:MenuElement({id = "size", name = "Text Size", value = 25, min = 1, max = 64, step = 1 })
                gso_menu.gsoezreal.autoq.textset:MenuElement({id = "custom", name = "Custom Position", value = false})
                gso_menu.gsoezreal.autoq.textset:MenuElement({id = "posX", name = "Text Position Width", value = self.resX * 0.5 - 150, min = 1, max = self.resX, step = 1 })
                gso_menu.gsoezreal.autoq.textset:MenuElement({id = "posY", name = "Text Position Height", value = self.resY * 0.5, min = 1, max = self.resY, step = 1 })
        gso_menu.gsoezreal:MenuElement({name = "Q settings", id = "qset", type = MENU })
            gso_menu.gsoezreal.qset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            gso_menu.gsoezreal.qset:MenuElement({id = "combo", name = "Combo", value = true})
            gso_menu.gsoezreal.qset:MenuElement({id = "harass", name = "Harass", value = false})
            gso_menu.gsoezreal.qset:MenuElement({id = "laneclear", name = "LaneClear", value = false})
            gso_menu.gsoezreal.qset:MenuElement({id = "lasthit", name = "LastHit", value = true})
            gso_menu.gsoezreal.qset:MenuElement({id = "qlh", name = "Q LastHit min. mana percent", value = 10, min = 0, max = 100, step = 1 })
            gso_menu.gsoezreal.qset:MenuElement({id = "qlc", name = "Q LaneClear min. mana percent", value = 50, min = 0, max = 100, step = 1 })
        gso_menu.gsoezreal:MenuElement({name = "W settings", id = "wset", type = MENU })
            gso_menu.gsoezreal.wset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
            gso_menu.gsoezreal.wset:MenuElement({id = "combo", name = "Combo", value = true})
            gso_menu.gsoezreal.wset:MenuElement({id = "harass", name = "Harass", value = false})
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------cast spells--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoEzreal:_castSpells()
    
    local aaTarget = _gso.TS:_getTarget(myHero.range, true, true)
    if aaTarget ~= nil then
        return
    end
    
    self:_castSpellsAA()
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------cast spells aa------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoEzreal:_castSpellsAA()
    
    local getTick = GetTickCount()
    
    local qMinus = getTick - self.lastQ
    local wMinus = getTick - self.lastW
    
    local isCombo = gso_menu.orb.keys.combo:Value()
    local isHarass = gso_menu.orb.keys.harass:Value()
    
    local isComboQ = isCombo and gso_menu.gsoezreal.qset.combo:Value()
    local isHarassQ = isHarass and gso_menu.gsoezreal.qset.harass:Value()
    
    local isComboW = isCombo and gso_menu.gsoezreal.wset.combo:Value()
    local isHarassW = isHarass and gso_menu.gsoezreal.wset.harass:Value()
    
    if (isComboQ or isHarassQ) and qMinus > 1000 and wMinus > 350 and Game.CanUseSpell(_Q) == 0 then
        local target = _gso.TS:_getTarget(1150, true, false)
        if target ~= nil then
            local sQ = { delay = 0.25, range = 1150, width = 60, speed = 2000, sType = "line", col = true }
            local mePos = myHero.pos
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, mePos, sQ.col, sQ.sType)
            if HitChance > gso_menu.gsoezreal.qset.hitchance:Value()-1 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(mePos, castpos) < sQ.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
                local cPos = cursorPos
                Control.SetCursorPos(castpos)
                Control.KeyDown(HK_Q)
                Control.KeyUp(HK_Q)
                self.lastQ = GetTickCount()
                _gso.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                _gso.Orb.canAA = false
                _gso.Orb.dActionsC = _gso.Orb.dActionsC + 1
                return
            end
        end
    end
    
    if (isComboW or isHarassW) and wMinus > 1000 and qMinus > 350 and Game.CanUseSpell(_W) == 0 then
        local target = _gso.TS:_getTarget(1000, false, false)
        if target ~= nil then
            local mePos = myHero.pos
            local sW = { delay = 0.25, range = 1150, width = 80, speed = 1550, sType = "line", col = false }
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, mePos, sW.col, sW.sType)
            if HitChance > gso_menu.gsoezreal.wset.hitchance:Value()-1 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(mePos, castpos) < sW.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
                local cPos = cursorPos
                Control.SetCursorPos(castpos)
                Control.KeyDown(HK_W)
                Control.KeyUp(HK_W)
                self.lastW = GetTickCount()
                _gso.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                _gso.Orb.canAA = false
                _gso.Orb.dActionsC = _gso.Orb.dActionsC + 1
                return
            end
        end
    end
    
end

function __gsoEzreal:_castQ(t, tPos, mePos)
    local sQ = { delay = 0.25, range = 1150, width = 60, speed = 2000, sType = "line", col = true }
    local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(t, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, mePos, sQ.col, sQ.sType)
    if HitChance > gso_menu.gsoezreal.qset.hitchance:Value()-1 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(mePos, castpos) < sQ.range and _gso.OB:_getDistance(tPos, castpos) < 500 then
        local cPos = cursorPos
        Control.SetCursorPos(castpos)
        Control.KeyDown(HK_Q)
        Control.KeyUp(HK_Q)
        self.lastQ = GetTickCount()
        _gso.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
        _gso.Orb.canAA = false
        _gso.Orb.dActionsC = _gso.Orb.dActionsC + 1
        return true
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------tick----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoEzreal:_tick()
    
    local checkTick = GetTickCount()
    
    local qMinus = checkTick - self.lastQ
    local wMinus = checkTick - self.lastW
    local eMinus = checkTick - self.lastE
    local botrkMinus = checkTick - _gso.Items.lastBotrk
    
    if _gso.Orb.canAA == false and qMinus > 350 and wMinus > 350 and eMinus > 350 and botrkMinus > 75 then
        _gso.Orb.canAA = true
    end
    
    if checkTick > self.lastE + 1000 then
        local dActions = _gso.TS.delayedSpell
        for k,v in pairs(dActions) do
            if k == 2 then
                if _gso.Orb.dActionsC == 0 then
                    v[1]()
                    _gso.Orb.dActions[GetTickCount()] = { function() return 0 end, 50 }
                    _gso.Orb.canAA = false
                    _gso.Orb.dActionsC = _gso.Orb.dActionsC + 1
                    self.lastE = GetTickCount()
                    _gso.TS.delayedSpell[k] = nil
                    break
                end
                if GetTickCount() - v[2] > 125 then
                    _gso.TS.delayedSpell[k] = nil
                end
                break
            end
        end
    end
    if qMinus > 1000 and _gso.Orb.dActionsC == 0 and Game.Timer() > _gso.Orb.lAttack + _gso.Orb.windUpT + 0.15 + _gso.Farm.latency + gso_menu.orb.delays.windup:Value()*0.001 and wMinus > 350 and Game.CanUseSpell(_Q) == 0 then
      
        local manaPercent = 100 * myHero.mana / myHero.maxMana
      
        local isAutoQ = gso_menu.gsoezreal.autoq.enable:Value() and manaPercent > gso_menu.gsoezreal.autoq.mana:Value()
        local isCombo = gso_menu.orb.keys.combo:Value()
        local isHarass = gso_menu.orb.keys.harass:Value()
        local meRange = myHero.range + myHero.boundingRadius
        
        if isAutoQ and not isCombo and not isHarass then
            local canCheckT = false
            for i = 1, #_gso.OB.enemyHeroes do
                local unit = _gso.OB.enemyHeroes[i]
                local unitPos = unit.pos
                local mePos = myHero.pos
                if _gso.OB:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                    canCheckT = true
                    break
                end
            end
            if not canCheckT or (canCheckT and Game.Timer() < _gso.Orb.lAttack + _gso.Orb.animT) then
                for i = 1, #_gso.OB.enemyHeroes do
                    local unit = _gso.OB.enemyHeroes[i]
                    local unitPos = unit.pos
                    local mePos = myHero.pos
                    local distance = _gso.OB:_getDistance(mePos, unitPos)
                    if _gso.TS:_valid(unit, true) and distance < 1150 then
                        local sQ = { delay = 0.25, range = 1150, width = 60, speed = 2000, sType = "line", col = true }
                        local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(unit, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, mePos, sQ.col, sQ.sType)
                        if HitChance > gso_menu.gsoezreal.autoq.hitchance:Value()-1 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(mePos, castpos) < sQ.range and _gso.OB:_getDistance(unitPos, castpos) < 500 then
                            local cPos = cursorPos
                            Control.SetCursorPos(castpos)
                            Control.KeyDown(HK_Q)
                            Control.KeyUp(HK_Q)
                            self.lastQ = GetTickCount()
                            _gso.Orb.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                            _gso.Orb.canAA = false
                            _gso.Orb.dActionsC = _gso.Orb.dActionsC + 1
                            return
                        end
                    end
                end
            end
        end
        
        local isLH = gso_menu.gsoezreal.qset.lasthit:Value() and (gso_menu.orb.keys.lastHit:Value() or gso_menu.orb.keys.harass:Value())
        local isLC = gso_menu.gsoezreal.qset.laneclear:Value() and gso_menu.orb.keys.laneClear:Value()
        if isLH or isLC then
          
            local canLH = manaPercent > gso_menu.gsoezreal.qset.qlh:Value()
            local canLC = manaPercent > gso_menu.gsoezreal.qset.qlc:Value()
            
            if not canLH and not canLC then return end
            
            if self.shouldWait == true and Game.Timer() > self.shouldWaitT + 0.5 then
                self.shouldWait = false
            end
            
            local almostLH = false
            local laneClearT = {}
            local lastHitT = {}
            
            -- [[ set enemy minions ]]
            local mLH = gso_menu.orb.delays.lhDelay:Value()*0.001
            for i = 1, #_gso.OB.enemyMinions do
                local eMinion = _gso.OB.enemyMinions[i]
                local eMinion_handle	= eMinion.handle
                local eMinion_health	= eMinion.health
                local myHero_aaData		= myHero.attackData
                local myHero_pFlyTime	= _gso.OB:_getDistance(myHero.pos, eMinion.pos) / 2000
                for k1,v1 in pairs(_gso.Farm.aAttacks) do
                    for k2,v2 in pairs(_gso.Farm.aAttacks[k1]) do
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
                    if eMinion.health - _gso.Farm:_possibleDmg(eMinion, 2.5) - myHero_dmg < 0 then
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
                    local checkT = Game.Timer() < _gso.Orb.LHTimers[4].tick
                    local mHandle = unit.handle
                    if not checkT or (checkT and _gso.Orb.LHTimers[4].id ~= mHandle) then
                        if _gso.OB:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                            canCheckT = true
                            break
                        end
                    end
                end
                if not canCheckT or (canCheckT and Game.Timer() < _gso.Orb.lAttack + _gso.Orb.animT) then
                    for i = 1, #lastHitT do
                        local minion = lastHitT[i]
                        local minionPos = minion.pos
                        local mePos = myHero.pos
                        local checkT = Game.Timer() < _gso.Orb.LHTimers[4].tick
                        local mHandle = minion.handle
                        if not checkT or (checkT and _gso.Orb.LHTimers[4].id ~= mHandle) then
                            local distance = _gso.OB:_getDistance(mePos, minionPos)
                            if distance < 1150 and self:_castQ(minion, minionPos, mePos) then
                                _gso.Orb.LHTimers[0].tick = Game.Timer() + 0.75
                                _gso.Orb.LHTimers[0].id = mHandle
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
                    local checkT = Game.Timer() < _gso.Orb.LHTimers[4].tick
                    local mHandle = unit.handle
                    if not checkT or (checkT and _gso.Orb.LHTimers[4].id ~= mHandle) then
                        if _gso.OB:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                            canCheckT = true
                            break
                        end
                    end
                end
                if not canCheckT or (canCheckT and Game.Timer() < _gso.Orb.lAttack + _gso.Orb.animT) then
                    for i = 1, #lastHitT do
                        local minion = lastHitT[i]
                        local minionPos = minion.pos
                        local mePos = myHero.pos
                        local checkT = Game.Timer() < _gso.Orb.LHTimers[4].tick
                        local mHandle = minion.handle
                        if not checkT or (checkT and _gso.Orb.LHTimers[4].id ~= mHandle) then
                            local distance = _gso.OB:_getDistance(mePos, minionPos)
                            if distance < 1150 and self:_castQ(minion, minionPos, mePos) then
                                _gso.Orb.LHTimers[0].tick = Game.Timer() + 0.75
                                _gso.Orb.LHTimers[0].id = mHandle
                                return
                            end
                        end
                    end
                end
                if not almostLH and not self.shouldWait then
                    canCheckT = false
                    for i = 1, #_gso.OB.enemyHeroes do
                        local unit = _gso.OB.enemyHeroes[i]
                        local unitPos = unit.pos
                        local mePos = myHero.pos
                        if _gso.OB:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                            canCheckT = true
                            break
                        end
                    end
                    if not canCheckT or (canCheckT and Game.Timer() < _gso.Orb.lAttack + _gso.Orb.animT) then
                        for i = 1, #_gso.OB.enemyHeroes do
                            local unit = _gso.OB.enemyHeroes[i]
                            local unitPos = unit.pos
                            local mePos = myHero.pos
                            local distance = _gso.OB:_getDistance(mePos, unitPos)
                            if _gso.TS:_valid(unit, true) and distance < 1150 and self:_castQ(unit, unitPos, mePos) then return end
                        end
                    end
                    canCheckT = false
                    for i = 1, #laneClearT do
                        local unit = laneClearT[i]
                        local unitPos = unit.pos
                        local mePos = myHero.pos
                        if _gso.OB:_getDistance(mePos, unitPos) < meRange + unit.boundingRadius then
                            canCheckT = true
                            break
                        end
                    end
                    if not canCheckT or (canCheckT and Game.Timer() < _gso.Orb.lAttack + _gso.Orb.animT) then
                        for i = 1, #laneClearT do
                            local minion = laneClearT[i]
                            local minionPos = minion.pos
                            local mePos = myHero.pos
                            local distance = _gso.OB:_getDistance(myHero.pos, minionPos)
                            if distance < 1150 and self:_castQ(minion, minionPos, mePos) then return end
                        end
                    end
                end
            end
        end
    end
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------draw-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoEzreal:_draw()
    
    if gso_menu.gsoezreal.autoq.draw:Value() then
        local mePos = myHero.pos:To2D()
        local isCustom = gso_menu.gsoezreal.autoq.textset.custom:Value()
        local posX = isCustom and gso_menu.gsoezreal.autoq.textset.posX:Value() or mePos.x - 50
        local posY = isCustom and gso_menu.gsoezreal.autoq.textset.posY:Value() or mePos.y
        if gso_menu.gsoezreal.autoq.enable:Value() then
            Draw.Text("Auto Q Enabled", gso_menu.gsoezreal.autoq.textset.size:Value(), posX, posY, Draw.Color(255, 000, 255, 000)) 
        else
            Draw.Text("Auto Q Disabled", gso_menu.gsoezreal.autoq.textset.size:Value(), posX, posY, Draw.Color(255, 255, 000, 000)) 
        end
    end
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------bonus dmg-------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoEzreal:_dmg()
    return 3
end












--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------ONLOAD-------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function OnLoad()
    gso_menu = MenuElement({name = "Gamsteron AIO", id = "gsoMenuAIO", type = MENU, leftIcon = "https://i.imgur.com/tm7UwiG.png"})
        gso_menu:MenuElement({name = "Target Selector", id = "ts", type = MENU, leftIcon = "https://i.imgur.com/vzoiheQ.png"})
            gso_menu.ts:MenuElement({ id = "Mode", name = "Mode", value = 1, drop = { "Auto", "Closest", "Least Health", "Least Priority" } })
            gso_menu.ts:MenuElement({ id = "priority", name = "Priorities", type = MENU })
            gso_menu.ts:MenuElement({ id = "selected", name = "Selected Target", type = MENU })
                gso_menu.ts.selected:MenuElement({ id = "enable", name = "Enable", value = true })
                gso_menu.ts.selected:MenuElement({ id = "only", name = "Only Selected Target", value = false })
                gso_menu.ts.selected:MenuElement({name = "Draw",  id = "draw", type = MENU})
                    gso_menu.ts.selected.draw:MenuElement({name = "Enable",  id = "enable", value = true})
                    gso_menu.ts.selected.draw:MenuElement({name = "Color",  id = "color", color = Draw.Color(255, 204, 0, 0)})
                    gso_menu.ts.selected.draw:MenuElement({name = "Width",  id = "width", value = 3, min = 1, max = 10})
                    gso_menu.ts.selected.draw:MenuElement({name = "Radius",  id = "radius", value = 150, min = 1, max = 300})
        gso_menu:MenuElement({name = "Orbwalker", id = "orb", type = MENU, leftIcon = "https://i.imgur.com/kPzTQDw.png"})
            gso_menu.orb:MenuElement({name = "Delays", id = "delays", type = MENU})
                gso_menu.orb.delays:MenuElement({name = "WindUp Delay", id = "windup", value = 0, min = 0, max = 100, step = 5 })
                gso_menu.orb.delays:MenuElement({name = "lasthit delay", id = "lhDelay", value = 0, min = 0, max = 50, step = 5 })
                gso_menu.orb.delays:MenuElement({name = "Humanizer", id = "humanizer", value = 200, min = 0, max = 300, step = 10 })
            gso_menu.orb:MenuElement({name = "Keys", id = "keys", type = MENU})
                gso_menu.orb.keys:MenuElement({name = "Combo Key", id = "combo", key = string.byte(" ")})
                gso_menu.orb.keys:MenuElement({name = "Harass Key", id = "harass", key = string.byte("C")})
                gso_menu.orb.keys:MenuElement({name = "LastHit Key", id = "lastHit", key = string.byte("X")})
                gso_menu.orb.keys:MenuElement({name = "LaneClear Key", id = "laneClear", key = string.byte("V")})
            gso_menu.orb:MenuElement({name = "Drawings", id = "draw", type = MENU})
                gso_menu.orb.draw:MenuElement({name = "Enable", id = "enable", value = true})
                gso_menu.orb.draw:MenuElement({name = "MyHero attack range", id = "me", type = MENU})
                    gso_menu.orb.draw.me:MenuElement({name = "Enable",  id = "enable", value = true})
                    gso_menu.orb.draw.me:MenuElement({name = "Color",  id = "color", color = Draw.Color(150, 49, 210, 0)})
                    gso_menu.orb.draw.me:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
                gso_menu.orb.draw:MenuElement({name = "Enemy attack range", id = "he", type = MENU})
                    gso_menu.orb.draw.he:MenuElement({name = "Enable",  id = "enable", value = true})
                    gso_menu.orb.draw.he:MenuElement({name = "Color",  id = "color", color = Draw.Color(150, 255, 0, 0)})
                    gso_menu.orb.draw.he:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
                gso_menu.orb.draw:MenuElement({name = "Cursor Posistion",  id = "cpos", type = MENU})
                    gso_menu.orb.draw.cpos:MenuElement({name = "Enable",  id = "enable", value = true})
                    gso_menu.orb.draw.cpos:MenuElement({name = "Color",  id = "color", color = Draw.Color(150, 153, 0, 76)})
                    gso_menu.orb.draw.cpos:MenuElement({name = "Width",  id = "width", value = 5, min = 1, max = 10})
                    gso_menu.orb.draw.cpos:MenuElement({name = "Radius",  id = "radius", value = 250, min = 1, max = 300})
        gso_menu:MenuElement({name = "Items", id = "gsoitem", type = MENU, leftIcon = "https://i.imgur.com/nMg6NAA.png"})
            gso_menu.gsoitem:MenuElement({name = "", id = "botrk", leftIcon = "https://i.imgur.com/xSE3Kc0.png", value = true})

    _gso.Items = __gsoItems()
    _gso.OB = __gsoOB()
    _gso.TS = __gsoTS()
    _gso.Farm = __gsoFarm()
    _gso.TPred = __gsoTPred()
    _gso.Orb = __gsoOrb()
    if _G.Orbwalker then
        GOS.BlockMovement = true
        GOS.BlockAttack = true
        _G.Orbwalker.Enabled:Value(false)
    end
    if _G.SDK and _G.SDK.Orbwalker then
        _G.SDK.Orbwalker:SetMovement(false)
        _G.SDK.Orbwalker:SetAttack(false)
        _G.SDK.Orbwalker.Menu.Enabled:Value(false)
    end
    if _G.EOW then
        _G.EOW:SetMovements(false)
        _G.EOW:SetAttacks(false)
    end
    if _gso.Vars.hName == "Ashe" then
        __gsoAshe()
    elseif _gso.Vars.hName == "Twitch" then
        __gsoTwitch()
    elseif _gso.Vars.hName == "KogMaw" then
        __gsoKogMaw()
    elseif _gso.Vars.hName == "Draven" then
        __gsoDraven()
    elseif _gso.Vars.hName == "Ezreal" then
        __gsoEzreal()
    end
    _gso.Vars._champMenu()
    print("gamsteronAIO ".._gso.Vars.version.." | loaded!")
end
