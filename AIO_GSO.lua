


local gso_version = "0.48"
local gso_hName = myHero.charName
local gso_supportedChampions = {
    ["Ashe"] = true,
    ["KogMaw"] = true,
    ["Twitch"] = true,
    ["Draven"] = true,
    ["Ezreal"] = true
}
if not gso_supportedChampions[gso_hName] == true then
    print("gamsteronAIO "..gso_version.." | hero not supported !")
    return
end



--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------MENU-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
local gso_menu = MenuElement({name = "Gamsteron AIO", id = "gsomenuaio", type = MENU, leftIcon = "https://i.imgur.com/nahe4Ua.png"})
local function gso_loadMenu()
    gso_menu:MenuElement({name = "", id = "orb", type = MENU, leftIcon = "https://i.imgur.com/iQOVX4b.png"})
        gso_menu.orb:MenuElement({name = "Delays", id = "delays", type = MENU})
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
                gso_menu.orb.draw.me:MenuElement({name = "Enable", id = "enable", value = true})
                gso_menu.orb.draw.me:MenuElement({name = "Color", id = "color", color = Draw.Color(150, 49, 210, 0)})
                gso_menu.orb.draw.me:MenuElement({name = "Width", id = "width", value = 1, min = 1, max = 10})
            gso_menu.orb.draw:MenuElement({name = "Enemy attack range", id = "he", type = MENU})
                gso_menu.orb.draw.he:MenuElement({name = "Enable", id = "enable", value = true})
                gso_menu.orb.draw.he:MenuElement({name = "Color", id = "color", color = Draw.Color(150, 255, 0, 0)})
                gso_menu.orb.draw.he:MenuElement({name = "Width", id = "width", value = 1, min = 1, max = 10})
            gso_menu.orb.draw:MenuElement({name = "Cursor Posistion", id = "cpos", type = MENU})
                gso_menu.orb.draw.cpos:MenuElement({name = "Enable", id = "enable", value = true})
                gso_menu.orb.draw.cpos:MenuElement({name = "Color", id = "color", color = Draw.Color(150, 153, 0, 76)})
                gso_menu.orb.draw.cpos:MenuElement({name = "Width", id = "width", value = 5, min = 1, max = 10})
                gso_menu.orb.draw.cpos:MenuElement({name = "Radius", id = "radius", value = 250, min = 1, max = 300})
    gso_menu:MenuElement({name = "Target Selector", id = "ts", type = MENU, leftIcon = "https://i.imgur.com/vzoiheQ.png"})
        gso_menu.ts:MenuElement({name = "Mode", id = "mode", value = 1, drop = { "Auto", "Closest", "Least Health", "Least Priority" } })
        gso_menu.ts:MenuElement({name = "Priorities", id = "priority", type = MENU })
        gso_menu.ts:MenuElement({name = "Selected Target", id = "selected", type = MENU })
            gso_menu.ts.selected:MenuElement({name = "Enable", id = "enable", value = true })
            gso_menu.ts.selected:MenuElement({name = "Only Selected Target", id = "only", value = false })
            gso_menu.ts.selected:MenuElement({name = "Draw", id = "draw", type = MENU})
                gso_menu.ts.selected.draw:MenuElement({name = "Enable", id = "enable", value = true})
                gso_menu.ts.selected.draw:MenuElement({name = "Color", id = "color", color = Draw.Color(255, 204, 0, 0)})
                gso_menu.ts.selected.draw:MenuElement({name = "Width", id = "width", value = 3, min = 1, max = 10})
                gso_menu.ts.selected.draw:MenuElement({name = "Radius", id = "radius", value = 150, min = 1, max = 300})
end
local gso_ts_mode, gso_ts_sel_on, gso_ts_sel_only, gso_ts_sel_dr_on, gso_ts_sel_dr_col, gso_ts_sel_dr_wid, gso_ts_sel_dr_rad, gso_orb_del_lh
local gso_orb_del_hum, gso_orb_key_com, gso_orb_key_har, gso_orb_key_lh, gso_orb_key_lc, gso_orb_dr_on, gso_orb_dr_me_on, gso_orb_dr_me_col
local gso_orb_dr_me_wid, gso_orb_dr_he_on, gso_orb_dr_he_col, gso_orb_dr_he_wid, gso_orb_dr_cpos_on, gso_orb_dr_cpos_col, gso_orb_dr_cpos_wid
local gso_orb_dr_cpos_rad
local gso_menuT = 0
local function gso_refreshValues()
    gso_orb_key_com = gso_menu.orb.keys.combo:Value()
    gso_orb_key_har = gso_menu.orb.keys.harass:Value()
    gso_orb_key_lh = gso_menu.orb.keys.lastHit:Value()
    gso_orb_key_lc = gso_menu.orb.keys.laneClear:Value()
    if os.clock() > gso_menuT + 2 then
        gso_ts_mode = gso_menu.ts.mode:Value()
        gso_ts_sel_on = gso_menu.ts.selected.enable:Value()
        gso_ts_sel_only = gso_menu.ts.selected.only:Value()
        gso_ts_sel_dr_on = gso_menu.ts.selected.draw.enable:Value()
        gso_ts_sel_dr_col = gso_menu.ts.selected.draw.color:Value()
        gso_ts_sel_dr_wid = gso_menu.ts.selected.draw.width:Value()
        gso_ts_sel_dr_rad = gso_menu.ts.selected.draw.radius:Value()
        gso_orb_del_lh = gso_menu.orb.delays.lhDelay:Value()*0.001
        gso_orb_del_hum = gso_menu.orb.delays.humanizer:Value()*0.001
        gso_orb_dr_on = gso_menu.orb.draw.enable:Value()
        gso_orb_dr_me_on = gso_menu.orb.draw.me.enable:Value()
        gso_orb_dr_me_col = gso_menu.orb.draw.me.color:Value()
        gso_orb_dr_me_wid = gso_menu.orb.draw.me.width:Value()
        gso_orb_dr_he_on = gso_menu.orb.draw.he.enable:Value()
        gso_orb_dr_he_col = gso_menu.orb.draw.he.color:Value()
        gso_orb_dr_he_wid = gso_menu.orb.draw.he.width:Value()
        gso_orb_dr_cpos_on = gso_menu.orb.draw.cpos.enable:Value()
        gso_orb_dr_cpos_col = gso_menu.orb.draw.cpos.color:Value()
        gso_orb_dr_cpos_wid = gso_menu.orb.draw.cpos.width:Value()
        gso_orb_dr_cpos_rad = gso_menu.orb.draw.cpos.radius:Value()
        gso_menuT = os.clock()
    end
end



--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|----------------------LOCALS-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
local gso_tick = GetTickCount
local gso_myHero = myHero
local gso_myHeroT = {
    pos = gso_myHero.pos,
    mpen = gso_myHero.magicPen,
    mpenP = gso_myHero.magicPenPercent,
    apen = gso_myHero.armorPen,
    apenP = gso_myHero.bonusArmorPenPercent,
    dmg = gso_myHero.totalDamage,
    aa = gso_myHero.attackData
}
local gso_sqrt = math.sqrt
local _gso = {
  Farm = nil,
  TPred = nil,
  Orb = nil
}
local gso_selectedTarget = nil
local gso_lastSelTick = 0
local gso_delayedSpell = {}
local gso_lastQ = 0
local gso_lastW = 0
local gso_lastE = 0
local gso_lastR = 0
local gso_apDmg = gso_hName == "KogMaw" and true or false
local gso_allyMinions  = {}
local gso_enemyMinions = {}
local gso_enemyHeroes  = {}
local gso_enemyTurrets = {}
local gso_undyingBuffs = { ["zhonyasringshield"] = true }
local gso_enemyTeam = 300 - myHero.team
local gso_latency        = Game.Latency() * 0.001
local gso_aaDmg          = gso_myHeroT.dmg
local gso_lastHit        = {}
local gso_almostLH       = {}
local gso_laneClear      = {}
local gso_aAttacks       = {}
local gso_shouldWaitT    = 0
local gso_shouldWait     = false
local gso_canAA        = true
local gso_lAttack      = 0
local gso_lMove        = 0
local gso_isTeemo      = false
local gso_isBlinded    = false
local gso_lastTarget   = nil
local gso_extraWindUpT = 0
local gso_extraAnimT   = 0
local gso_windUpT      = gso_myHeroT.aa.windUpTime
local gso_animT        = gso_myHeroT.aa.animationTime
local gso_endTime      = gso_myHeroT.aa.endTime
local gso_dActions     = {}
local gso_dActionsC    = 0
local gso_loadedChamps = false
local gso_priorities = {
    ["Aatrox"] = 3, ["Ahri"] = 2, ["Akali"] = 2, ["Alistar"] = 5, ["Amumu"] = 5, ["Anivia"] = 2, ["Annie"] = 2, ["Ashe"] = 1, ["AurelionSol"] = 2, ["Azir"] = 2,
    ["Bard"] = 3, ["Blitzcrank"] = 5, ["Brand"] = 2, ["Braum"] = 5, ["Caitlyn"] = 1, ["Camille"] = 3, ["Cassiopeia"] = 2, ["Chogath"] = 5, ["Corki"] = 1, ["Darius"] = 4,
    ["Diana"] = 2, ["DrMundo"] = 5, ["Draven"] = 1, ["Ekko"] = 2, ["Elise"] = 3, ["Evelynn"] = 2, ["Ezreal"] = 1, ["Fiddlesticks"] = 3, ["Fiora"] = 3, ["Fizz"] = 2, ["Galio"] = 5,
    ["Gangplank"] = 2, ["Garen"] = 5, ["Gnar"] = 5, ["Gragas"] = 4, ["Graves"] = 2, ["Hecarim"] = 4, ["Heimerdinger"] = 3, ["Illaoi"] =  3, ["Irelia"] = 3, ["Ivern"] = 5,
    ["Janna"] = 4, ["JarvanIV"] = 3, ["Jax"] = 3, ["Jayce"] = 2, ["Jhin"] = 1, ["Jinx"] = 1, ["Kalista"] = 1, ["Karma"] = 2, ["Karthus"] = 2, ["Kassadin"] = 2, ["Katarina"] = 2,
    ["Kayle"] = 2, ["Kayn"] = 2, ["Kennen"] = 2, ["Khazix"] = 2, ["Kindred"] = 2, ["Kled"] = 4, ["KogMaw"] = 1, ["Leblanc"] = 2, ["LeeSin"] = 3, ["Leona"] = 5, ["Lissandra"] = 2,
    ["Lucian"] = 1, ["Lulu"] = 3, ["Lux"] = 2, ["Malphite"] = 5, ["Malzahar"] = 3, ["Maokai"] = 4, ["MasterYi"] = 1, ["MissFortune"] = 1, ["MonkeyKing"] = 3, ["Mordekaiser"] = 2,
    ["Morgana"] = 3, ["Nami"] = 3, ["Nasus"] = 4, ["Nautilus"] = 5, ["Nidalee"] = 2, ["Nocturne"] = 2, ["Nunu"] = 4, ["Olaf"] = 4, ["Orianna"] = 2, ["Ornn"] = 4, ["Pantheon"] = 3,
    ["Poppy"] = 4, ["Quinn"] = 1, ["Rakan"] = 3, ["Rammus"] = 5, ["RekSai"] = 4, ["Renekton"] = 4, ["Rengar"] = 2, ["Riven"] = 2, ["Rumble"] = 2, ["Ryze"] = 2, ["Sejuani"] = 4,
    ["Shaco"] = 2, ["Shen"] = 5, ["Shyvana"] = 4, ["Singed"] = 5, ["Sion"] = 5, ["Sivir"] = 1, ["Skarner"] = 4, ["Sona"] = 3, ["Soraka"] = 3, ["Swain"] = 3, ["Syndra"] = 2,
    ["TahmKench"] = 5, ["Taliyah"] = 2, ["Talon"] = 2, ["Taric"] = 5, ["Teemo"] = 2, ["Thresh"] = 5, ["Tristana"] = 1, ["Trundle"] = 4, ["Tryndamere"] = 2, ["TwistedFate"] = 2,
    ["Twitch"] = 1, ["Udyr"] = 4, ["Urgot"] = 4, ["Varus"] = 1, ["Vayne"] = 1, ["Veigar"] = 2, ["Velkoz"] = 2, ["Vi"] = 4, ["Viktor"] = 2, ["Vladimir"] = 3, ["Volibear"] = 4,
    ["Warwick"] = 4, ["Xayah"] = 1, ["Xerath"] = 2, ["XinZhao"] = 3, ["Yasuo"] = 2, ["Yorick"] = 4, ["Zac"] = 5, ["Zed"] = 2, ["Ziggs"] = 2, ["Zilean"] = 3, ["Zoe"] = 2, ["Zyra"] = 2
}



--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------CALLBACKS---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
local gso_drawChamp     = function() return 0 end
local gso_loadChampMenu = function() return 0 end
local gso_bonusDmg      = function() return 0 end
local gso_bonusDmgUnit  = function() return 0 end
local gso_onTick        = function() return 0 end
local gso_castSpells    = function() return 0 end
local gso_castSpellsAA  = function() return 0 end
local gso_beforeAA      = function() return 0 end
local gso_mousePos      = function() return nil end
local gso_canMove       = function() return true end
local gso_canAttack     = function() return true end
local function gso_setDrawChamp(func)     gso_drawChamp = func end
local function gso_setLoadChampMenu(func) gso_loadChampMenu = func end
local function gso_setBonusDmg(func)      gso_bonusDmg = func end
local function gso_setBonusDmgUnit(func)  gso_bonusDmgUnit = func end
local function gso_setOnTick(func)        gso_onTick = func end
local function gso_setCastSpells(func)    gso_castSpells = func end
local function gso_setCastSpellsAA(func)  gso_castSpellsAA = func end
local function gso_setBeforeAA(func)      gso_beforeAA = func end
local function gso_setMousePos(func)      gso_mousePos = func end
local function gso_setCanMove(func)       gso_canMove = func end
local function gso_setCanAttack(func)     gso_canAttack = func end



--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------LOCAL FUNCTIONS-----------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------ONLOAD---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
local function gso_loadChampions()
    if Game.Timer() > 6 then
      for i = 1, Game.HeroCount() do
          local hero = Game.Hero(i)
          if hero and hero.team == gso_enemyTeam then
              local eName = hero.charName
              if eName and #eName > 0 and not gso_menu.ts.priority[eName] then
                  local priority = gso_priorities[eName] ~= nil and gso_priorities[eName] or 5
                  gso_menu.ts.priority:MenuElement({ id = eName, name = eName, value = priority, min = 1, max = 5, step = 1 })
                  if eName == "Teemo" then          gso_isTeemo = true
                  elseif eName == "Kayle" then      gso_undyingBuffs["JudicatorIntervention"] = true
                  elseif eName == "Taric" then      gso_undyingBuffs["TaricR"] = true
                  elseif eName == "Kindred" then    gso_undyingBuffs["kindredrnodeathbuff"] = true
                  elseif eName == "Zilean" then     gso_undyingBuffs["ChronoShift"] = true; gso_undyingBuffs["chronorevive"] = true
                  elseif eName == "Jax" then        gso_undyingBuffs["JaxCounterStrike"] = true
                  elseif eName == "Fiora" then      gso_undyingBuffs["FioraW"] = true
                  elseif eName == "Aatrox" then     gso_undyingBuffs["aatroxpassivedeath"] = true
                  elseif eName == "Vladimir" then   gso_undyingBuffs["VladimirSanguinePool"] = true
                  elseif eName == "KogMaw" then     gso_undyingBuffs["KogMawIcathianSurprise"] = true
                  elseif eName == "Karthus" then    gso_undyingBuffs["KarthusDeathDefiedBuff"] = true
                  elseif eName == "Tryndamere" then gso_undyingBuffs["UndyingRage"] = true end
              end
          end
      end
      gso_loadedChamps = true
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|-------------------------MATH----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
local function gso_distance(x, z) return x*x+z*z end
local function gso_inDistance(x, z, s) return x*x+z*z<s*s end
local function gso_distanceSqrt(x, z) return gso_sqrt(x*x+z*z) end
local function gso_extended(s, ax, az, bx, bz, fromx, fromz)
    local axbx = ax - bx
    local azbz = az - bz
    local num = 1 / gso_sqrt(axbx * axbx + azbz * azbz)
    return fromx + (axbx * num * s), fromz + (azbz * num * s)
end
local function gso_predPos(speed, pos, unit)
    local unitPath = unit.pathing
    if unitPath.hasMovePath == true then
        local unitMS = unit.ms
        local uPos = unit.pos
        local ePos = unitPath.endPos
        local px, pz = pos.x, pos.z
        local ux, uz = uPos.x, uPos.z
        local ex, ez = ePos.x, ePos.z
        local distUP  = gso_distanceSqrt(px - ux, pz - uz)
        local distEP  = gso_distanceSqrt(px - ex, pz - ez)
        if distEP > distUP then
            local posx, posz = gso_extended(50+(unit.ms*(distUP / (speed - unit.ms))),ex,ez,ux,uz,ux,uz)
            return { x = posx, z = posz }
        else
            local posx, posz = gso_extended(50+(unit.ms*(distUP / (speed + unit.ms))),ex,ez,ux,uz,ux,uz)
            return { x = posx, z = posz }
        end
    end
    return unit.pos
end

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------VALID----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
local function gso_isImmortal(unit, orb)
    local unitHPPercent = 100 * unit.health / unit.maxHealth
    local lowerthan15 = unitHPPercent < 15
    if gso_undyingBuffs["UndyingRage"] ~= nil then         gso_undyingBuffs["UndyingRage"] = lowerthan15 end
    if gso_undyingBuffs["kindredrnodeathbuff"] ~= nil then gso_undyingBuffs["kindredrnodeathbuff"] = unitHPPercent < 10 end
    if gso_undyingBuffs["ChronoShift"] ~= nil then         gso_undyingBuffs["ChronoShift"] = lowerthan15; gso_undyingBuffs["chronorevive"] = lowerthan15 end
    if gso_undyingBuffs["JaxCounterStrike"] ~= nil then    gso_undyingBuffs["JaxCounterStrike"] = orb end
    for i = 1, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 then
            local undyingBuff = gso_undyingBuffs[buff.name]
            if undyingBuff and undyingBuff == true then
                return true
            end
        end
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------TARGET SELECTOR----------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
local function gso_getTarget(_range, orb, changeRange)
    if gso_ts_sel_only == true and gso_selectedTarget ~= nil then
        return gso_selectedTarget
    end
    local result  = nil
    local num     = 1000000000
    local prioT  = { 10000000, 10000000 }
    local mePos = gso_myHero.pos
    local mx, mz = mePos.x, mePos.z
    local mdef = gso_apDmg and gso_myHeroT.mpen or gso_myHeroT.apen
    local mdefp = gso_apDmg and gso_myHeroT.mpenP or gso_myHeroT.apenP
    for i = 1, #gso_enemyHeroes do
        local unit = gso_enemyHeroes[i]
        if not gso_isImmortal(unit, orb) then
            local hPos = unit.pos
            local hx, hz = hPos.x, hPos.z
            local range = changeRange and _range + gso_myHero.boundingRadius + unit.boundingRadius - 30 or _range
            local distance = gso_distance(mx-hx, mz-hz)
            if distance < range*range then
                if gso_ts_sel_on == true and gso_selectedTarget ~= nil and unit.networkID == gso_selectedTarget.networkID then
                    return gso_selectedTarget
                elseif gso_ts_mode == 1 then
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
                    local def = gso_apDmg and unit.magicResist - mdef or unit.armor - mdef
                    def = def * calcNum
                    if def > 0 then
                          def = gso_apDmg and mdefp * def or mdefp * def
                    end
                    local hpE = unit.health
                    hpE = hpE * calcNum
                    hpE = hpE * ( ( 100 + def ) / 100 )
                    hpE = hpE - (unit.totalDamage*unit.attackSpeed*2) - unit.ap
                    if hpE < num then
                        num     = hpE
                        result  = unit
                    end
                elseif gso_ts_mode == 2 then
                    if distance < num then
                        num = distance
                        result = unit
                    end
                elseif gso_ts_mode == 3 then
                    local hpE = unit.health
                    if hpE < num then
                        num = hpE
                        result = unit
                    end
                elseif gso_ts_mode == 4 then
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
    end
    return result
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------OBJECT MANAGER-----------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
local function gso_objectManager()
    for i=1, #gso_allyMinions do gso_allyMinions[i]=nil end
    for i=1, #gso_enemyMinions do gso_enemyMinions[i]=nil end
    for i=1, #gso_enemyHeroes do gso_enemyHeroes[i]=nil end
    for i=1, #gso_enemyTurrets do gso_enemyTurrets[i]=nil end
    local mePos = gso_myHero.pos
    local mx, mz = mePos.x, mePos.z
    gso_myHeroT = nil
    gso_myHeroT = {
        pos = gso_myHero.pos,
        mpen = gso_myHero.magicPen,
        mpenP = gso_myHero.magicPenPercent,
        apen = gso_myHero.armorPen,
        apenP = gso_myHero.bonusArmorPenPercent,
        dmg = gso_myHero.totalDamage,
        aa = gso_myHero.attackData
    }
    for i = 1, Game.MinionCount() do
        local minion = Game.Minion(i)
        if minion then
            local minionPos = minion.pos
            local mix, miz = minionPos.x, minionPos.z
            if gso_inDistance(mx - mix, mz - miz, 2000) and not minion.dead and minion.isTargetable and minion.valid and minion.visible then
                local team = minion.team
                if team == gso_enemyTeam or team == 300 then
                    gso_enemyMinions[#gso_enemyMinions+1] = minion
                else
                    gso_allyMinions[#gso_allyMinions+1] = minion
                end
            end
        end
    end
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if hero then
            local heroPos = hero.pos
            local hx, hz = heroPos.x, heroPos.z
            if gso_inDistance(mx - hx, mz - hz, 10000) and hero.team == gso_enemyTeam and not hero.dead and hero.isTargetable and hero.valid and hero.visible then
                gso_enemyHeroes[#gso_enemyHeroes+1] = hero
            end
        end
    end
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        if turret then
            local turretPos = turret.pos
            local tx, tz = turretPos.x, turretPos.z
            if gso_inDistance(mx - tx, mz - tz, 2000) and turret.team == gso_enemyTeam and not turret.dead and turret.isTargetable and turret.visible and turret.valid then
                gso_enemyTurrets[#gso_enemyTurrets+1] = turret
            end
        end
    end
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------FARM FUNCTIONS-----------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
local function gso_possibleDmg(eMin, time)
    local result = 0
    for i = 1, #gso_allyMinions do
        local aMin = gso_allyMinions[i]
        local aaData  = aMin.attackData
        local aDmg    = (aMin.totalDamage*(1+aMin.bonusDamagePercent))
        if aaData.target == eMin.handle then
            local endT    = aaData.endTime
            local animT   = aaData.animationTime
            local windUpT = aaData.windUpTime
            local pSpeed  = aaData.projectileSpeed
            local pFlyT   = pSpeed > 0 and gso_distanceSqrt(aMin.pos.x - eMin.pos.x, aMin.pos.z - eMin.pos.z) / pSpeed or 0
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
local function gso_setEnemyMinions() 
    for i=1, #gso_lastHit do gso_lastHit[i]=nil end
    for i=1, #gso_almostLH do gso_almostLH[i]=nil end
    for i=1, #gso_laneClear do gso_laneClear[i]=nil end
    for i = 1, #gso_enemyMinions do
        local eMinion = gso_enemyMinions[i]
        local range = gso_myHero.range + gso_myHero.boundingRadius + eMinion.boundingRadius - 30
        local mePos = gso_myHero.pos
        local eMPos = eMinion.pos
        local distance = gso_distanceSqrt(mePos.x - eMPos.x, mePos.z - eMPos.z)
        if distance < range then
            local eMinion_handle	= eMinion.handle
            local eMinion_health	= eMinion.health
            local myHero_aaData		= gso_myHeroT.aa
            local myHero_pFlyTime	= myHero_aaData.windUpTime + (distance / myHero_aaData.projectileSpeed) + gso_latency + 0.05 + gso_orb_del_lh
            for k1,v1 in pairs(gso_aAttacks) do
                for k2,v2 in pairs(gso_aAttacks[k1]) do
                    if v2.canceled == false and eMinion_handle == v2.to.handle then
                        local checkT	= Game.Timer()
                        local pEndTime	= v2.startTime + v2.pTime
                        if pEndTime > checkT and  pEndTime - checkT < myHero_pFlyTime - gso_orb_del_lh then
                            eMinion_health = eMinion_health - v2.dmg
                        end
                    end
                end
            end
            local myHero_dmg = gso_aaDmg + gso_bonusDmgUnit(eMinion)
            if eMinion_health - myHero_dmg < 0 then
                gso_lastHit[#gso_lastHit+1] = { eMinion, eMinion_health }
            else
                if eMinion.health - gso_possibleDmg(eMinion, gso_myHeroT.aa.animationTime*3) - myHero_dmg < 0 then
                    gso_shouldWait = true
                    gso_shouldWaitT = Game.Timer()
                    gso_almostLH[#gso_almostLH+1] = eMinion
                else
                    gso_laneClear[#gso_laneClear+1] = eMinion
                end
            end
        end
    end
end
local function gso_setActiveAA()
    for i = 1, #gso_allyMinions do
        local aMinion = gso_allyMinions[i]
        local aHandle	= aMinion.handle
        local aAAData	= aMinion.attackData
        if aAAData.endTime > Game.Timer() then
            for i = 1, #gso_enemyMinions do
                local eMinion = gso_enemyMinions[i]
                local eHandle	= eMinion.handle
                if eHandle == aAAData.target then
                    local checkT		= Game.Timer()
                    -- p -> projectile
                    local pSpeed		= aAAData.projectileSpeed
                    local aPos = aMinion.pos
                    local ax, az = aPos.x, aPos.z
                    local ePos = eMinion.pos
                    local ex, ez = ePos.x, ePos.z
                    local pFlyT		= pSpeed > 0 and gso_distanceSqrt(ax - ex, az - ez) / pSpeed or 0
                    local pStartT	= aAAData.endTime - aAAData.windDownTime
                    if not gso_aAttacks[aHandle] then
                      gso_aAttacks[aHandle] = {}
                    end
                    local aaID = aAAData.endTime
                    if checkT < pStartT + pFlyT then
                        if pSpeed > 0 then
                            if checkT > pStartT then
                                if not gso_aAttacks[aHandle][aaID] then
                                    local extx, extz = gso_extended(pSpeed*(checkT-pStartT),ex,ez,ax,az,ax,az)
                                    gso_aAttacks[aHandle][aaID] = {
                                        canceled  = false,
                                        speed     = pSpeed,
                                        startTime = pStartT,
                                        pTime     = pFlyT,
                                        pos       = { x = extx, z = extz },
                                        from      = aMinion,
                                        fromPos   = { x = ax, z = az },
                                        to        = eMinion,
                                        toPos     = { x = ex, z = ez },
                                        dmg       = (aMinion.totalDamage*(1+aMinion.bonusDamagePercent))-eMinion.flatDamageReduction
                                    }
                                end
                            elseif aMinion.pathing.hasMovePath == true then
                              --print("attack canceled")
                              gso_aAttacks[aHandle][aaID] = {
                                  canceled  = true,
                                  from      = aMinion
                              }
                            end
                          elseif not gso_aAttacks[aHandle][aaID] then
                              gso_aAttacks[aHandle][aaID] = {
                                  canceled  = false,
                                  speed     = pSpeed,
                                  startTime = pStartT - aAAData.windUpTime,
                                  pTime     = aAAData.windUpTime,
                                  pos       = { x = ax, z = az },
                                  from      = aMinion,
                                  fromPos   = { x = ax, z = az },
                                  to        = eMinion,
                                  toPos     = { x = ex, z = ez },
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
local function gso_handleActiveAA()
    local aAttacks2 = gso_aAttacks
    for k1,v1 in pairs(aAttacks2) do
        local count		= 0
        local checkT	= Game.Timer()
        for k2,v2 in pairs(aAttacks2[k1]) do
            count = count + 1
            if v2.speed == 0 and (not v2.from or v2.from == nil or v2.from.dead) then
                --print("dead")
                gso_aAttacks[k1] = nil
                break
            end
            if v2.canceled == false then
                local ranged = v2.speed > 0
                if ranged == true then
                    local pos = gso_predPos(v2.speed, v2.pos, v2.to)
                    gso_aAttacks[k1][k2].pTime = gso_distanceSqrt(v2.fromPos.x - pos.x, v2.fromPos.z - pos.z) / v2.speed
                end
                if checkT > v2.startTime + gso_aAttacks[k1][k2].pTime - gso_latency - 0.02 or not v2.to or v2.to == nil or v2.to.dead then
                    gso_aAttacks[k1][k2] = nil
                elseif ranged == true then
                    local extx, extz = gso_extended((checkT-v2.startTime)*v2.speed,v2.toPos.x,v2.toPos.z,v2.fromPos.x,v2.fromPos.z,v2.fromPos.x,v2.fromPos.z)
                    gso_aAttacks[k1][k2].pos = {x=extx, z= extz}
                end
            end
        end
        if count == 0 then
            --print("no active attacks")
            gso_aAttacks[k1] = nil
        end
    end
end
local function gso_farmtick()
    gso_latency = Game.Latency() * 0.001
    gso_aaDmg   = gso_myHeroT.dmg + gso_bonusDmg()
    if gso_shouldWait == true and Game.Timer() > gso_shouldWaitT + 0.5 then
        gso_shouldWait = false
    end
    gso_setActiveAA()
    gso_handleActiveAA()
    gso_setEnemyMinions()
end

--------------------|---------------------------------------------------------|--------------------
--------------------|----------------------ORBWALKER--------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
local function gso_orb(unit)
    local checkT = Game.Timer()
    local aaData = gso_myHeroT.aa
    local endTime = aaData.endTime
    gso_animT = aaData.animationTime
    gso_windUpT = aaData.windUpTime
    if endTime > gso_endTime then
        gso_endTime = endTime
    end
    local canMove = gso_canMove() and checkT > gso_lAttack + gso_windUpT - 0.05 + (gso_latency*1.5) + gso_extraWindUpT
    local canAA = gso_canAttack() and gso_isBlinded == false and gso_canAA and canMove and checkT > gso_endTime - 0.034 - (gso_latency*1.5) + gso_extraAnimT
    local isTarget = unit ~= nil
    if gso_dActionsC == 0 then
        if isTarget and canAA then
            gso_beforeAA()
            gso_lAttack = checkT
            gso_lMove = 0
            local cPos = cursorPos
            Control.SetCursorPos(unit.pos)
            Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
            Control.mouse_event(MOUSEEVENTF_RIGHTUP)
            gso_dActions[gso_tick()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
            gso_dActionsC = gso_dActionsC + 1
        elseif canMove then
            if checkT > gso_lMove + gso_orb_del_hum and gso_dActionsC == 0 then
                local mPos = gso_mousePos()
                if mPos ~= nil then
                    local cPos = cursorPos
                    Control.SetCursorPos(mPos)
                    Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
                    Control.mouse_event(MOUSEEVENTF_RIGHTUP)
                    gso_dActions[gso_tick()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gso_dActionsC = gso_dActionsC + 1
                    gso_lMove = checkT
                else
                    Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
                    Control.mouse_event(MOUSEEVENTF_RIGHTUP)
                    gso_lMove = checkT
                end
            end
        end
    end
end
local function gso_comboT()
    local target = gso_getTarget(gso_myHero.range, true, true)
    if target ~= nil then
        gso_lastTarget = target
        return target
    else
        gso_lastTarget = nil
        return nil
    end
end
local function gso_lastHitT()
    local result  = nil
    local min     = 10000000
    for i = 1, #gso_lastHit do
        local eMinionLH = gso_lastHit[i]
        local minion	= eMinionLH[1]
        local hp		= eMinionLH[2]
        if hp < min then
            min = hp
            result = minion
        end
    end
    return result
end
local function gso_getTurret()
    local result = nil
        for i=1, #gso_enemyTurrets do
            local turret = gso_enemyTurrets[i]
            local range = gso_myHero.range + gso_myHero.boundingRadius + turret.boundingRadius - 30
            if gso_inDistance(gso_myHeroT.pos.x - turret.pos.x, gso_myHeroT.pos.z - turret.pos.z, range) then
                result = turret
                break
            end
        end
    return result
end
local function gso_laneClearT()
    local result	= gso_lastHitT()
    if result == nil and #gso_almostLH == 0 and gso_shouldWait == false then
        result = gso_comboT()
        if result == nil then
            result = gso_getTurret()
            if result == nil then
                local min = 10000000
                for i = 1, #gso_laneClear do
                    local minion = gso_laneClear[i]
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
local function gso_harassT()
    local result = gso_lastHitT()
    return result == nil and gso_comboT() or result
end

--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------------BUFF---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
local function gso_getBuffCount(buffName)
    for i = 1, gso_myHero.buffCount do
        local buff = gso_myHero:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == buffName then
            return buff.count
        end
    end
    return 0
end
local function gso_hasBuff(buffName)
    for i = 1, gso_myHero.buffCount do
        local buff = gso_myHero:GetBuff(i)
        if buff and buff.count > 0 and buff.name:lower() == buffName then
            return true
        end
    end
    return false
end
local function gso_isImmobile(unit)
    for i = 1, unit.buffCount do
        local buff = unit:GetBuff(i)
        local type = buff.type
        if buff and buff.count > 0 and (type == 5 or type == 11 or type == 29 or type == 24 or buff.name == "recall") then
            return true
        end
    end
    return false
end

--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------OTHERS---------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
local function gso_castAgain(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
    Control.KeyDown(i)
    Control.KeyUp(i)
end



local gso_TPred = nil
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
	local dist, t1, t2 = gso_sqrt(d*d+e*e), nil, nil
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
					local nom = gso_sqrt(sqr)
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
	return gso_sqrt(self:GetDistanceSqr(p1, p2))
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
		elseif unit.type ~= gso_myHero.type then
			CastPosition = Vector(Waypoints[#Waypoints].x, Waypoints[#Waypoints].y, Waypoints[#Waypoints].z)
			Position = CastPosition
		end
		
	elseif unit.type ~= gso_myHero.type then
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
		
		if minion.type == gso_myHero.type then
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
	from = from and Vector(from) or gso_myHero.pos
  for i = 1, #gso_enemyMinions do
    local minion = gso_enemyMinions[i]
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
		from = Vector(gso_myHero.pos)
	end
	local IsFromMyHero = self:GetDistanceSqr(from, gso_myHero.pos) < 50*50 and true or false
	
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
	
	if self:GetDistance(gso_myHero.pos, unit.pos) < 250 then
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

gso_TPred = __gsoTPred()




--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|------------------------ASHE-----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
if gso_hName == "Ashe" then
    local ashe_lastQ = 0
    local ashe_lastW = 0
    local ashe_lastR = 0
    local ashe_qBuffEndT = 0
    local function ashe_loadMenu()
        gso_menu:MenuElement({name = "Ashe", id = "champ", type = MENU, leftIcon = "https://i.imgur.com/WohLMsm.png"})
            gso_menu.champ:MenuElement({name = "AA Cancel Settings", id = "aacancel", type = MENU})
                gso_menu.champ.aacancel:MenuElement({name = "WindUp Delay - move", id = "windup", value = 50, min = 0, max = 300, step = 5 })
                gso_menu.champ.aacancel:MenuElement({name = "Anim Delay - attack", id = "anim", value = 25, min = 0, max = 300, step = 5 })
            gso_menu.champ:MenuElement({id = "rdist", name = "use R if enemy distance < X", value = 500, min = 250, max = 1000, step = 50})
            gso_menu.champ:MenuElement({type = MENU, id = "combo", name = "Combo"})
                gso_menu.champ.combo:MenuElement({id = "qc", name = "UseQ", value = true})
                gso_menu.champ.combo:MenuElement({id = "wc", name = "UseW", value = true})
                gso_menu.champ.combo:MenuElement({id = "rcd", name = "UseR [enemy distance < X", value = true})
                gso_menu.champ.combo:MenuElement({id = "rci", name = "UseR [enemy IsImmobile]", value = true})
            gso_menu.champ:MenuElement({type = MENU, id = "harass", name = "Harass"})
                gso_menu.champ.harass:MenuElement({id = "qh", name = "UseQ", value = true})
                gso_menu.champ.harass:MenuElement({id = "wh", name = "UseW", value = true})
                gso_menu.champ.harass:MenuElement({id = "rhd", name = "UseR [enemy distance < X]", value = false})
                gso_menu.champ.harass:MenuElement({id = "rhi", name = "UseR [enemy IsImmobile]", value = false})
    end
    local function ashe_castSpells()
        local getTick = gso_tick()
        local wMinus = getTick - ashe_lastW
        local rMinus = getTick - ashe_lastR
        local isCombo = gso_orb_key_com
        local isHarass = gso_orb_key_har
        local isComboW = isCombo and gso_menu.champ.combo.wc:Value()
        local isHarassW = isHarass and gso_menu.champ.harass.wh:Value()
        local isComboRd = isCombo and gso_menu.champ.combo.rcd:Value()
        local isHarassRd = isHarass and gso_menu.champ.harass.rhd:Value()
        local isComboRi = isCombo and gso_menu.champ.combo.rcd:Value()
        local isHarassRi = isHarass and gso_menu.champ.harass.rhd:Value()
        if rMinus > 2000 and wMinus > 350 and Game.CanUseSpell(_R) == 0 then
            if isComboRd or isHarassRd then
                local t = nil
                local menuDist = gso_menu.champ.rdist:Value()
                for i = 1, #gso_enemyHeroes do
                    local hero = gso_enemyHeroes[i]
                    local hPos = hero.pos
                    local distance = gso_distanceSqrt(gso_myHeroT.pos.x - hPos.x, gso_myHeroT.pos.z - hPos.z)
                    if distance > 250 and distance < menuDist and not gso_isImmortal(hero, false) then
                        menuDist = distance
                        t = hero
                    end
                end
                if t ~= nil then
                    local sR = { delay = 0.25, range = 600, width = 125, speed = 1600, sType = "line", col = false }
                    local castpos,HitChance, pos = gso_TPred:GetBestCastPosition(t, sR.delay, sR.width*0.5, sR.range, sR.speed, gso_myHeroT.pos, sR.col, sR.sType)
                    if HitChance > 0 and castpos:ToScreen().onScreen and gso_inDistance(gso_myHeroT.pos.x - castpos.x, gso_myHeroT.pos.z - castpos.z, sR.range) and gso_inDistance(t.pos.x - castpos.x, t.pos.z - castpos.z, 500) then
                        local cPos = cursorPos
                        Control.SetCursorPos(castpos)
                        Control.KeyDown(HK_R)
                        Control.KeyUp(HK_R)
                        ashe_lastR = gso_tick()
                        gso_dActions[gso_tick()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                        gso_canAA = false
                        gso_dActionsC = gso_dActionsC + 1
                        return
                    end
                end
            elseif isComboRi or isHarassRi then
                for i = 1, #gso_enemyHeroes do
                    local hero = gso_enemyHeroes[i]
                    local hPos = hero.pos
                    if gso_inDistance(gso_myHeroT.pos.x - hPos.x, gso_myHeroT.pos.z - hPos.z, 1000) and gso_isImmobile(hero) and not gso_isImmortal(hero, false) then
                        local rPred = hero.pos
                        if rPred and rPred:ToScreen().onScreen then
                            local cPos = cursorPos
                            Control.SetCursorPos(rPred)
                            Control.KeyDown(HK_R)
                            Control.KeyUp(HK_R)
                            ashe_lastR = gso_tick()
                            gso_dActions[gso_tick()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                            gso_canAA = false
                            gso_dActionsC = gso_dActionsC + 1
                            return
                        end
                    end
                end
            end
        end
        if wMinus > 2000 and rMinus > 350 and Game.CanUseSpell(_W) == 0 and (isComboW or isHarassW) then
            local aaTarget = gso_getTarget(gso_myHero.range, true, true)
            if aaTarget == nil then
                local target = gso_getTarget(1200, false, false)
                if target ~= nil then
                    local sW = { delay = 0.25, range = 1200, width = 75, speed = 2000, sType = "line", col = true }
                    local castpos,HitChance, pos = gso_TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, gso_myHeroT.pos, sW.col, sW.sType)
                    if HitChance > 0 and castpos:ToScreen().onScreen and gso_inDistance(gso_myHeroT.pos.x - castpos.x, gso_myHeroT.pos.z - castpos.z, sW.range) and gso_inDistance(target.pos.x - castpos.x,target.pos.z - castpos.z, 500) then
                        local cPos = cursorPos
                        Control.SetCursorPos(castpos)
                        Control.KeyDown(HK_W)
                        Control.KeyUp(HK_W)
                        ashe_lastW = gso_tick()
                        gso_dActions[gso_tick()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                        gso_canAA = false
                        gso_dActionsC = gso_dActionsC + 1
                    end
                end
            end
        end
    end
    local function ashe_castSpellsAA()
        local getTick = gso_tick()
        local qMinus = getTick - ashe_lastQ
        local wMinus = getTick - ashe_lastW
        local rMinus = getTick - ashe_lastR
        local isCombo = gso_orb_key_com
        local isHarass = gso_orb_key_har
        local isComboQ = isCombo and gso_menu.champ.combo.qc:Value()
        local isHarassQ = isHarass and gso_menu.champ.harass.qh:Value()
        local isComboW = isCombo and gso_menu.champ.combo.wc:Value()
        local isHarassW = isHarass and gso_menu.champ.harass.wh:Value()
        if (isComboQ or isHarassQ) and qMinus > 2000 then
            if Game.CanUseSpell(_Q) == 0 then
                Control.KeyDown(HK_Q)
                Control.KeyUp(HK_Q)
                ashe_lastQ = gso_tick()
            end
        end
        if wMinus > 2000 and rMinus > 350 and Game.CanUseSpell(_W) == 0 and (isComboW or isHarassW) then
            local target = gso_getTarget(1200, false, false)
            if target ~= nil then
                local sW = { delay = 0.25, range = 1200, width = 150, speed = 2000, sType = "line", col = true }
                local castpos,HitChance, pos = gso_TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, gso_myHeroT.pos, sW.col, sW.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and gso_inDistance(gso_myHeroT.pos.x - castpos.x, gso_myHeroT.pos.z - castpos.z, sW.range) and gso_inDistance(target.pos.x - castpos.x,target.pos.z - castpos.z, 500) then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    Control.KeyDown(HK_W)
                    Control.KeyUp(HK_W)
                    ashe_lastW = gso_tick()
                    gso_dActions[gso_tick()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gso_canAA = false
                    gso_dActionsC = gso_dActionsC + 1
                end
            end
        end
    end
    local function ashe_tick()
        gso_extraWindUpT = gso_menu.champ.aacancel.windup:Value()*0.001
        gso_extraAnimT = gso_menu.champ.aacancel.anim:Value()*0.001
        local checkTick = gso_tick()
        local wMinus = checkTick - ashe_lastW
        local rMinus = checkTick - ashe_lastR
        if gso_canAA == false and wMinus > 350 and rMinus > 350 then
            gso_canAA = true
        end
        local checkT = Game.Timer()
        if gso_myHero:GetSpellData(_Q).level > 0 then
            for i = 1, gso_myHero.buffCount do
                local buff = gso_myHero:GetBuff(i)
                if buff and buff.count > 0 and buff.duration < 0.3 and buff.name:lower() == "asheqattack" then
                    print("okaa")
                    ashe_qBuffEndT = checkT
                    break
                end
            end
        end
    end
    local function ashe_setCanMove()
        local result = true
        local checkT = Game.Timer()
        if checkT < ashe_qBuffEndT + gso_windUpT + (gso_animT*3) then
            result = checkT > gso_endTime - (gso_animT - gso_windUpT) - 0.075 + (gso_menu.champ.aacancel.windup:Value()*0.001)
        end
        return result
    end
    local function ashe_dmgUnit(unit)
        local dmg = gso_myHeroT.dmg
        local crit = 0.1 + gso_myHero.critChance
        for i = 1, unit.buffCount do
            local buff = unit:GetBuff(i)
            if buff.count > 0 and buff.name:lower() == "ashepassiveslow" then
                local aacompleteT = gso_myHeroT.aa.windUpTime + (gso_distanceSqrt(gso_myHeroT.pos.x - unit.pos.x, gso_myHeroT.pos.z - unit.pos.z) / gso_myHeroT.aa.projectileSpeed)
                if aacompleteT + 0.1 < buff.duration then
                    return dmg * crit
                end
            end
        end
        return 0
    end
    gso_setLoadChampMenu(function() ashe_loadMenu() end)
    gso_setCastSpells(function() ashe_castSpells() end)
    gso_setCastSpellsAA(function() ashe_castSpellsAA() end)
    gso_setOnTick(function() ashe_tick() end)
    gso_setBonusDmg(function() return 3 end)
    gso_setBonusDmgUnit(function(unit) return ashe_dmgUnit(unit) end)
    gso_setCanMove(function() return ashe_setCanMove() end)
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------TWITCH-------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
elseif gso_hName == "Twitch" then
    local twitch_lastW = 0
    local twitch_lastE = 0
    local twitch_eBuffs = {}
    local function twitch_loadMenu()
        gso_menu:MenuElement({name = "Twitch", id = "champ", type = MENU, leftIcon = "https://i.imgur.com/tVpVF5L.png"})
            gso_menu.champ:MenuElement({name = "AA Cancel Settings", id = "aacancel", type = MENU})
                gso_menu.champ.aacancel:MenuElement({name = "WindUp Delay - move", id = "windup", value = 50, min = 0, max = 300, step = 5 })
                gso_menu.champ.aacancel:MenuElement({name = "Anim Delay - attack", id = "anim", value = 25, min = 0, max = 300, step = 5 })
            gso_menu.champ:MenuElement({name = "W settings", id = "wset", type = MENU })
                gso_menu.champ.wset:MenuElement({id = "combo", name = "Use W Combo", value = true})
                gso_menu.champ.wset:MenuElement({id = "harass", name = "Use W Harass", value = false})
            gso_menu.champ:MenuElement({name = "E settings", id = "eset", type = MENU })
                gso_menu.champ.eset:MenuElement({id = "combo", name = "Use E Combo", value = true})
                gso_menu.champ.eset:MenuElement({id = "harass", name = "Use E Harass", value = false})
                gso_menu.champ.eset:MenuElement({id = "stacks", name = "X stacks", value = 6, min = 1, max = 6, step = 1 })
                gso_menu.champ.eset:MenuElement({id = "enemies", name = "X enemies", value = 1, min = 1, max = 5, step = 1 })
    end
    local function twitch_castSpellsAA()
        local getTick = gso_tick()
        local wMinus = getTick - twitch_lastW
        local eMinus = getTick - twitch_lastE
        local isCombo = gso_orb_key_com
        local isHarass = gso_orb_key_har
        local isComboW = isCombo and gso_menu.champ.wset.combo:Value()
        local isHarassW = isHarass and gso_menu.champ.wset.harass:Value()
        local isComboE = isCombo and gso_menu.champ.eset.combo:Value()
        local isHarassE = isHarass and gso_menu.champ.eset.harass:Value()
        if eMinus > 1000 and wMinus > 350 and Game.CanUseSpell(_E) == 0 then
            --[[ KS ]]
            for i = 1, #gso_enemyHeroes do
                local hero  = gso_enemyHeroes[i]
                local nID   = hero.networkID
                local hPos = hero.pos
                if twitch_eBuffs[nID] and twitch_eBuffs[nID].count > 0 and gso_inDistance(gso_myHeroT.pos.x - hPos.x, gso_myHeroT.pos.z - hPos.z, 1200) and not gso_isImmortal(hero, false) then
                    local elvl = gso_myHero:GetSpellData(_E).level
                    local basedmg = 5 + ( elvl * 15 )
                    local cstacks = twitch_eBuffs[nID].count
                    local perstack = ( 10 + (5*elvl) ) * cstacks
                    local bonusAD = gso_myHero.bonusDamage * 0.25 * cstacks
                    local bonusAP = gso_myHero.ap * 0.2 * cstacks
                    local edmg = basedmg + perstack + bonusAD + bonusAP
                    local tarm = hero.armor - gso_myHeroT.apen
                          tarm = tarm > 0 and gso_myHeroT.apenPercent * tarm or tarm
                    local DmgDealt = tarm > 0 and edmg * ( 100 / ( 100 + tarm ) ) or edmg * ( 2 - ( 100 / ( 100 - tarm ) ) )
                    local HPRegen = hero.hpRegen * 1.5
                    local CanKill = hero.health + hero.shieldAD + HPRegen < DmgDealt
                    if CanKill then
                        Control.KeyDown(HK_E)
                        Control.KeyUp(HK_E)
                        twitch_lastE = gso_tick()
                        gso_canAA = false
                        return
                    end
                end
            end
            --[[ COMBO/HARASS ]]
            if isComboE or isHarassE then 
                local xStacks   = gso_menu.champ.eset.stacks:Value()
                local xEnemies  = gso_menu.champ.eset.enemies:Value()
                local countE    = 0
                for i = 1, #gso_enemyHeroes do
                    local hero = gso_enemyHeroes[i]
                    local hPos = hero.pos
                    if gso_inDistance(gso_myHeroT.pos.x - hPos.x, gso_myHeroT.pos.z - hPos.z, 1200) and not gso_isImmortal(hero, false) then
                        local nID = hero.networkID
                        if twitch_eBuffs[nID] and twitch_eBuffs[nID].count >= xStacks then
                            countE = countE + 1
                        end
                    end
                end
                if countE >= xEnemies then
                    Control.KeyDown(HK_E)
                    Control.KeyUp(HK_E)
                    twitch_lastE = gso_tick()
                    gso_canAA = false
                    return
                end
            end
        end
        if (isComboW or isHarassW) and wMinus > 2000 and eMinus > 350 and Game.CanUseSpell(_W) == 0 then
            local target = gso_getTarget(950, false, false)
            if target ~= nil then
                local sW = { delay = 0.25, range = 950, width = 275, speed = 1400, sType = "circular", col = false }
                local castpos,HitChance, pos = gso_TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, gso_myHeroT.pos, sW.col, sW.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and gso_inDistance(gso_myHeroT.pos.x - castpos.x, gso_myHeroT.pos.z - castpos.z, sW.range) and gso_inDistance(target.pos.x - castpos.x, target.pos.z - castpos.z, 500) then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    Control.KeyDown(HK_W)
                    Control.KeyUp(HK_W)
                    twitch_lastW = gso_tick()
                    gso_dActions[gso_tick()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gso_canAA = false
                    gso_dActionsC = gso_dActionsC + 1
                end
            end
        end
    end
    local function twitch_castSpells()
        local aaTarget = gso_getTarget(gso_myHero.range, true, true)
        if aaTarget ~= nil then
            return
        end
        twitch_castSpellsAA()
    end
    local function twitch_tick()
        gso_extraAnimT = gso_menu.champ.aacancel.anim:Value()*0.001
        gso_extraWindUpT = gso_menu.champ.aacancel.windup:Value()*0.001
        for i = 1, #gso_enemyHeroes do
            local hero  = gso_enemyHeroes[i]
            local nID   = hero.networkID
            if not twitch_eBuffs[nID] then
                twitch_eBuffs[nID] = { count = 0, durT = 0 }
            end
            if not hero.dead then
                local hasB = false
                local cB = twitch_eBuffs[nID].count
                local dB = twitch_eBuffs[nID].durT
                for i = 1, hero.buffCount do
                    local buff = hero:GetBuff(i)
                    if buff.count > 0 and buff.name:lower() == "twitchdeadlyvenom" then
                        hasB = true
                        if cB < 6 and buff.duration > dB then
                            twitch_eBuffs[nID].count = cB + 1
                            twitch_eBuffs[nID].durT = buff.duration
                        else
                            twitch_eBuffs[nID].durT = buff.duration
                        end
                        break
                    end
                end
                if not hasB then
                    twitch_eBuffs[nID].count = 0
                    twitch_eBuffs[nID].durT = 0
                end
            end
        end
        local checkTick = gso_tick()
        local wMinus = checkTick - twitch_lastW
        local eMinus = checkTick - twitch_lastE
        if gso_canAA == false and wMinus > 350 and eMinus > 350 then
            gso_canAA = true
        end
    end
    gso_setLoadChampMenu(function() twitch_loadMenu() end)
    gso_setCastSpells(function() twitch_castSpells() end)
    gso_setCastSpellsAA(function() twitch_castSpellsAA() end)
    gso_setOnTick(function() twitch_tick() end)
    gso_setBonusDmg(function() return 3 end)
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|--------------------KOGMAW-------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
elseif gso_hName == "KogMaw" then
    local kog_lastQ = 0
    local kog_lastW = 0
    local kog_lastE = 0
    local kog_lastR = 0
    local function kog_loadMenu()
        gso_menu:MenuElement({name = "KogMaw", id = "champ", type = MENU, leftIcon = "https://i.imgur.com/PR2suYf.png"})
            gso_menu.champ:MenuElement({name = "AA Cancel Settings", id = "aacancel", type = MENU})
                gso_menu.champ.aacancel:MenuElement({name = "WindUp Delay - move", id = "windup", value = 50, min = 0, max = 300, step = 5 })
                gso_menu.champ.aacancel:MenuElement({name = "Anim Delay - attack", id = "anim", value = 25, min = 0, max = 300, step = 5 })
            gso_menu.champ:MenuElement({name = "Q settings", id = "qset", type = MENU })
                gso_menu.champ.qset:MenuElement({id = "combo", name = "Combo", value = true})
                gso_menu.champ.qset:MenuElement({id = "harass", name = "Harass", value = false})
            gso_menu.champ:MenuElement({name = "W settings", id = "wset", type = MENU })
                gso_menu.champ.wset:MenuElement({id = "combo", name = "Combo", value = true})
                gso_menu.champ.wset:MenuElement({id = "harass", name = "Harass", value = false})
            gso_menu.champ:MenuElement({name = "E settings", id = "eset", type = MENU })
                gso_menu.champ.eset:MenuElement({id = "combo", name = "Combo", value = true})
                gso_menu.champ.eset:MenuElement({id = "harass", name = "Harass", value = false})
            gso_menu.champ:MenuElement({name = "R settings", id = "rset", type = MENU })
                gso_menu.champ.rset:MenuElement({id = "combo", name = "Combo", value = true})
                gso_menu.champ.rset:MenuElement({id = "harass", name = "Harass", value = false})
                gso_menu.champ.rset:MenuElement({id = "stack", name = "Stop at x stacks", value = 3, min = 1, max = 9, step = 1 })
    end
    local function kog_castSpellsAA()
        local getTick = gso_tick()
        local qMinus = getTick - kog_lastQ
        local wMinus = getTick - kog_lastW
        local eMinus = getTick - kog_lastE
        local rMinus = getTick - kog_lastR
        local isCombo = gso_orb_key_com
        local isHarass = gso_orb_key_har
        local isComboQ = isCombo and gso_menu.champ.qset.combo:Value()
        local isHarassQ = isHarass and gso_menu.champ.qset.harass:Value()
        local isComboE = isCombo and gso_menu.champ.eset.combo:Value()
        local isHarassE = isHarass and gso_menu.champ.eset.harass:Value()
        local isComboR = isCombo and gso_menu.champ.rset.combo:Value()
        local isHarassR = isHarass and gso_menu.champ.rset.harass:Value()
        local sQ = { delay = 0.25, range = 1175, width = 70, speed = 1650, sType = "line", col = true }
        local sE = { delay = 0.25, range = 1280, width = 120, speed = 1350, sType = "line", col = false }
        local sR = { delay = 1.2, range = 0, width = 225, speed = math.maxinteger, sType = "circular", col = false }
        if (isComboQ or isHarassQ) and qMinus > 2000 and eMinus > 400 and rMinus > 400 and Game.CanUseSpell(_Q) == 0 then
            local target = gso_getTarget(1175, false, false)
            if target ~= nil then
                local castpos,HitChance, pos = gso_TPred:GetBestCastPosition(target, sQ.delay, sQ.width*0.5, sQ.range, sQ.speed, gso_myHeroT.pos, sQ.col, sQ.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and gso_inDistance(gso_myHeroT.pos.x - castpos.x, gso_myHeroT.pos.z - castpos.z, sQ.range) and gso_inDistance(target.pos.x - castpos.x, target.pos.z - castpos.z, 500) then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    Control.KeyDown(HK_Q)
                    Control.KeyUp(HK_Q)
                    kog_lastQ = gso_tick()
                    gso_dActions[gso_tick()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gso_canAA = false
                    gso_dActionsC = gso_dActionsC + 1
                    return
                end
            end
        end
        if (isComboE or isHarassE) and eMinus > 2000 and qMinus > 400 and rMinus > 400 and Game.CanUseSpell(_E) == 0 then
            local target = gso_getTarget(1280, false, false)
            if target ~= nil then
                local castpos,HitChance, pos = gso_TPred:GetBestCastPosition(target, sE.delay, sE.width*0.5, sE.range, sE.speed, gso_myHeroT.pos, sE.col, sE.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and gso_inDistance(gso_myHeroT.pos.x - castpos.x, gso_myHeroT.pos.z - castpos.z, sE.range) and gso_inDistance(target.pos.x - castpos.x, target.pos.z - castpos.z, 500) then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    Control.KeyDown(HK_E)
                    Control.KeyUp(HK_E)
                    kog_lastE = gso_tick()
                    gso_dActions[gso_tick()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gso_canAA = false
                    gso_dActionsC = gso_dActionsC + 1
                    return
                end
            end
        end
        if (isComboR or isHarassR) and rMinus > 700 and qMinus > 400 and eMinus > 400 and Game.CanUseSpell(_R) == 0 and gso_getBuffCount("kogmawlivingartillerycost") < gso_menu.champ.rset.stack:Value() then
            sR.range = 900 + ( 300 * gso_myHero:GetSpellData(_R).level )
            local target = gso_getTarget(sR.range + (sR.width*0.5), false, false)
            if target ~= nil then
                local castpos,HitChance, pos = gso_TPred:GetBestCastPosition(target, sR.delay, sR.width*0.5, sR.range, sR.speed, gso_myHeroT.pos, sR.col, sR.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and gso_inDistance(gso_myHeroT.pos.x - castpos.x, gso_myHeroT.pos.z - castpos.z, sR.range) and gso_inDistance(target.pos.x - castpos.x, target.pos.z - castpos.z, 500) then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    Control.KeyDown(HK_R)
                    Control.KeyUp(HK_R)
                    kog_lastR = gso_tick()
                    gso_dActions[gso_tick()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gso_canAA = false
                    gso_dActionsC = gso_dActionsC + 1
                end
            end
        end
    end
    local function kog_castSpells()
        local getTick = gso_tick()
        local wMinus = getTick - kog_lastW
        local isCombo   = gso_orb_key_com
        local isHarass  = gso_orb_key_har
        local isComboW   = isCombo and gso_menu.champ.wset.combo:Value()
        local isHarassW  = isHarass and gso_menu.champ.wset.harass:Value()
        if (isComboW or isHarassW) and wMinus > 1000 and Game.CanUseSpell(_W) == 0 then
            local isTarget = false
            for i = 1, #gso_enemyHeroes do
                local hero = gso_enemyHeroes[i]
                local range = 610 + ( 20 * gso_myHero:GetSpellData(_W).level ) + gso_myHero.boundingRadius + hero.boundingRadius
                local hPos = hero.pos
                if gso_inDistance(gso_myHeroT.pos.x - hero.pos.x, gso_myHeroT.pos.z - hPos.z, range) and not gso_isImmortal(hero, true) then
                    isTarget = true
                    break
                end
            end
            if isTarget == true then
                Control.KeyDown(HK_W)
                Control.KeyUp(HK_W)
                kog_lastW = gso_tick()
                return
            end
        end
        if wMinus < 300 then
            return
        end
        local aaTarget = gso_getTarget(gso_myHero.range, true, true)
        if aaTarget ~= nil then
            return
        end
        kog_castSpellsAA()
    end
    local function kog_tick()
        gso_extraAnimT = gso_menu.champ.aacancel.anim:Value()*0.001
        gso_extraWindUpT = gso_menu.champ.aacancel.windup:Value()*0.001
        local checkT = gso_tick()
        local qMinus = checkT - kog_lastQ
        local eMinus = checkT - kog_lastE
        local rMinus = checkT - kog_lastR
        if gso_canAA == false and qMinus > 350 and eMinus > 350 and rMinus > 350 then
            gso_canAA = true
        end
    end
    gso_setLoadChampMenu(function() kog_loadMenu() end)
    gso_setCastSpells(function() kog_castSpells() end)
    gso_setCastSpellsAA(function() kog_castSpellsAA() end)
    gso_setBonusDmg(function() return 3 end)
    gso_setOnTick(function() kog_tick() end)
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------DRAVEN----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
elseif gso_hName == "Draven" then
    local draven_lastQ = 0
    local draven_lastW = 0
    local draven_lastE = 0
    local draven_qParticles = {}
    local function draven_loadMenu()
        gso_menu:MenuElement({name = "Draven", id = "champ", type = MENU, leftIcon = "https://i.imgur.com/U13x6xb.png"})
            gso_menu.champ:MenuElement({name = "AA Cancel Settings", id = "aacancel", type = MENU})
                gso_menu.champ.aacancel:MenuElement({name = "WindUp Delay - move", id = "windup", value = 75, min = 0, max = 300, step = 5 })
                gso_menu.champ.aacancel:MenuElement({name = "Anim Delay - attack", id = "anim", value = 25, min = 0, max = 300, step = 5 })
            gso_menu.champ:MenuElement({name = "AXE settings", id = "aset", type = MENU })
                gso_menu.champ.aset:MenuElement({id = "catch", name = "Catch axes", value = true})
                gso_menu.champ.aset:MenuElement({id = "catcht", name = "stop catch axe under turret", value = true})
                gso_menu.champ.aset:MenuElement({name = "Distance", id = "dist", type = MENU })
                    gso_menu.champ.aset.dist:MenuElement({id = "mode", name = "Axe Mode", value = 1, drop = { "closest to mousePos", "closest to heroPos" } })
                    gso_menu.champ.aset.dist:MenuElement({id = "duration", name = "extra axe duration time", value = -250, min = -300, max = 0, step = 10 })
                    gso_menu.champ.aset.dist:MenuElement({id = "stopmove", name = "axePos in distance < X | Hold radius", value = 75, min = 75, max = 125, step = 5 })
                    gso_menu.champ.aset.dist:MenuElement({id = "cdist", name = "max distance from axePos to cursorPos", value = 750, min = 250, max = 1500, step = 50 })
                    gso_menu.champ.aset.dist:MenuElement({id = "hdist", name = "max distance from axePos to heroPos", value = 500, min = 250, max = 750, step = 50 })
                    gso_menu.champ.aset.dist:MenuElement({id = "enemyq", name = "stop catch if axe is near enemy - X dist", value = 0, min = 0, max = 250, step = 5 })
                    gso_menu.champ.aset.dist:MenuElement({id = "enemyhero", name = "stop catch if hero is near enemy - X dist", value = 0, min = 0, max = 500, step = 5 })
                gso_menu.champ.aset:MenuElement({name = "Draw", id = "draw", type = MENU })
                    gso_menu.champ.aset.draw:MenuElement({name = "Enable",  id = "enable", value = true})
                    gso_menu.champ.aset.draw:MenuElement({name = "Good", id = "good", type = MENU })
                        gso_menu.champ.aset.draw.good:MenuElement({name = "Color",  id = "color", color = Draw.Color(255, 49, 210, 0)})
                        gso_menu.champ.aset.draw.good:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
                        gso_menu.champ.aset.draw.good:MenuElement({name = "Radius",  id = "radius", value = 170, min = 50, max = 300, step = 10})
                    gso_menu.champ.aset.draw:MenuElement({name = "Bad", id = "bad", type = MENU })
                        gso_menu.champ.aset.draw.bad:MenuElement({name = "Color",  id = "color", color = Draw.Color(255, 153, 0, 0)})
                        gso_menu.champ.aset.draw.bad:MenuElement({name = "Width",  id = "width", value = 1, min = 1, max = 10})
                        gso_menu.champ.aset.draw.bad:MenuElement({name = "Radius",  id = "radius", value = 170, min = 50, max = 300, step = 10})
            gso_menu.champ:MenuElement({name = "Q settings", id = "qset", type = MENU })
                gso_menu.champ.qset:MenuElement({id = "combo", name = "Combo", value = true})
                gso_menu.champ.qset:MenuElement({id = "harass", name = "Harass", value = false})
            gso_menu.champ:MenuElement({name = "W settings", id = "wset", type = MENU })
                gso_menu.champ.wset:MenuElement({id = "combo", name = "Combo", value = true})
                gso_menu.champ.wset:MenuElement({id = "harass", name = "Harass", value = false})
                gso_menu.champ.wset:MenuElement({id = "hdist", name = "max enemy distance", value = 750, min = 500, max = 2000, step = 50 })
            gso_menu.champ:MenuElement({name = "E settings", id = "eset", type = MENU })
                gso_menu.champ.eset:MenuElement({id = "combo", name = "Combo", value = true})
                gso_menu.champ.eset:MenuElement({id = "harass", name = "Harass", value = false})
    end
    local function draven_draw()
        if gso_menu.champ.aset.catch:Value() and gso_menu.champ.aset.draw.enable:Value() then
            for k,v in pairs(draven_qParticles) do
                if not v.success then
                    if v.active then
                        Draw.Circle(v.pos, gso_menu.champ.aset.draw.good.radius:Value(), gso_menu.champ.aset.draw.good.width:Value(), gso_menu.champ.aset.draw.good.color:Value())
                    else
                        Draw.Circle(v.pos, gso_menu.champ.aset.draw.bad.radius:Value(), gso_menu.champ.aset.draw.bad.width:Value(), gso_menu.champ.aset.draw.bad.color:Value())
                    end
                end
            end
        end
    end
    local function draven_castSpells()
        local getTick = gso_tick()
        local qMinus = getTick - draven_lastQ
        local wMinus = getTick - draven_lastW
        local eMinus = getTick - draven_lastE
        local isCombo = gso_orb_key_com
        local isHarass = gso_orb_key_har
        local isComboW = isCombo and gso_menu.champ.wset.combo:Value()
        local isHarassW = isHarass and gso_menu.champ.wset.harass:Value()
        local isComboE = isCombo and gso_menu.champ.eset.combo:Value()
        local isHarassE = isHarass and gso_menu.champ.eset.harass:Value()
        local isWReady = (isComboW or isHarassW) and wMinus > 1000 and qMinus > 250 and eMinus > 250 and Game.CanUseSpell(_W) == 0
        local isEReady = (isComboE or isHarassE) and eMinus > 2000 and qMinus > 250 and eMinus > 250 and Game.CanUseSpell(_E) == 0
        if isWReady or isEReady then
            local aaTarget = gso_getTarget(gso_myHero.range, true, true)
            if aaTarget == nil then
                if isWReady then
                    local wTarget = gso_getTarget(gso_menu.champ.wset.hdist:Value(), false, false)
                    if wTarget ~= nil then
                        Control.KeyDown(HK_W)
                        Control.KeyUp(HK_W)
                        draven_lastW = gso_tick()
                        return
                    end
                end
                if isEReady then
                    local target = gso_getTarget(1050, false, false)
                    if target ~= nil then
                        local sE = { delay = 0.25, range = 1050, width = 150, speed = 1400, sType = "line", col = false }
                        local castpos,HitChance, pos = gso_TPred:GetBestCastPosition(target, sE.delay, sE.width*0.5, sE.range, sE.speed, gso_myHeroT.pos, sE.col, sE.sType)
                        if HitChance > 0 and castpos:ToScreen().onScreen and gso_inDistance(gso_myHeroT.pos.x - castpos.x, gso_myHeroT.pos.z - castpos.z, sE.range) and gso_inDistance(target.pos.x - castpos.x, target.pos.z - castpos.z, 250) then
                            local cPos = cursorPos
                            Control.SetCursorPos(castpos)
                            Control.KeyDown(HK_E)
                            Control.KeyUp(HK_E)
                            draven_lastE = gso_tick()
                            gso_dActions[gso_tick()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                            gso_canAA = false
                            gso_dActionsC = gso_dActionsC + 1
                        end
                    end
                end
            end
        end
    end
    local function draven_castSpellsAA()
        local getTick = gso_tick()
        local qMinus = getTick - draven_lastQ
        local wMinus = getTick - draven_lastW
        local eMinus = getTick - draven_lastE
        local isCombo = gso_orb_key_com
        local isHarass = gso_orb_key_har
        local isComboQ = isCombo and gso_menu.champ.qset.combo:Value()
        local isHarassQ = isHarass and gso_menu.champ.qset.harass:Value()
        local isComboW = isCombo and gso_menu.champ.wset.combo:Value()
        local isHarassW = isHarass and gso_menu.champ.wset.harass:Value()
        local isComboE = isCombo and gso_menu.champ.eset.combo:Value()
        local isHarassE = isHarass and gso_menu.champ.eset.harass:Value()
        if (isComboQ or isHarassQ) and qMinus > 1000 and wMinus > 250 and eMinus > 250 and Game.CanUseSpell(_Q) == 0 then
            Control.KeyDown(HK_Q)
            Control.KeyUp(HK_Q)
            draven_lastQ = gso_tick()
        end
        if (isComboW or isHarassW) and wMinus > 1000 and qMinus > 250 and eMinus > 250 and Game.CanUseSpell(_W) == 0 then
            Control.KeyDown(HK_W)
            Control.KeyUp(HK_W)
            draven_lastW = gso_tick()
        end
        if (isComboE or isHarassE) and eMinus > 2000 and qMinus > 250 and eMinus > 250 and Game.CanUseSpell(_E) == 0 then
            local target = gso_getTarget(1100, false, false)
            if target ~= nil then
                local sE = { delay = 0.25, range = 1050, width = 150, speed = 1400, sType = "line", col = false }
                local castpos,HitChance, pos = gso_TPred:GetBestCastPosition(target, sE.delay, sE.width*0.5, sE.range, sE.speed, gso_myHeroT.pos, sE.col, sE.sType)
                if HitChance > 0 and castpos:ToScreen().onScreen and gso_inDistance(gso_myHeroT.pos.x - castpos.x, gso_myHeroT.pos.z - castpos.z, sE.range) and gso_inDistance(target.pos.x - castpos.x, target.pos.z - castpos.z, 250) then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    Control.KeyDown(HK_E)
                    Control.KeyUp(HK_E)
                    draven_lastE = gso_tick()
                    gso_dActions[gso_tick()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gso_canAA = false
                    gso_dActionsC = gso_dActionsC + 1
                end
            end
        end
    end
    local function draven_setBeforeAA()
        local getTick = gso_tick()
        local qMinus = getTick - draven_lastQ
        local wMinus = getTick - draven_lastW
        local eMinus = getTick - draven_lastE
        local isCombo = gso_orb_key_com
        local isHarass = gso_orb_key_har
        local isComboQ = isCombo and gso_menu.champ.qset.combo:Value()
        local isHarassQ = isHarass and gso_menu.champ.qset.harass:Value()
        local isComboW = isCombo and gso_menu.champ.wset.combo:Value()
        local isHarassW = isHarass and gso_menu.champ.wset.harass:Value()
        if (isComboQ or isHarassQ) and qMinus > 1000 and wMinus > 250 and eMinus > 250 and Game.CanUseSpell(_Q) == 0 then
            Control.KeyDown(HK_Q)
            Control.KeyUp(HK_Q)
            draven_lastQ = gso_tick()
        end
        if (isComboW or isHarassW) and wMinus > 1000 and qMinus > 250 and eMinus > 250 and Game.CanUseSpell(_W) == 0 then
            Control.KeyDown(HK_W)
            Control.KeyUp(HK_W)
            draven_lastW = gso_tick()
        end
    end
    local function draven_tick()
        gso_extraAnimT = gso_menu.champ.aacancel.anim:Value()*0.001
        gso_extraWindUpT = gso_menu.champ.aacancel.windup:Value()*0.001
        local checkT = gso_tick()
        local eMinus = checkT - draven_lastE
        if gso_canAA == false and eMinus > 350 then
            gso_canAA = true
        end
        for i = 1, Game.ParticleCount() do
            local particle = Game.Particle(i)
            local particlePos = particle.pos
            if gso_inDistance(gso_myHeroT.pos.x - particlePos.x, gso_myHeroT.pos.z - particlePos.z, 500) and particle.name == "Draven_Base_Q_reticle" then
                local particleID = particle.handle
                if not draven_qParticles[particleID] then
                    draven_qParticles[particleID] = { pos = particlePos, tick = gso_tick(), success = false, active = false }
                    gso_lMove = 0
                end
            end
        end
        for k,v in pairs(draven_qParticles) do
            local timerMinus = gso_tick() - v.tick
            local numMenu = 1200 + gso_menu.champ.aset.dist.duration:Value()
            if not v.success and timerMinus > numMenu then
                draven_qParticles[k].success = true
                gso_lMove = 0
            end
            if timerMinus > numMenu and timerMinus < numMenu + 100 then
                gso_lMove = 0
            end
            if timerMinus > 2000 then
                draven_qParticles[k] = nil
            end
        end
    end
    local function draven_setMousePos()
        local qPos = nil
        local canCatch = gso_menu.champ.aset.catch:Value()
        local stopCatchT = gso_menu.champ.aset.catcht:Value()
        local stopmove = gso_menu.champ.aset.dist.stopmove:Value()
        if canCatch then
            local qMode = gso_menu.champ.aset.dist.mode:Value()
            local hdist = gso_menu.champ.aset.dist.hdist:Value()
            local cdist = gso_menu.champ.aset.dist.cdist:Value()
            local num = 1000000000
            for k,v in pairs(draven_qParticles) do
                if not v.success then
                    local vPos = v.pos
                    local mePos = gso_myHeroT.pos
                    local mPos = mousePos
                    local distanceToHero = gso_distanceSqrt(vPos.x-mePos.x, vPos.z-mePos.z)
                    local distanceToMouse = gso_distanceSqrt(vPos.x-mPos.x, vPos.z-mPos.z)
                    if distanceToHero < hdist and distanceToMouse < cdist then
                        local canContinue = true
                        local eQMenu = gso_menu.champ.aset.dist.enemyq:Value()
                        local eHeroMenu = gso_menu.champ.aset.dist.enemyhero:Value()
                        if eQMenu > 0 then
                            local cEM = #gso_enemyMinions
                            for i = 1, cEM do
                                local minion = gso_enemyMinions[i]
                                local minionPos = minion.pos
                                if gso_inDistance(vPos.x - minionPos.x, vPos.z - minionPos.z, eQMenu) then
                                    canContinue = false
                                    break
                                end
                            end
                        end
                        if eQMenu > 0 or eHeroMenu > 0 then
                            local cEH = #gso_enemyHeroes
                            for i = 1, cEH do
                                local hero = gso_enemyHeroes[i]
                                local heroPos = hero.pos
                                if gso_inDistance(vPos.x - heroPos.x, vPos.z - heroPos.z, eQMenu) then
                                    canContinue = false
                                    break
                                end
                                if gso_inDistance(gso_myHeroT.pos.x - heroPos.x, gso_myHeroT.pos.z - heroPos.z, eHeroMenu) then
                                    canContinue = false
                                    break
                                end
                            end
                        end
                        if canContinue then
                            draven_qParticles[k].active = true
                            if qMode == 1 and distanceToMouse < num then
                                qPos = vPos
                                num = distanceToMouse
                            elseif qMode == 2 and distanceToHero < num then
                                qPos = vPos
                                num = distanceToHero
                            end
                        else
                            draven_qParticles[k].active = false
                            if gso_tick() > v.tick + 250 then
                                gso_lMove = 0
                            end
                        end
                    else
                        draven_qParticles[k].active = false
                    end
                end
            end
        end
        if qPos ~= nil then
            qPos = qPos:Extended(mousePos, stopmove)
            if stopCatchT then
                local cET = #gso_enemyTurrets
                for i=1, cET do
                    local turret = gso_enemyTurrets[i]
                    local turretPos = turret.pos
                    if gso_inDistance(qPos.x - turretPos.x, qPos.z - turretPos.z, 775 + turret.boundingRadius) then
                        return nil
                    end
                end
            end
        end
        return qPos
    end
    gso_setLoadChampMenu(function() draven_loadMenu() end)
    gso_setDrawChamp(function() draven_draw() end)
    gso_setCastSpells(function() draven_castSpells() end)
    gso_setCastSpellsAA(function() draven_castSpellsAA() end)
    gso_setBonusDmg(function() return 3 end)
    gso_setOnTick(function() draven_tick() end)
    gso_setMousePos(function() return draven_setMousePos() end)
    gso_setBeforeAA(function() draven_setBeforeAA() end)
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------EZREAL----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
elseif gso_hName == "Ezreal" then
    local ezreal_lastQ = 0
    local ezreal_lastW = 0
    local ezreal_lastE = 0
    local function ezreal_loadMenu()
        gso_menu:MenuElement({name = "Ezreal", id = "champ", type = MENU, leftIcon = "https://i.imgur.com/OURoL03.png"})
            gso_menu.champ:MenuElement({name = "AA Cancel Settings", id = "aacancel", type = MENU})
                gso_menu.champ.aacancel:MenuElement({name = "WindUp Delay - move", id = "windup", value = 50, min = 0, max = 300, step = 5 })
                gso_menu.champ.aacancel:MenuElement({name = "Anim Delay - attack", id = "anim", value = 25, min = 0, max = 300, step = 5 })
            gso_menu.champ:MenuElement({name = "Q settings", id = "qset", type = MENU })
                gso_menu.champ.qset:MenuElement({id = "hitchance", name = "Hitchance", value = 1, drop = { "normal", "high" } })
                gso_menu.champ.qset:MenuElement({id = "combo", name = "Combo", value = true})
                gso_menu.champ.qset:MenuElement({id = "harass", name = "Harass", value = false})
            gso_menu.champ:MenuElement({name = "W settings", id = "wset", type = MENU })
                gso_menu.champ.wset:MenuElement({id = "hitchance", name = "Hitchance", value = 2, drop = { "normal", "high" } })
                gso_menu.champ.wset:MenuElement({id = "combo", name = "Combo", value = true})
                gso_menu.champ.wset:MenuElement({id = "harass", name = "Harass", value = false})
    end
    local function ezreal_castSpellsAA()
        local getTick = gso_tick()
        local qMinus = getTick - ezreal_lastQ
        local wMinus = getTick - ezreal_lastW
        local isCombo = gso_orb_key_com
        local isHarass = gso_orb_key_har
        local isComboQ = isCombo and gso_menu.champ.qset.combo:Value()
        local isHarassQ = isHarass and gso_menu.champ.qset.harass:Value()
        local isComboW = isCombo and gso_menu.champ.wset.combo:Value()
        local isHarassW = isHarass and gso_menu.champ.wset.harass:Value()
        if (isComboQ or isHarassQ) and qMinus > 1000 and wMinus > 350 and Game.CanUseSpell(_Q) == 0 then
            local target = gso_getTarget(1150, true, false)
            if target ~= nil then
                local sW = { delay = 0.25, range = 1150, width = 60, speed = 2000, sType = "line", col = true }
                local castpos,HitChance, pos = gso_TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, gso_myHeroT.pos, sW.col, sW.sType)
                if HitChance > gso_menu.champ.qset.hitchance:Value()-1 and castpos:ToScreen().onScreen and gso_inDistance(gso_myHeroT.pos.x - castpos.x, gso_myHeroT.pos.z - castpos.z, sW.range) and gso_inDistance(target.pos.x - castpos.x, target.pos.z - castpos.z, 500) then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    Control.KeyDown(HK_Q)
                    Control.KeyUp(HK_Q)
                    ezreal_lastQ = gso_tick()
                    gso_dActions[gso_tick()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gso_canAA = false
                    gso_dActionsC = gso_dActionsC + 1
                    return
                end
            end
        end
        if (isComboW or isHarassW) and wMinus > 1000 and qMinus > 350 and Game.CanUseSpell(_W) == 0 then
            local target = gso_getTarget(1000, false, false)
            if target ~= nil then
                local sW = { delay = 0.25, range = 1150, width = 80, speed = 1550, sType = "line", col = false }
                local castpos,HitChance, pos = gso_TPred:GetBestCastPosition(target, sW.delay, sW.width*0.5, sW.range, sW.speed, gso_myHeroT.pos, sW.col, sW.sType)
                if HitChance > gso_menu.champ.wset.hitchance:Value()-1 and castpos:ToScreen().onScreen and gso_inDistance(gso_myHeroT.pos.x - castpos.x, gso_myHeroT.pos.z - castpos.z, sW.range) and gso_inDistance(target.pos.x - castpos.x, target.pos.z - castpos.z, 500) then
                    local cPos = cursorPos
                    Control.SetCursorPos(castpos)
                    Control.KeyDown(HK_W)
                    Control.KeyUp(HK_W)
                    ezreal_lastW = gso_tick()
                    gso_dActions[gso_tick()] = { function() Control.SetCursorPos(cPos.x, cPos.y) end, 50 }
                    gso_canAA = false
                    gso_dActionsC = gso_dActionsC + 1
                    return
                end
            end
        end
    end
    local function ezreal_castSpells()
        local aaTarget = gso_getTarget(gso_myHero.range, true, true)
        if aaTarget ~= nil then
            return
        end
        ezreal_castSpellsAA()
    end
    local function ezreal_tick()
        gso_extraAnimT = gso_menu.champ.aacancel.anim:Value()*0.001
        gso_extraWindUpT = gso_menu.champ.aacancel.windup:Value()*0.001
        local checkTick = gso_tick()
        local qMinus = checkTick - ezreal_lastQ
        local wMinus = checkTick - ezreal_lastW
        local eMinus = checkTick - ezreal_lastE
        if gso_canAA == false and qMinus > 350 and wMinus > 350 and eMinus > 350 then
            gso_canAA = true
        end
        if checkTick > ezreal_lastE + 1000 then
            local dActions = gso_delayedSpell
            for k,v in pairs(dActions) do
                if k == 2 then
                    if gso_dActionsC == 0 then
                        v[1]()
                        gso_dActions[gso_tick()] = { function() return 0 end, 50 }
                        gso_canAA = false
                        gso_dActionsC = gso_dActionsC + 1
                        ezreal_lastE = gso_tick()
                        gso_delayedSpell[k] = nil
                        break
                    end
                    if gso_tick() - v[2] > 125 then
                        gso_delayedSpell[k] = nil
                    end
                    break
                end
            end
        end
    end
    gso_setLoadChampMenu(function() ezreal_loadMenu() end)
    gso_setCastSpells(function() ezreal_castSpells() end)
    gso_setCastSpellsAA(function() ezreal_castSpellsAA() end)
    gso_setOnTick(function() ezreal_tick() end)
    gso_setBonusDmg(function() return 3 end)
end



--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------OnLoad----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function OnLoad()
    gso_loadMenu()
    gso_loadChampMenu()
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
    print("gamsteronAIO "..gso_version.." | orbwalker loaded!")
    print("gamsteronAIO "..gso_version.." | "..gso_hName.." loaded!")
end



--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------OnTick----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function OnTick()
    gso_refreshValues()
    if not gso_loadedChamps then gso_loadChampions() end
    if gso_isTeemo then gso_isBlinded = gso_hasBuff("BlindingDart") end
    gso_objectManager()
    gso_onTick()
    local dActions = gso_dActions
    local cDActions = 0
    for k,v in pairs(dActions) do
        cDActions = cDActions + 1
        if not v[3] and gso_tick() - k > v[2] then
            v[1]()
            v[3] = true
        elseif v[3] and gso_tick() - k > v[2] + 25 then
            gso_dActions[k] = nil
        end
    end
    gso_dActionsC = cDActions
    local checkT  = Game.Timer()
    if gso_dActionsC == 0 and checkT > gso_lAttack + gso_windUpT + 0.15 then
        gso_castSpells()
        if gso_dActionsC == 0 and checkT < gso_lAttack + gso_animT then
            gso_castSpellsAA()
        end
    end
    if not Game.IsChatOpen() and (gso_orb_key_com or gso_orb_key_har or gso_orb_key_lh or gso_orb_key_lc) then
        local AAtarget = nil
        if gso_orb_key_har or gso_orb_key_lh or gso_orb_key_lc then gso_farmtick() end
        if gso_orb_key_com then
            AAtarget = gso_comboT()
        elseif gso_orb_key_har then
            AAtarget = gso_harassT()
        elseif gso_orb_key_lh then
            AAtarget = gso_lastHitT()
        elseif gso_orb_key_lc then
            AAtarget = gso_laneClearT()
        end
        gso_orb(AAtarget)
    end
end


--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|-----------------------OnDraw----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function OnDraw()
    gso_drawChamp()
    if gso_ts_sel_dr_on and gso_selectedTarget ~= nil then
        Draw.Circle(gso_selectedTarget.pos, gso_ts_sel_dr_rad, gso_ts_sel_dr_wid, gso_ts_sel_dr_col)
    end
    if not gso_orb_dr_on then return end
    if gso_orb_dr_me_on and gso_myHeroT.pos:ToScreen().onScreen then
        Draw.Circle(gso_myHero.pos, gso_myHero.range + gso_myHero.boundingRadius + 35, gso_orb_dr_me_wid, gso_orb_dr_me_col)
    end
    if gso_orb_dr_he_on then
        for i = 1, #gso_enemyHeroes do
            local hero = gso_enemyHeroes[i]
            local hPos = hero.pos
            if hPos:ToScreen().onScreen then
                Draw.Circle(hPos, hero.range + hero.boundingRadius + 35, gso_orb_dr_he_wid, gso_orb_dr_he_col)
            end
        end
    end
    if gso_orb_dr_cpos_on then
        Draw.Circle(mousePos, gso_orb_dr_cpos_rad, gso_orb_dr_cpos_wid, gso_orb_dr_cpos_col)
    end
end



--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------OnWndMsg----------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
--------------------|---------------------------------------------------------|--------------------
function OnWndMsg(msg, wParam)
    local getTick = gso_tick()
    local isKey = gso_orb_key_com or gso_orb_key_har or gso_orb_key_lc or gso_orb_key_lh
    if wParam == HK_Q and getTick > gso_lastQ + 500 then
        gso_lastQ = getTick
        if isKey and not gso_delayedSpell[0] then
            gso_delayedSpell[0] = { function() gso_castAgain(wParam) end, getTick }
        end
    elseif wParam == HK_W and getTick > gso_lastW + 500 then
        gso_lastW = getTick
        if isKey and not gso_delayedSpell[1] then
            gso_delayedSpell[1] = { function() gso_castAgain(wParam) end, getTick }
        end
    elseif wParam == HK_E and getTick > gso_lastE + 500 then
        gso_lastE = getTick
        if isKey and not gso_delayedSpell[2] then
            gso_delayedSpell[2] = { function() gso_castAgain(wParam) end, getTick }
        end
    elseif wParam == HK_R and getTick > gso_lastR + 500 then
        gso_lastR = getTick
        if isKey and not gso_delayedSpell[3] then
            gso_delayedSpell[3] = { function() gso_castAgain(wParam) end, getTick }
        end
    elseif msg == WM_LBUTTONDOWN and gso_ts_sel_on == true then
        if getTick > gso_lastSelTick + 100 and getTick > gso_lastQ + 250 and getTick > gso_lastW + 250 and getTick > gso_lastE + 250 and getTick > gso_lastR + 250 then
            local num = 1000000000
            local enemy = nil
            for i = 1, #gso_enemyHeroes do
                local hero = gso_enemyHeroes[i]
                if not gso_isImmortal(hero, true) then
                    local hPos = hero.pos
                    local hx, hz = hPos.x, hPos.z
                    local mPos = mousePos
                    local distance = gso_distance(mPos.x - hx, mPos.z - hz)
                    if distance < 150*150 and distance < num then
                        enemy = hero
                        num = distance
                    end
                end
            end
            if enemy ~= nil then
                gso_selectedTarget = enemy
            else
                gso_selectedTarget = nil
            end
            gso_lastSelTick = gso_tick()
        end
    end
end
