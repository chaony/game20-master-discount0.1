--- 章节结算 成功
---@class SettlementChapterWinNode:OOUIbase
local M = class("SettlementChapterWinNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementChapterWinNode"

function M:onEnter()
	self:setTextByLanKey("title_text", "new_str_0261")
    self:setTextByLanKey("get_reward_text", "new_str_0261")
    self:setTextByLanKey("win_ok_btn_text", "new_str_0241")
    self:setTextByLanKey("return_btn_text", "new_str_0478")
    self.reward_grid = self:findGameObject("reward_grid")
    self.m_reward_node = self:findGameObject("rewards_node")
    self:showReward()
    self:refreshUI()
    self:showRelicChoice()
end

function M:refreshUI()
    self:updateTaskLoopScroll()
    local cur_stage_cfg = UserDataManager:getCurStageCfg()
    if (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE) 
            and cur_stage_cfg and cur_stage_cfg.next_open_id and cur_stage_cfg.next_open_id ~= 0 then
        local open_flag, tips_str = BtnOpenUtil:isBtnOpen(cur_stage_cfg.next_open_id)
        self:setObjectVisible("next_open_id_text",true);
        if not open_flag then
            self:setTextByLanKey("next_open_id_text", tips_str)
        else
            self:setTextByLanKey("next_open_id_text", "")
        end
    else
        self:setObjectVisible("next_open_id_text",false);
        self:setTextByLanKey("next_open_id_text", "")
    end
    self:setObjectVisible("auto_next", self.m_model.autoChapterNextOpen == true)
    self:setObjectVisible("get_img", self.m_model.auotChapterBl == 1 and self.m_model.auto_open_limit == true)
    local can_click, str = self.m_model:checkChapterNextLimit()
    if self.m_model.auto_open_limit == true then
        self:setObjectVisible("open_status", true)
        self:setObjectVisible("close_status", false)
    else
        self:setObjectVisible("open_status", false)
        self:setObjectVisible("close_status", true)
        if can_click == 2 and str then
            self:setTextByLanKey("next_close_tips", "xian_str_0012", str)
        elseif can_click == 1 then
            local lv = self.m_model:getAutoVipLvByType()
            self:setTextByLanKey("next_close_tips", "xian_str_0014", lv)
        end
    end
end

function M:playAnim()
    if self.m_luaBehaviour then
        self.m_luaBehaviour:RunAnim("SettlementChapterWinNode_show", nil, 1)
    end
end

--[[
    奖励列表
]]
function M:showReward()
	self.m_item = {}
    local num = math.min(10,#self.m_model.m_rewards)
    local rectTransform = self.m_luaBehaviour:FindRectTransform("Scroll View")
    local sizeDelta = rectTransform.sizeDelta
    for i = 1, num do
		local data = self.m_model.m_rewards[i]
		local showNum = data[1] ~= RewardUtil.REWARD_TYPE_KEYS.HEROS
        local item = GameUtil:createItemElement(data, showNum, true)
        if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RAID then --武道场
            local vec2 = sizeDelta
            vec2.y = 200
            rectTransform.sizeDelta  = vec2
            item = GameUtil:instanceObject(self.m_reward_node)
            item:SetActive(true)
            GameUtil:updateItemElement(item, data, showNum, true)
            local luaBehaviour = UIUtil.findLuaBehaviour(item)
            local mystic_piece_flag = false
            mystic_piece_flag = mystic_piece_flag or data.mystic_piece == 1
            local extra_type = data.extra_type
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "privilege_img", extra_type == 1)

            local show_flag = false
            if GameUtil:checkDoubleActiveByType(5) == true then
                show_flag = true
            end
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "double_earn", show_flag)
        end
		item.transform:SetParent(self.reward_grid.transform, false)
		-- UIUtil.setScale(item.transform, 0.6)
		
       
		-- UIUtil.setOpacity(item.transform, 0)
		self.m_item[i] = item
    end
    -- self.m_control:setOnceTimer(1,handler(self,self.revealItem))
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOP_OF_TIME or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.TOWER then
        self:setObjectVisible("reward_bg", false)
        self:setObjectVisible("loopscroll", false)
    else
        self:setObjectVisible("reward_bg", num > 0)
    end
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MINING or 
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MAZE or 
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.BIOGRAPHY or
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.BIG_MAP or    
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_MINING or
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RAID or 
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE or
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GVE_BATTLE_BOSS or
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE or 
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RACCON or 
            self.m_model.m_mode == GlobalConfig.BATTLE_MODE.NEW_BIG_MAP then
        self:setObjectVisible("win_ok_btn",  false)
    elseif self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_TOWER and self.m_model:isActiveTowerMaxFloor() then
        self:setObjectVisible("win_ok_btn",  false)
    else
        self:setObjectVisible("win_ok_btn",  true)    
    end
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MAZE or
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.WORLD_BOSS or
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE_BOSS or
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.FIVE_ARRAY or 
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.EVIL_SHADOW or
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.COMMON_BATTLE or
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.SORT_CHIVALROUS or
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.DRAGONSWORD or
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.ACTIVE or 
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.BIOGRAPHY or 
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.LOCAL_ARENA or 
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.BIG_MAP or 
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.RAID or 
        self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MAZE or
            self.m_model.m_mode == GlobalConfig.BATTLE_MODE.NEW_BIG_MAP then
        self:setObjectVisible("return_btn",  true)  
    else
        self:setObjectVisible("return_btn",  false)     
    end
	self.num = num
end

function M:revealItem()
    for k,v in pairs(self.m_item) do
        UIUtil.setOpacity(v.transform, 1)
    end
end


--[[
    任务列表
]]
function M:updateTaskLoopScroll()
    --关卡任务
    local data = nil
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE then
        data = UserDataManager:getBattleOverQuestsByTargetType({[1] = 1})
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
    -- if self.m_task_scroll_view == nil then
    --     local loopscroll = self:findGameObject("loopscroll")
    --     local params ={
    --         show_data = data,
    --         loop_scroll_object = loopscroll,
    --         update_cell = function(index, cell_obj, cell_data)
    --             self:updateTaskCell(cell_obj, cell_data)
    --         end,
    --     }
    --     self.m_task_scroll_view = LoopScrollViewUtil.new(params)
    -- else
    --     self.m_task_scroll_view:reloadData(data)
    -- end 
end

local FINISH_COLOR = Color.New(74/255, 237/255, 109/255)
local UN_FINISH_COLOR = Color.New(204/255, 239/255, 239/255)

function M:updateTaskCell(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local cfg = data.cfg
    local cur_progress = data.cur_progress
    local target_value = data.target_value
    local status = data.status
    local finish_flag = data.status == 2
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", finish_flag)
    local num_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num_text", tostring(cur_progress) .. "/" .. tostring(target_value))
    local des_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "des_text", cfg.name)
    num_text.color = finish_flag and FINISH_COLOR or UN_FINISH_COLOR
    des_text.color = finish_flag and FINISH_COLOR or UN_FINISH_COLOR
end

function M:updateButtonVisible(flag)

end

function M:updateTime()
    if self.m_model.auotChapterBl == 1 and self.m_model.auto_open_limit == true then
        self:setTextByLanKey("auto_next_text", "settlement_str_0001", self.m_model.autoChapterDownTime)
        if self.m_model.autoChapterDownTime>= 0 then
            self:setObjectVisible("open_status", true)
        else
            self:setObjectVisible("open_status", false)   
        end
    else
        self:setTextByLanKey("auto_next_text", "settlement_str_0002")
    end
end

function M:showOverWord()
    self:setObjectVisible("win_ok_btn", false)
    self:setObjectVisible("return_btn", false)
end

---侠客岛遗物
function M:showRelicChoice()
    if self.m_model.m_mode==GlobalConfig.BATTLE_MODE.XIAKEDAO then
        if table.nums(self.m_model.m_data.drop_heirlooms)>0 then
            local relicChoiceNode=CustomRequire("UI.Xiakedao.Relic.RelicChoiceNode")
            relicChoiceNode.new(self.m_control,{parent=self.m_params.parent})
        end
    end
end

return M