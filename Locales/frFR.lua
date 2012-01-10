--[[ *******************************************************************
Project                 : Broker_Currencyflow
Description             : French translation file (frFR)
Author                  : Aledara (wowi AT jocosoft DOT com)
Translator              : Culhag @ Garona EU
Revision                : $Rev: 36 $
********************************************************************* ]]

local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale( "Currencyflow", "frFR" )
if not L then return end

-- Name of currency
L["NAME_YES"]			= "Oui"
L["NAME_NO"]			= "Non"
L["NAME_MONEY"]			= "Richesse"
L["NAME_DALJCTOKEN"]		= "Marque de joaillerie de Dalaran"
L["NAME_DALCOOKINGAWARD"]	= "Prix de cuisine de Dalaran"
L["NAME_CHAMPIONSEAL"]		= "Sceaux de champion"
L["NAME_JUSTICEPOINTS"]		= "Points de justice"
L["NAME_HONORPOINTS"]		= "Points d'honneur"
L["NAME_CONQUESTPOINTS"]	= "Points de conqu\195\170te"

-- Name of archaeology fragments
L["NAME_AF_DWARF"]		= "Nain"
L["NAME_AF_DRAENEI"]		= "Draene\195\175"
L["NAME_AF_FOSSIL"]		= "Fossile"
L["NAME_AF_NIGHTELF"]		= "Elfe de la nuit"
L["NAME_AF_NERUBIAN"]		= "N\195\169rubien"
L["NAME_AF_ORC"]		= "Orc"
L["NAME_AF_TOLVIR"]		= "Tol'vir"
L["NAME_AF_TROLL"]		= "Troll"
L["NAME_AF_VRYKULL"]		= "Vrykull"
L["NAME_AF_OTHER"]		= "Autre"

-- Config panel - Main
L["CFGHDR_TOOLTIP"]		= "Encadr\195\169"
L["CFGNAME_CASHFORMAT"]		= "Format de monnaie"
L["CFGDESC_CASHFORMAT"]		= "Choisissez comment votre argent sera affich\195\169"
L["CFGOPT_CF_CONDENSED"]	= "Couleur"
L["CFGOPT_CF_SHORT"]		= "Condens\195\169"
L["CFGOPT_CF_FULL"]		= "Symboles"
L["CFGOPT_CF_COINS"]		= "Pi\195\168ces"
L["CFGNAME_TTSCALE"]		= "Echelle de l'encadr\195\169"
L["CFGDESC_TTSCALE"]		= "Choisissez la taille de l'encadr\195\169"
L["CFGNAME_SHOWCASHDETAIL"]	= "Montrer les d\195\169tails"
L["CFGDESC_SHOWCASHDETAIL"]	= "Montre les d\195\169tails des gains et pertes"
L["CFGHDR_BUTTON"]		= "Bouton"
L["CFGNAME_BUTTONFIRST"]	= "Premier"
L["CFGDESC_BUTTONFIRST"]	= "Premi\195\168re monnaie \195\160 afficher sur le bouton"
L["CFGNAME_BUTTONSECOND"]	= "Deuxi\195\168me"
L["CFGDESC_BUTTONSECOND"]	= "Deuxi\195\168me monnaie \195\160 afficher sur le bouton"
L["CFGNAME_BUTTONTHIRD"]	= "Troisi\195\168me"
L["CFGDESC_BUTTONTHIRD"]	= "Troisi\195\168me monnaie \195\160 afficher sur le bouton"
L["CFGNAME_BUTTONFOURTH"]	= "Quatri\195\168me"
L["CFGDESC_BUTTONFOURTH"]	= "Quatri\195\168me monnaie \195\160 afficher sur le bouton"
L["CFGOPT_BTNNONE"]		= "Aucun"
L["CFGOPT_BTNMONEY"]		= "Richesse actuelle"
L["CFGOPT_BTNSESSIONTOTAL"]	= "Or total de la session"
L["CFGOPT_BTNSESSIONPERHOUR"]	= "Or/Hr de la session"
L["CFGOPT_BTNTODAYTOTAL"]	= "Or total aujourd'hui"
L["CFGOPT_BTNTODAYPERHOUR"]	= "Or/Hr Aujourd'hui"
L["CFGOPT_BTNWEEKTOTAL"]	= "Or total cette semaine"
L["CFGOPT_BTNWEEKPERHOUR"]	= "Or/Hr cette semaine"
L["CFGOPT_BTNOTHER"]		= "%s actuel(le)"

L["CFGPAGE_SECTIONS"]		= "Sections"
L["CFGNAME_THISSESSION"]	= "Session"
L["CFGHDR_HISTORY"]		= "Sections de l'historique"
L["CFGNAME_TODAYSELF"]		= "Aujourd'hui (perso)"
L["CFGNAME_TODAYTOTAL"]		= "Aujourd'hui (total)"
L["CFGNAME_YESTERDAYSELF"]	= "Hier (perso)"
L["CFGNAME_YESTERDAYTOTAL"]	= "Hier (total)"
L["CFGNAME_WEEKSELF"]		= "Cette semaine (perso)"
L["CFGNAME_WEEKTOTAL"]		= "Cette semaine (total)"
L["CFGNAME_TIPOPTIONS"]		= "Clic-droit pour les options"
L["CFGNAME_TIPRESETSESSION"]	= "Shift-Clic pour r\195\169initialiser la session"
L["CFGNAME_GAINED"]		= "Gain"
L["CFGNAME_SPENT"]		= "Perte"
L["CFGNAME_PROFIT"]		= "Profit"
L["CFGHDR_OTHERCHARS"]		= "Autres personnages du royaume"
L["CFGNAME_OTHERCHARS"]		= "Montrer les autres personnages"
L["CFGDESC_OTHERCHARS"]		= 'Montre la section "Personnages"'
L["CFGNAME_CHARACTERS"]		= "Personnages"
L["CFGNAME_SORTOTHERCHARS"]	= "Trier les personnages par"
L["CFGDESC_SORTOTHERCHARS"]	= "Choisissez comment la liste des personnages sera tri\195\169e."
L["CFGOPT_SORTNAME"]		= "Nom"
L["CFGNAME_SORTDESC"]		= "Ordre d\195\169croissant"
L["CFGDESC_SORTDESC"]		= "Si coch\195\169, les \195\169l\195\169ments seront tri\195\169s du plus grand au plus petit"
L["CFGHDR_TOTALS"]		= "Total"
L["CFGNAME_TOTAL"]		= "Total"
L["CFGNAME_SHOWTOTALS"]		= "Montrer le total"
L["CFGDESC_SHOWTOTALS"]		= "Montre le total pour tous vos personnages sur ce royaume"

L["CFGPAGE_COLUMNS"]		= "Colonnes"
L["CFGHDR_GENERAL"]		= "G\195\169n\195\169ral"
L["CFGNAME_SHOWCASHPERHOUR"]	= "Montrer les gains par heure"
L["CFGDESC_SHOWCASHPERHOUR"]	= "Montre la colonne des gains par heure"
L["CFGDESC_SHOWCOLUMNFOR"]	= "Montre la colonne pour %s"
L["CFGHDR_PVE"]			= "Monnaies PvE"
L["CFGHDR_PVP"]			= "Monnaies PvP"
L["CFGHDR_ARCHFRAGMENTS"]	= "Fragments d'arch\195\169ologie"
L["CFGHDR_OTHERCURRENCY"]	= "Autres monnaies"

L["CFGPAGE_CHARACTERS"]		= "Personnages"
L["CFGTXT_IGNOREDCHARS"]	= "Les personnages ignor\195\169s seront compl\195\168tement ignor\195\169s par l'add-on. Il n'en sera pas fait d'historique, ils n'appara\195\174tront pas dans l'encadr\195\169, et ne seront inclus dans aucun calcul."
L["CFGNAME_IGNORECHARS"]	= "Ignorer les personnages"

L["CFGHDR_DELETECHAR"]		= "Supprimer un personnage"
L["CFGDESC_DELETECHAR"]		= "S\195\169lectionnez un personnage \195\160 supprimer"
L["CFGTXT_DELETECHAR"]		= "Si un personnage est supprim\195\169, tout son historique sera effac\195\169."

L["CFGNAME_DELETE"]		= "Supprimer"
L["CFG_CONFIRMDELETE"]		= 'Etes-vous s\195\187r de vouloir supprimer le personnage "%s"?'
L["CFG_CONFIRMRESETSESSION"]	= "Etes-vous s\195\187r de vouloir r\195\169initialiser la session actuelle ?"

L["CFGPAGE_PROFILES"]		= "Profils"
