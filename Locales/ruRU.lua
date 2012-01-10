--[[ *******************************************************************
Project                 : Broker_Currencyflow
Description             : Russian translation file (ruRU)
Author                  : Aledara (wowi AT jocosoft DOT com)
Translator              : Пашуля @ Черный Шрам EU
Revision                : $Rev: 36 $
********************************************************************* ]]

local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale( "Currencyflow", "ruRU" )
if not L then return end
L["NAME_YES"]			= "Да"
L["NAME_NO"]			= "Нет"
L["NAME_MONEY"]			= "Деньги"
L["NAME_DALJCTOKEN"]		= "Даларанский знак ювелира"
L["NAME_DALCOOKINGAWARD"]	= "Даларанская кулинарная награда"

L["NAME_CHAMPIONSEAL"]		= "Печать чемпиона"
L["NAME_JUSTICEPOINTS"]		= "Очки доблести"
L["NAME_HONORPOINTS"]		= "Очки чести"
L["NAME_CONQUESTPOINTS"]	= "Очки завоевания"

-- Name of archaeology fragments
L["NAME_AF_DWARF"]		= "Дворфийский артефакт"
L["NAME_AF_DRAENEI"]		= "Дренейский артефакт"
L["NAME_AF_FOSSIL"]		= "Окаменелость"
L["NAME_AF_NIGHTELF"]		= "Артефакт ночных эльфов"
L["NAME_AF_NERUBIAN"]		= "Нерубский артефакт"
L["NAME_AF_ORC"]		= "Оркский артефакт"
L["NAME_AF_TOLVIR"]		= "Тол'вирский артефакт"
L["NAME_AF_TROLL"]		= "Тролльский артефакт"
L["NAME_AF_VRYKULL"]		= "Врайкульский артефакт"
L["NAME_AF_OTHER"]		= "Другое"

-- Config panel - Main
L["CFGHDR_TOOLTIP"]		= "Подсказка"
L["CFGNAME_CASHFORMAT"]		= "Формат"
L["CFGDESC_CASHFORMAT"]		= "Выберите, в каков виде показывать деньги"
L["CFGOPT_CF_CONDENSED"]	= "Сжатый"
L["CFGOPT_CF_SHORT"]		= "Краткий"
L["CFGOPT_CF_FULL"]		= "Полный"
L["CFGOPT_CF_COINS"]		= "Монеты"
L["CFGNAME_TTSCALE"]		= "Масштаб подсказки"
L["CFGDESC_TTSCALE"]		= "Выберите размер подсказки"
L["CFGNAME_SHOWCASHDETAIL"]	= "Показывать детали"
L["CFGDESC_SHOWCASHDETAIL"]	= "Показывать линии получено/потрачено"
L["CFGHDR_BUTTON"]		= "Кнопка"
L["CFGNAME_BUTTONFIRST"]	= "Первая"
L["CFGDESC_BUTTONFIRST"]	= "Первая валюта, которую показывать на кнопке"
L["CFGNAME_BUTTONSECOND"]	= "Вторая"
L["CFGDESC_BUTTONSECOND"]	= "Вторая валюта, которую показывать на кнопке"
L["CFGNAME_BUTTONTHIRD"]	= "Третья"
L["CFGDESC_BUTTONTHIRD"]	= "Третья валюта, которую показывать на кнопке"
L["CFGNAME_BUTTONFOURTH"]	= "Четвертая"
L["CFGDESC_BUTTONFOURTH"]	= "Четвертая валюта, которую показывать на кнопке"
L["CFGOPT_BTNNONE"]		= "---"
L["CFGOPT_BTNMONEY"]		= "Текущий баланс"
L["CFGOPT_BTNSESSIONTOTAL"]	= "Всего золота за сессию"
L["CFGOPT_BTNSESSIONPERHOUR"]	= "За сессию золота/ч"
L["CFGOPT_BTNTODAYTOTAL"]	= "Всего золота сегодня"
L["CFGOPT_BTNTODAYPERHOUR"]	= "Сегодня золота/ч"
L["CFGOPT_BTNWEEKTOTAL"]	= "Всего золота за неделю"
L["CFGOPT_BTNWEEKPERHOUR"]	= "За неделю золота/ч"
L["CFGOPT_BTNMONTHTOTAL"]	= "Всего золота за месяц"
L["CFGOPT_BTNMONTHPERHOUR"]	= "За месяц золота/ч"
L["CFGOPT_BTNOTHER"]		= "Текущее %s"

L["CFGPAGE_SECTIONS"]		= "Секции"
L["CFGNAME_THISSESSION"]	= "Текущая сессия"
L["CFGHDR_HISTORY"]		= "Секции истории"
L["CFGNAME_TODAYSELF"]		= "Сегодня (лично)"
L["CFGNAME_TODAYTOTAL"]		= "Сегодня (всего)"
L["CFGNAME_YESTERDAYSELF"]	= "Вчера (лично)"
L["CFGNAME_YESTERDAYTOTAL"]	= "Вчера (всего)"
L["CFGNAME_WEEKSELF"]		= "Неделя (лично)"
L["CFGNAME_WEEKTOTAL"]		= "Неделя (всего)"
L["CFGNAME_MONTHSELF"]		= "Месяц (лично)"
L["CFGNAME_MONTHTOTAL"]		= "Месяц (всего)"
L["CFGNAME_TIPOPTIONS"]		= "ПКМ для настроек"
L["CFGNAME_TIPRESETSESSION"]	= "Shift-Клик для сброса сессии"
L["CFGNAME_GAINED"]		= "Получено"
L["CFGNAME_SPENT"]		= "Потрачено"
L["CFGNAME_PROFIT"]		= "Доход"
L["CFGHDR_OTHERCHARS"]		= "Другие персонажи в игровом мире"
L["CFGNAME_OTHERCHARS"]		= "Показывать других персонажей"
L["CFGDESC_OTHERCHARS"]		= 'Показывать секцию "Персонажи"'
L["CFGNAME_CHARACTERS"]		= "Персонажи"
L["CFGNAME_SORTOTHERCHARS"]	= "Сортировать персонажей по"
L["CFGDESC_SORTOTHERCHARS"]	= "Выберите, как список персонажей будет сортирован"
L["CFGOPT_SORTNAME"]		= "Имя"
L["CFGNAME_SORTDESC"]		= "по убыванию"
L["CFGDESC_SORTDESC"]		= "Если выбрано, значения будут сортированы от большего к меньшему"
L["CFGHDR_TOTALS"]		= "ИТОГО"
L["CFGNAME_TOTAL"]		= "ИТОГО"
L["CFGNAME_SHOWTOTALS"]		= "Показывать ИТОГО"
L["CFGDESC_SHOWTOTALS"]		= "Показывать ИТОГО для всех персонажей данного игрового мира"

L["CFGPAGE_COLUMNS"]		= "Колонки"
L["CFGHDR_GENERAL"]		= "Общее"
L["CFGNAME_SHOWCASHPERHOUR"]	= "Показывать сумму в час"
L["CFGDESC_SHOWCASHPERHOUR"]	= "Показывать колонку для суммы в час"
L["CFGDESC_SHOWCOLUMNFOR"]	= "Показывать колонку подсказки для %s"
L["CFGHDR_PVE"]			= "ПвЕ валюта"
L["CFGHDR_PVP"]			= "ПвП валюта"
L["CFGHDR_ARCHFRAGMENTS"]	= "Археологические фрагменты"
L["CFGHDR_OTHERCURRENCY"]	= "Другая валюта"

L["CFGPAGE_CHARACTERS"]		= "Персонажи"
L["CFGTXT_IGNOREDCHARS"]	= "Игнорируемые персонажи не будут никак учитываться аддоном. У них не будет ни собственной истории, не будут показываться в подсказке и не будут учавствовать ни в каких подсчетах."
L["CFGNAME_IGNORECHARS"]	= "Игнорировать персонажей"

L["CFGHDR_DELETECHAR"]		= "Удалить персонажа"
L["CFGDESC_DELETECHAR"]		= "Выберите прсонажа для удаления"
L["CFGTXT_DELETECHAR"]		= "Если персонаж удален, вся его история также будет удалена"

L["CFGNAME_DELETE"]		= "Удалить"
L["CFG_CONFIRMDELETE"]		= 'Вы уверены, что хотите удалить персонажа "%s"?'
L["CFG_CONFIRMRESETSESSION"]	= "Вы уверены что хотите сбросить текущую сессию?"

L["CFGPAGE_PROFILES"]		= "Профили"
