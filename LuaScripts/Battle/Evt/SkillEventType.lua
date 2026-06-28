--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-01-19 16:09:28
]]

--专门用于 被动技能的事件 事件类型
local SkillEventType = {}

--MV 表示事件是从 Model 到 View
--VM 表示事件是从 View 到 Model


--鬼谷 W_GuiG_skill2_1_Model
SkillEventType.MV_W_GuiG_skill2_1_Line = "W_GuiG_skill2_1_Line";
SkillEventType.MV_W_GuiG_skill2_1_PlayerEffect = "MV_W_GuiG_skill2_1_PlayerEffect";
SkillEventType.MV_W_GuiG_skill2_1_DestroyLineEffect = "MV_W_GuiG_skill2_1_DestroyLineEffect";


--霸王枪 W_BaWQ_skill1_1_Model
SkillEventType.MV_W_BaWQ_skill1_1_Model_Res_Changed = "MV_W_BaWQ_skill1_1_Model_Res_Changed"; -- 枪头变化

--合欢 W_HeH_skill3_1_Model
SkillEventType.MV_W_HeH_skill3_1_Model_PlayEffect = "MV_W_HeH_skill3_1_Model_PlayEffect";


--金钱 W_JinQ_skill2_1_Model
SkillEventType.MV_W_JinQ_skill2_1_Model_ShowEffect = "MV_W_JinQ_skill2_1_Model_ShowEffect"
SkillEventType.MV_W_JinQ_skill2_1_Model_CreateFootEffect = "MV_W_JinQ_skill2_1_Model_CreateFootEffect"


--太极 W_TaiJ_skill3_1_Model
SkillEventType.MV_W_TaiJ_skill3_1_Model_HidePlayer = "MV_W_TaiJ_skill3_1_Model_HidePlayer"
SkillEventType.MV_W_TaiJ_skill3_1_Model_ShowEffect = "MV_W_TaiJ_skill3_1_Model_ShowEffect"


--探花 W_TanH_skill1_1_Model
SkillEventType.MV_W_TanH_skill1_1_Model_ShowEffect = "MV_W_TanH_skill1_1_Model_ShowEffect"
SkillEventType.MV_W_TanH_skill1_1_Model_RefreshEffect = "MV_W_TanH_skill1_1_Model_RefreshEffect"


--形意 W_XingY_attack1_Model
SkillEventType.MV_W_XingY_attack1_Model_ClearStateEffect = "MV_W_XingY_attack1_Model_ClearStateEffect"
SkillEventType.MV_W_XingY_attack1_Model_ClearEffect = "MV_W_XingY_attack1_Model_ClearEffect"


--绝情 W_JueQ_skill0_1_Model
SkillEventType.MV_W_JueQ_skill0_1_Model_CreateEffect = "MV_W_JueQ_skill0_1_Model_CreateEffect"
SkillEventType.MV_W_JueQ_skill0_1_Model_DeleteEffect = "MV_W_JueQ_skill0_1_Model_DeleteEffect"

--万花 W_TanH_skill1_1_Model
SkillEventType.MV_W_WanH_skill1_1_Model_ShowEffect = "MV_W_WanH_skill1_1_Model_ShowEffect"

--邪极 W_XieJ_skill1_1_Model
SkillEventType.MV_W_XieJ_skill1_1_Model_ResLv_Changed = "MV_W_XieJ_skill1_1_Model_ResLv_Changed"
SkillEventType.MV_W_XieJ_Weapon_skill_Model_Puppet_Change = "MV_W_XieJ_Weapon_skill_Model_Puppet_Change"

--九黎 W_JiuL_attack1_1_Model
SkillEventType.W_JiuL_attack1_1_Model_ShowObj = "W_JiuL_attack1_1_Model_ShowObj";
SkillEventType.W_JiuL_attack1_1_Model_ChangeState = "W_JiuL_attack1_1_Model_ChangeState";

--藏剑 W_CangJ_skill3_1_Model
SkillEventType.W_CangJ_skill3_1_Model_ChangeState = "W_CangJ_skill3_1_Model_ChangeState";

--天山 W_TianS_skill2_1_Model
SkillEventType.W_TianS_skill2_1_Model_ChangeState = "W_TianS_skill2_1_Model_ChangeState";

--金钱 G_JinQ_skill2_1_Model
SkillEventType.MV_G_JinQ_skill2_1_Model_ShowEffect = "MV_G_JinQ_skill2_1_Model_ShowEffect"
SkillEventType.MV_G_JinQ_skill2_1_Model_CreateFootEffect = "MV_G_JinQ_skill2_1_Model_CreateFootEffect"

--九天 W_JiuT_skill2_1_Model
SkillEventType.MV_W_JiuT_skill2_1_Model_ShowEffect = "MV_W_JiuT_skill2_1_Model_ShowEffect"
SkillEventType.MV_W_JiuT_skill2_1_Model_CreateFootEffect = "MV_W_JiuT_skill2_1_Model_CreateFootEffect"

--羽人非獍 W_YuRFJ_skill0_1_Model
SkillEventType.MV_W_YuRFJ_skill0_1_Model_ShowEffect = "MV_W_YuRFJ_skill0_1_Model_ShowEffect"
SkillEventType.MV_W_YuRFJ_skill0_1_Model_CreateFootEffect = "MV_W_YuRFJ_skill0_1_Model_CreateFootEffect"

--九黎SP W_JiuLSP_attack1_1_Model
SkillEventType.W_JiuLSP_Summon_ShowObj = "W_JiuLSP_Summon_ShowObj";
SkillEventType.W_JiuLSP_LaoHu_Dead = "W_JiuLSP_LaoHu_Dead";

return SkillEventType