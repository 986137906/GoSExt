
local GetTickCount = GetTickCount
local Game = Game
local myHero = myHero
local Control = Control
local math = math
local Vector = Vector
local Draw = Draw

_gso = {
  Vars = nil,
  OB = nil,
  TS = nil,
  Farm = nil,
  TPred = nil,
  Orb = nil
}



--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------VARIABLES---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

class "__gsoVars"



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------init---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoVars:__init()
    
    self.version = "0.47"
    
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

function __gsoVars:_setOnDraw(func)
    self._onDraw[#self._onDraw+1] = func
end

function __gsoVars:_setBonusDmg(func)
    self._bonusDmg = func
end

function __gsoVars:_setBonusDmgUnit(func)
    self._bonusDmgUnit = func
end

function __gsoVars:_setOnTick(func)
    self._onTick = func
end

function __gsoVars:_setCastSpells(func)
    self._castSpells = func
end

function __gsoVars:_setCastSpellsAA(func)
    self._castSpellsAA = func
end

function __gsoVars:_setBeforeAA(func)
    self._beforeAA = func
end

function __gsoVars:_setMousePos(func)
    self._mousePos = func
end

function __gsoVars:_setCanMove(func)
    self._canMove = func
end

function __gsoVars:_setCanAttack(func)
    self._canAttack = func
end

--------------------|---------------------------------------------------------|--------------------
--------------------|----------------------execute----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

_gso.Vars = __gsoVars()
if _gso.Vars.loaded == false then
    return
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
end


function __gsoOB:_getDistance(source, unit)
  if source == nil or unit == nil then return 99999999999 end
  local x = source.x - unit.x
  local y = source.y - unit.y
  local z = source.z - unit.z
        x = x * x
        y = y * y
        z = z * z
  return math.sqrt(x+y+z)
end


function __gsoOB:_tick()
    
    local cAM = #self.allyMinions
    for i=1, cAM do self.allyMinions[i]=nil end
    
    local cEM = #self.enemyMinions
    for i=1, cEM do self.enemyMinions[i]=nil end
    
    local cEH = #self.enemyHeroes
    for i=1, cEH do self.enemyHeroes[i]=nil end
    
    local cET = #self.enemyTurrets
    for i=1, cET do self.enemyTurrets[i]=nil end
    
    for i = 1, Game.MinionCount() do
        local minion = Game.Minion(i)
        if self:_getDistance(myHero.pos, minion.pos) < 2000 then
            if minion.isEnemy then
                self.enemyMinions[#self.enemyMinions+1] = minion
            else
                self.allyMinions[#self.allyMinions+1] = minion
            end
        end
    end
    
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if hero.isEnemy and self:_getDistance(myHero.pos, hero.pos) < 10000 then
            self.enemyHeroes[#self.enemyHeroes+1] = hero
        end
    end
    
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        if turret.isEnemy and self:_getDistance(myHero.pos, turret.pos) < 2000 then
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
  
    self.menu = MenuElement({name = "Gamsteron TS", id = "gsoMenuTS", type = MENU, leftIcon = "https://i.imgur.com/vzoiheQ.png"})
    
    self.Modes = {
        "Auto",
        "Closest",
        "Least Health",
        "Least Priority"
    }
    
    self.loadedChamps = false
    
    self.isKayle = false
    self.isTaric = false
    self.isKindred = false
    self.isZilean = false
    
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
    Callback.Add('Load', function()
        self:_menu()
    end)
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------menu---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoTS:_menu()
    self.menu:MenuElement({ id = "Mode", name = "Mode", value = 1, drop = self.Modes })
		self.menu:MenuElement({ id = "priority", name = "Priorities", type = MENU })
    self.menu:MenuElement({ id = "selected", name = "Selected Target", type = MENU })
        self.menu.selected:MenuElement({ id = "enable", name = "Enable", value = true })
        self.menu.selected:MenuElement({ id = "only", name = "Only Selected Target", value = false })
        self.menu.selected:MenuElement({name = "Draw",  id = "draw", type = MENU})
            self.menu.selected.draw:MenuElement({name = "Enable",  id = "enable", value = true})
            self.menu.selected.draw:MenuElement({name = "Color",  id = "color", color = Draw.Color(255, 204, 0, 0)})
            self.menu.selected.draw:MenuElement({name = "Width",  id = "width", value = 3, min = 1, max = 10})
            self.menu.selected.draw:MenuElement({name = "Radius",  id = "radius", value = 150, min = 1, max = 300})
end

function __gsoTS:_isImmortal(unit, orb)
    local unitHPPercent = 100 * unit.health / unit.maxHealth
    local uName = unit.charName
    local undyingBuffs = {}
    undyingBuffs["zhonyasringshield"] = true
    undyingBuffs["JaxCounterStrike"] = unit.charName == "Jax" and orb or nil
    undyingBuffs["FioraW"] = unit.charName == "Fiora" and true or nil
    undyingBuffs["aatroxpassivedeath"] = unit.charName == "Aatrox" and true or nil
    undyingBuffs["VladimirSanguinePool"] = unit.charName == "Vladimir" and true or nil
    undyingBuffs["KogMawIcathianSurprise"] = unit.charName == "KogMaw" and true or nil
    undyingBuffs["KarthusDeathDefiedBuff"] = unit.charName == "Karthus" and true or nil
    undyingBuffs["UndyingRage"] = unit.charName == "Tryndamere" and unitHPPercent < 15 or nil
    undyingBuffs["JudicatorIntervention"] = self.isKayle and true or nil
    undyingBuffs["TaricR"] = self.isTaric and true or nil
    undyingBuffs["kindredrnodeathbuff"] = self.isKindred and unitHPPercent < 10 or nil
    undyingBuffs["ChronoShift"] = self.isZilean and unitHPPercent < 15 or nil
    undyingBuffs["chronorevive"] = self.isZilean and unitHPPercent < 15 or nil
    for i = 1, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.count > 0 then
            local undyingBuff = undyingBuffs[buff.name]
            if undyingBuff and undyingBuff == true then
                return true
            end
        end
    end
    return false
end

function __gsoTS:_valid(unit, orb)
    if not unit or unit == nil then
        return false
    end
    if unit.type == Obj_AI_Hero and self:_isImmortal(unit, orb) then
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
    if self.menu.selected.draw.enable:Value() == true and self.selectedTarget ~= nil then
        Draw.Circle(self.selectedTarget.pos, self.menu.selected.draw.radius:Value(), self.menu.selected.draw.width:Value(), self.menu.selected.draw.color:Value())
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
    local isKey = _gso.Orb.menu.keys.combo:Value() or _gso.Orb.menu.keys.harass:Value() or _gso.Orb.menu.keys.laneClear:Value() or _gso.Orb.menu.keys.lastHit:Value()
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
    elseif msg == WM_LBUTTONDOWN and self.menu.selected.enable:Value() == true then
        if getTick > self.lastSelTick + 100 and getTick > self.lastQ + 250 and getTick > self.lastW + 250 and getTick > self.lastE + 250 and getTick > self.lastR + 250 then 
            local num = 10000000
            local enemy = nil
            for i = 1, #_gso.OB.enemyHeroes do
                local hero = _gso.OB.enemyHeroes[i]
                if self:_valid(hero, true) and _gso.OB:_getDistance(myHero.pos, hero.pos) < 10000 then
                    local distance = _gso.OB:_getDistance(hero.pos, _G.mousePos)
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
    if self.menu.selected.only:Value() == true and self.selectedTarget ~= nil then
        return self.selectedTarget
    end
    local result  = nil
    local num     = 10000000
    local mode    = self.menu.Mode:Value()
    local prioT  = { 10000000, 10000000 }
    for i = 1, #_gso.OB.enemyHeroes do
        local unit = _gso.OB.enemyHeroes[i]
        local range = changeRange == true and _range + myHero.boundingRadius + unit.boundingRadius - 30 or _range
        local distance = _gso.OB:_getDistance(myHero.pos, unit.pos)
        if self:_valid(unit, orb) and distance < range then
            if self.menu.selected.enable:Value() == true and self.selectedTarget ~= nil and unit.networkID == self.selectedTarget.networkID then
                return self.selectedTarget
            elseif mode == 1 then
                local unitName = unit.charName
                local priority = 6
                if unitName ~= nil then
                    priority = self.menu.priority[unitName] and self.menu.priority[unitName]:Value() or priority
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
                if hpE < num and _gso.OB:_getDistance(myHero.pos, unit.pos) < range then
                    num     = hpE
                    result  = unit
                end
            elseif mode == 2 then
                if distance < num and _gso.OB:_getDistance(myHero.pos, unit.pos) < range then
                    num = distance
                    result = unit
                end
            elseif mode == 3 then
                local hpE = unit.health
                if hpE < num and _gso.OB:_getDistance(myHero.pos, unit.pos) < range then
                    num = hpE
                    result = unit
                end
            elseif mode == 4 then
                local unitName = unit.charName
                local hpE = unit.health - (unit.totalDamage*unit.attackSpeed*2) - unit.ap
                local priority = 6
                if unitName ~= nil then
                    priority = self.menu.priority[unitName] and self.menu.priority[unitName]:Value() or priority
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
    local result = unit.pos
    if unit.pathing.hasMovePath == true then
        local uPos    = unit.pos
        local ePos    = unit.pathing.endPos
        local distUP  = _gso.OB:_getDistance(pPos, uPos)
        local distEP  = _gso.OB:_getDistance(pPos, ePos)
        if distEP > distUP then
            result = uPos:Extended(ePos, 50+(unit.ms*(distUP / (speed - unit.ms))))
        else
            result = uPos:Extended(ePos, 50+(unit.ms*(distUP / (speed + unit.ms))))
        end
    end
    return result
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
    
    local mLH = _gso.Orb.menu.delays.lhDelay:Value()*0.001
    for i = 1, #_gso.OB.enemyMinions do
        local eMinion = _gso.OB.enemyMinions[i]
        local distance = _gso.OB:_getDistance(myHero.pos, eMinion.pos)
        if distance < myHero.range + myHero.boundingRadius + eMinion.boundingRadius - 30 then
            local eMinion_handle	= eMinion.handle
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
                    local pSpeed		= aAAData.projectileSpeed
                    local pFlyT		= pSpeed > 0 and _gso.OB:_getDistance(aMinion.pos, eMinion.pos) / pSpeed or 0
                    local pStartT	= aAAData.endTime - aAAData.windDownTime
                    if not self.aAttacks[aHandle] then
                      self.aAttacks[aHandle] = {}
                    end
                    local aaID = math.floor(aAAData.endTime)
                    if checkT < pStartT + pFlyT then
                        if pSpeed > 0 then
                            if checkT > pStartT then
                                if not self.aAttacks[aHandle][aaID] then
                                    self.aAttacks[aHandle][aaID] = {
                                                                        canceled  = false,
                                                                        speed     = pSpeed,
                                                                        startTime = pStartT,
                                                                        pTime     = pFlyT,
                                                                        pos       = aMinion.pos:Extended(eMinion.pos, pSpeed*(checkT-pStartT)),
                                                                        from      = aMinion,
                                                                        fromPos   = aMinion.pos,
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
                                                                  pos       = aMinion.pos,
                                                                  from      = aMinion,
                                                                  fromPos   = aMinion.pos,
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
            if v2.speed == 0 and (not v2.from or v2.from == nil or v2.from.dead) then
                --print("dead")
                self.aAttacks[k1] = nil
                break
            end
            if v2.canceled == false then
                local ranged = v2.speed > 0
                if ranged == true then
                    self.aAttacks[k1][k2].pTime = _gso.OB:_getDistance(v2.fromPos, self:_predPos(v2.speed, v2.pos, v2.to)) / v2.speed
                end
                if checkT > v2.startTime + self.aAttacks[k1][k2].pTime - self.latency - 0.02 or not v2.to or v2.to == nil or v2.to.dead then
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
	local dist, t1, t2 = math.sqrt(d*d+e*e), nil, nil
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
					local nom = math.sqrt(sqr)
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
	if object.pathing.hasMovePath then
		table.insert(result, Vector(object.pos.x,object.pos.y, object.pos.z))
		for i = object.pathing.pathIndex, object.pathing.pathCount do
			path = object:GetPath(i)
			table.insert(result, Vector(path.x, path.y, path.z))
		end
	else
		table.insert(result, object and Vector(object.pos.x,object.pos.y, object.pos.z) or Vector(object.pos.x,object.pos.y, object.pos.z))
	end
	return result
end

function __gsoTPred:GetDistanceSqr(p1, p2)
	if not p1 or not p2 then return 999999999 end
	return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function __gsoTPred:GetDistance(p1, p2)
	return math.sqrt(self:GetDistanceSqr(p1, p2))
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
	local ExtraDelay = speed == math.huge and 0 or from and unit and unit.pos and (self:GetDistance(from, unit.pos) / speed)
	if (self:CanMove(unit, delay + ExtraDelay) == false) then
		return true
	end
	return false
end
function __gsoTPred:CalculateTargetPosition(unit, delay, radius, speed, from, spelltype)
	local Waypoints = {}
	local Position, CastPosition = Vector(unit.pos), Vector(unit.pos)
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
	local MPos, CastPosition = #waypoints == 1 and Vector(minion.pos) or self:CalculateTargetPosition(minion, delay, radius, speed, from, "line")
	
	if from and MPos and self:GetDistanceSqr(from, MPos) <= (range)^2 and self:GetDistanceSqr(from, minion.pos) <= (range + 100)^2 then
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
		
		local proj2, pointLine, isOnSegment = self:VectorPointProjectionOnLineSegment(from, Position, Vector(minion.pos))
		if proj2 and isOnSegment and (self:GetDistanceSqr(minion.pos, proj2) <= (minion.boundingRadius + radius + buffer) ^ 2) then
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
	
	if not from then
		from = Vector(myHero.pos)
	end
	local IsFromMyHero = self:GetDistanceSqr(from, myHero.pos) < 50*50 and true or false
	
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
	
	if self:GetDistance(myHero.pos, unit.pos) < 250 then
		HitChance = 2
		Position, CastPosition = self:CalculateTargetPosition(unit, delay*0.5, radius, speed*2, from, spelltype)
		Position = CastPosition
	end
	local angletemp = Vector(from):AngleBetween(Vector(unit.pos), Vector(CastPosition))
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
		if collision and self:CheckMinionCollision(unit, unit.pos, delay, radius, range, speed, from) then
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
  
    print("gamsteronAIO ".._gso.Vars.version.." | orbwalker loaded!")
    self.menu = MenuElement({name = "Gamsteron Orbwalker", id = "gsoMenuOrb", type = MENU, leftIcon = "https://i.imgur.com/nahe4Ua.png"})
    self:_menu()
    
    self.canAA        = true
    self.lAttack      = 0
    self.lMove        = 0
    
    self.isTeemo      = false
    self.isBlinded    = false
    self.lastTarget   = nil
    
    self.extraWindUpT = 0
    self.extraAnimT   = 0
    self.windUpT      = myHero.attackData.windUpTime
    self.animT        = myHero.attackData.animationTime
    self.endTime      = myHero.attackData.endTime
    
    self.dActions     = {}
    self.dActionsC    = 0
    
    Callback.Add('Tick', function() self:_tick() end)
    Callback.Add('Draw', function() self:_draw() end)
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------menu---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoOrb:_menu()
  self.menu:MenuElement({name = "Delays", id = "delays", type = MENU})
      self.menu.delays:MenuElement({name = "lasthit delay", id = "lhDelay", value = 0, min = 0, max = 50, step = 5 })
      self.menu.delays:MenuElement({name = "Humanizer", id = "humanizer", value = 200, min = 0, max = 300, step = 10 })
  self.menu:MenuElement({name = "Keys", id = "keys", type = MENU})
      self.menu.keys:MenuElement({name = "Combo Key", id = "combo", key = string.byte(" ")})
      self.menu.keys:MenuElement({name = "Harass Key", id = "harass", key = string.byte("C")})
      self.menu.keys:MenuElement({name = "LastHit Key", id = "lastHit", key = string.byte("X")})
      self.menu.keys:MenuElement({name = "LaneClear Key", id = "laneClear", key = string.byte("V")})
  self.menu:MenuElement({name = "Drawings", id = "draw", type = MENU})
      self.menu.draw:MenuElement({name = "Enable", id = "enable", value = true})
      self.menu.draw:MenuElement({name = "MyHero attack range", id = "me", type = MENU})
          self.menu.draw.me:MenuElement({name = "Enable",  id = "enable", value = true})
          self.menu.draw.me:MenuElement({name = "Color",  id = "color", color = Draw.Color(150, 49, 210, 0)})
          self.menu.draw.me:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
      self.menu.draw:MenuElement({name = "Enemy attack range", id = "he", type = MENU})
          self.menu.draw.he:MenuElement({name = "Enable",  id = "enable", value = true})
          self.menu.draw.he:MenuElement({name = "Color",  id = "color", color = Draw.Color(150, 255, 0, 0)})
          self.menu.draw.he:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
      self.menu.draw:MenuElement({name = "Cursor Posistion",  id = "cpos", type = MENU})
          self.menu.draw.cpos:MenuElement({name = "Enable",  id = "enable", value = true})
          self.menu.draw.cpos:MenuElement({name = "Color",  id = "color", color = Draw.Color(150, 153, 0, 76)})
          self.menu.draw.cpos:MenuElement({name = "Width",  id = "width", value = 5, min = 1, max = 10})
          self.menu.draw.cpos:MenuElement({name = "Radius",  id = "radius", value = 250, min = 1, max = 300})
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
    local cLH     = #_gso.Farm.lastHit
    for i = 1, cLH do
        local eMinionLH = _gso.Farm.lastHit[i]
        local minion	= eMinionLH[1]
        local hp		= eMinionLH[2]
        if hp < min then
            min = hp
            result = minion
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
            if _gso.TS:_valid(turret, false) and _gso.OB:_getDistance(myHero.pos, turret.pos) < range then
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
    local mHum    = self.menu.delays.humanizer:Value()*0.001
    
    local aaData = myHero.attackData
    local endTime = aaData.endTime
    self.animT = aaData.animationTime
    self.windUpT = aaData.windUpTime
    
    if endTime > self.endTime then
        self.endTime = endTime
    end
    
    local canMove = _gso.Vars._canMove() and checkT > self.lAttack + self.windUpT + (_gso.Farm.latency*1.5) - 0.05 + self.extraWindUpT
    local canAA = _gso.Vars._canAttack() and self.isBlinded == false and self.canAA and canMove and checkT > self.endTime - 0.034 - (_gso.Farm.latency*1.5) + self.extraAnimT
    local isTarget = unit ~= nil
    
    if self.dActionsC == 0 then
        if isTarget and canAA then
            _gso.Vars._beforeAA()
            self.lAttack = checkT
            self.lMove = 0
            local cPos = cursorPos
            Control.SetCursorPos(unit.pos)
            Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
            Control.mouse_event(MOUSEEVENTF_RIGHTUP)
            self.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            self.dActionsC = self.dActionsC + 1
        elseif canMove then
            if checkT > self.lMove + mHum and self.dActionsC == 0 then
                local mPos = _gso.Vars._mousePos()
                if mPos ~= nil then
                    if mPos:DistanceTo(myHero.pos) > 50 then
                        local cPos = cursorPos
                        Control.SetCursorPos(mPos)
                        Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
                        Control.mouse_event(MOUSEEVENTF_RIGHTUP)
                        self.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                        self.dActionsC = self.dActionsC + 1
                        self.lMove = checkT
                    end
                else
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
        if buff.count > 0 and buff.name == "BlindingDart" then
            return true
        end
    end
    return false
end



--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------tick----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoOrb:_tick()
    
    if _gso.TS.loadedChamps == false then
        if Game.Timer() > 6 then
            for i = 1, Game.HeroCount() do
                local hero = Game.Hero(i)
                if hero and hero.isEnemy then
                    local eName = hero.charName
                    if eName and #eName > 0 and not _gso.TS.menu.priority[eName] then
                        local priority = _gso.TS.Priorities[eName] ~= nil and _gso.TS.Priorities[eName] or 5
                        _gso.TS.menu.priority:MenuElement({ id = eName, name = eName, value = priority, min = 1, max = 5, step = 1 })
                        if eName == "Teemo" then
                            self.isTeemo = true
                        elseif eName == "Kayle" then
                            _gso.TS.isKayle = true
                        elseif eName == "Taric" then
                            _gso.TS.isTaric = true
                        elseif eName == "Kindred" then
                            _gso.TS.isKindred = true
                        elseif eName == "Zilean" then
                            _gso.TS.isZilean = true
                        end
                    end
                end
            end
            _gso.TS.loadedChamps = true
        end
    end
    
    if self.isTeemo == true then
        self.isBlinded = self:_checkTeemoBlind()
    end
    
    _gso.OB:_tick()
    _gso.Farm:_tick()
    
    local checkT  = Game.Timer()
    local ck      = self.menu.keys.combo:Value()
    local hk      = self.menu.keys.harass:Value()
    local lhk     = self.menu.keys.lastHit:Value()
    local lck     = self.menu.keys.laneClear:Value()
    
    _gso.Vars._onTick()
    
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
    if self.dActionsC == 0 and checkT > self.lAttack + self.windUpT + 0.15 then
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
        self:_orb(AAtarget)
    end
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------draw----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoOrb:_draw()
    for i = 1, #_gso.Vars._onDraw do
        _gso.Vars._onDraw[i]()
    end
    if not self.menu.draw.enable:Value() then return end
    if self.menu.draw.me.enable:Value() and not myHero.dead and myHero.pos:ToScreen().onScreen then
        Draw.Circle(myHero.pos, myHero.range + myHero.boundingRadius + 35, self.menu.draw.me.width:Value(), self.menu.draw.me.color:Value())
    end
    if self.menu.draw.he.enable:Value() then
        local countEH = #_gso.OB.enemyHeroes
        for i = 1, countEH do
            local hero = _gso.OB.enemyHeroes[i]
            if _gso.TS:_valid(hero, false) and _gso.OB:_getDistance(myHero.pos, hero.pos) < 2000 and hero.pos:ToScreen().onScreen then
                Draw.Circle(hero.pos, hero.range + hero.boundingRadius + 35, self.menu.draw.he.width:Value(), self.menu.draw.he.color:Value())
            end
        end
    end
    if self.menu.draw.cpos.enable:Value() then
        Draw.Circle(mousePos, self.menu.draw.cpos.radius:Value(), self.menu.draw.cpos.width:Value(), self.menu.draw.cpos.color:Value())
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
  
    print("gamsteronAIO ".._gso.Vars.version.." | ashe loaded!")
    
    self.menu = MenuElement({name = "Gamsteron Ashe", id = "gsoMenuAshe", type = MENU, leftIcon = "https://i.imgur.com/WohLMsm.png"})
    self:_menu()
    
    self.lastQ = 0
    self.lastW = 0
    self.lastR = 0
    
    self.qBuffEndT = 0
    
    _gso.Orb.extraWindUpT = self.menu.aacancel.windup:Value()*0.001
    _gso.Orb.extraAnimT = self.menu.aacancel.anim:Value()*0.001
    
    _gso.Vars:_setCastSpells(function() self:_castSpells() end)
    _gso.Vars:_setCastSpellsAA(function() self:_castSpellsAA() end)
    _gso.Vars:_setOnTick(function() self:_tick() end)
    _gso.Vars:_setBonusDmg(function() return self:_dmg() end)
    _gso.Vars:_setBonusDmgUnit(function(unit) return self:_dmgUnit(unit) end)
    _gso.Vars:_setCanMove(function() return self:_setCanMove() end)
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------menu---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoAshe:_menu()
    self.menu:MenuElement({name = "AA Cancel Settings", id = "aacancel", type = MENU})
        self.menu.aacancel:MenuElement({name = "WindUp Delay - move", id = "windup", value = 50, min = 0, max = 300, step = 5 })
        self.menu.aacancel:MenuElement({name = "Anim Delay - attack", id = "anim", value = 25, min = 0, max = 300, step = 5 })
    self.menu:MenuElement({id = "rdist", name = "use R if enemy distance < X", value = 500, min = 250, max = 1000, step = 50})
    self.menu:MenuElement({type = MENU, id = "combo", name = "Combo"})
        self.menu.combo:MenuElement({id = "qc", name = "UseQ", value = true})
        self.menu.combo:MenuElement({id = "wc", name = "UseW", value = true})
        self.menu.combo:MenuElement({id = "rcd", name = "UseR [enemy distance < X", value = true})
        self.menu.combo:MenuElement({id = "rci", name = "UseR [enemy IsImmobile]", value = true})
    self.menu:MenuElement({type = MENU, id = "harass", name = "Harass"})
        self.menu.harass:MenuElement({id = "qh", name = "UseQ", value = true})
        self.menu.harass:MenuElement({id = "wh", name = "UseW", value = true})
        self.menu.harass:MenuElement({id = "rhd", name = "UseR [enemy distance < X]", value = false})
        self.menu.harass:MenuElement({id = "rhi", name = "UseR [enemy IsImmobile]", value = false})
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------cast spells--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoAshe:_castSpells()
  
    local getTick = GetTickCount()
    
    local wMinus = getTick - self.lastW
    local rMinus = getTick - self.lastR
    
    local isCombo = _gso.Orb.menu.keys.combo:Value()
    local isHarass = _gso.Orb.menu.keys.harass:Value()
    
    local isComboW = isCombo and self.menu.combo.wc:Value()
    local isHarassW = isHarass and self.menu.harass.wh:Value()
    
    local isComboRd = isCombo and self.menu.combo.rcd:Value()
    local isHarassRd = isHarass and self.menu.harass.rhd:Value()
    
    local isComboRi = isCombo and self.menu.combo.rcd:Value()
    local isHarassRi = isHarass and self.menu.harass.rhd:Value()

    if rMinus > 2000 and wMinus > 350 and Game.CanUseSpell(_R) == 0 then
        if isComboRd or isHarassRd then
            local t = nil
            local menuDist = self.menu.rdist:Value()
            for i = 1, #_gso.OB.enemyHeroes do
                local hero = _gso.OB.enemyHeroes[i]
                local distance = _gso.OB:_getDistance(myHero.pos, hero.pos)
                if _gso.TS:_valid(hero, false) and distance > 250 and distance < menuDist then
                    menuDist = distance
                    t = hero
                end
            end
            if t ~= nil then
                local sR = { delay = 0.25, range = 600, width = 125, speed = 1600, sType = "line", col = false }
                local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(t, sR.delay, sR.width*0.5, sR.range, sR.speed, myHero.pos, sR.col, sR.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(myHero.pos, castpos) < sR.range and _gso.OB:_getDistance(t.pos, castpos) < 500 then
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
                if _gso.TS:_valid(hero, false) and _gso.OB:_getDistance(myHero.pos, hero.pos) < 1000 and _gso.TS:_isImmobile(hero) then
                    local rPred = hero.pos
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
                local sW = { delay = 0.25, range = 1200, width = 75, speed = 2000, sType = "line", col = true }
                local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, myHero.pos, sW.col, sW.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(myHero.pos, castpos) < sW.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
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
    
    local isCombo = _gso.Orb.menu.keys.combo:Value()
    local isHarass = _gso.Orb.menu.keys.harass:Value()

    local isComboQ = isCombo and self.menu.combo.qc:Value()
    local isHarassQ = isHarass and self.menu.harass.qh:Value()
    
    local isComboW = isCombo and self.menu.combo.wc:Value()
    local isHarassW = isHarass and self.menu.harass.wh:Value()
    
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
            local sW = { delay = 0.25, range = 1200, width = 150, speed = 2000, sType = "line", col = true }
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, myHero.pos, sW.col, sW.sType)
            if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(myHero.pos, castpos) < sW.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
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
    
    _gso.Orb.extraWindUpT = self.menu.aacancel.windup:Value()*0.001
    _gso.Orb.extraAnimT = self.menu.aacancel.anim:Value()*0.001
    
    --[[ ENABLE AA AFTER SPELLS ]]
    local checkTick = GetTickCount()
    local wMinus = checkTick - self.lastW
    local rMinus = checkTick - self.lastR
    if _gso.Orb.canAA == false and wMinus > 350 and rMinus > 350 then
        _gso.Orb.canAA = true
    end
    
    --[[ RESET AA AFTER Q ]]
    local checkT = Game.Timer()
    if myHero:GetSpellData(_Q).level > 0 then
        for i = 1, myHero.buffCount do
            local buff = myHero:GetBuff(i)
            if buff.count > 0 and buff.name:lower() == "asheqattack" and buff.duration < 0.3 then
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
        result = checkT > _gso.Orb.endTime - (_gso.Orb.animT - _gso.Orb.windUpT) - 0.075 + (self.menu.aacancel.windup:Value()*0.001)
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
        if buff.count > 0 and buff.name:lower() == "ashepassiveslow" then
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
  
    print("gamsteronAIO ".._gso.Vars.version.." | twitch loaded!")
    
    self.menu = MenuElement({name = "Gamsteron Twitch", id = "gsoMenuTwitch", type = MENU, leftIcon = "https://i.imgur.com/tVpVF5L.png"})
    self:_menu()
    
    self.lastW         = 0
    self.lastE         = 0
    self.eBuffs        = {}
    
    _gso.Orb.extraAnimT = self.menu.aacancel.anim:Value()*0.001
    _gso.Orb.extraWindUpT = self.menu.aacancel.windup:Value()*0.001
    
    _gso.Vars:_setCastSpells(function() self:_castSpells() end)
    _gso.Vars:_setCastSpellsAA(function() self:_castSpellsAA() end)
    _gso.Vars:_setOnTick(function() self:_tick() end)
    _gso.Vars:_setBonusDmg(function() return self:_dmg() end)
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------menu---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoTwitch:_menu()
    self.menu:MenuElement({name = "AA Cancel Settings", id = "aacancel", type = MENU})
        self.menu.aacancel:MenuElement({name = "WindUp Delay - move", id = "windup", value = 50, min = 0, max = 300, step = 5 })
        self.menu.aacancel:MenuElement({name = "Anim Delay - attack", id = "anim", value = 25, min = 0, max = 300, step = 5 })
    self.menu:MenuElement({name = "W settings", id = "wset", type = MENU })
        self.menu.wset:MenuElement({id = "combo", name = "Use W Combo", value = true})
        self.menu.wset:MenuElement({id = "harass", name = "Use W Harass", value = false})
    self.menu:MenuElement({name = "E settings", id = "eset", type = MENU })
        self.menu.eset:MenuElement({id = "combo", name = "Use E Combo", value = true})
        self.menu.eset:MenuElement({id = "harass", name = "Use E Harass", value = false})
        self.menu.eset:MenuElement({id = "stacks", name = "X stacks", value = 6, min = 1, max = 6, step = 1 })
        self.menu.eset:MenuElement({id = "enemies", name = "X enemies", value = 1, min = 1, max = 5, step = 1 })
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
    
    local isCombo = _gso.Orb.menu.keys.combo:Value()
    local isHarass = _gso.Orb.menu.keys.harass:Value()
    
    local isComboW = isCombo and self.menu.wset.combo:Value()
    local isHarassW = isHarass and self.menu.wset.harass:Value()
    
    local isComboE = isCombo and self.menu.eset.combo:Value()
    local isHarassE = isHarass and self.menu.eset.harass:Value()
    
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
            local xStacks   = self.menu.eset.stacks:Value()
            local xEnemies  = self.menu.eset.enemies:Value()
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
        local target = _gso.TS:_getTarget(950, false, false)
        if target ~= nil then
            local sW = { delay = 0.25, range = 950, width = 275, speed = 1400, sType = "circular", col = false }
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, myHero.pos, sW.col, sW.sType)
            if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(myHero.pos, castpos) < sW.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
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
    
    _gso.Orb.extraAnimT = self.menu.aacancel.anim:Value()*0.001
    _gso.Orb.extraWindUpT = self.menu.aacancel.windup:Value()*0.001
    
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
    
    if _gso.Orb.canAA == false and wMinus > 350 and eMinus > 350 then
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
  
    print("gamsteronAIO ".._gso.Vars.version.." | kog'maw loaded!")
    self.menu = MenuElement({name = "Gamsteron Kog'Maw", id = "gsoMenuKogMaw", type = MENU, leftIcon = "https://i.imgur.com/PR2suYf.png"})
    self:_menu()
    
    _gso.TS.apDmg = true
    
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    self.lastR = 0
    
    _gso.Orb.extraAnimT = self.menu.aacancel.anim:Value()*0.001
    _gso.Orb.extraWindUpT = self.menu.aacancel.windup:Value()*0.001
    
    _gso.Vars:_setCastSpells(function() self:_castSpells() end)
    _gso.Vars:_setCastSpellsAA(function() self:_castSpellsAA() end)
    _gso.Vars:_setBonusDmg(function() return self:_dmg() end)
    _gso.Vars:_setOnTick(function() self:_tick() end)
end


--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------menu----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoKogMaw:_menu()
    self.menu:MenuElement({name = "AA Cancel Settings", id = "aacancel", type = MENU})
        self.menu.aacancel:MenuElement({name = "WindUp Delay - move", id = "windup", value = 50, min = 0, max = 300, step = 5 })
        self.menu.aacancel:MenuElement({name = "Anim Delay - attack", id = "anim", value = 25, min = 0, max = 300, step = 5 })
    self.menu:MenuElement({name = "Q settings", id = "qset", type = MENU })
        self.menu.qset:MenuElement({id = "combo", name = "Combo", value = true})
        self.menu.qset:MenuElement({id = "harass", name = "Harass", value = false})
    self.menu:MenuElement({name = "W settings", id = "wset", type = MENU })
        self.menu.wset:MenuElement({id = "combo", name = "Combo", value = true})
        self.menu.wset:MenuElement({id = "harass", name = "Harass", value = false})
    self.menu:MenuElement({name = "E settings", id = "eset", type = MENU })
        self.menu.eset:MenuElement({id = "combo", name = "Combo", value = true})
        self.menu.eset:MenuElement({id = "harass", name = "Harass", value = false})
    self.menu:MenuElement({name = "R settings", id = "rset", type = MENU })
        self.menu.rset:MenuElement({id = "combo", name = "Combo", value = true})
        self.menu.rset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.rset:MenuElement({id = "stack", name = "Stop at x stacks", value = 3, min = 1, max = 9, step = 1 })
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------buff manager-------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoKogMaw:_getBuffCount()
    local result = 0
    for i = 1, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        if buff.count > 0 and buff.name:lower() == "kogmawlivingartillerycost" then
            return buff.count
        end
    end
    return result
end

function __gsoKogMaw:_hasBuff()
    local result = false
    for i = 1, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        if buff.count > 0 and buff.name:lower() == "kogmawbioarcanebarrage" then
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
    
    local isCombo   = _gso.Orb.menu.keys.combo:Value()
    local isHarass  = _gso.Orb.menu.keys.harass:Value()
    
    local isComboW   = isCombo and self.menu.wset.combo:Value()
    local isHarassW  = isHarass and self.menu.wset.harass:Value()
    
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
    
    local isCombo = _gso.Orb.menu.keys.combo:Value()
    local isHarass = _gso.Orb.menu.keys.harass:Value()
    
    local isComboQ = isCombo and self.menu.qset.combo:Value()
    local isHarassQ = isHarass and self.menu.qset.harass:Value()
    
    local isComboE = isCombo and self.menu.eset.combo:Value()
    local isHarassE = isHarass and self.menu.eset.harass:Value()
    
    local isComboR = isCombo and self.menu.rset.combo:Value()
    local isHarassR = isHarass and self.menu.rset.harass:Value()
    
    local sQ = { delay = 0.25, range = 1175, width = 70, speed = 1650, sType = "line", col = true }
    local sE = { delay = 0.25, range = 1280, width = 120, speed = 1350, sType = "line", col = false }
    local sR = { delay = 1.2, range = 0, width = 225, speed = math.maxinteger, sType = "circular", col = false }
    
    if (isComboQ or isHarassQ) and qMinus > 2000 and eMinus > 400 and rMinus > 400 and Game.CanUseSpell(_Q) == 0 then
        local target = _gso.TS:_getTarget(1175, false, false)
        if target ~= nil then
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, myHero.pos, sQ.col, sQ.sType)
            if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(myHero.pos, castpos) < sQ.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
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
        local target = _gso.TS:_getTarget(1280, false, false)
        if target ~= nil then
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sE.delay, sE.width*0.5, sE.range, sE.speed, myHero.pos, sE.col, sE.sType)
            if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(myHero.pos, castpos) < sE.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
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
    if (isComboR or isHarassR) and rMinus > 700 and qMinus > 400 and eMinus > 400 and Game.CanUseSpell(_R) == 0 and self:_getBuffCount() < self.menu.rset.stack:Value() then
        sR.range = 900 + ( 300 * myHero:GetSpellData(_R).level )
        local target = _gso.TS:_getTarget(sR.range + (sR.width*0.5), false, false)
        if target ~= nil then
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sR.delay, sR.width*0.5, sR.range, sR.speed, myHero.pos, sR.col, sR.sType)
            if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(myHero.pos, castpos) < sR.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
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
  
    _gso.Orb.extraAnimT = self.menu.aacancel.anim:Value()*0.001
    _gso.Orb.extraWindUpT = self.menu.aacancel.windup:Value()*0.001
    
    local checkT = GetTickCount()
    
    local qMinus = checkT - self.lastQ
    local eMinus = checkT - self.lastE
    local rMinus = checkT - self.lastR
    
    if _gso.Orb.canAA == false and qMinus > 350 and eMinus > 350 and rMinus > 350 then
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
  
    print("gamsteronAIO ".._gso.Vars.version.." | draven loaded!")
    
    self.qModes = { "closest to mousePos", "closest to heroPos" }
    
    self.menu = MenuElement({name = "Gamsteron Draven", id = "gsoMenuDraven", type = MENU, leftIcon = "https://i.imgur.com/U13x6xb.png"})
    self:_menu()
    
    self.qParticles = {}
    
    self.lastQ = 0
    self.lastW = 0
    self.lastE = 0
    
    self.lMove = 0
    
    _gso.Orb.extraAnimT = self.menu.aacancel.anim:Value()*0.001
    _gso.Orb.extraWindUpT = self.menu.aacancel.windup:Value()*0.001
    
    _gso.Vars:_setCastSpells(function() self:_castSpells() end)
    _gso.Vars:_setCastSpellsAA(function() self:_castSpellsAA() end)
    _gso.Vars:_setBonusDmg(function() return self:_dmg() end)
    _gso.Vars:_setOnTick(function() self:_tick() end)
    _gso.Vars:_setMousePos(function() return self:_setMousePos() end)
    _gso.Vars:_setOnDraw(function() self:_draw() end)
    _gso.Vars:_setBeforeAA(function() self:_setBeforeAA() end)
end


--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------menu----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoDraven:_menu()
    self.menu:MenuElement({name = "AA Cancel Settings", id = "aacancel", type = MENU})
        self.menu.aacancel:MenuElement({name = "WindUp Delay - move", id = "windup", value = 75, min = 0, max = 300, step = 5 })
        self.menu.aacancel:MenuElement({name = "Anim Delay - attack", id = "anim", value = 25, min = 0, max = 300, step = 5 })
    self.menu:MenuElement({name = "AXE settings", id = "aset", type = MENU })
        self.menu.aset:MenuElement({id = "catch", name = "Catch axes", value = true})
        self.menu.aset:MenuElement({id = "catcht", name = "stop catch axe under turret", value = true})
        self.menu.aset:MenuElement({name = "Distance", id = "dist", type = MENU })
            self.menu.aset.dist:MenuElement({id = "mode", name = "Axe Mode", value = 1, drop = self.qModes })
            self.menu.aset.dist:MenuElement({id = "duration", name = "extra axe duration time", value = 0, min = -300, max = 0, step = 10 })
            self.menu.aset.dist:MenuElement({id = "stopmove", name = "axePos in distance < X | Hold radius", value = 100, min = 0, max = 125, step = 5 })
            self.menu.aset.dist:MenuElement({id = "cdist", name = "max distance from axePos to cursorPos", value = 1000, min = 0, max = 1500, step = 50 })
            self.menu.aset.dist:MenuElement({id = "hdist", name = "max distance from axePos to heroPos", value = 500, min = 0, max = 750, step = 50 })
            self.menu.aset.dist:MenuElement({id = "enemyq", name = "stop catch if axe is near enemy - X dist", value = 150, min = 0, max = 250, step = 5 })
            self.menu.aset.dist:MenuElement({id = "enemyhero", name = "stop catch if hero is near enemy - X dist", value = 250, min = 0, max = 500, step = 5 })
        self.menu.aset:MenuElement({name = "Draw", id = "draw", type = MENU })
            self.menu.aset.draw:MenuElement({name = "Enable",  id = "enable", value = true})
            self.menu.aset.draw:MenuElement({name = "Good", id = "good", type = MENU })
                self.menu.aset.draw.good:MenuElement({name = "Color",  id = "color", color = Draw.Color(255, 49, 210, 0)})
                self.menu.aset.draw.good:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
                self.menu.aset.draw.good:MenuElement({name = "Radius",  id = "radius", value = 170, min = 50, max = 300, step = 10})
            self.menu.aset.draw:MenuElement({name = "Bad", id = "bad", type = MENU })
                self.menu.aset.draw.bad:MenuElement({name = "Color",  id = "color", color = Draw.Color(255, 153, 0, 0)})
                self.menu.aset.draw.bad:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
                self.menu.aset.draw.bad:MenuElement({name = "Radius",  id = "radius", value = 170, min = 50, max = 300, step = 10})
    self.menu:MenuElement({name = "Q settings", id = "qset", type = MENU })
        self.menu.qset:MenuElement({id = "combo", name = "Combo", value = true})
        self.menu.qset:MenuElement({id = "harass", name = "Harass", value = false})
    self.menu:MenuElement({name = "W settings", id = "wset", type = MENU })
        self.menu.wset:MenuElement({id = "combo", name = "Combo", value = true})
        self.menu.wset:MenuElement({id = "harass", name = "Harass", value = false})
        self.menu.wset:MenuElement({id = "hdist", name = "max enemy distance", value = 750, min = 500, max = 2000, step = 50 })
    self.menu:MenuElement({name = "E settings", id = "eset", type = MENU })
        self.menu.eset:MenuElement({id = "combo", name = "Combo", value = true})
        self.menu.eset:MenuElement({id = "harass", name = "Harass", value = false})
end




--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------cast spells--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoDraven:_castSpells()
    
    local getTick = GetTickCount()

    local qMinus = getTick - self.lastQ
    local wMinus = getTick - self.lastW
    local eMinus = getTick - self.lastE

    local isCombo = _gso.Orb.menu.keys.combo:Value()
    local isHarass = _gso.Orb.menu.keys.harass:Value()

    local isComboW = isCombo and self.menu.wset.combo:Value()
    local isHarassW = isHarass and self.menu.wset.harass:Value()

    local isComboE = isCombo and self.menu.eset.combo:Value()
    local isHarassE = isHarass and self.menu.eset.harass:Value()

    local isWReady = (isComboW or isHarassW) and wMinus > 1000 and qMinus > 250 and eMinus > 250 and Game.CanUseSpell(_W) == 0
    local isEReady = (isComboE or isHarassE) and eMinus > 2000 and qMinus > 250 and eMinus > 250 and Game.CanUseSpell(_E) == 0
    
    if isWReady or isEReady then
        local aaTarget = _gso.TS:_getTarget(myHero.range, true, true)
        if aaTarget == nil then
            if isWReady then
                local wTarget = _gso.TS:_getTarget(self.menu.wset.hdist:Value(), false, false)
                if wTarget ~= nil then
                    Control.KeyDown(HK_W)
                    Control.KeyUp(HK_W)
                    self.lastW = GetTickCount()
                    return
                end
            end
            if isEReady then
                local target = _gso.TS:_getTarget(1050, false, false)
                if target ~= nil then
                    local sE = { delay = 0.25, range = 1050, width = 150, speed = 1400, sType = "line", col = false }
                    local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sE.delay, sE.width*0.5, sE.range, sE.speed, myHero.pos, sE.col, sE.sType)
                    if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(myHero.pos, castpos) < sE.range and _gso.OB:_getDistance(target.pos, castpos) < 250 then
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
    
    local isCombo = _gso.Orb.menu.keys.combo:Value()
    local isHarass = _gso.Orb.menu.keys.harass:Value()

    local isComboQ = isCombo and self.menu.qset.combo:Value()
    local isHarassQ = isHarass and self.menu.qset.harass:Value()
    
    local isComboW = isCombo and self.menu.wset.combo:Value()
    local isHarassW = isHarass and self.menu.wset.harass:Value()
    
    local isComboE = isCombo and self.menu.eset.combo:Value()
    local isHarassE = isHarass and self.menu.eset.harass:Value()
    
    if (isComboQ or isHarassQ) and qMinus > 1000 and wMinus > 250 and eMinus > 250 and Game.CanUseSpell(_Q) == 0 then
        Control.KeyDown(HK_Q)
        Control.KeyUp(HK_Q)
        self.lastQ = GetTickCount()
    end
    
    if (isComboW or isHarassW) and wMinus > 1000 and qMinus > 250 and eMinus > 250 and Game.CanUseSpell(_W) == 0 then
        Control.KeyDown(HK_W)
        Control.KeyUp(HK_W)
        self.lastW = GetTickCount()
    end
    
    if (isComboE or isHarassE) and eMinus > 2000 and qMinus > 250 and eMinus > 250 and Game.CanUseSpell(_E) == 0 then
        local target = _gso.TS:_getTarget(1100, false, false)
        if target ~= nil then
            local sE = { delay = 0.25, range = 1050, width = 150, speed = 1400, sType = "line", col = false }
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sE.delay, sE.width*0.5, sE.range, sE.speed, myHero.pos, sE.col, sE.sType)
            if HitChance > 0 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(myHero.pos, castpos) < sE.range and _gso.OB:_getDistance(target.pos, castpos) < 250 then
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
    
    local isCombo = _gso.Orb.menu.keys.combo:Value()
    local isHarass = _gso.Orb.menu.keys.harass:Value()

    local isComboQ = isCombo and self.menu.qset.combo:Value()
    local isHarassQ = isHarass and self.menu.qset.harass:Value()
    
    local isComboW = isCombo and self.menu.wset.combo:Value()
    local isHarassW = isHarass and self.menu.wset.harass:Value()
    
    if (isComboQ or isHarassQ) and qMinus > 1000 and wMinus > 250 and eMinus > 250 and Game.CanUseSpell(_Q) == 0 then
        Control.KeyDown(HK_Q)
        Control.KeyUp(HK_Q)
        self.lastQ = GetTickCount()
    end
    
    if (isComboW or isHarassW) and wMinus > 1000 and qMinus > 250 and eMinus > 250 and Game.CanUseSpell(_W) == 0 then
        Control.KeyDown(HK_W)
        Control.KeyUp(HK_W)
        self.lastW = GetTickCount()
    end
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------tick-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoDraven:_tick()
  
    _gso.Orb.extraAnimT = self.menu.aacancel.anim:Value()*0.001
    _gso.Orb.extraWindUpT = self.menu.aacancel.windup:Value()*0.001
  
    local checkT = GetTickCount()
    
    local eMinus = checkT - self.lastE
    
    if _gso.Orb.canAA == false and eMinus > 350 then
        _gso.Orb.canAA = true
    end
    
    for i = 1, Game.ParticleCount() do
        local particle = Game.Particle(i)
        if particle.name == "Draven_Base_Q_reticle" then
            if not self.qParticles[particle.handle] then
                if _gso.OB:_getDistance(myHero.pos, particle.pos) < 500 then
                    self.qParticles[particle.handle] = { pos = particle.pos, tick = GetTickCount(), success = false, active = false }
                    _gso.Orb.lMove = 0
                end
            end
        end
    end
    
    for k,v in pairs(self.qParticles) do
        if not v.success and GetTickCount() > v.tick + 1200 + self.menu.aset.dist.duration:Value() then
            self.qParticles[k].success = true
            _gso.Orb.lMove = 0
        end
        if GetTickCount() > v.tick + 2000 then
            self.qParticles[k] = nil
        end
    end
    
end


--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------set mouse pos------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoDraven:_setMousePos()
    
    local qPos = nil
    local canCatch = self.menu.aset.catch:Value()
    local stopCatchT = self.menu.aset.catcht:Value()
    local stopmove = self.menu.aset.dist.stopmove:Value()
    if canCatch then
        local qMode = self.menu.aset.dist.mode:Value()
        local hdist = self.menu.aset.dist.hdist:Value()
        local cdist = self.menu.aset.dist.cdist:Value()
        local num = 1000000000
        for k,v in pairs(self.qParticles) do
            if not v.success then
                local distanceToHero = v.pos:DistanceTo(myHero.pos)
                local distanceToMouse = v.pos:DistanceTo(_G.mousePos)
                if distanceToHero < hdist and distanceToMouse < cdist then
                    local canContinue = true
                    local cEM = #_gso.OB.enemyMinions
                    for i = 1, cEM do
                        local minion = _gso.OB.enemyMinions[i]
                        if _gso.TS:_valid(minion, false) and _gso.OB:_getDistance(v.pos, minion.pos) < self.menu.aset.dist.enemyq:Value() then
                            canContinue = false
                            break
                        end
                    end
                    local cEH = #_gso.OB.enemyHeroes
                    for i = 1, cEH do
                        local hero = _gso.OB.enemyHeroes[i]
                        if not hero.dead and hero.isTargetable and hero.visible and hero.valid then
                            if _gso.OB:_getDistance(v.pos, hero.pos) < self.menu.aset.dist.enemyq:Value() then
                                canContinue = false
                                break
                            end
                            if _gso.OB:_getDistance(myHero.pos, hero.pos) < self.menu.aset.dist.enemyhero:Value() then
                                canContinue = false
                                break
                            end
                        end
                    end
                    if stopCatchT then
                        local cET = #_gso.OB.enemyTurrets
                        for i=1, cET do
                            local turret = _gso.OB.enemyTurrets[i]
                            local range = 775 + turret.boundingRadius + myHero.boundingRadius
                            if _gso.TS:_valid(turret, false) and _gso.OB:_getDistance(v.pos, turret.pos) < range then
                                canContinue = false
                                break
                            end
                        end
                    end
                    if canContinue then
                        self.qParticles[k].active = true
                        if qMode == 1 and distanceToMouse < num then
                            qPos = v.pos
                            num = distanceToMouse
                        elseif qMode == 2 and distanceToHero < num then
                            qPos = v.pos
                            num = distanceToHero
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
        qPos = qPos:Extended(_G.mousePos, stopmove)
    end
    return qPos
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------draw-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoDraven:_draw()
    
    if self.menu.aset.catch:Value() and self.menu.aset.draw.enable:Value() then
        for k,v in pairs(self.qParticles) do
            if not v.success then
                if v.active then
                    Draw.Circle(v.pos, self.menu.aset.draw.good.radius:Value(), self.menu.aset.draw.good.width:Value(), self.menu.aset.draw.good.color:Value())
                else
                    Draw.Circle(v.pos, self.menu.aset.draw.bad.radius:Value(), self.menu.aset.draw.bad.width:Value(), self.menu.aset.draw.bad.color:Value())
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
  
    print("gamsteronAIO ".._gso.Vars.version.." | ezreal loaded!")
    
    self.menu = MenuElement({name = "Gamsteron Ezreal", id = "gsoMenuEzreal", type = MENU, leftIcon = "https://i.imgur.com/OURoL03.png"})
    self:_menu()
    
    self.lastQ    = 0
    self.lastW    = 0
    self.lastE    = 0
    self.delayedE = nil
    
    _gso.Orb.extraAnimT = self.menu.aacancel.anim:Value()*0.001
    _gso.Orb.extraWindUpT = self.menu.aacancel.windup:Value()*0.001
    
    _gso.Vars:_setCastSpells(function() self:_castSpells() end)
    _gso.Vars:_setCastSpellsAA(function() self:_castSpellsAA() end)
    _gso.Vars:_setOnTick(function() self:_tick() end)
    _gso.Vars:_setBonusDmg(function() return self:_dmg() end)
    
end



--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------menu---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoEzreal:_menu()
    self.menu:MenuElement({name = "AA Cancel Settings", id = "aacancel", type = MENU})
        self.menu.aacancel:MenuElement({name = "WindUp Delay - move", id = "windup", value = 50, min = 0, max = 300, step = 5 })
        self.menu.aacancel:MenuElement({name = "Anim Delay - attack", id = "anim", value = 25, min = 0, max = 300, step = 5 })
    self.menu:MenuElement({name = "Q settings", id = "qset", type = MENU })
        self.menu.qset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
        self.menu.qset:MenuElement({id = "combo", name = "Combo", value = true})
        self.menu.qset:MenuElement({id = "harass", name = "Harass", value = false})
    self.menu:MenuElement({name = "W settings", id = "wset", type = MENU })
        self.menu.wset:MenuElement({id = "hitchance", name = "Hitchance", value = 2, drop = { "normal", "high" } })
        self.menu.wset:MenuElement({id = "combo", name = "Combo", value = true})
        self.menu.wset:MenuElement({id = "harass", name = "Harass", value = false})
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
    
    local isCombo = _gso.Orb.menu.keys.combo:Value()
    local isHarass = _gso.Orb.menu.keys.harass:Value()
    
    local isComboQ = isCombo and self.menu.qset.combo:Value()
    local isHarassQ = isHarass and self.menu.qset.harass:Value()
    
    local isComboW = isCombo and self.menu.wset.combo:Value()
    local isHarassW = isHarass and self.menu.wset.harass:Value()
    
    if (isComboQ or isHarassQ) and qMinus > 1000 and wMinus > 350 and Game.CanUseSpell(_Q) == 0 then
        local target = _gso.TS:_getTarget(1150, true, false)
        if target ~= nil then
            local sW = { delay = 0.25, range = 1150, width = 60, speed = 2000, sType = "line", col = true }
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, myHero.pos, sW.col, sW.sType)
            if HitChance > self.menu.qset.hitchance:Value()-1 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(myHero.pos, castpos) < sW.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
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
            local sW = { delay = 0.25, range = 1150, width = 80, speed = 1550, sType = "line", col = false }
            local castpos,HitChance, pos = _gso.TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, myHero.pos, sW.col, sW.sType)
            if HitChance > self.menu.wset.hitchance:Value()-1 and castpos:ToScreen().onScreen and _gso.OB:_getDistance(myHero.pos, castpos) < sW.range and _gso.OB:_getDistance(target.pos, castpos) < 500 then
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



--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------tick----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

function __gsoEzreal:_tick()
    
    _gso.Orb.extraAnimT = self.menu.aacancel.anim:Value()*0.001
    _gso.Orb.extraWindUpT = self.menu.aacancel.windup:Value()*0.001
    
    local checkTick = GetTickCount()
    
    local qMinus = checkTick - self.lastQ
    local wMinus = checkTick - self.lastW
    local eMinus = checkTick - self.lastE
    
    if _gso.Orb.canAA == false and qMinus > 350 and wMinus > 350 and eMinus > 350 then
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

_gso.OB = __gsoOB()
_gso.TS = __gsoTS()
_gso.Farm = __gsoFarm()
_gso.TPred = __gsoTPred()
_gso.Orb = __gsoOrb()

function OnLoad()
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
end
