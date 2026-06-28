------------- GameVersionConfig

local M = {
	-- 游戏版本
	CLIENT_VERSION = "1.0.001",
	-- 游戏资源版本
	GAME_RESOURCES_VERION = "t1.0.1",
	-- 字节区服版本号  1 开头正式和预发布  0 开头 其他服
	BYTE_DANCE_SERVER_VERSION = "1.10.1",
	-- uid登录
	SHOW_UID_LOGIN_BTN = false,
	UID_LOGIN_FRONTWINDOW = "5e3b4530b293b5c1f4eeca4638ab4dc1",
	SERVER_CHAT_URL = "49.233.43.174",
	SERVER_CHAT_PORT = 9050,

	BATTLE_LOG_PATH = "I:\\WorkSpace\\zmhx\\ResProject\\Assets\\StreamingAssets\\LuaScripts\\Battle\\Log\\";
	LUA_ROOT_PATH = "I:\\WorkSpace\\zmhx\\ResProject\\Assets\\StreamingAssets\\";
	Debug = true,
	DebugUI = false,
	LUA_RELOAD_DEBUG = true,
	SERVICE_URL = nil, -- 需要用户选服时设置
	OPEN_BATTLE_LOG = false,
	USE_LOCAL_BATTLE_DATA = false,
	IS_SERVER = false,
	IS_TENCENT_TEST = true,
	OPEN_SELECT_SERVER = true,
	DOWNLOAD_CONFIG = false,
	PAY_TEST = true, -- 支付测试开关，false走sdk流程
	-- PAY_TEST = false, -- 支付测试开关，false走sdk流程
	vcd = 1,
	GUIDE_OPEN = true,
	Is_BIGGAMEAPP = false, --是否是狗头包
	BYTE_DANCE_ACCOUNT_TEST = false, -- 字节的账号测试
	--PORTAL_SERVER_ADDRESS_LIST = { -- 入口服列表
	--	"https://lf3-ca13cdn.dailygn.com/obj/rt-game-lf/gdl_app_6245/entrance/wl_test.json",
	--	"https://lf6-ca13cdn.dailygn.com/obj/rt-game-lf/gdl_app_6245/entrance/wl_test.json",
	--	"https://lf9-ca13cdn.dailygn.com/obj/rt-game-lf/gdl_app_6245/entrance/wl_test.json"
	--},
	
	-- 所有所有服务器 android
	PORTAL_SERVER_ADDRESS_NET = "http://testgw.moogame.cn:50080/wlxxconf/entrance/richug_g20cn.out.json",
	PORTAL_SERVER_ADDRESS_CN = "http://testgw.moogame.cn:50080/wlxxconf/entrance/richug_g20cn.out.json",

	--新功能
	--PORTAL_SERVER_ADDRESS_NET = "http://testwlxx.moogame.cn:50080/wlxxconf/entrance/richug_g20f1.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://testwlxx.moogame.cn:50080/wlxxconf/entrance/richug_g20f1.json",


	--g20内网
	--PORTAL_SERVER_ADDRESS_NET = "http://testwlxx.moogame.cn:50080/wlxxconf/entrance/richug_cn.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://testwlxx.moogame.cn:50080/wlxxconf/entrance/richug_cn.json",
	--宋磊服
	-- PORTAL_SERVER_ADDRESS_NET = "http://10.96.193.68:8880/underworld/static/entrance/sl.json",  
	-- PORTAL_SERVER_ADDRESS_CN = "http://10.96.193.68:8880/underworld/static/entrance/sl.json",

	-- 所有所有服务器 ios
	--PORTAL_SERVER_ADDRESS_NET = "http://assets-zmhx.seayoo.com/entrance/ios.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://assets-zmhx.seayoo.com/entrance/ios.json",
	
	-- 开发入口服务器 underworld
	-- PORTAL_SERVER_ADDRESS_NET = "http://assets-zmhx.seayoo.com/entrance/underworld.json",
	-- PORTAL_SERVER_ADDRESS_CN = "http://assets-zmhx.seayoo.com/entrance/underworld.json",

	-- 服务器 underworld_beta
	--PORTAL_SERVER_ADDRESS_NET = "http://assets-zmhx.seayoo.com/entrance/underworld_beta.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://assets-zmhx.seayoo.com/entrance/underworld_beta.json",

	-- 审核入口服务器 underworld_edition
	--PORTAL_SERVER_ADDRESS_NET = "http://assets-zmhx.seayoo.com/entrance/underworld_edition.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://assets-zmhx.seayoo.com/entrance/underworld_edition.json",

	-- 审核入口服务器 underworld_edition_horizontal
	--PORTAL_SERVER_ADDRESS_NET = "http://assets-zmhx.seayoo.com/entrance/underworld_edition_horizontal.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://assets-zmhx.seayoo.com/entrance/underworld_edition_horizontal.json",

	-- 腾讯内测服务器 underworld_prod
	--PORTAL_SERVER_ADDRESS_NET = "http://dhjh-cdn.kingsoft.com/entrance/underworld_prod.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://dhjh-cdn.kingsoft.com/entrance/underworld_prod.json",

	-- 正式服 underworld_release
	--PORTAL_SERVER_ADDRESS_NET = "http://assets-zmhx.seayoo.com/entrance/underworld_release.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://assets-zmhx.seayoo.com/entrance/underworld_release.json",

	-- 腾讯审核服务器  underworld_stg_horizontal
	-- PORTAL_SERVER_ADDRESS_NET = "http://assets-zmhx.seayoo.com/entrance/underworld_stg_horizontal.json",
	-- PORTAL_SERVER_ADDRESS_CN = "http://assets-zmhx.seayoo.com/entrance/underworld_stg_horizontal.json",

	-- 腾讯测试服务器 underworld_stg_portrait
	-- PORTAL_SERVER_ADDRESS_NET = "http://assets-zmhx.seayoo.com/entrance/underworld_stg_portrait.json",
	-- PORTAL_SERVER_ADDRESS_CN = "http://assets-zmhx.seayoo.com/entrance/underworld_stg_portrait.json",

	-- pr1服 underworld_tencent_cloud
	-- PORTAL_SERVER_ADDRESS_NET = "http://dhjh-cdn.kingsoft.com/entrance/underworld_tencent_cloud.json",
	-- PORTAL_SERVER_ADDRESS_CN = "http://dhjh-cdn.kingsoft.com/entrance/underworld_tencent_cloud.json",

	-- 策划1服 underworld_planning1
	--PORTAL_SERVER_ADDRESS_NET = "http://assets-zmhx.seayoo.com/entrance/underworld_planning1.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://assets-zmhx.seayoo.com/entrance/underworld_planning1.json",

	-- 策划2服 underworld_planning2
	-- PORTAL_SERVER_ADDRESS_NET = "http://assets-zmhx.seayoo.com/entrance/underworld_planning2.json",
	-- PORTAL_SERVER_ADDRESS_CN = "http://assets-zmhx.seayoo.com/entrance/underworld_planning2.json",

	-- 策划3服 underworld_planning3
	--PORTAL_SERVER_ADDRESS_NET = "http://assets-zmhx.seayoo.com/entrance/underworld_planning3.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://assets-zmhx.seayoo.com/entrance/underworld_planning3.json",

	-- 策划4服 underworld_planning4
	--PORTAL_SERVER_ADDRESS_NET = "http://assets-zmhx.seayoo.com/entrance/underworld_planning4.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://assets-zmhx.seayoo.com/entrance/underworld_planning4.json",

	-- 策划5服 underworld_planning5
	--  PORTAL_SERVER_ADDRESS_NET = "http://assets-zmhx.seayoo.com/entrance/underworld_planning5.json",
	--  PORTAL_SERVER_ADDRESS_CN = "http://assets-zmhx.seayoo.com/entrance/underworld_planning5.json",

	-- 自己的字节服
	-- PORTAL_SERVER_ADDRESS_NET = "http://assets-zmhx.seayoo.com/entrance/underworld_bytedance.json",
	-- PORTAL_SERVER_ADDRESS_CN = "http://assets-zmhx.seayoo.com/entrance/underworld_bytedance.json",

	-- 小米、uc、华为付费测试服
	--PORTAL_SERVER_ADDRESS_NET = "http://assets-zmhx.seayoo.com/entrance/underworld_test.json",
	--PORTAL_SERVER_ADDRESS_CN = "http://assets-zmhx.seayoo.com/entrance/underworld_test.json",

	-- 字节的服测试服务
	--PORTAL_SERVER_ADDRESS_NET = "https://lf3-ca13cdn.dailygn.com/obj/rt-game-lf/gdl_app_6245/entrance/wl_test.json",
	--PORTAL_SERVER_ADDRESS_CN = "https://lf6-ca13cdn.dailygn.com/obj/rt-game-lf/gdl_app_6245/entrance/wl_test.json",

	-- 字节的正式服务器
	-- PORTAL_SERVER_ADDRESS_NET = "https://lf3-ca13cdn.dailygn.com/obj/rt-game-lf/gdl_app_6245/entrance/wl.json",
	-- PORTAL_SERVER_ADDRESS_CN = "https://lf6-ca13cdn.dailygn.com/obj/rt-game-lf/gdl_app_6245/entrance/wl.json",

	-- 字节的预发布服务器
	-- PORTAL_SERVER_ADDRESS_NET = "https://lf3-ca13cdn.dailygn.com/obj/rt-game-lf/gdl_app_6245/entrance/wl_pre.json",
	-- PORTAL_SERVER_ADDRESS_CN = "https://lf6-ca13cdn.dailygn.com/obj/rt-game-lf/gdl_app_6245/entrance/wl_pre.json",

	--审核服：
	-- PORTAL_SERVER_ADDRESS_NET = "https://lf3-ca13cdn.dailygn.com/obj/rt-game-lf/gdl_app_6245/entrance/wl_audit.json",
	-- PORTAL_SERVER_ADDRESS_CN = "https://lf6-ca13cdn.dailygn.com/obj/rt-game-lf/gdl_app_6245/entrance/wl_audit.json",

	-- 渠道测试服务器
	-- PORTAL_SERVER_ADDRESS_NET = "https://lf3-ca13cdn.dailygn.com/obj/rt-game-lf/gdl_app_6245/entrance/wl_channel.json",
	-- PORTAL_SERVER_ADDRESS_CN = "https://lf6-ca13cdn.dailygn.com/obj/rt-game-lf/gdl_app_6245/entrance/wl_channel.json",
	--------------------------------------------废弃 start---------------------------------------------------
	-- 开发入口服务器   
	--SERVER_LIST_URL_NET = "http://49.233.43.174/underworld",
	--SERVER_LIST_URL_CN = "http://49.233.43.174/underworld",
	--------------------------------------------废弃 end---------------------------------------------------
}

-- 入口地址
--M.MASTER_URL = M.SERVER_LIST_URL_NET
M.PORTAL_SERVER_ADDRESS_URL = M.PORTAL_SERVER_ADDRESS_NET

return M

