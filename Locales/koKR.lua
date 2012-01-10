--[[ *******************************************************************
Project                 : Broker_Currencyflow
Description             : Korean translation file (koKR)
Author                  : Aledara (wowi AT jocosoft DOT com)
Translator              : Ohyung (ohyung AT ohyung DOT com)
Revision                : $Rev: 36 $
********************************************************************* ]]

local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale( "Currencyflow", "koKR" )
if not L then return end

-- Name of currency
L["NAME_YES"]			= "네"
L["NAME_NO"]			= "아니오"
L["NAME_MONEY"]			= "소지금"
L["NAME_DALJCTOKEN"]		= "달라란 보석세공사의 징표"
L["NAME_ILLJCTOKEN"]		= "저명한 보석세공사의 징표"
L["NAME_DALCOOKINGAWARD"]	= "달라란 요리상"
L["NAME_CHEFSAWARD"]		= "요리사상"

L["NAME_CHAMPIONSEAL"]		= "용사의 인장"
L["NAME_JUSTICEPOINTS"]		= "정의 점수"
L["NAME_VALORPOINTS"]		= "용맹의 점수"
L["NAME_HONORPOINTS"]		= "명예 점수"
L["NAME_CONQUESTPOINTS"]	= "정복 점수"
L["NAME_TOLBARADCOMMENDATION"]	= "톨 바라드 증표"

-- Name of archaeology fragments
L["NAME_AF_DWARF"]		= "드워프"
L["NAME_AF_DRAENEI"]		= "드레나이"
L["NAME_AF_FOSSIL"]		= "화석"
L["NAME_AF_NIGHTELF"]		= "나이트 엘프"
L["NAME_AF_NERUBIAN"]		= "네루비안"
L["NAME_AF_ORC"]		= "오크"
L["NAME_AF_TOLVIR"]		= "톨비르"
L["NAME_AF_TROLL"]		= "트롤"
L["NAME_AF_VRYKULL"]		= "브리쿨"
L["NAME_AF_OTHER"]		= "기타"

-- Config panel - Main
L["CFGHDR_TOOLTIP"]		= "툴팁"
L["CFGNAME_CASHFORMAT"]		= "소지금 표시 방법"
L["CFGDESC_CASHFORMAT"]		= "소지금을 표시하는 방법 선택 합니다"
L["CFGOPT_CF_CONDENSED"]	= "생략"
L["CFGOPT_CF_SHORT"]		= "짧게"
L["CFGOPT_CF_FULL"]		= "전체"
L["CFGOPT_CF_COINS"]		= "동전"
L["CFGNAME_TTSCALE"]		= "툴팁 크기"
L["CFGDESC_TTSCALE"]		= "툴팁 크기를 선택 합니다"
L["CFGNAME_SHOWCASHDETAIL"]	= "소지금 자세히 표시"
L["CFGDESC_SHOWCASHDETAIL"]	= "소지금 획득/소모량을 추가로 표시합니다"
L["CFGHDR_BUTTON"]		= "버튼"
L["CFGNAME_BUTTONFIRST"]	= "첫번째"
L["CFGDESC_BUTTONFIRST"]	= "첫번째 표시할 화폐를 선택합니다"
L["CFGNAME_BUTTONSECOND"]	= "두번째"
L["CFGDESC_BUTTONSECOND"]	= "두번째 표시할 화폐를 선택합니다"
L["CFGNAME_BUTTONTHIRD"]	= "세번째"
L["CFGDESC_BUTTONTHIRD"]	= "세번째 표시할 화폐를 선택합니다"
L["CFGNAME_BUTTONFOURTH"]	= "네번째"
L["CFGDESC_BUTTONFOURTH"]	= "네번째 표시할 화폐를 선택합니다"
L["CFGOPT_BTNNONE"]		= "없음"
L["CFGOPT_BTNMONEY"]		= "현재 소지금"
L["CFGOPT_BTNSESSIONTOTAL"]	= "전체 접속후 소지금"
L["CFGOPT_BTNSESSIONPERHOUR"]	= "시간당 접속 소지금"
L["CFGOPT_BTNTODAYTOTAL"]	= "전체 오늘의 소지금"
L["CFGOPT_BTNTODAYPERHOUR"]	= "시간당 오늘 소지금"
L["CFGOPT_BTNWEEKTOTAL"]	= "전체 이번주 소지금"
L["CFGOPT_BTNWEEKPERHOUR"]	= "시간당 이번주 소지금"
L["CFGOPT_BTNMONTHTOTAL"]	= "전체 이번달 소지금"
L["CFGOPT_BTNMONTHPERHOUR"]	= "시간당 이번달 소지금"
L["CFGOPT_BTNOTHER"]		= "현재 %s"

L["CFGPAGE_SECTIONS"]		= "접속"
L["CFGNAME_THISSESSION"]	= "현재 접속"
L["CFGHDR_HISTORY"]		= "히스토리 섹션"
L["CFGNAME_TODAYSELF"]		= "오늘 (나)"
L["CFGNAME_TODAYTOTAL"]		= "오늘 (전체)"
L["CFGNAME_YESTERDAYSELF"]	= "어제 (나)"
L["CFGNAME_YESTERDAYTOTAL"]	= "어제 (전체)"
L["CFGNAME_WEEKSELF"]		= "이번주 (나)"
L["CFGNAME_WEEKTOTAL"]		= "이번주 (전체)"
L["CFGNAME_MONTHSELF"]		= "이번달 (나)"
L["CFGNAME_MONTHTOTAL"]		= "이번달 (전체)"
L["CFGNAME_TIPOPTIONS"]		= "Right-Click 으로 옵션창 열기"
L["CFGNAME_TIPRESETSESSION"]	= "Shift-Click 으로 세션 초기화"
L["CFGNAME_GAINED"]		= "획득"
L["CFGNAME_SPENT"]		= "소모"
L["CFGNAME_PROFIT"]		= "이득"
L["CFGHDR_OTHERCHARS"]		= "서버내 다른 케릭터 보기"
L["CFGNAME_OTHERCHARS"]		= "모든 케릭터 표시"
L["CFGDESC_OTHERCHARS"]		= '서버내 케릭터들을 표시합니다'
L["CFGNAME_CHARACTERS"]		= "케릭터"
L["CFGNAME_SORTOTHERCHARS"]	= "케릭터 정렬 조건"
L["CFGDESC_SORTOTHERCHARS"]	= "어떤방식으로 정렬할지 고릅니다."
L["CFGOPT_SORTNAME"]		= "이름"
L["CFGNAME_SORTDESC"]		= "역순 정렬"
L["CFGDESC_SORTDESC"]		= "선택하면 높은것부터 낮은것 순서로 정렬합니다"
L["CFGHDR_TOTALS"]		= "전체"
L["CFGNAME_TOTAL"]		= "합계"
L["CFGNAME_SHOWTOTALS"]		= "케릭터 소지금 합계 표시"
L["CFGDESC_SHOWTOTALS"]		= "이 서버내의 케릭터 소지금의 합계를 표시합니다"

L["CFGPAGE_COLUMNS"]		= "칼럼"
L["CFGHDR_GENERAL"]		= "일반"
L["CFGNAME_SHOWCASHPERHOUR"]	= "시간당 소지금 표시"
L["CFGDESC_SHOWCASHPERHOUR"]	= "시간당 소지금 칼럼 표시"
L["CFGDESC_SHOWCOLUMNFOR"]	= "%s에 대한 툴팁 칼럼을 표시"
L["CFGHDR_PVE"]			= "PVE 화폐"
L["CFGHDR_PVP"]			= "PVP 화폐"
L["CFGHDR_ARCHFRAGMENTS"]	= "고고학 유물"
L["CFGHDR_OTHERCURRENCY"]	= "기타 화폐"

L["CFGPAGE_CHARACTERS"]		= "케릭터"
L["CFGTXT_IGNOREDCHARS"]	= "케릭터 무시는 이 애드온에서 모든것을 무시하게 됨니다. 히스토리, 툴팁등 어떠한것도 표시하거나 저장하지 않습니다."
L["CFGNAME_IGNORECHARS"]	= "케릭터 무시"

L["CFGHDR_DELETECHAR"]		= "케릭터 삭제"
L["CFGDESC_DELETECHAR"]		= "삭제할 케릭터 선택"
L["CFGTXT_DELETECHAR"]		= "케릭터를 삭제하면 모든 히스토리가 삭제됩니다."

L["CFGNAME_DELETE"]		= "삭제"
L["CFG_CONFIRMDELETE"]		= '"%s" 케릭터를 삭제 하시겠습니까?'
L["CFG_CONFIRMRESETSESSION"]	= "이번 접속의 데이터를 초기화 하시겠습니까?"

L["CFGPAGE_PROFILES"]		= "프로필"


