--[[ *******************************************************************
Project                 : Broker_Cashflow
Description             : German translation file (deDE)
Author                  : Aledara (wowi AT jocosoft DOT com)
Translator              : Luzzifus / xevilgrin
Revision                : $Rev: 36 $
********************************************************************* ]]

local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale( "Cashflow", "deDE" )
if not L then return end

--[[
	Special characters:
	ä = \195\164
	Ä = \195\132
	ö = \195\182
	Ö = \195\150
	ü = \195\188
	Ü = \195\156
	ß = \195\159
]]

-- Text used in the tooltip
L["CFGNAME_THISSESSION"] = "Diese Sitzung"
L["CFGNAME_TODAYSELF"] = "Heute (Selbst)"
L["CFGNAME_TODAYTOTAL"] = "Heute (Alle)"
L["CFGNAME_YESTERDAYSELF"] = "Gestern (Selbst)"
L["CFGNAME_YESTERDAYTOTAL"] = "Gestern (Alle)"
L["CFGNAME_WEEKSELF"] = "Diese Woche (Selbst)"
L["CFGNAME_WEEKTOTAL"] = "Diese Woche (Alle)"
L["CFGNAME_MONTHSELF"] = "Dieser Monat (Selbst)"
L["CFGNAME_MONTHTOTAL"] = "Dieser Monat (Alle)"
L["CFGNAME_GAINED"] = "Eingenommen"
L["CFGNAME_SPENT"] = "Ausgegeben"
L["CFGNAME_PROFIT"] = "Gewinn"
L["CFGNAME_CHARACTERS"] = "Charaktere"

L["CFGNAME_TOTAL"] = "Gesamt"
L["CFGNAME_TIPOPTIONS"] = "Rechtsklick f\195\188r das Optionen Men\195\188"

-- Text used in config (main)
L["CFGNAME_CASHFORMAT"] = "Gold Format"
L["CFGOPT_CF_CONDENSED"] = "Komprimiert"
L["CFGOPT_CF_SHORT"] = "Kurz"
L["CFGOPT_CF_FULL"] = "Voll"
L["CFGNAME_TTSCALE"] = "Tooltip Skalierung"
L["CFGDESC_TTSCALE"] = "\195\132ndert die Gr\195\182\195\159e des Tooltips"
L["CFGNAME_SHOWCASHDETAIL"] = "Zeige Gold Details"
L["CFGDESC_SHOWCASHDETAIL"] = "Zeige eingenommenes und ausgegebenes Gold an"

-- Text used in config (sections)
L["CFGPAGE_SECTIONS"] = "Bereiche"
L["CFGHDR_HISTORY"] = "Historische Bereiche"
L["CFGHDR_OTHERCHARS"] = "Weitere Charaktere auf diesem Realm"
L["CFGHDR_TOTALS"] = "Gesamt"
L["CFGNAME_OTHERCHARS"] = "Zeige andere Charaktere"
L["CFGNAME_SORTOTHERCHARS"] = "Sortiere Charaktere nach "
L["CFGDESC_SORTOTHERCHARS"] = "W\195\164hle nach welchen Kriterien die Charakterliste sortiert werden soll"
L["CFGOPT_SORTNAME"] = "Name"
L["NAME_MONEY"] = "Gold"
L["CFGNAME_SORTDESC"] = "Sortiere absteigend"
L["CFGDESC_SORTDESC"] = "Sortiere beginnend beim gr\195\182\195\159ten Wert"
L["CFGNAME_SHOWTOTALS"] = "Zeige Gesamtwerte"
L["CFGDESC_SHOWTOTALS"] = "Zeige die Summe jeder W\195\164hrung ueber alle Charaktere auf diesem Realm"
L["CFGDESC_OTHERCHARS"] = 'Zeigt den Bereich "Charaktere"'

-- Text used in config (columns)
L["CFGPAGE_COLUMNS"] = "Spalten"
L["CFGHDR_GENERAL"] = "Allgemein"
L["CFGNAME_SHOWCASHPERHOUR"] = "Gold pro Stunde"
L["CFGDESC_SHOWCASHPERHOUR"] = "Zeige die Spalte mit Gold pro Stunde an"
L["CFGHDR_PVE"] = "PVE Marken"
L["CFGHDR_PVP"] = "PVP Marken"
L["CFGHDR_OTHERCURRENCY"] = "Weitere Marken"
L["CFGDESC_SHOWCOLUMNFOR"] = "Zeige Spalte f\195\188r %s"

-- Text used in config (profiles)
L["CFGPAGE_PROFILES"] = "Profile"
