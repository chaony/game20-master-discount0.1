--- 章节结算 成功
local M = class("SettlementMultChapterWinNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementMultGuJianWinNode"

function M:onEnter()
	self:setTextByLanKey("title_text", "new_str_0261")
    self.reward_grid = self:findGameObject("reward_grid")
    self.m_reward_node = self:findGameObject("rewards_node")
    self:showReward()
    self:refreshUI()
end

function M:refreshUI()
    local cur_stage_cfg = UserDataManager:getCurStageCfg()
    self:setObjectVisible("next_open_id_text",true);
    if (self.m_model.m_mode == GlobalConfig.BATTLE_MODE.STAGE or self.m_model.m_mode == GlobalConfig.BATTLE_MODE.MULT_STAGE) and cur_stage_cfg and cur_stage_cfg.next_open_id and cur_stage_cfg.next_open_id ~= 0 then
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
    self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getBattleRounds()
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("result_loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateScrollViewCell(index, cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {index = index , cell_data = cell_data})
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data, true)
    end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local round_data = data.round_data or {}
    local result = round_data.result or 0
    local round = round_data.round or 0
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_title_text", "new_str_0295", index)

    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "team_num_text", "mult_stage_text00" .. index)
    local lan_atlas = ResourceUtil:getLanAtlas()
    LuaBehaviourUtil.setImg(luaBehaviour,"left_result_img",result == 1 and "a_sjjs_shengli" or "a_sjjs_shibai", lan_atlas)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "battle_log_btn", self.m_model.m_quick_pass ~= true)
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
    local rectTransform = self.m_luaBehaviour:FindRectTransform("ScrollView")
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
        end
		item.transform:SetParent(self.reward_grid.transform, false)
		self.m_item[i] = item
    end
    self:setObjectVisible("reward_bg", num > 0)
    if self.m_model.m_mode == GlobalConfig.BATTLE_MODE.GU_JIAN_MULT then
        self:setObjectVisible("win_ok_btn",  false)
    else
        self:setObjectVisible("win_ok_btn",  true)
    end
    self:setObjectVisible("return_btn",  false)     
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

return M