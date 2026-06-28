--- 江湖传说结算
local M = class("SettlementLegendNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementLegendNode"

function M:onEnter()
    self.reward_grid = self:findGameObject("reward_grid")
    self:refreshUI()
end

function M:refreshUI()
    self:setObjectVisible("new_img", self.m_model.m_legend_new_record)
    self:showNum(self.m_model:getBattleInfo(), "info_", "a_jhcg_js_")
    local ruler_str, ruler_str1= "", ""
    if self.m_model.m_common.battle_mode == 2 then
        self:setTextByLanKey("battle_info_text", "legend_str_006")
        ruler_str = "tid#LegendRule_03"
        ruler_str1 = "tid#LegendRule_07"
    elseif self.m_model.m_common.battle_mode == 3 then
        self:setTextByLanKey("battle_info_text", "legend_str_021")
        ruler_str = "tid#LegendRule_04"
        ruler_str1 = "tid#LegendRule_08"
    end
    self:setTextByLanKey("record_left_text", "legend_str_032")
    self:setTextByLanKey("record_right_text", "legend_str_033")
    local record = self.m_model.m_data.surpass
    local break_value = self.m_model:getLegendBreakValue()
    local need_sorce = break_value - self.m_model:getBattleInfo()
    self:setObjectVisible("level_change_img", true)
    self:setObjectVisible("ruler_text", false)
    self:setObjectVisible("ruler_text1", false)
    self:setObjectVisible("level_change_content", false)
    self:setTextByLanKey("new_text", "xin_jl_text")
    self:setTextByLanKey("return_btn_text", "new_str_0478")
    local level_change_img = self:findImage("level_change_img")
    if break_value == 0 then --难度拉满了
        self:setImg("a_jhcg_yidadaozuigaonandu",  ResourceUtil:getLanAtlas(), "level_change_img")
    elseif need_sorce > 0 then
        self:setObjectVisible("ruler_text", true)
        self:setObjectVisible("ruler_text1", true)
        self:setObjectVisible("level_change_content", true)
        self:setTextByLanKey("ruler_text", ruler_str, need_sorce)
        self:setTextByLanKey("ruler_text1", ruler_str1)
        self:setObjectVisible("level_change_img", false)
        self:showNum(need_sorce, "level_change_", "a_jhcg_js_")
    else
        self:setImg("a_jhcg_nandushengji",  ResourceUtil:getLanAtlas(), "level_change_img")
    end
    level_change_img:SetNativeSize()

    self:showNum(tostring(record).."%", "record_", "a_jhcg_")
    --self:showReward()
end

function M:showNum(num, key, img_name)
    local num_str = tostring(num)
    for i = 1, 4 do
        if i <= string.len(num_str) then
            LuaBehaviourUtil.setImg(self.m_luaBehaviour, key.."num"..tostring(i), img_name..string.sub(num_str,i,i), "main_ui")
            LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, key.."num"..tostring(i), true)
        else
            LuaBehaviourUtil.setObjectVisible(self.m_luaBehaviour, key.."num"..tostring(i), false)
        end
    end
end

function M:showOverWord()
    self:setObjectVisible("return_btn", false)
end

--[[
    奖励列表
]]
function M:showReward()
    local reward = self.m_model.m_rewards or {}
    local num = #reward
    for i = 1, num do
        local data = reward[i]
        local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
        local item = GameUtil:createItemElement(data, showNum, true)
        item.transform:SetParent(self.reward_grid.transform, false)
        self:setObjectVisible("get_reward_text_bg_img", true)
        self:setObjectVisible("get_reward_text", true)
    end
end
return M