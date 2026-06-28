--- 五行阵结算
local M = class("SettlementFiveElementNodeNew",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementFiveElementNodeNew"

M.TAB = {	{img = "a_ui_xuanwu"} , 
		    {img = "a_ui_zhuque"} , 
			{img = "a_wxz_icon_tu"} , 	
			{img = "a_ui_qinglong"} , 
			{img = "a_ui_baihu"} , 
		}

function M:onEnter()
    self.reward_grid = self:findGameObject("reward_grid")
    self:refreshUI()
end

function M:refreshUI()
    --self:setObjectVisible("reward_bg", self.m_model.m_result == 1)
    self:setObjectVisible("reward_bg", false)
    self:setTextByLanKey("get_reward_text", "new_str_0534")
    self:setTextByLanKey("get_jl_text", "hunt_treasure_str_036")
    self:setObjectVisible("get_jl_text_bg_img", false)
    self:setObjectVisible("get_jl_text", false)
    if self.m_model.m_result == 1 and self.m_model.m_replay ~= true then
        local data = self.m_model:getDefByFloor()
        if data then
            GameUtil:setLanImgText(self:findRectTransform("main_img"), data.icon)
        end
    end
    --self:updateTaskLoopScroll()
    self:showReward()
end

--[[
    奖励列表
]]
function M:showReward()
    local reward = self.m_model.m_rewards or {}
    local heirloom = {}
    if self.m_model.m_data and self.m_model.m_data.reward and self.m_model.m_data.reward.ft_heirloom then
        heirloom = RewardUtil:mergeRewardAndFormat({heirloom = self.m_model.m_data.reward.ft_heirloom or {}})
    end
    for index = 1, #heirloom do
        table.insert(reward, heirloom[index])
    end
    local num = #reward
    for i = 1, num do
        local data = reward[i]
        local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
        local item = GameUtil:createItemElement(data, showNum, true)
        item.transform:SetParent(self.reward_grid.transform, false)
        self:setObjectVisible("get_jl_text_bg_img", true)
        self:setObjectVisible("get_jl_text", true)
    end
end

function M:updateTaskLoopScroll()
    --关卡任务
    local data = nil
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY 
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW 
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE
            or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS then
        data = UserDataManager:getBattleOverQuestsByTargetType({[43] = 1, [44] = 1})
    else
        data = {}
    end
    for i = 1, 3 do
        local cell_name = "cell_"..i
        self:setObjectVisible(cell_name, false)
    end
    for i = 1, #data do
        local cell_name = "cell_"..i
        self:setObjectVisible(cell_name, true)
        local task_cell = self:findGameObject(cell_name)
        self:updateTaskCell(task_cell, data[i])
    end
end

local FINISH_COLOR = Color.New(74/255, 237/255, 109/255)
local UN_FINISH_COLOR = Color.New(244/255, 236/255, 201/255)

function M:updateTaskCell(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local cfg = data.cfg
    local cur_progress = data.cur_progress
    local target_value = data.target_value
    local status = data.status
    local finish_flag = data.status == 2
   -- LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", finish_flag)
    local num_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num_text", tostring(cur_progress) .. "/" .. tostring(target_value))
    local des_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "des_text", cfg.name)
    num_text.color = finish_flag and FINISH_COLOR or UN_FINISH_COLOR
    des_text.color = finish_flag and FINISH_COLOR or UN_FINISH_COLOR
end

function M:showOverWord()
    self:setObjectVisible("return_btn", false)
end

return M