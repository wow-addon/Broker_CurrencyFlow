--[[ *******************************************************************
Project                 : Broker_Currencyflow
Author                  : Aledara (wowi AT jocosoft DOT com), masi (mfourtytwoi@gmail.com)
Revision                : $Rev: 138 $
********************************************************************* ]]

local MODNAME = "Currencyflow"
local FULLNAME = "Broker: "..MODNAME

local Currencyflow  = LibStub( "AceAddon-3.0" ):NewAddon( MODNAME, "AceEvent-3.0" )
local QT  = LibStub:GetLibrary( "LibQTip-1.0" )
local L   = LibStub:GetLibrary( "AceLocale-3.0" ):GetLocale( MODNAME )
local Config  = LibStub( "AceConfig-3.0" )
local ConfigReg = LibStub( "AceConfigRegistry-3.0" )
local ConfigDlg = LibStub( "AceConfigDialog-3.0" )

_G["Currencyflow"] = Currencyflow

local tooltip
local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
local ICON_QM = "Interface\\Icons\\INV_Misc_QuestionMark"

local fmt_yellow = "|cffffff00%s|r"
local fmt_white = "|cffffffff%s|r"
local COLOR_MAXREACHED = "ff8800"
local HISTORY_DAYS = 30

local TYPE_MONEY = 1
local TYPE_CURRENCY = 2
local TYPE_FRAGMENT = 3
local TYPE_ITEM = 4

local charToDelete = nil

-- These are the currencies we can keep track of
local tracking = {
  ["gold"] = {["type"] = TYPE_MONEY, ["name"] = L["NAME_MONEY"], ["icon"] = "Interface\\Minimap\\Tracking\\Auctioneer"},

  -- Misc
  [61]  = {["type"] = TYPE_CURRENCY, ["name"] = L["NAME_DALJCTOKEN"]},
  [361] = {["type"] = TYPE_CURRENCY, ["name"] = L["NAME_ILLJCTOKEN"]},
  [81]  = {["type"] = TYPE_CURRENCY, ["name"] = L["NAME_DALCOOKINGAWARD"]},
  [402] = {["type"] = TYPE_CURRENCY, ["name"] = L["NAME_IRONPAWTOKEN"]},
  [416] = {["type"] = TYPE_CURRENCY, ["name"] = L["NAME_MARKOFTHEWORLDTREE"]},
  [515] = {["type"] = TYPE_CURRENCY, ["name"] = L["NAME_DARKMOONPRIZETICKET"]},
  [698] = {["type"] = TYPE_CURRENCY, ["name"] = L["NAME_ZENJCTOKEN"]}, -- MoP jewelcrafting


  -- PvE
  [241] = {["type"] = TYPE_CURRENCY, ["name"] = L["NAME_CHAMPIONSEAL"]},
  [395] = {["type"] = TYPE_CURRENCY, ["name"] = L["NAME_JUSTICEPOINTS"]}, -- Low tier
  [396] = {["type"] = TYPE_CURRENCY, ["name"] = L["NAME_VALORPOINTS"]}, -- High tier
  [614] = {["type"] = TYPE_CURRENCY, ["name"] = L["NAME_MOTEDARKNESS"]}, -- T13 (Dragonsoul) currency
  [615] = {["type"] = TYPE_CURRENCY, ["name"] = L["NAME_ESSENCEDEATHWING"]}, -- T13 (Dragonsoul) currency

  -- PvP
  [392] = {["type"] = TYPE_CURRENCY, ["name"] = L["NAME_HONORPOINTS"]}, -- Low tier
  [390] = {["type"] = TYPE_CURRENCY, ["name"] = L["NAME_CONQUESTPOINTS"]}, -- High tier
  [391] = {["type"] = TYPE_CURRENCY, ["name"] = L["NAME_TOLBARADCOMMENDATION"]}, -- Tol Barad

  -- Archaeology Fragments
  [384] = {["type"] = TYPE_FRAGMENT, ["index"] = 1, ["name"] = L["NAME_AF_DWARF"]},
  [398] = {["type"] = TYPE_FRAGMENT, ["index"] = 2, ["name"] = L["NAME_AF_DRAENEI"]},
  [393] = {["type"] = TYPE_FRAGMENT, ["index"] = 3, ["name"] = L["NAME_AF_FOSSIL"]},
  [394] = {["type"] = TYPE_FRAGMENT, ["index"] = 4, ["name"] = L["NAME_AF_NIGHTELF"]},
  [400] = {["type"] = TYPE_FRAGMENT, ["index"] = 5, ["name"] = L["NAME_AF_NERUBIAN"]},
  [397] = {["type"] = TYPE_FRAGMENT, ["index"] = 6, ["name"] = L["NAME_AF_ORC"]},
  [401] = {["type"] = TYPE_FRAGMENT, ["index"] = 7, ["name"] = L["NAME_AF_TOLVIR"]},
  [385] = {["type"] = TYPE_FRAGMENT, ["index"] = 8, ["name"] = L["NAME_AF_TROLL"]},
  [399] = {["type"] = TYPE_FRAGMENT, ["index"] = 9, ["name"] = L["NAME_AF_VRYKULL"]},
  [676] = {["type"] = TYPE_FRAGMENT, ["index"] = 10, ["name"] = L["NAME_AF_PANDAREN"]},
  [677] = {["type"] = TYPE_FRAGMENT, ["index"] = 11, ["name"] = L["NAME_AF_MOGU"]},
  [0]   = {["type"] = TYPE_FRAGMENT, ["index"] = 12, ["name"] = L["NAME_AF_OTHER"]},
}

-- Used to copy a table instead of just copying the reference to it.
-- Does not copy metatable information
function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return new_table
    end
    return _copy(object)
end

local function Notice( msg )
  if ( msg ~= nil and DEFAULT_CHAT_FRAME ) then
    DEFAULT_CHAT_FRAME:AddMessage( MODNAME.." notice: "..msg, 0.6, 1.0, 1.0 )
  end
end

-- Returns character name, colored by class
function Currencyflow:ColorByClass( name, class )
  local classcol = RAID_CLASS_COLORS[class] or {["r"] = 1, ["g"] = 1, ["b"] = 0}
  return format("|cff%02x%02x%02x%s|r", classcol["r"]*255, classcol["g"]*255, classcol["b"]*255, name)
end

function Currencyflow:GetToday()
  -- Offset to UTC, in seconds
  local offset = time(date("*t")) - time(date("!*t"))
  return floor((time()+offset) / 86400)
end

function Currencyflow:updateTime()
  local now = time()
  self.session.time = self.session.time + now - self.savedTime

  self.db.factionrealm.chars[self.meidx].history = self.db.factionrealm.chars[self.meidx].history or {}
  self.db.factionrealm.chars[self.meidx].history[self.today] = self.db.factionrealm.chars[self.meidx].history[self.today] or { time = 0, gold = { gained = 0, spent = 0 } }
  self.db.factionrealm.chars[self.meidx].history[self.today].time = self.db.factionrealm.chars[self.meidx].history[self.today].time + now - self.savedTime
  self.savedTime = now
end

--[[
  Displays the given amount of gold in the configured format.
  if colorize is true, it will color the text red if negative, green if positive (or 0)
  if it's false, it wil color the text white, and with a "-" in front if it's negative
]]
function Currencyflow:FormatGold( amount, colorize )
  local ICON_GOLD = "|TInterface\\MoneyFrame\\UI-GoldIcon:0|t"
  local ICON_SILVER = "|TInterface\\MoneyFrame\\UI-SilverIcon:0|t"
  local ICON_COPPER = "|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"

  local COLOR_WHITE = "ffffff"
  local COLOR_GREEN = "00ff00"
  local COLOR_RED = "ff0000"
  local COLOR_COPPER = "eda55f"
  local COLOR_SILVER = "c7c7cf"
  local COLOR_GOLD = "ffd700"

  -- Make sure amount is a number
  -- NaN values are not equal to themselfs, see http://snippets.luacode.org/snippets/Test_for_NaN_75
  if amount ~= amount then amount = 0 end

  local gold = abs(amount / 10000)
  local silver = abs(mod(amount / 100, 100))
  local copper = abs(mod(amount, 100))

  -- Make sure the values are numbers too
  if gold ~= gold then gold = 0 end
  if silver ~= silver then silver = 0 end
  if copper ~= copper then copper = 0 end

  -- Determine text color
  local color = COLOR_WHITE
  local sign = ""
  if colorize and self.db.profile.cashFormat ~= 1 then
    -- With format 1, the text color itself is in gold/silver/copper,
    -- so colorize has no effect, and we always show "-" on negative
    if amount < 0 then color = COLOR_RED else color = COLOR_GREEN end
  elseif amount < 0 then
    sign = "-"
  end

  -- Determine unit display
  if self.db.profile.cashFormat == 1 then
    -- Abacus "Condensed"
    if gold > 0 then
      return sign..format("|cff%s%d|r |cff%s%02d|r |cff%s%02d|r", COLOR_GOLD, gold, COLOR_SILVER, silver, COLOR_COPPER, copper)
    elseif silver > 0 then
      return sign..format("|cff%s%d|r |cff%s%02d|r", COLOR_SILVER, silver, COLOR_COPPER, copper)
    else
      return sign..format("|cff%s%d|r", COLOR_COPPER, copper)
    end
  elseif self.db.profile.cashFormat == 2 then
    -- Abacus "Short"
    if gold > 0 then
      return sign..format("|cff%s%.1f|r|cff%sg|r ", color, gold, COLOR_GOLD)
    elseif silver > 0 then
      return sign..format("|cff%s%.1f|r|cff%ss|r", color, silver, COLOR_SILVER)
    else
      return sign..format("|cff%s%d|r|cff%sc|r", color, copper, COLOR_COPPER)
    end
  elseif self.db.profile.cashFormat == 3 then
    -- Abacus "Full"
    if gold > 0 then
      return sign..format("|cff%s%d|r|cff%sg|r |cff%s%02d|r|cff%ss|r |cff%s%02d|r|cff%sc|r", color, gold, COLOR_GOLD, color, silver, COLOR_SILVER, color, copper, COLOR_COPPER)
    elseif silver > 0 then
      return sign..format("|cff%s%d|r|cff%ss|r |cff%s%02d|r|cff%sc|r", color, silver, COLOR_SILVER, color, copper, COLOR_COPPER)
    else
      return sign..format("|cff%s%d|r|cff%sc|r", color, copper, COLOR_COPPER)
    end
  elseif self.db.profile.cashFormat == 4 then
    -- With coin icons
    if gold > 0 then
      return sign..format("|cff%s%d|r%s |cff%s%02d|r%s |cff%s%02d|r%s", color, gold, ICON_GOLD, color, silver, ICON_SILVER, color, copper, ICON_COPPER)
    elseif silver > 0 then
      return sign..format("|cff%s%d|r%s |cff%s%02d|r%s", color, silver, ICON_SILVER, color, copper, ICON_COPPER)
    else
      return sign..format("|cff%s%d|r%s", color, copper, ICON_COPPER)
    end
  end
  return "<error>"
end

--[[
  Formats (colors) the given amount of currency with either the given color, or
  red/green if none given
]]
function Currencyflow:FormatCurrency( amount, color )
  if color == "" then
    if amount < 0 then color = "ff0000" else color = "00ff00" end
  end
  return "|cff"..color..amount.."|r"
end

--[[
  Returns time, gained, spent values.
  char: Character index, or 0 to sum all (non-ignored)
  day: Day #, or 0 for session, or negative for range
  currency: Currency id
]]
function Currencyflow:db_GetHistory( char, day, currency )
  -- Basically the same thing, except no sums/ranges!
  local getval = function( char, day, currency )
    -- time is set to 1 to avoid division by zero later on
    local time, gained, spent = 1, 0, 0
    if day == 0 then
      time = self.session.time or 0
      if self.session[currency] then
        gained = self.session[currency].gained or 0
        spent = self.session[currency].spent or 0
      end
    elseif self.db.factionrealm.chars[char] and self.db.factionrealm.chars[char].history and self.db.factionrealm.chars[char].history[day] then
      time = self.db.factionrealm.chars[char].history[day].time or 0
      self.db.factionrealm.chars[char].history[day][currency] = self.db.factionrealm.chars[char].history[day][currency] or {}
      if self.db.factionrealm.chars[char].history[day][currency] then
        gained = self.db.factionrealm.chars[char].history[day][currency].gained or 0
        spent = self.db.factionrealm.chars[char].history[day][currency].spent or 0
      end
    end
    return time, gained, spent
  end

  local i, time,gained,spent, t,g,s = 0, 0,0,0, 1,0,0

  if char > 0 then
    if day >= 0  then
      time, gained, spent = getval(char, day, currency)
    else
      -- day < 0, so we need a range
      for i = self.today + day, self.today do
        t,g,s = getval(char, i, currency)
        time = time + t
        gained = gained + g
        spent = spent + s
      end
    end
  elseif day >= 0 then
    for k,v in pairs(self.db.factionrealm.chars) do
      if not v.ignore then
        t,g,s = getval(k, day, currency)
        time = time + t
        gained = gained + g
        spent = spent + s
      end
    end
  else
    -- day < 0, so we need a range
    for k,v in pairs(self.db.factionrealm.chars) do
      if not v.ignore then
        for i = self.today + day, self.today do
          t,g,s = getval(k, i, currency)
          time = time + t
          gained = gained + g
          spent = spent + s
        end
      end
    end
  end

  return time, gained, spent
end

--[[
  Returns current "inventory" of given char for given currency.
  char: Character index, or 0 to sum all
  currency: Currency id
]]
function Currencyflow:db_GetTotal( char, currency )
  local value = 0
  if char == 0 then
    for k,_ in pairs(self.db.factionrealm.chars) do
      if self.db.factionrealm.chars[k] and not self.db.factionrealm.chars[k].ignore then
        value = value + (self.db.factionrealm.chars[k][currency] or 0)
      end
    end
  elseif self.db.factionrealm.chars[char] then
    value = self.db.factionrealm.chars[char][currency] or 0
  end
  return value
end

--[[
  Update given currency to current amount. Updating session and todays
  history, and creating structure as needed.
  Pass false for Session only on login to sync database with the
  real world
  If ignore is set to true for this character, history is set to nil,
  to reduce database size
]]
function Currencyflow:db_UpdateCurrency( currencyId, updateSession )
  -- Bail if invalid id given
  if tracking[currencyId] == nil then return end

  -- Update all character's maximum reached values, if weekly earnings are reset.
  -- currencyId can be "gold"
  if type(currencyId) == "number" then
    lastWeekEarned = self.db.factionrealm.chars[self.meidx]["lastWeekEarned"..currencyId]
    earnedThisWeek, weeklyMax = select(4, GetCurrencyInfo(currencyId))
    -- Only for currencies, that have a weekly maximum
    if lastWeekEarned and weeklyMax > 0 and lastWeekEarned > earnedThisWeek then
      for idx, charinfo in pairs(self.db.factionrealm.chars) do
        charinfo["maxReached"..currencyId] = false
      end
    end
  end

  -- If I'm being ignored, clear my history, and bail
  if self.db.factionrealm.chars[self.meidx].ignore then
    self.db.factionrealm.chars[self.meidx].history = nil
    return
  end

  self:updateTime()

  -- In case we roll over midnight during a session
  if self.today < self.GetToday() then
    self.today = self.GetToday()

    -- Remove last history entry
    self.db.factionrealm.chars[self.meidx].history[self.today - HISTORY_DAYS] = nil

    -- Create blank entry for today
    self.db.factionrealm.chars[self.meidx].history[self.today] = self.db.factionrealm.chars[self.meidx].history[self.today] or { time = 0, gold = { gained = 0, spent = 0 } }
  end

  -- Remember what it was
  local oldVal = self.db.factionrealm.chars[self.meidx][currencyId] or 0

  -- Get new value and check if maximum is reached
  if tracking[currencyId].type == TYPE_MONEY then amount = GetMoney()
  elseif tracking[currencyId].type == TYPE_CURRENCY then
    amount, texture, earnedThisWeek, weeklyMax, totalMax  = select(2,GetCurrencyInfo(currencyId)) 
    if not amount then amount = 0 end
    if weeklyMax and weeklyMax > 0 then 
      self.db.factionrealm.chars[self.meidx]["maxReached" .. currencyId] = earnedThisWeek >= weeklyMax / 100  
      -- we can safely save the new earnedThisWeek value, since we checked for a reset before
      self.db.factionrealm.chars[self.meidx]["lastWeekEarned" .. currencyId] = earnedThisWeek
    elseif totalMax and totalMax > 0 then 
      self.db.factionrealm.chars[self.meidx]["maxReached" .. currencyId] = amount >= totalMax / 100 
    end
  elseif tracking[currencyId].type == TYPE_FRAGMENT then 
    amount = select(2,GetCurrencyInfo(currencyId))
    if amount then self.db.factionrealm.chars[self.meidx]["maxReached" .. currencyId] = amount >= 200 
    else amount = 0 end
  elseif tracking[currencyId].type == TYPE_ITEM then amount = GetItemCount(currencyId,true) or 0 end

  -- Bail if amount has not changed
  if amount == oldVal then return end

  -- Set new value
  self.db.factionrealm.chars[self.meidx][currencyId] = amount

  -- Make sure history structure exists
  self.db.factionrealm.chars[self.meidx].history = self.db.factionrealm.chars[self.meidx].history or {}
  self.db.factionrealm.chars[self.meidx].history[self.today] = self.db.factionrealm.chars[self.meidx].history[self.today] or {time = 0, gold = {gained = 0, spent = 0}}
  self.db.factionrealm.chars[self.meidx].history[self.today][currencyId] = self.db.factionrealm.chars[self.meidx].history[self.today][currencyId] or {gained = 0, spent = 0}

  -- Make sure session structure exists
  self.session[currencyId] = self.session[currencyId] or {gained = 0, spent = 0}

  -- If we seem to have gained/lost anything on login, it just "magically"
  -- happened, and we don't track it in history
  if updateSession then
    if amount > oldVal then
      self.db.factionrealm.chars[self.meidx].history[self.today][currencyId].gained = (self.db.factionrealm.chars[self.meidx].history[self.today][currencyId].gained or 0) + amount - oldVal
      self.session[currencyId].gained = self.session[currencyId].gained + amount - oldVal
    else
      self.db.factionrealm.chars[self.meidx].history[self.today][currencyId].spent = (self.db.factionrealm.chars[self.meidx].history[self.today][currencyId].spent or 0) + oldVal - amount
      self.session[currencyId].spent = self.session[currencyId].spent + oldVal - amount
    end
  end
end

-- Add Other toons we know about and total to the tooltip, if so desired
function Currencyflow:addCharactersAndTotal()
  -- If neither charactares or totals are configured to be shown, get out of here
  if not self.db.profile.showOtherChars and not self.db.profile.showTotals then return end

  local colsPerItem = 1
  if self.db.profile.showCashPerHour then colsPerItem = 2 end

  -- Sort the table according to settings
  table.sort(self.db.factionrealm.chars, function(a,b)
    if a == nil or b == nil then
      return false 
    end

    -- Safety net for nil values.
    a_value = nil == a[self.db.profile.sortChars] and 0 or a[self.db.profile.sortChars]
    b_value = nil == b[self.db.profile.sortChars] and 0 or b[self.db.profile.sortChars]
    
    if self.db.profile.sortDesc then
      if a[self.db.profile.sortChars] == b[self.db.profile.sortChars] then 
        return a.charname > b.charname
      else
        return a_value > b_value
      end
    elseif (a[self.db.profile.sortChars] == b[self.db.profile.sortChars]) then 
      return a.charname < b.charname
    else
      return a_value < b_value
    end
  end)

  -- We need to update self.meidx as it has most likely changed
  self.meidx = -1
  for k in pairs(self.db.factionrealm.chars) do
    if self.db.factionrealm.chars[k].charname == UnitName("player") then
      self.meidx = k
      break
    end
  end

  -- Add other characters 
  if self.db.profile.showOtherChars then
    tooltip:AddSeparator()
    lineNum = tooltip:AddLine(" ")
    tooltip:SetCell( lineNum, 1, format(fmt_yellow, L["CFGNAME_CHARACTERS"]), "LEFT", tooltip:GetColumnCount() )

    for k,v in  pairs(self.db.factionrealm.chars) do
      if not v.ignore then
        local newLineNum = tooltip:AddLine(" ")
        tooltip:SetCell( newLineNum, 1, self:ColorByClass(v.charname, v.class) )
        tooltip:SetCell( newLineNum, 2, self:FormatGold(self:db_GetTotal(k, "gold"), false), "RIGHT", colsPerItem )

        colNum = colsPerItem + 2

        for id,currency in pairs(tracking) do
          if self.db.profile["showCurrency"..id] then
            if self.db.profile.colorMaxReached and v["maxReached"..id] then 
              color = COLOR_MAXREACHED
            elseif math.fmod(colNum,2) == 0 then 
              color = "aaaaff" 
            else 
              color = "ddddff" 
            end
            tooltip:SetCell( newLineNum, colNum, self:FormatCurrency(self:db_GetTotal(k, id), color), "RIGHT" )
            colNum = colNum + 1
          end
        end
      end
    end
  end

  -- Add grand total
  if self.db.profile.showTotals then
    tooltip:AddSeparator()
    local newLineNum = tooltip:AddLine(" ")
    tooltip:SetCell( newLineNum, 1, format(fmt_yellow, L["CFGNAME_TOTAL"]) )
    tooltip:SetCell( newLineNum, 2, self:FormatGold(self:db_GetTotal(0, "gold"), false), "RIGHT", colsPerItem )

    colNum = colsPerItem + 2

    for id,currency in pairs(tracking) do
      if self.db.profile["showCurrency"..id] then
        if math.fmod(colNum,2) == 0 then color = "aaaaff" else color = "ddddff" end
        tooltip:SetCell( newLineNum, colNum, self:FormatCurrency(self:db_GetTotal(0, id), color), "RIGHT" )
        colNum = colNum + 1
      end
    end
  end
end

function Currencyflow:drawTooltip()
  tooltip:Hide()
  tooltip:Clear()

  self:updateTime()

  -- Add our header
  local lineNum = tooltip:AddHeader(" ")
  tooltip:SetCell( lineNum, 1, format(fmt_white, FULLNAME), "CENTER", tooltip:GetColumnCount() )
  tooltip:AddLine(" ")

  local colsPerItem = 1
  if self.db.profile.showCashPerHour then colsPerItem = 2 end

  -- Add the header for the gold column(s)
  lineNum = tooltip:AddLine(" ")
  tooltip:SetCell( lineNum, 2, "|TInterface\\Icons\\INV_Misc_Coin_01:16|t", "CENTER" )
  if self.db.profile.showCashPerHour then tooltip:SetCell( lineNum, 3, "|TInterface\\Icons\\INV_Misc_Coin_01:16|t/Hr", "CENTER" ) end

  -- Add a header for each of the currencies we're showing
  local colNum = colsPerItem + 2
  local icon

  for id,currency in pairs(tracking) do
    if self.db.profile["showCurrency"..id] then
      tooltip:SetCell( lineNum, colNum, "|T"..currency.icon..":16|t", "CENTER" )
      colNum = colNum + 1
    end
  end

  if self.db.profile.showThisSession  then self:addNewCurrencySection( "session", L["CFGNAME_THISSESSION"] ) end
  if self.db.profile.showTodaySelf  then self:addNewCurrencySection( "todayself", L["CFGNAME_TODAYSELF"] ) end
  if self.db.profile.showTodayTotal then self:addNewCurrencySection( "todayall", L["CFGNAME_TODAYTOTAL"] ) end
  if self.db.profile.showYesterdaySelf  then self:addNewCurrencySection( "yesterdayself", L["CFGNAME_YESTERDAYSELF"] ) end
  if self.db.profile.showYesterdayTotal then self:addNewCurrencySection( "yesterdayall", L["CFGNAME_YESTERDAYTOTAL"] ) end
  if self.db.profile.showThisWeekSelf then self:addNewCurrencySection( "thisweekself", L["CFGNAME_WEEKSELF"] ) end
  if self.db.profile.showThisWeekTotal  then self:addNewCurrencySection( "thisweekall", L["CFGNAME_WEEKTOTAL"] ) end
  if self.db.profile.showThisMonthSelf  then self:addNewCurrencySection( "thismonthself", L["CFGNAME_MONTHSELF"] ) end
  if self.db.profile.showThisMonthTotal then self:addNewCurrencySection( "thismonthall", L["CFGNAME_MONTHTOTAL"] ) end

  if not self.db.profile.showCashDetail then tooltip:AddLine(" ") end

  -- Add Other toons we know about
  self:addCharactersAndTotal()

  -- And a hint to show options
  tooltip:AddLine( " " )
  lineNum = tooltip:AddLine( " " )
  tooltip:SetCell( lineNum, 1, format(fmt_yellow, L["CFGNAME_TIPOPTIONS"]), "LEFT", tooltip:GetColumnCount() )
  lineNum = tooltip:AddLine( " " )
  tooltip:SetCell( lineNum, 1, format(fmt_yellow, L["CFGNAME_TIPRESETSESSION"]), "LEFT", tooltip:GetColumnCount() )
end

function Currencyflow:addNewCurrencySection(type, title)
  local char,day,currency, column, t,g,s, l1,l2,l3

  if type == "session" then char = self.meidx; day = 0
  elseif type == "todayself" then char = self.meidx; day = self.today
  elseif type == "todayall" then char = 0; day = self.today
  elseif type == "yesterdayself" then char = self.meidx; day = self.today - 1
  elseif type == "yesterdayall" then char = 0; day = self.today - 1
  elseif type == "thisweekself" then char = self.meidx; day = -7
  elseif type == "thisweekall" then char = 0; day = -7
  elseif type == "thismonthself" then char = self.meidx; day = -30
  elseif type == "thismonthall" then char = 0; day = -30
  else return end

  -- Create the tooltip line(s)
  if self.db.profile.showCashDetail then
    lineNum = tooltip:AddLine(" ")
    tooltip:SetCell( lineNum, 1, format(fmt_yellow, title), "LEFT", tooltip:GetColumnCount() )

    l1 = tooltip:AddLine(L["CFGNAME_GAINED"])
    l2 = tooltip:AddLine(L["CFGNAME_SPENT"])
    l3 = tooltip:AddLine(L["CFGNAME_PROFIT"])
  else
    l1 = tooltip:AddLine(title)
  end

  -- Get values for gold  
  column = 2
  t,g,s = self:db_GetHistory(char, day, "gold")
  self:setCurrencyColumn(l1, column, t,g,s, true)

  column = column + 1
  if self.db.profile.showCashPerHour then column = column + 1 end

  -- Add each currency we're tracking (and showing)
  for id,currency in pairs(tracking) do
    if self.db.profile["showCurrency"..id] then
      t,g,s = self:db_GetHistory( char, day, id )
      self:setCurrencyColumn(l1, column, t,g,s, false)
      column = column + 1
    end
  end

  if self.db.profile.showCashDetail then tooltip:AddLine(" ") end
end

function Currencyflow:setCurrencyColumn( startRow, startCol, t,g,s, doPerHour )
  local color
  if self.db.profile.showCashDetail then
    if startCol == 2 then
      tooltip:SetCell( startRow, startCol, self:FormatGold(g, false), "RIGHT" )
      tooltip:SetCell( startRow+1, startCol, self:FormatGold(s, false), "RIGHT" )
      tooltip:SetCell( startRow+2, startCol, self:FormatGold(g-s, true), "RIGHT" )
    else
      if math.fmod(startCol,2) == 0 then color = "aaaaff" else color = "ddddff" end
      tooltip:SetCell( startRow, startCol,self:FormatCurrency(g, color), "RIGHT" )
      tooltip:SetCell( startRow+1, startCol, self:FormatCurrency(s, color), "RIGHT" )
      tooltip:SetCell( startRow+2, startCol, self:FormatCurrency(g-s, ""), "RIGHT" )
    end
  elseif startCol == 2 then
    tooltip:SetCell( startRow, startCol, self:FormatGold(g-s, true), "RIGHT" )
  else
    tooltip:SetCell( startRow, startCol, self:FormatCurrency(g-s, ""), "RIGHT" )
  end 

  if doPerHour and self.db.profile.showCashPerHour then
    if self.db.profile.showCashDetail then
      if startCol == 2 then
        tooltip:SetCell( startRow, startCol+1, self:FormatGold( g/t*3600, false ), "RIGHT" )
        tooltip:SetCell( startRow+1, startCol+1, self:FormatGold( s/t*3600, false ), "RIGHT" )
        tooltip:SetCell( startRow+2, startCol+1, self:FormatGold( (g-s)/t*3600, true ), "RIGHT" )
      else
        if fmod(startCol,2) == 0 then color = "aaaaff" else color = "ddddff" end
        tooltip:SetCell( startRow, startCol+1,self:FormatCurrency( g/t*3600, color ), "RIGHT" )
        tooltip:SetCell( startRow+1, startCol+1, self:FormatCurrency( s/t*3600, color ), "RIGHT" )
        tooltip:SetCell( startRow+2, startCol+1, self:FormatCurrency( (g-s)/t*3600, "" ), "RIGHT" )
      end
    elseif startCol == 2 then
      tooltip:SetCell( startRow, startCol+1, self:FormatGold( (g-s)/t*3600, true ), "RIGHT" )
    else
      -- Not being used, but it's here for completeness
      tooltip:SetCell( startRow, startCol+1, self:FormatCurrency( (g-s)/t*3600, "" ), "RIGHT" )
    end
  end
end

local LDB = LibStub( "LibDataBroker-1.1" )
local launcher = LDB:NewDataObject( MODNAME, {
  type = "data source",
  text = " ",
  label = FULLNAME,
  icon = "Interface\\Minimap\\Tracking\\Auctioneer",
  OnClick = function(clickedframe, button)
    if button == "LeftButton" and IsShiftKeyDown() then
      -- Reset current session
      StaticPopupDialogs["RESET_SESSION"] = {
        text = L["CFG_CONFIRMRESETSESSION"],
        button1 = L["NAME_YES"],
        button2 = L["NAME_NO"],
        OnAccept = function()
          Currencyflow.session = {time = 0, gold = {gained = 0, spent = 0}}
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
      }
      StaticPopup_Show ("RESET_SESSION")


    elseif button == "RightButton" then Currencyflow:LoadCurrencies(); InterfaceOptionsFrame_OpenToCategory(FULLNAME) end
  end,
  OnEnter = function ( self )
    -- We need to calculate how many columns we meed up front
    local numcols = 2 -- title and gold

    -- One for the cash per hour
    if Currencyflow.db.profile.showCashPerHour then numcols = numcols + 1 end

    -- And one for each currency we want shown
    for id,currency in pairs(tracking) do
      if Currencyflow.db.profile["showCurrency"..id] then numcols = numcols + 1 end
    end

    tooltip = QT:Acquire( "CurrencyflowTT", numcols )
    tooltip:SetScale( Currencyflow.db.profile.tipscale )

    Currencyflow:drawTooltip()

    tooltip:SetAutoHideDelay(0.1, self)
    tooltip:EnableMouse()
    tooltip:SmartAnchorTo(self)
    tooltip:UpdateScrolling()
    tooltip:Show()
  end,
} )

function Currencyflow:UpdateLabel()

  function getLabelSegment(segment)
    segment = tonumber(segment)
    if segment == 2 then
      -- Current Gold
      return self:FormatGold(GetMoney(), false)
    elseif segment == 3 or segment == 4 then
      -- Session gold total, gold/hr
      t,g,s = self:db_GetHistory(self.meidx, 0, "gold")
      if segment == 3 then return self:FormatGold(g-s, false) else return self:FormatGold((g-s)/t*3600, false).."/Hr" end
    elseif segment == 5 or segment == 6 then
      -- Today gold total, gold/hr
      t,g,s = self:db_GetHistory(self.meidx, self.today, "gold")
      if segment == 5 then return self:FormatGold(g-s, false) else return self:FormatGold((g-s)/t*3600, false).."/Hr" end
    elseif segment == 7 or segment == 8 then
      -- Week gold total, gold/hr
      t,g,s = self:db_GetHistory(self.meidx, -7, "gold")
      if segment == 7 then return self:FormatGold(g-s, false) else return self:FormatGold((g-s)/t*3600, false).."/Hr" end
    elseif segment == 9 or segment == 10 then
      -- Month gold total, gold/hr
      t,g,s = self:db_GetHistory(self.meidx, -30, "gold")
      if segment == 9 then return self:FormatGold(g-s, false) else return self:FormatGold((g-s)/t*3600, false).."/Hr" end
    elseif tracking[segment] then
      -- Other currencies
      if tracking[segment].type == TYPE_CURRENCY or tracking[segment].type == TYPE_FRAGMENT then 
        if self.db.profile.colorMaxReached 
          and self.db.factionrealm.chars[self.meidx]["maxReached"..segment] then
          color = COLOR_MAXREACHED
        else
          color = ""
        end
        amount = select(2,GetCurrencyInfo(segment)) or 0
      elseif tracking[segment].type == TYPE_ITEM then amount = GetItemCount(segment,true) or 0 end
      return self:FormatCurrency(amount, (color or "")).." |T"..tracking[segment].icon..":0|t"
    else
      -- invalid
      return "???"
    end
  end

  local result
  if self.db.profile.buttonFirst == "1" then result = MODNAME
  else
    result = getLabelSegment(self.db.profile.buttonFirst)
    if self.db.profile.buttonSecond > "1" then result = result.." / "..getLabelSegment(self.db.profile.buttonSecond) end
    if self.db.profile.buttonThird > "1" then result = result.." / "..getLabelSegment(self.db.profile.buttonThird) end
    if self.db.profile.buttonFourth > "1" then result = result.." / "..getLabelSegment(self.db.profile.buttonFourth) end
  end
  launcher.text = result
end

function Currencyflow:SetupOptions()
  -- Create configuration panel
  ConfigReg:RegisterOptionsTable( FULLNAME, self:OptionsMain() )
  ConfigReg:RegisterOptionsTable( FULLNAME.." - "..L["CFGPAGE_SECTIONS"], self:OptionsSections() )
  ConfigReg:RegisterOptionsTable( FULLNAME.." - "..L["CFGPAGE_COLUMNS"], self:OptionsColumns() )
  ConfigReg:RegisterOptionsTable( FULLNAME.." - "..L["CFGPAGE_CHARACTERS"], self:OptionsCharacters() )
  ConfigReg:RegisterOptionsTable( FULLNAME.." - "..L["CFGPAGE_PROFILES"], LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db) )

  ConfigDlg:AddToBlizOptions( FULLNAME )
  ConfigDlg:AddToBlizOptions( FULLNAME.." - "..L["CFGPAGE_SECTIONS"], L["CFGPAGE_SECTIONS"], FULLNAME )
  ConfigDlg:AddToBlizOptions( FULLNAME.." - "..L["CFGPAGE_COLUMNS"], L["CFGPAGE_COLUMNS"], FULLNAME )
  ConfigDlg:AddToBlizOptions( FULLNAME.." - "..L["CFGPAGE_CHARACTERS"], L["CFGPAGE_CHARACTERS"], FULLNAME )
  ConfigDlg:AddToBlizOptions( FULLNAME.." - "..L["CFGPAGE_PROFILES"], L["CFGPAGE_PROFILES"], FULLNAME )
end

function Currencyflow:OptionsMain()
  local buttonOptions = {
    ["1"] = L["CFGOPT_BTNNONE"],
    ["2"] = L["CFGOPT_BTNMONEY"],
    ["3"] = L["CFGOPT_BTNSESSIONTOTAL"],
    ["4"] = L["CFGOPT_BTNSESSIONPERHOUR"],
    ["5"] = L["CFGOPT_BTNTODAYTOTAL"],
    ["6"] = L["CFGOPT_BTNTODAYPERHOUR"],
    ["7"] = L["CFGOPT_BTNWEEKTOTAL"],
    ["8"] = L["CFGOPT_BTNWEEKPERHOUR"],
    ["9"] = L["CFGOPT_BTNMONTHTOTAL"],
    ["10"] = L["CFGOPT_BTNMONTHPERHOUR"],
  }
  for id,currency in pairs(tracking) do buttonOptions[tostring(id)] = format(L["CFGOPT_BTNOTHER"], currency.name) end

  return {
    type = "group",
    desc = "General",
    get = function(key) return self.db.profile[key.arg] end,
    set = function(key, value) self.db.profile[key.arg] = value; Currencyflow:UpdateLabel() end,
    args = {
      header0 = {order = 0, name = L["CFGHDR_GENERAL"], type = "header"},
      colorMaxReached = {
        order = 1, name = L["CFG_COLORMAXREACHED"], 
        type = "toggle", arg = "colorMaxReached",
        desc = L["CFGDESC_COLORMAXREACHED"],
      },
      header1 = {order = 5, name = L["CFGHDR_TOOLTIP"], type = "header"},
      cashFormat = {
        order = 10, name = L["CFGNAME_CASHFORMAT"],
        type = "select", arg = "cashFormat",
        values = { [1] = L["CFGOPT_CF_CONDENSED"], [2] = L["CFGOPT_CF_SHORT"], [3] = L["CFGOPT_CF_FULL"], [4] = L["CFGOPT_CF_COINS"] },
        desc = L["CFGDESC_CASHFORMAT"],
      },
      tipscale = {
        order = 20, name = L["CFGNAME_TTSCALE"],
        type = "range", arg = "tipscale",
        min = 0.5, max = 1.5, step = 0.05,
        desc = L["CFGDESC_TTSCALE"],
      },
      showCashDetail = {
        order = 30, name = L["CFGNAME_SHOWCASHDETAIL"],
        type = "toggle", arg = "showCashDetail",
        desc = L["CFGDESC_SHOWCASHDETAIL"],
      },

      header2 = {order = 100, name = L["CFGHDR_BUTTON"], type = "header"},
      buttonFirst = {
        order = 110, name = L["CFGNAME_BUTTONFIRST"],
        type = "select", arg = "buttonFirst",
        values = buttonOptions,
        desc = L["CFGDESC_BUTTONFIRST"],
      },
      buttonSecond = {
        order = 120, name = L["CFGNAME_BUTTONSECOND"],
        type = "select", arg = "buttonSecond",
        values = buttonOptions,
        desc = L["CFGDESC_BUTTONSECOND"],
      },
      buttonThird = {
        order = 130, name = L["CFGNAME_BUTTONTHIRD"],
        type = "select", arg = "buttonThird",
        values = buttonOptions,
        desc = L["CFGDESC_BUTTONTHIRD"],
      },
      buttonFourth = {
        order = 140, name = L["CFGNAME_BUTTONFOURTH"],
        type = "select", arg = "buttonFourth",
        values = buttonOptions,
        desc = L["CFGDESC_BUTTONFOURTH"],
      },
    }
  }
end

function Currencyflow:OptionsSections()
  local order = 1
  local options = {}
  local addSectionCheckbox = function(id, name)
    options[id] = {
      name = name,
      type = "toggle", order = order, arg = id,
    }
    order = order + 1
  end

  addSectionCheckbox( "showThisSession", L["CFGNAME_THISSESSION"] )

  options["header1"] = {name = L["CFGHDR_HISTORY"], type = "header", order = order}
  order = order + 1

  addSectionCheckbox( "showTodaySelf", L["CFGNAME_TODAYSELF"] )
  addSectionCheckbox( "showTodayTotal", L["CFGNAME_TODAYTOTAL"] )
  addSectionCheckbox( "showYesterdaySelf", L["CFGNAME_YESTERDAYSELF"] )
  addSectionCheckbox( "showYesterdayTotal", L["CFGNAME_YESTERDAYTOTAL"] )
  addSectionCheckbox( "showThisWeekSelf", L["CFGNAME_WEEKSELF"] )
  addSectionCheckbox( "showThisWeekTotal", L["CFGNAME_WEEKTOTAL"] )
  addSectionCheckbox( "showThisMonthSelf", L["CFGNAME_MONTHSELF"] )
  addSectionCheckbox( "showThisMonthTotal", L["CFGNAME_MONTHTOTAL"] )

  options["header2"] = {name = L["CFGHDR_OTHERCHARS"], type = "header", order = 100}
  options["showOtherChars"] = {
    name = L["CFGNAME_OTHERCHARS"],
    type = "toggle", order = 101, arg = "showOtherChars",
    desc = L["CFGDESC_OTHERCHARS"],
  }
  options["sortChars"] = {
    name = L["CFGNAME_SORTOTHERCHARS"],
    type = "select", order = 102, arg = "sortChars",
    desc = L["CFGDESC_SORTOTHERCHARS"],
    values = function()
      local val = {
        ["charname"] = L["CFGOPT_SORTNAME"],
        ["gold"] = L["NAME_MONEY"],
      }
      for id,currency in pairs(tracking) do
        val[tostring(id)] = currency.name
      end
      return val
    end,
    disabled = function() return not self.db.profile.showOtherChars end,
  }

  options["sortDesc"] = {
    name = L["CFGNAME_SORTDESC"],
    type = "toggle", order = 103, arg = "sortDesc",
    desc = L["CFGDESC_SORTDESC"],
    disabled = function() return not self.db.profile.showOtherChars end,
  }

  options["header3"] = {name = L["CFGHDR_TOTALS"], type = "header", order = 200}

  options["showTotals"] = {
    name = L["CFGNAME_SHOWTOTALS"],
    type = "toggle", order = 201, arg = "showTotals",
    desc = L["CFGDESC_SHOWTOTALS"],
  }

  return {
    type = "group",
    get = function(key) return self.db.profile[key.arg] end,
    set = function(key, value) self.db.profile[key.arg] = value; Currencyflow:UpdateLabel() end,
    args = options
  }
end

function Currencyflow:OptionsColumns()
  local order = 1
  local currencyColumns = {
    header1 = {name = L["CFGHDR_GENERAL"], type = "header", order = 100},
    showCashPerHour = {
      name = L["CFGNAME_SHOWCASHPERHOUR"],
      type = "toggle", order = 101, arg = "showCashPerHour",
      desc = L["CFGDESC_SHOWCASHPERHOUR"],
    },
  }

  local addColumn = function(id)
    -- Retrieve item info at time of usage, to minimize risk of
    -- item not being available
    currencyColumns["showCurrency"..id] = {
      name = function()
        return "|T"..tracking[id].icon..":16|t "..tracking[id].name
      end,
      type = "toggle", order = order, arg = "showCurrency"..id,
      desc = function() return format(L["CFGDESC_SHOWCOLUMNFOR"], tracking[id].name) end
    }
    order = order + 1
  end


  -- We have only one table with currencies, and we want to split them
  -- into sections (PvE, PvP, Fragments, etc.). So we do this the hacky way.

  -- PVE --
  currencyColumns["header2"] = {name = L["CFGHDR_PVE"], type = "header", order = 200}
  order = 201
  addColumn(241) -- Champion's Seal
  addColumn(395) -- Justice Point
  addColumn(396) -- Valor Point
  addColumn(614) -- Mote of Darkness
  addColumn(615) -- Essence of Corrupted Deathwing

  -- PVP --
  currencyColumns["header3"] = {name = L["CFGHDR_PVP"], type = "header", order = 300}
  order = 301
  addColumn(392) -- Honor Point
  addColumn(390) -- Conquest Point
  addColumn(391) -- Tol Barad Commendation

  -- Archeology Fragment --
  currencyColumns["header4"] = {name = L["CFGHDR_ARCHFRAGMENTS"], type = "header", order = 400}
  order = 401
  for id,currency in pairs(tracking) do
    if currency.type == TYPE_FRAGMENT then addColumn(id) end
  end

  -- OTHER --
  currencyColumns["header5"] = {name = L["CFGHDR_OTHERCURRENCY"], type = "header", order = 500}
  order = 501
  addColumn(61) -- Jewelcrafter's Token
  addColumn(361) -- Illustrious Jewelcrafter's Token
  addColumn(81) -- Cooking Award
  addColumn(402) -- Chef's Award
  addColumn(416) -- Mark of the World Tree
  addColumn(515) -- Darkmoon Prize Ticket
  addColumn(698) -- MoP JC Token

  return {
    type = "group",
    get = function(key) return self.db.profile[key.arg] end,
    set = function(key, value) self.db.profile[key.arg] = value; Currencyflow:UpdateLabel() end,
    args = currencyColumns,
  }
end

function Currencyflow:OptionsCharacters()
  return {
    type = "group",
    args = {
      header1 = { type = "description", name = L["CFGTXT_IGNOREDCHARS"], order = 10 },
      ignoreChars = {
        order = 11, type = "multiselect",
        name = L["CFGNAME_IGNORECHARS"],
        values = function()
          local val = {}
          for k,v in pairs(self.db.factionrealm.chars) do val[k] = v.charname end
          return val
        end,
        get = function(key,id) return self.db.factionrealm.chars[id].ignore or false end,
        set = function(key,id,value) self.db.factionrealm.chars[id].ignore = value end,
      },

      header2 = { type = "header", name = L["CFGHDR_DELETECHAR"], order = 20 },
      header3 = { type = "description", name = L["CFGTXT_DELETECHAR"], order = 21 },
      deleteChars = {
        order = 22, type = "select",
        name = L["CFGHDR_DELETECHAR"],
        desc = L["CFGDESC_DELETECHAR"],
        values = function()
          local val = {}
          for k,v in pairs(self.db.factionrealm.chars) do if k ~= self.meidx then val[k] = v.charname end end
          return val
        end,
        get = function(key) return charToDelete end,
        set = function(key, value) charToDelete = value end,
      },
      deleteConfirm = {
        order = 23, type = "execute",
        name = L["CFGNAME_DELETE"],
        func = function()
          if charToDelete ~= nil then self.db.factionrealm.chars[charToDelete] = nil end
          charToDelete = nil
        end,
        width = "half",
        confirm = function()
          return format(L["CFG_CONFIRMDELETE"], self.db.factionrealm.chars[charToDelete].charname)
        end,
        disabled = function() return charToDelete == nil end,
      }
    }

  }
end

-- This funtion tries to update the currencies list with client info
function Currencyflow:LoadCurrencies()
  for id,currency in pairs(tracking) do
    if currency.type == TYPE_CURRENCY then
      local name, _, icon = GetCurrencyInfo(id)

      if name ~= nil and name ~= "" then currency.name = name
      else currency.name = "|cff999999"..currency.name.."|r" end

      if icon ~= nil and icon ~= "" then currency.icon = "Interface\\Icons\\"..icon
      else currency.icon = ICON_QM end
    elseif currency.type == TYPE_ITEM then
      local name, link, rarity, level, minlevel, type, subtype, stackcount, equiploc, icon, sellprice = GetItemInfo(id)

      if name ~= nil and name ~= "" then currency.name = name
      else currency.name = "|cff999999"..currency.name.."|r" end

      if icon ~= nil and icon ~= "" then currency.icon = "Interface\\Icons\\"..icon
      else currency.icon = ICON_QM end
    elseif currency.type == TYPE_FRAGMENT then
      local name, currencyid, icon, itemid = GetArchaeologyRaceInfo(currency.index)

      -- Another dumb marvel of blizz consistency. When info
      -- is not available, instead of returning nil or "",
      -- this one puts "UNKNOWN" in the name.... sigh...
      if icon ~= nil and icon ~= "" then
        currency.name = name
        currency.icon = icon
      else
        currency.name = "|cff999999"..currency.name.."|r"
        currency.icon = ICON_QM
      end

      -- Related, but seemingly useless API calls:
      -- GetArchaeologyInfo()
      -- Always returns "Archaeology" (maybe localized???), tried with and without params

      -- ArchaeologyGetIconInfo(index)
      -- Always returns nil.
    end
  end
end

function Currencyflow:OnEnable()
  Notice("Currencyflow enabled")
  self.savedTime = time()
  self.today = self.GetToday()
  self.session = {time = 0, gold = {gained = 0, spent = 0}}

  self:LoadCurrencies()

  -- Database, and initial layout
  self.db = LibStub("AceDB-3.0"):New("Currencyflow_DB", { profile = {
    cashFormat = 3,
    tipscale = 1.0,
    showCashDetail = true,
    buttonFirst = "2",
    buttonSecond = "1",
    buttonThird = "1",
    buttonFourth = "1",

    showThisSession = true,
    showTodaySelf = true,
    showTodayTotal = true,
    showYesterdaySelf = true,
    showYesterdayTotal = true,
    showThisWeekTotal = true,
    showThisMonthTotal = true,
    showOtherChars = true,
    sortChars = "charname",
    sortDesc = false,
    showTotals = true,

    showCashPerHour = true,
    showCurrency392 = true, -- Honor points
    showCurrency395 = true, -- Justice points
  }}, "Default")

  -- If there is a database, make sure it's up to date
  if self.db.factionrealm.chars then
    self:UpdateDatabase()
  else
    -- If original Broker_Cashflow (not this addon!) db version 9 exists, import it.
    cashflow = { db = LibStub("AceDB-3.0"):New("Cashflow_DB", { profile = {
        cashFormat = 3,
        tipscale = 1.0,
        showCashDetail = true,
        buttonFirst = "2",
        buttonSecond = "1",
        buttonThird = "1",
        buttonFourth = "1",

        showThisSession = true,
        showTodaySelf = true,
        showTodayTotal = true,
        showYesterdaySelf = true,
        showYesterdayTotal = true,
        showThisWeekTotal = true,
        showThisMonthTotal = true,
        showOtherChars = true,
        sortChars = "charname",
        sortDesc = false,
        showTotals = true,

        showCashPerHour = true,
        showCurrency392 = true, -- Honor points
        showCurrency395 = true, -- Justice points 
      }}, "Default")}

    -- Again, this is another addon, it's the original.
    if cashflow.db.factionrealm.version and cashflow.db.factionrealm.version <= 9 then
      -- We can only copy the characters for the current faction/realm.
      Notice("Import database from Broker_Cashflow...")
      factionrealm_chars = deepcopy(cashflow.db.factionrealm.chars)
      self.db.factionrealm.version = cashflow.db.factionrealm.version
      self.db.factionrealm.chars = {}
      for _,v in pairs(factionrealm_chars) do
        if v then
          table.insert(self.db.factionrealm.chars, deepcopy(v))
        end
      end
      Notice("Import done.")

      self:UpdateDatabase()
    else
      -- Create a skelleton structure
      self.db.factionrealm.version = 9
      self.db.factionrealm.chars = {}
    end
  end

  -- Make sure I'm in the character list, and remember my position
  self.meidx = -1
  
  for k,v in pairs(self.db.factionrealm.chars) do
    if v.charname == UnitName("player") then self.meidx = k end
  end
  if self.meidx == -1 then
    local _,classname = UnitClass("player")
    table.insert(self.db.factionrealm.chars, {
      charname = UnitName("player"),
      class = classname,
      ignore = false,
      history = {[self.today] = {["time"] = 0}}
    })
    self.meidx = #self.db.factionrealm.chars
  end

  -- Remove old stuff
  self:RemoveOldData()

  -- Update current gold
  self:db_UpdateCurrency( "gold", false )

  -- Update other currencies
  for id,currency in pairs(tracking) do self:db_UpdateCurrency( id, false ) end

  -- Setup our configuration panel
  self:SetupOptions()

  -- Create some slashcommands
  _G.SlashCmdList["CASHFLOW"] = function() InterfaceOptionsFrame_OpenToCategory(FULLNAME) end
  _G["SLASH_CASHFLOW1"] = "/cashflow"
  _G["SLASH_CASHFLOW2"] = "/cf"

  -- self:RegisterEvent("CURRENCY_DISPLAY_UPDATE", "UpdateCurrencies")
  self:RegisterEvent("PLAYER_LEAVING_WORLD", "UnregisterEvents")
  self:RegisterEvent("PLAYER_ENTERING_WORLD", "RegisterEvents")

  self:UpdateLabel()
end

function Currencyflow:UnregisterEvents()
  self:UnregisterEvent("PLAYER_MONEY")
  self:UnregisterEvent("PLAYER_TRADE_MONEY")
  self:UnregisterEvent("TRADE_MONEY_CHANGED")
  self:UnregisterEvent("SEND_MAIL_MONEY_CHANGED")
  self:UnregisterEvent("SEND_MAIL_COD_CHANGED")
  self:UnregisterEvent("MAIL_CLOSED")
  self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
end

function Currencyflow:RegisterEvents()
  self:RegisterEvent("PLAYER_MONEY", "UpdateGold")
  self:RegisterEvent("PLAYER_TRADE_MONEY", "UpdateGold")
  self:RegisterEvent("TRADE_MONEY_CHANGED", "UpdateGold")
  self:RegisterEvent("SEND_MAIL_MONEY_CHANGED", "UpdateGold")
  self:RegisterEvent("SEND_MAIL_COD_CHANGED", "UpdateGold")
  self:RegisterEvent("MAIL_CLOSED", "UpdateGold")
  self:RegisterEvent("CURRENCY_DISPLAY_UPDATE", "UpdateCurrencies")
end

-- This will update the database format to the current version
function Currencyflow:UpdateDatabase()
  -- If version is not set, we're "upgrading" to version 1
  if not self.db.factionrealm.version then self.db.factionrealm.version = 1 end

  -- Version 1 -> 2:
  --   Migrate characters table from factionrealm.chars[name] to
  --   factionrealm.chars[#].charname for easier sorting.
  --   Gotta love how "flexible" lua is!
  if self.db.factionrealm.version == 1 then
    Notice( "Updating database to version 2" )
    local a = {}
    for k,v in pairs(self.db.factionrealm.chars) do table.insert(a, k) end
    for _,k in pairs(a) do
      self.db.factionrealm.chars[k].charname = k
      table.insert(self.db.factionrealm.chars, self.db.factionrealm.chars[k])
      self.db.factionrealm.chars[k] = nil
    end
    self.db.factionrealm.version = 2
    Notice( "Update complete" )
  end

  -- Version 2 -> 3:
  --   Move history to character level
  if self.db.factionrealm.version == 2 then
    Notice( "Updating database to version 3" )
    for k,v in pairs(self.db.factionrealm.chars) do
      self.db.factionrealm.chars[k].history = {[self.today] = {["time"] = 0}}
    end
    self.db.factionrealm.history = nil
    self.db.factionrealm.version = 3
    Notice( "Update complete" )
  end

  -- Version 3 -> 4:
  --   Add "ignore" option to characters
  if self.db.factionrealm.version == 3 then
    Notice( "Updating database to version 4" )
    for k,v in pairs(self.db.factionrealm.chars) do
      self.db.factionrealm.chars[k].ignore = false;
    end
    self.db.factionrealm.version = 4
    Notice( "Update complete" )
  end

  -- Version 4 -> 5:
  --   Cataclysm!
  if self.db.factionrealm.version == 4 then
    Notice( "Updating database to version 5" )
    for k,v in pairs(self.db.factionrealm.chars) do

      -- Change ID of Champion's Seal (from item# 44990 to currency# 241)
      if self.db.factionrealm.chars[k][44990] then
        self.db.factionrealm.chars[k][241] = self.db.factionrealm.chars[k][44990];
        self.db.factionrealm.chars[k][44990] = nil;
      end

      -- Clean out the old stuff that doesn't exist anymore
      self.db.factionrealm.chars[k][29434] = nil; -- Badge of Justice
      self.db.factionrealm.chars[k][47241] = nil; -- Emblem of Triumph
      self.db.factionrealm.chars[k][49426] = nil; -- Emblem of Frost
      self.db.factionrealm.chars[k][29434] = nil; -- Badge of Justice
      self.db.factionrealm.chars[k][20560] = nil; -- Alterac Valley MoH
      self.db.factionrealm.chars[k][20559] = nil; -- Arathi Basin MoH
      self.db.factionrealm.chars[k][29024] = nil; -- Eye of the Storm MoH
      self.db.factionrealm.chars[k][47395] = nil; -- Isle of Conquest MoH
      self.db.factionrealm.chars[k][42425] = nil; -- Strand o/t Anctients MoH
      self.db.factionrealm.chars[k][20558] = nil; -- Warsong Gulch MoH
      self.db.factionrealm.chars[k][43589] = nil; -- Wintergrasp MoH
      self.db.factionrealm.chars[k][37836] = nil; -- Venture Coin
      self.db.factionrealm.chars[k][43307] = nil; -- Stone Keeper's Shard
      self.db.factionrealm.chars[k][43307] = nil; -- Old Arena Points
      self.db.factionrealm.chars[k][43308] = nil; -- Old Honor Points

      -- Reset honor, arena, and justice points, since old stuff has been converted
      -- No use trying to calculate it. I tried, was very inacurate
      self.db.factionrealm.chars[k][392] = nil;
      self.db.factionrealm.chars[k][395] = nil;

      -- Update preferences
      self.db.profile["showCurrency241"] = self.db.profile["showCurrency44990"];
      self.db.profile["showCurrency44990"] = nil;
      self.db.profile["showCurrency47241"] = nil;
      self.db.profile["showCurrency49426"] = nil;
      self.db.profile["showCurrency29434"] = nil;
      self.db.profile["showCurrency20560"] = nil;
      self.db.profile["showCurrency20559"] = nil;
      self.db.profile["showCurrency29024"] = nil;
      self.db.profile["showCurrency47395"] = nil;
      self.db.profile["showCurrency42425"] = nil;
      self.db.profile["showCurrency20558"] = nil;
      self.db.profile["showCurrency43589"] = nil;
      self.db.profile["showCurrency37836"] = nil;
      self.db.profile["showCurrency43307"] = nil;
      self.db.profile["showCurrency43307"] = nil;
      self.db.profile["showCurrency43308"] = nil;
    end
    self.db.factionrealm.version = 5
    Notice( "Update complete. Please cycle through all your characters to update current information." )
  end

  -- Version 5 -> 6:
  --   Dal JC token & cooking award item -> currency
  if self.db.factionrealm.version == 5 then
    Notice( "Updating database to version 6" )
    for k,v in pairs(self.db.factionrealm.chars) do
      -- Change ID of Jewelcrafters token (from item# 41596 to currency# 61)
      -- Change ID of Cooking award (from item# ... to currency# 81)
      if self.db.factionrealm.chars[k][41596] then
        self.db.factionrealm.chars[k][61] = self.db.factionrealm.chars[k][41596];
        self.db.factionrealm.chars[k][41596] = nil;
      end
      if self.db.factionrealm.chars[k][43016] then
        self.db.factionrealm.chars[k][81] = self.db.factionrealm.chars[k][43016];
        self.db.factionrealm.chars[k][43016] = nil;
      end
    end
    self.db.factionrealm.version = 6
  end

  -- Version 6 -> 7:
  --   Introduced buttonFirst and buttonSecond config options
  if self.db.factionrealm.version == 6 then
    Notice( "Updating database to version 7" )
    self.db.profile.buttonFirst = "2"
    self.db.profile.buttonSecond = "1"
    self.db.factionrealm.version = 7
  end

  -- Version 7 -> 8:
  --   Introduced buttonThird and buttonFourth config options
  if self.db.factionrealm.version == 7 then
    Notice( "Updating database to version 8" )
    self.db.profile.buttonThird = "1"
    self.db.profile.buttonFourth = "1"
    self.db.factionrealm.version = 8
  end

  -- Version 8 -> 9:
  --   History indexes changed (got rid of faulty offset calculation)
  if self.db.factionrealm.version == 8 then
    Notice( "Updating database to version 9" )
    for k,v in pairs(self.db.factionrealm.chars) do
      self.db.factionrealm.chars[k].history = {[self.today] = {["time"] = 0}}
    end
    self.db.factionrealm.version = 9
    Notice( "Update complete" )
  end

  -- Version 9 -> 10:
  --   Add boolean value indicating wether a currency's max is reached.
  if self.db.factionrealm.version == 9 then 
    Notice( "Updating database to version 10" )
    for index, charinfo in pairs(self.db.factionrealm.chars) do
      for id, currency in pairs(tracking) do
        if charinfo[id] and currency.type == TYPE_CURRENCY then
          weeklyMax, totalMax = select(5, GetCurrencyInfo(id))
          -- Since we can't get other character's weekly earnings, set default to false
          -- Max values are 0 if unlimited
          if weeklyMax > 0 then 
            charinfo["maxReached" .. id] = false 
            charinfo["lastWeekEarned" .. id] = nil -- Needed to get hold of weekly resets
          elseif totalMax > 0 then charinfo["maxReached" .. id] = totalMax == charinfo[id] 
          end
        elseif charinfo[id] and currency.type == TYPE_FRAGMENT then
          -- Fragments can be collected up to 200
          charinfo["maxReached" .. id] = charinfo[id] >= 200 
        end
      end
    end
    self.db.factionrealm.version = 10
    Notice( "Update complete. For weekly maximums you need to log on each character." )
  end
end

function Currencyflow:RemoveOldData()
  -- Remove history over a month old
  local lastMonth = self.today - (HISTORY_DAYS - 1)

  for day in pairs(self.db.factionrealm.chars[self.meidx].history) do
    if day < lastMonth then self.db.factionrealm.chars[self.meidx].history[day] = nil end
  end

  self.db.factionrealm.chars[self.meidx].history[self.today] = self.db.factionrealm.chars[self.meidx].history[self.today] or {time = 0, gold = {gained = 0, spent = 0}}
end

function Currencyflow:UpdateGold()
  self:db_UpdateCurrency("gold", true)
  self:UpdateLabel()
end

function Currencyflow:UpdateCurrencies()
  -- Update all currencies
  for id,currency in pairs(tracking) do self:db_UpdateCurrency(id, true) end
  self:UpdateLabel()
end
