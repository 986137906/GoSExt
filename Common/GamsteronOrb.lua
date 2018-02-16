

--[[

    A P I :

        I. LOAD:
            1. require "GamsteronOrb"                                                         -> Declaration of Library
            2. gsoSDK.Load.Loaded                                                             -> Check if Library is loaded
                Example:
                    if gsoSDK and gsoSDK.Load and gsoSDK.Load.Loaded then
                        ..
                    end

        II. MENU:
            1. gsoSDK.Load.menu.orb.keys.combo:Value()                                        -> Combo Key
            2. gsoSDK.Load.menu.orb.keys.harass:Value()                                       -> Harass Key
            3. gsoSDK.Load.menu.orb.keys.lastHit:Value()                                      -> LastHit Key
            4. gsoSDK.Load.menu.orb.keys.laneClear:Value()                                    -> LaneClear Key

        III. OBJECT LISTS (access from event gsoSDK.Vars:_setOnTick):
            1. gsoSDK.OB.allyMinions                                                          -> Ally Minions
            2. gsoSDK.OB.enemyMinions                                                         -> Enemy Minions
            3. gsoSDK.OB.enemyHeroes                                                          -> Enemy Heroes
            4. gsoSDK.OB.enemyTurrets                                                         -> Enemy Turrets
            5. gsoSDK.Farm.almostLH                                                           -> Almost LastHitable Enemy Minions
            6. gsoSDK.Farm.laneClear                                                          -> LaneClearable Enemy Minions
            7. gsoSDK.Farm.lastHit                                                            -> LastHitable Enemy Minions
                Example for 1, 2, 3, 4, 5, 6:
                    for i = 1, #gsoSDK.OB.allyMinions do
                        local minion = gsoSDK.OB.allyMinions[i]
                    end
                Example for 7:
                    for i = 1, #gsoSDK.Farm.lastHit do
                        local minion = gsoSDK.Farm.lastHit[i][1]
                        local predictedHP = gsoSDK.Farm.lastHit[i][2]
                    end
        IV. IMPORTANT FUNCTIONS FOR SPELLS INTEGRATION:
            1. gsoSDK.Vars._manualSpell(spell)                                                -> use this in onTick event for manual spells ( tristana W, ezreal E, lucian E etc. ) -> this will use spell only if was used recently by user
                Example :
                    function tick()
                        gsoSDK.Vars._castManualSpell(_E)
                    end
            2. gsoSDK.Vars._canUseSpell()                                                     -> check if can use spells ( in this way cursor will always return to previous position )
                                                                                                 only if spell is changing cursorPos (ezreal q etc) - you don't need it for draven q, tristana q etc.
            3. gsoSDK.Vars._afterSpell()                                                      -> Use this after each spell usage ( in this way cursor will always return to previous position 
                Example :                                                                        only if spell is changing cursorPos (ezreal q etc) - you don't need it for draven q, tristana q etc.
                    if qReady and gsoSDK.Vars._canUseSpell() then
                        useQ()
                        gsoSDK.Vars._afterSpell()
                    end
        V. CALLBACKS:
            1. gsoSDK.Vars:_setOnTick(                                                        -> you can declare onTick via my orbwalker ( in this way you will have access to object lists [ look above at III. OBJECT LISTS ] )
                    function()
                        handleTwitchEBuffs()
                    end)  
            2. gsoSDK.Vars:_setOnKeyPress(
                    function(target)                                                          -> on key press - return current orb target (minion, turret, hero) -> can be nil
                        spells(target)
                    end)                                        
            3. gsoSDK.Vars:_setBonusDmg(                                                      -> return number ! - Declaration of myHero extra dmg [ important for laneclear, lasthit ]
                    function()
                        return caitPassive()
                    end)
            4. gsoSDK.Vars:_setBonusDmgUnit(                                                  -> return number ! - Declaration of myHero extra dmg [ important for laneclear, lasthit ]
                    function(minion)
                        return ashePassive(minion)
                    end)
            5. gsoSDK.Vars:_setOnAttack(                                                      -> you can disable current attack [ args.Process = false ], it's not recommended for spells like dravenQ -> use spells in beforeAttack event
                    function(args)                                                               onAttack event is good for champions like jhin, graves etc. -> passive buff check
                        args.Process = true
                        args.Target = getTarget()
                    end)
            6. gsoSDK.Vars:_setBeforeAttack(                                                  -> (anim*0.75)-(anim*0.9) before attack send (if anim = 1000 -> 150ms for spells)
                    function(unit)
                        castDravenQ()
                    end)
            7. gsoSDK.Vars:_setAfterAttack(                                                   -> afterMove-(anim*0.75) after/before attack send (if anim = 1000 -> ~550ms for spells) - smooth spells usage between attacks 
                    function(unit)
                        castVayneQ()
                    end)
            8. gsoSDK.Vars:_setOnMove(                                                        -> you can disable current move [ args.Process = false ],
                    function(args)                                                               args.MovePos = nil - will move to mousePos without changing cursorPos (don't setup mousePos via args.MovePos ! )
                        args.Process = true
                        if axe then
                            args.MovePos = DravenAxe()
                        else
                            args.MovePos = nil
                        end
                    end)
            9. gsoSDK.Vars:_setAASpeed(                                                       -> set custom attack speed -> gos ext .attackSpeed is delayed -> you can declare attack speed after ashe q buff ends for 1sec
                    function(unit)                                                               (else ashe can stand longer after q buff ends)
                        if Game.Timer() < AsheQBuffEndTime + 1000 then
                            return asBeforeQ
                        end
                    end)
        VI. ADDITIONAL:
            1. gsoSDK.Utils:_checkWall(from, to, distance)                                    -> return true if collide with wall
            2. gsoSDK.Utils.maxPing                                                           -> return seconds (for example 0.001) -> maxPing from last 2.5 sec
            3. gsoSDK.Utils.minPing                                                           -> return seconds (for example 0.001) -> minPing from last 2.5 sec
            4. gsoSDK.Utils:_getDistance(a, b)                                                -> return distance between pos a and b
            5. gsoSDK.Utils:_isImmortal(unit, orb)                                            -> return true if enemy hero has kayle R, taric R etc. orb = true for attacks and ezreal q, else orb = false
                                                                                                 gos ext .isImmortal return true for enemies that have GA item
            6. gsoSDK.Orb.lMovePath                                                           -> return last move position
            7. gsoSDK.TS:_getTarget(range, orb, changeRange)                                  -> range = [number] spell range, orb = [boolean] true for attacks and ezreal q else false, changeRange = [boolean] true if attack range, false for spells range
            8. gsoSDK.Vars._canMove()                                                         -> true/false
]]

local GetTickCount = GetTickCount
local Game = Game
local myHero = myHero
local Control = Control
local mathSqrt = math.sqrt
local Vector = Vector
local Draw = Draw
gsoSDK = {
  Vars = nil,
  Spells = nil,
  Utils = nil,
  OB = nil,
  TS = nil,
  Farm = nil,
  Orb = nil,
  Load = nil
}
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
class "__gsoVars"
--
--
--
function __gsoVars:__init()
    self.version = "1.0"
    self.Icons = {
        ["gsoaio"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/gsoaio.png",
        ["orb"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/orb.png",
        ["ts"] = "https://raw.githubusercontent.com/gamsteron/GoSExt/master/Icons/ts.png"
    }
    self._afterSpell    = function() gsoSDK.Orb.dActions[GetTickCount()] = { function() return 0 end, 50 }; gsoSDK.Orb.dActionsC = gsoSDK.Orb.dActionsC + 1 end
    self._canUseSpell   = function() return gsoSDK.Orb.dActionsC == 0 end
    self._aaSpeed       = function() return myHero.attackSpeed end
    self._bonusDmg      = function() return 0 end
    self._bonusDmgUnit  = function(minion) return 0 end
    self._onAttack      = function(args) return 0 end
    self._onMove        = function(args) return 0 end
    self._beforeAttack  = function(unit) return 0 end
    self._afterAttack   = function(unit) return 0 end
    self._onTick        = function() return 0 end
    self._onKeyPress    = function() return 0 end
    self._manualSpell   = function(spell) self:_castManualSpell(spell) end
    self._canMove       = function() return gsoSDK.Orb.canMove == true and Game.Timer() > gsoSDK.Orb.lAttack + gsoSDK.Orb.windUpT + 0.1 + gsoSDK.Utils.maxPing end
    self._lastSpell     = 0
end
function __gsoVars:_setAASpeed(func) self._aaSpeed = func end
function __gsoVars:_setBonusDmg(func) self._bonusDmg = func end
function __gsoVars:_setBonusDmgUnit(func) self._bonusDmgUnit = func end
function __gsoVars:_setOnAttack(func) self._onAttack = func end
function __gsoVars:_setOnMove(func) self._onMove = func end
function __gsoVars:_setBeforeAttack(func) self._beforeAttack = func end
function __gsoVars:_setAfterAttack(func) self._afterAttack = func end
function __gsoVars:_setOnTick(func) self._onTick = func end
function __gsoVars:_setOnKeyPress(func) self._onKeyPress = func end
function __gsoVars:_castManualSpell(spell)
    local getTick = GetTickCount()
    if getTick - self._lastSpell > 1000 and Game.CanUseSpell(spell) == 0 then
        local dActions = gsoAIO.Spells.delayedSpell
        for k,v in pairs(dActions) do
            if k == 2 then
                if gsoAIO.Orb.dActionsC == 0 then
                    v[1]()
                    self._lastSpell = getTick
                    gsoAIO.Orb.dActions[GetTickCount()] = { function() return 0 end, 50 }
                    gsoAIO.Orb.dActionsC = gsoAIO.Orb.dActionsC + 1
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
end
gsoSDK.Vars = __gsoVars()
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
class "__gsoSpells"
--
--
--
function __gsoSpells:__init()
    self.lastQ    = 0
    self.lastW    = 0
    self.lastE    = 0
    self.lastR    = 0
    self.delayedSpell = {}
    Callback.Add('WndMsg', function(msg, wParam) self:_onWndMsg(msg, wParam) end)
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoSpells:_onWndMsg(msg, wParam)
    local getTick = GetTickCount()
    local isKey = gsoSDK.Load.menu.orb.keys.combo:Value() or gsoSDK.Load.menu.orb.keys.harass:Value() or gsoSDK.Load.menu.orb.keys.laneClear:Value() or gsoSDK.Load.menu.orb.keys.lastHit:Value()
    if Game.CanUseSpell(_Q) == 0 and wParam == HK_Q and getTick > self.lastQ + 1000 then
        self.lastQ = getTick
        if isKey and not self.delayedSpell[0] then
            self.delayedSpell[0] = { function() gsoSDK.Utils:_castAgain(wParam) end, getTick }
        end
    elseif Game.CanUseSpell(_W) == 0 and wParam == HK_W and getTick > self.lastW + 1000 then
        self.lastW = getTick
        if isKey and not self.delayedSpell[1] then
            self.delayedSpell[1] = { function() gsoSDK.Utils:_castAgain(wParam) end, getTick }
        end
    elseif Game.CanUseSpell(_E) == 0 and wParam == HK_E and getTick > self.lastE + 1000 then
        self.lastE = getTick
        if isKey and not self.delayedSpell[2] then
            self.delayedSpell[2] = { function() gsoSDK.Utils:_castAgain(wParam) end, getTick }
        end
    elseif Game.CanUseSpell(_R) == 0 and wParam == HK_R and getTick > self.lastR + 1000 then
        self.lastR = getTick
        if isKey and not self.delayedSpell[3] then
            self.delayedSpell[3] = { function() gsoSDK.Utils:_castAgain(wParam) end, getTick }
        end
    end
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
class "__gsoUtils"
--
--
--
function __gsoUtils:__init()
    self.latencies = {}
    self.maxPing = Game.Latency() * 0.001
    self.minPing = Game.Latency() * 0.001
    self.delayedActions = {}
    self.attacks = {
        ["caitlynheadshotmissile"] = true,
        ["quinnwenhanced"] = true,
        ["viktorqbuff"] = true
    }
    self.noAttacks = {
        ["volleyattack"] = true,
        ["volleyattackwithsound"] = true,
        ["sivirwattackbounce"] = true,
        ["asheqattacknoonhit"] = true
    }
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
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoUtils:_tick()
    self.latencies[GetTickCount() + 2500] = Game.Latency() * 0.001
    local maxPing = 0
    local minPing = 50
    for k,v in pairs(self.latencies) do
        if v > maxPing then
            maxPing = v
        end
        if v < minPing then
            minPing = v
        end
        if GetTickCount() > k then
            self.latencies[k] = nil
        end
    end
    self.maxPing = maxPing
    self.minPing = minPing
    for i = 1, #gsoSDK.Utils.delayedActions do
        local dAction = gsoSDK.Utils.delayedActions[i]
        if Game.Timer() > dAction.endTime then
            dAction.func()
            gsoSDK.Utils.delayedActions[i] = nil
        end
    end
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoUtils:_getDistance(a, b)
  local x = a.x - b.x
  local z = a.z - b.z
  return mathSqrt(x * x + z * z)
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
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
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoUtils:_valid(unit, orb)
    if not unit or self:_isImmortal(unit, orb) then
        return false
    end
    if not unit.dead and unit.isTargetable and unit.visible and unit.valid then
        return true
    end
    return false
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoUtils:_castAgain(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoUtils:_hasBuff(unit, bName)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == bName then
            return true
        end
    end
    return false
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoUtils:_checkWall(from, to, distance)
    local pos1 = to + (to-from):Normalized() * 50
    local pos2 = pos1 + (to-from):Normalized() * (distance - 50)
    local point1 = Point(pos1.x, pos1.z)
    local point2 = Point(pos2.x, pos2.z)
    if (MapPosition:inWall(point1) and MapPosition:inWall(point2)) or MapPosition:intersectsWall(LineSegment(point1, point2)) then
        return true
    end
    return false
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
class "__gsoOB"
--
--
--
function __gsoOB:__init()
    self.allyMinions  = {}
    self.enemyMinions = {}
    self.enemyHeroes  = {}
    self.enemyTurrets = {}
    self.meTeam       = myHero.team
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoOB:_tick()
    local mePos = myHero.pos
    for i=1, #self.allyMinions do self.allyMinions[i]=nil end
    for i=1, #self.enemyMinions do self.enemyMinions[i]=nil end
    for i=1, #self.enemyHeroes do self.enemyHeroes[i]=nil end
    for i=1, #self.enemyTurrets do self.enemyTurrets[i]=nil end
    for i = 1, Game.MinionCount() do
        local minion = Game.Minion(i)
        if minion and gsoSDK.Utils:_getDistance(mePos, minion.pos) < 2000 and not minion.dead and minion.isTargetable and minion.visible and minion.valid and not minion.isImmortal then
            if minion.team ~= self.meTeam then
                self.enemyMinions[#self.enemyMinions+1] = minion
            else
                self.allyMinions[#self.allyMinions+1] = minion
            end
        end
    end
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if hero and hero.team ~= self.meTeam and gsoSDK.Utils:_getDistance(mePos, hero.pos) < 10000 and not hero.dead and hero.isTargetable and hero.visible and hero.valid then
            self.enemyHeroes[#self.enemyHeroes+1] = hero
        end
    end
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        if turret and turret.team ~= self.meTeam and gsoSDK.Utils:_getDistance(mePos, turret.pos) < 2000 and not turret.dead and turret.isTargetable and turret.visible and turret.valid and not turret.isImmortal then
            self.enemyTurrets[#self.enemyTurrets+1] = turret
        end
    end
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
class "__gsoTS"
--
--
--
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
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoTS:_getTarget(_range, orb, changeRange)
    if gsoSDK.Load.menu.ts.selected.only:Value() == true and gsoSDK.Utils:_valid(self.selectedTarget, true) then
        return self.selectedTarget
    end
    local result  = nil
    local num     = 10000000
    local mode    = gsoSDK.Load.menu.ts.Mode:Value()
    local prioT  = { 10000000, 10000000 }
    for i = 1, #gsoSDK.OB.enemyHeroes do
        local unit = gsoSDK.OB.enemyHeroes[i]
        local unitID = unit.networkID
        local canTrist = gsoSDK.Vars.meTristana and gsoSDK.Load.menu.ts.tristE.enable:Value() and gsoSDK.Vars.tristanaETar and gsoSDK.Vars.tristanaETar.stacks >= gsoSDK.Load.menu.ts.tristE.stacks:Value() and unitID == gsoSDK.Vars.tristanaETar.id
        local range = changeRange == true and _range + myHero.boundingRadius + unit.boundingRadius or _range
        local meExtended = myHero.pos:Extended(gsoSDK.Orb.lMovePath , (0.15+(gsoSDK.Utils.maxPing*1.5)) * myHero.ms)
        local dist1 = gsoSDK.Utils:_getDistance(myHero.pos, unit.pos)
        local dist2 = gsoSDK.Utils:_getDistance(meExtended, unit.pos)
        local dist3 = dist2 > dist1 and dist2 or dist1
        if gsoSDK.Utils:_valid(unit, orb) and dist3 < range then
            if gsoSDK.Load.menu.ts.selected.enable:Value() and self.selectedTarget and unitID == self.selectedTarget.networkID then
                return self.selectedTarget
            elseif canTrist then
                return unit
            elseif mode == 1 then
                local unitName = unit.charName
                local priority = 6
                if unitName ~= nil then
                    priority = gsoSDK.Load.menu.ts.priority[unitName] and gsoSDK.Load.menu.ts.priority[unitName]:Value() or priority
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
                    priority = gsoSDK.Load.menu.ts.priority[unitName] and gsoSDK.Load.menu.ts.priority[unitName]:Value() or priority
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
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
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
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoTS:_lastHitT()
    local result  = nil
    local min     = 10000000
    for i = 1, #gsoSDK.Farm.lastHit do
        local eMinionLH = gsoSDK.Farm.lastHit[i]
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
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoTS:_getTurret()
    local result = nil
    for i=1, #gsoSDK.OB.enemyTurrets do
        local turret = gsoSDK.OB.enemyTurrets[i]
        local range = myHero.range + myHero.boundingRadius + turret.boundingRadius
        if gsoSDK.Utils:_getDistance(myHero.pos, turret.pos) < range then
            result = turret
            break
        end
    end
    return result
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoTS:_laneClearT()
    local result	= self:_lastHitT()
    if not result then
        result = self:_comboT()
        if not result and #gsoSDK.Farm.almostLH == 0 and gsoSDK.Farm.shouldWait == false then
            result = self:_getTurret()
            if not result then
                local min = 10000000
                for i = 1, #gsoSDK.Farm.laneClear do
                    local minion = gsoSDK.Farm.laneClear[i]
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
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoTS:_harassT()
    local result = self:_lastHitT()
    return result == nil and self:_comboT() or result
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoTS:_draw()
    if gsoSDK.Load.menu.ts.selected.draw.enable:Value() == true and gsoSDK.Utils:_valid(self.selectedTarget, true) then
        Draw.Circle(self.selectedTarget.pos, gsoSDK.Load.menu.ts.selected.draw.radius:Value(), gsoSDK.Load.menu.ts.selected.draw.width:Value(), gsoSDK.Load.menu.ts.selected.draw.color:Value())
    end
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoTS:_tick()
    if gsoSDK.TS.isTeemo == true then
        self.isBlinded = gsoSDK.Utils:_hasBuff(myHero, "blindingdart")
    end
    if self.loadedChamps == false then
        for i = 1, Game.HeroCount() do
            local hero = Game.Hero(i)
            if hero.team ~= gsoSDK.OB.meTeam then
                local eName = hero.charName
                if eName and #eName > 0 and not gsoSDK.Load.menu.ts.priority[eName] then
                    self.lastFound = Game.Timer()
                    local priority = gsoSDK.Utils.Priorities[eName] ~= nil and gsoSDK.Utils.Priorities[eName] or 5
                    gsoSDK.Load.menu.ts.priority:MenuElement({ id = eName, name = eName, value = priority, min = 1, max = 5, step = 1 })
                    if eName == "Teemo" then          self.isTeemo = true
                    elseif eName == "Kayle" then      gsoSDK.Utils.undyingBuffs["JudicatorIntervention"] = true
                    elseif eName == "Taric" then      gsoSDK.Utils.undyingBuffs["TaricR"] = true
                    elseif eName == "Kindred" then    gsoSDK.Utils.undyingBuffs["kindredrnodeathbuff"] = true
                    elseif eName == "Zilean" then     gsoSDK.Utils.undyingBuffs["ChronoShift"] = true; gsoSDK.Utils.undyingBuffs["chronorevive"] = true
                    elseif eName == "Tryndamere" then gsoSDK.Utils.undyingBuffs["UndyingRage"] = true
                    elseif eName == "Jax" then        gsoSDK.Utils.undyingBuffs["JaxCounterStrike"] = true
                    elseif eName == "Fiora" then      gsoSDK.Utils.undyingBuffs["FioraW"] = true
                    elseif eName == "Aatrox" then     gsoSDK.Utils.undyingBuffs["aatroxpassivedeath"] = true
                    elseif eName == "Vladimir" then   gsoSDK.Utils.undyingBuffs["VladimirSanguinePool"] = true
                    elseif eName == "KogMaw" then     gsoSDK.Utils.undyingBuffs["KogMawIcathianSurprise"] = true
                    elseif eName == "Karthus" then    gsoSDK.Utils.undyingBuffs["KarthusDeathDefiedBuff"] = true
                    end
                end
            end
        end
        if Game.Timer() > self.lastFound + 5 and Game.Timer() < self.lastFound + 10 then
            self.loadedChamps = true
        end
    end
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoTS:_onWndMsg(msg, wParam)
    local getTick = GetTickCount()
    if msg == WM_LBUTTONDOWN and gsoSDK.Load.menu.ts.selected.enable:Value() == true then
        if getTick > self.lastSelTick + 100 and getTick > gsoSDK.Spells.lastQ + 250 and getTick > gsoSDK.Spells.lastW + 250 and getTick > gsoSDK.Spells.lastE + 250 and getTick > gsoSDK.Spells.lastR + 250 then 
            local num = 10000000
            local enemy = nil
            for i = 1, #gsoSDK.OB.enemyHeroes do
                local hero = gsoSDK.OB.enemyHeroes[i]
                local heroPos = hero.pos
                if gsoSDK.Utils:_valid(hero, true) and gsoSDK.Utils:_getDistance(myHero.pos, heroPos) < 10000 then
                    local distance = gsoSDK.Utils:_getDistance(heroPos, mousePos)
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
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
class "__gsoFarm"
--
--
--
function __gsoFarm:__init()
    self.aaDmg          = myHero.totalDamage
    self.lastHit        = {}
    self.almostLH       = {}
    self.laneClear      = {}
    self.aAttacks       = {}
    self.shouldWaitT    = 0
    self.shouldWait     = false
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoFarm:_tick()
    self.aaDmg   = myHero.totalDamage + gsoSDK.Vars._bonusDmg()
    if self.shouldWait == true and Game.Timer() > self.shouldWaitT + 0.5 then
        self.shouldWait = false
    end
    self:_setActiveAA()
    self:_handleActiveAA()
    self:_setEnemyMinions()
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoFarm:_predPos(speed, pPos, unit)
    local unitPath = unit.pathing
    if unitPath.hasMovePath == true then
        local uPos    = unit.pos
        local ePos    = unitPath.endPos
        local distUP  = gsoSDK.Utils:_getDistance(pPos, uPos)
        local distEP  = gsoSDK.Utils:_getDistance(pPos, ePos)
        local unitMS  = unit.ms
        if distEP > distUP then
            return uPos:Extended(ePos, 50+(unitMS*(distUP / (speed - unitMS))))
        else
            return uPos:Extended(ePos, 50+(unitMS*(distUP / (speed + unitMS))))
        end
    end
    return unit.pos
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoFarm:_possibleDmg(eMin, time)
    local result = 0
    for i = 1, #gsoSDK.OB.allyMinions do
        local aMin = gsoSDK.OB.allyMinions[i]
        local aaData  = aMin.attackData
        local aDmg    = (aMin.totalDamage*(1+aMin.bonusDamagePercent))
        if aaData.target == eMin.handle then
            local endT    = aaData.endTime
            local animT   = aaData.animationTime
            local windUpT = aaData.windUpTime
            local pSpeed  = aaData.projectileSpeed
            local pFlyT   = pSpeed > 0 and gsoSDK.Utils:_getDistance(aMin.pos, eMin.pos) / pSpeed or 0
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
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoFarm:_setEnemyMinions()
    for i=1, #self.lastHit do self.lastHit[i]=nil end
    for i=1, #self.almostLH do self.almostLH[i]=nil end
    for i=1, #self.laneClear do self.laneClear[i]=nil end
    local mLH = gsoSDK.Load.menu.orb.delays.lhDelay:Value()*0.001
    for i = 1, #gsoSDK.OB.enemyMinions do
        local eMinion = gsoSDK.OB.enemyMinions[i]
        local eMinion_handle	= eMinion.handle
        local distance = gsoSDK.Utils:_getDistance(myHero.pos, eMinion.pos)
        if distance < myHero.range + myHero.boundingRadius + eMinion.boundingRadius then
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
            local myHero_dmg = self.aaDmg + gsoSDK.Vars._bonusDmgUnit(eMinion)
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
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoFarm:_setActiveAA()
    for i = 1, #gsoSDK.OB.allyMinions do
        local aMinion = gsoSDK.OB.allyMinions[i]
        local aHandle	= aMinion.handle
        local aAAData	= aMinion.attackData
        if aAAData.endTime > Game.Timer() then
            for i = 1, #gsoSDK.OB.enemyMinions do
                local eMinion = gsoSDK.OB.enemyMinions[i]
                local eHandle	= eMinion.handle
                if eHandle == aAAData.target then
                    local checkT		= Game.Timer()
                    -- p -> projectile
                    local pSpeed  = aAAData.projectileSpeed
                    local aMPos   = aMinion.pos
                    local eMPos   = eMinion.pos
                    local pFlyT		= pSpeed > 0 and gsoSDK.Utils:_getDistance(aMPos, eMPos) / pSpeed or 0
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
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
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
                    self.aAttacks[k1][k2].pTime = gsoSDK.Utils:_getDistance(v2.fromPos, self:_predPos(v2.speed, v2.pos, v2.to)) / v2.speed
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
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
class "__gsoOrb"
--
--
--
function __gsoOrb:__init()
    
    --[[ move if stop holding orb key ]]
    self.lastKey      = 0
    
    --[[ orbwalker ]]
    self.canMove      = true
    self.canAA        = true
    self.aaReset      = false
    self.lAttack      = 0
    self.lMove        = 0
    self.lMovePath    = mousePos
    
    --[[ delayed actions ]]
    self.dActionsC    = 0
    self.dActions     = {}
    
    --[[ local aa data ]]
    self.baseAASpeed  = 0
    self.baseWindUp   = 0
    self.windUpT      = 0
    self.animT        = 0
    
    --[[ server aa data ]]
    self.serverStart = 0
    self.serverWindup = 0
    self.serverAnim = 0
    
    --[[ callbacks ]]
    Callback.Add('Tick', function() self:_tick() end)
    Callback.Add('Draw', function() self:_draw() end)
    Callback.Add('WndMsg', function(msg, wParam) self:_onWndMsg(msg, wParam) end)
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoOrb:_onWndMsg(msg, wParam)
    if wParam == HK_TCO then
        self.lAttack = Game.Timer()
    end
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoOrb:_orb(unit)
    
    if self.baseAASpeed == 0 then
        self.baseAASpeed  = 1 / myHero.attackData.animationTime / myHero.attackSpeed
    end
    if self.baseWindUp == 0 then
        self.baseWindUp = myHero.attackData.windUpTime / myHero.attackData.animationTime
    end
    
    local aaSpeed = gsoSDK.Vars._aaSpeed() * self.baseAASpeed
    local numAS   = aaSpeed >= 2.5 and 2.5 or aaSpeed
    local animT   = 1 / numAS
    local windUpT = animT * self.baseWindUp
    self.serverAnim = aaSpeed >= 2.5 and animT or self.serverAnim
    self.serverWindup = aaSpeed >= 2.5 and windUpT or self.serverWindup
    local extraWindUp = math.abs(windUpT-self.serverWindup) + (gsoSDK.Load.menu.orb.delays.windup:Value() * 0.001)
    local windUpAA = windUpT > self.serverWindup and self.serverWindup or windUpT
    self.windUpT = windUpT > self.serverWindup and windUpT or self.serverWindup
    self.animT = animT > self.serverAnim and animT or self.serverAnim
    
    local unitValid = unit and not unit.dead and unit.isTargetable and unit.visible and unit.valid
    if unitValid and unit.type == Obj_AI_Hero then
        unitValid = gsoSDK.Utils:_isImmortal(unit, true) == false
    end
    local meExtended = unitValid and myHero.pos:Extended(self.lMovePath, (0.15+(gsoSDK.Utils.maxPing*1.5)) * myHero.ms) or nil
    local dist1 = unitValid and gsoSDK.Utils:_getDistance(myHero.pos, unit.pos) or 0
    local dist2 = unitValid and gsoSDK.Utils:_getDistance(meExtended, unit.pos) or 0
    local dist3 = dist2 > dist1 and dist2 or dist1
    local inAARange = unitValid and dist3 < myHero.range + myHero.boundingRadius + unit.boundingRadius
    if not unitValid or not inAARange then
        unit = nil
    end
    
    local canOrb  = self.dActionsC == 0
    self.canAA    = canOrb and not gsoSDK.TS.isBlinded and (self.aaReset or Game.Timer() > self.serverStart - windUpAA + self.animT - gsoSDK.Utils.minPing - 0.05 )
    self.canMove  = canOrb and Game.Timer() > self.serverStart + extraWindUp - (gsoSDK.Utils.minPing*0.5)
    
    gsoSDK.Vars._onKeyPress(unit)
    
    if not self.canAA and self.canMove and Game.Timer() > gsoSDK.Orb.lAttack + gsoSDK.Orb.windUpT + 0.1 + gsoSDK.Utils.maxPing then
        if Game.Timer() < self.lAttack + (self.animT*0.75) then
            gsoSDK.Vars._afterAttack(unit)
        elseif Game.Timer() < self.lAttack + (self.animT*0.9) then
            gsoSDK.Vars._beforeAttack(unit)
        end
    end
    
    if unit ~= nil and self.canAA then
        self:_attack(unit)
    elseif self.canMove and Game.Timer() > self.lMove + (gsoSDK.Load.menu.orb.delays.humanizer:Value()*0.001) then
        self:_move()
    end
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoOrb:_tick()

--  DISABLE IN EVADING TIME :
    if ExtLibEvade and ExtLibEvade.Evading then return end

--  OBJECT TICK :
    gsoSDK.OB:_tick()

--  FARM TICK :
    gsoSDK.Farm:_tick()

--  ADDON TICK :
    gsoSDK.Vars._onTick()

--  HANDLE DELAYED ACTIONS :
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

--  GET SERVER AA DATA :
    local aSpell = myHero.activeSpell
    local aSpellName = aSpell.name:lower()
    if not gsoSDK.Utils.noAttacks[aSpellName] and (aSpellName:find("attack") or gsoSDK.Utils.attacks[aSpellName]) and aSpell.startTime > self.serverStart then
        self.serverStart = aSpell.startTime
        self.serverWindup = aSpell.windup
        self.serverAnim = aSpell.animation
    end

--  EXECUTE MODES :
    local ck  = gsoSDK.Load.menu.orb.keys.combo:Value()
    local hk  = gsoSDK.Load.menu.orb.keys.harass:Value()
    local lhk = gsoSDK.Load.menu.orb.keys.lastHit:Value()
    local lck = gsoSDK.Load.menu.orb.keys.laneClear:Value()
    if Game.IsChatOpen() == false and (ck or hk or lhk or lck) then
        local AAtarget = nil
        if ck then
            AAtarget = gsoSDK.TS:_comboT()
        elseif hk then
            AAtarget = gsoSDK.TS:_harassT()
        elseif lhk then
            AAtarget = gsoSDK.TS:_lastHitT()
        elseif lck then
            AAtarget = gsoSDK.TS:_laneClearT()
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
        self.lastKey = 0
    end
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoOrb:_attack(unit)
    if ExtLibEvade and ExtLibEvade.Evading then return end
    local args = { Process = true, Target = unit }
    gsoSDK.Vars._onAttack(args)
    if not args.Process then
        return
    else
        unit = args.Target
    end
    if not unit then return end
    self.aaReset = false
    self.lMove = 0
    local cPos = cursorPos
    Control.SetCursorPos(unit.pos)
    Control.KeyDown(HK_TCO)
    Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
    Control.mouse_event(MOUSEEVENTF_RIGHTUP)
    Control.KeyUp(HK_TCO)
    self.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
    self.dActionsC = self.dActionsC + 1
    if gsoSDK.Vars.meTristana and gsoSDK.Vars.tristanaETar and gsoSDK.Vars.tristanaETar.id == unit.networkID then
        gsoSDK.Vars.tristanaETar.stacks = gsoSDK.Vars.tristanaETar.stacks + 1
        if gsoSDK.Vars.tristanaETar.stacks == 5 then
            gsoSDK.Utils.delayedActions[#gsoSDK.Utils.delayedActions+1] = { func = function() gsoSDK.Vars.tristanaETar = nil end, endTime = Game.Timer() + self.windUpT + (gsoSDK.Utils:_getDistance(myHero.pos, unit.pos) / 2000) }
        end
    end
    self.lAttack = Game.Timer()
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoOrb:_move()
    local args = { Process = true, MovePos = nil }
    gsoSDK.Vars._onMove(args)
    if not args.Process then
        return
    end
    local mPos = args.MovePos
    if mPos ~= nil then
        if ExtLibEvade and ExtLibEvade.Evading then return end
        if Control.IsKeyDown(2) then self.lastKey = GetTickCount() end
        local cPos = cursorPos
        Control.SetCursorPos(mPos)
        self.lMovePath = mPos
        Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
        Control.mouse_event(MOUSEEVENTF_RIGHTUP)
        self.dActions[GetTickCount()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
        self.dActionsC = self.dActionsC + 1
        self.lMove = Game.Timer()
    else
        if ExtLibEvade and ExtLibEvade.Evading then return end
        if Control.IsKeyDown(2) then self.lastKey = GetTickCount() end
        self.lMovePath = mousePos
        Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
        Control.mouse_event(MOUSEEVENTF_RIGHTUP)
        self.lMove = Game.Timer()
    end
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoOrb:_draw()
    if not gsoSDK.Load.menu.orb.draw.enable:Value() then return end
    local mePos = myHero.pos
    if gsoSDK.Load.menu.orb.draw.me.enable:Value() and not myHero.dead and mePos:ToScreen().onScreen then
        Draw.Circle(mePos, myHero.range + myHero.boundingRadius + 35, gsoSDK.Load.menu.orb.draw.me.width:Value(), gsoSDK.Load.menu.orb.draw.me.color:Value())
    end
    if gsoSDK.Load.menu.orb.draw.he.enable:Value() then
        local countEH = #gsoSDK.OB.enemyHeroes
        for i = 1, countEH do
            local hero = gsoSDK.OB.enemyHeroes[i]
            local heroPos = hero.pos
            if gsoSDK.Utils:_getDistance(mePos, heroPos) < 2000 and heroPos:ToScreen().onScreen then
                Draw.Circle(heroPos, hero.range + hero.boundingRadius + 35, gsoSDK.Load.menu.orb.draw.he.width:Value(), gsoSDK.Load.menu.orb.draw.he.color:Value())
            end
        end
    end
    if gsoSDK.Load.menu.orb.draw.cpos.enable:Value() then
        Draw.Circle(mousePos, gsoSDK.Load.menu.orb.draw.cpos.radius:Value(), gsoSDK.Load.menu.orb.draw.cpos.width:Value(), gsoSDK.Load.menu.orb.draw.cpos.color:Value())
    end
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
class "__gsoLoad"
--
--
--
function __gsoLoad:__init()
    self.menu = MenuElement({name = "Gamsteron Orbwalker", id = "gamsteronorb", type = MENU, leftIcon = gsoSDK.Vars.Icons["gsoaio"] })
    Callback.Add('Load', function() self:_load() end)
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
function __gsoLoad:_load()
    self.menu:MenuElement({name = "Target Selector", id = "ts", type = MENU, leftIcon = gsoSDK.Vars.Icons["ts"] })
        self.menu.ts:MenuElement({ id = "Mode", name = "Mode", value = 1, drop = { "Auto", "Closest", "Least Health", "Least Priority" } })
        self.menu.ts:MenuElement({ id = "priority", name = "Priorities", type = MENU })
        self.menu.ts:MenuElement({ id = "selected", name = "Selected Target", type = MENU })
            self.menu.ts.selected:MenuElement({ id = "enable", name = "Enable", value = true })
            self.menu.ts.selected:MenuElement({ id = "only", name = "Only Selected Target", value = false })
            self.menu.ts.selected:MenuElement({name = "Draw",  id = "draw", type = MENU})
                self.menu.ts.selected.draw:MenuElement({name = "Enable",  id = "enable", value = true})
                self.menu.ts.selected.draw:MenuElement({name = "Color",  id = "color", color = Draw.Color(255, 204, 0, 0)})
                self.menu.ts.selected.draw:MenuElement({name = "Width",  id = "width", value = 3, min = 1, max = 10})
                self.menu.ts.selected.draw:MenuElement({name = "Radius",  id = "radius", value = 150, min = 1, max = 300})
    self.menu:MenuElement({name = "Orbwalker", id = "orb", type = MENU, leftIcon = gsoSDK.Vars.Icons["orb"] })
        self.menu.orb:MenuElement({name = "Delays", id = "delays", type = MENU})
            self.menu.orb.delays:MenuElement({name = "Extra Kite Delay", id = "windup", value = 0, min = 0, max = 50, step = 1 })
            self.menu.orb.delays:MenuElement({name = "Extra LastHit Delay", id = "lhDelay", value = 0, min = 0, max = 50, step = 1 })
            self.menu.orb.delays:MenuElement({name = "Extra Move Delay", id = "humanizer", value = 200, min = 120, max = 300, step = 10 })
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
    
    gsoSDK.Spells = __gsoSpells()
    gsoSDK.Utils = __gsoUtils()
    gsoSDK.OB = __gsoOB()
    gsoSDK.TS = __gsoTS()
    gsoSDK.Farm = __gsoFarm()
    gsoSDK.Orb = __gsoOrb()
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
    print("Gamsteron Orb "..gsoSDK.Vars.version.." | loaded!")
    self.Loaded = true
end
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
--
--
--
gsoSDK.Load = __gsoLoad()
