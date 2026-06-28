---@class SettlementArenaWinNode:OOUIbase
---@field m_model SettlementModel
--- 竞技场结算 成功
local M = class("SettlementArenaWinNode",LikeOO.OOUIbase)

M.m_uiName = "Settlement/SettlementArenaWinNode"

function M:onEnter()
    self:setTextByLanKey("rank_title_text", "new_str_0226")
    self:setTextByLanKey("vs_info_title_text", "new_str_0510")
    self:setTextByLanKey("vs_title_text", "new_str_0511")
    --self.win_spine = self:findGameObject("win_sp")
    --self.animation = self.win_spine:GetComponent("SkeletonGraphic")
    --self:addSpineComplete(self.animation.AnimationState,handler(self,self.setAnimation))
    self:refreshUI()
end

function M:refreshUI()
    local data = self.m_model.m_data
    local cur_rank = data.rank or 0
    local pre_rank = data.pre_rank or 0
    local dif_rank = pre_rank - cur_rank
    self:setTextByLanKey("left_rank_text", tostring(pre_rank))
    local right_rank_text = self:setTextByLanKey("right_rank_text", tostring(cur_rank))
    right_rank_text.color = (pre_rank <= 0 or dif_rank >= 0) and GlobalConfig.COMMON_COLLOR.COMMON_18 or GlobalConfig.COMMON_COLLOR.COMMON_11
    local arrow_img = self:setImg((pre_rank <= 0 or dif_rank >= 0) and "a_zdjs_jiantou" or "a_zdjs_jiantou_1", "battle_ui", "arrow_img")
    --arrow_img.transform.localRotation = Quaternion.Euler(0,0,dif_rank >= 0 and 90 or -90) -- 上 下
    local player_left_node = self:findGameObject("player_left_node")
    local player_right_node = self:findGameObject("player_right_node")
    local left_user = self.m_model:getUserInfoBySort(1)
    local right_user = self.m_model:getUserInfoBySort(2)
    self:setPlayerInfo(player_left_node, data.score, data.pre_score, left_user)
    self:setPlayerInfo(player_right_node, data.defend_score, data.defend_pre_score, right_user)

    self:updateTaskLoopScroll()
end

function M:setPlayerInfo(obj, cur_score, pre_score, user)
    if user then
        cur_score = cur_score or 0
        pre_score = pre_score or 0
        local luaBehaviour = UIUtil.findLuaBehaviour(obj.transform)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.name))
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_title_text", "new_str_0249")
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "score_text", tostring(cur_score))
        local dif_score = cur_score - pre_score
        local dif_score_str = dif_score
        if dif_score > 0 then
            dif_score_str = "+" .. tostring(dif_score)
        end
        local add_score_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "add_score_text", "(" .. dif_score_str .. ")")
        local HeadNode = luaBehaviour:FindGameObject("HeadNode")
        GameUtil:setUserAvatar(HeadNode, user, true,nil,{show_flag = true, scale = 1})
        add_score_text.color = dif_score >= 0 and GlobalConfig.COMMON_COLLOR.COMMON_18 or GlobalConfig.COMMON_COLLOR.COMMON_11
    end
end

function M:setAnimation()
	if self.animation.AnimationState:ToString() == "animation_1" then
		self.animation.AnimationState:SetAnimation(0, "animation_2", true)
	end
end

--[[
    任务列表
]]
function M:updateTaskLoopScroll()
    --竞技场胜场任务
    local data = UserDataManager:getBattleOverQuestsByTargetType({[7] = 1, [8] = 1, [18] = 1})
    if self.m_model.m_data.week_win_times and self.m_model:weekWinNum() <= self.m_model:weekWinMaxNum() then
        local param_data = {
            id = 0,
            str = "settlement_str_0003",
            num = self.m_model:weekWinNum(),
            max_num = self.m_model:weekWinMaxNum(),
        }
        table.insert( data, param_data)
    end

    if self.m_task_scroll_view == nil then
        local loopscroll = self:findGameObject("task_loopscroll")
        local params ={
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateTaskCell(cell_obj, cell_data)
            end,
        }
        self.m_task_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_task_scroll_view:reloadData(data)
    end 
end

function M:updateTaskCell(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if data.id > 0 then
        local cfg = data.cfg
        local cur_progress = data.cur_progress
        local target_value = data.target_value
        local status = data.status
        local finish_flag = data.status == 2
        --LuaBehaviourUtil.setObjectVisible(luaBehaviour, "finish_img", finish_flag)
        local num_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num_text", tostring(cur_progress) .. "/" .. tostring(target_value))
        local des_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "des_text", Language:getTextByKey(cfg.name) .. "(" .. tostring(cur_progress) .. "/" .. tostring(target_value) .. ")")
        num_text.color = finish_flag and GlobalConfig.COMMON_COLLOR.COMMON_28 or GlobalConfig.COMMON_COLLOR.COMMON_24
        des_text.color = finish_flag and GlobalConfig.COMMON_COLLOR.COMMON_28 or GlobalConfig.COMMON_COLLOR.COMMON_24
        LuaBehaviourUtil.setImg(luaBehaviour, "finish_img", finish_flag and "a_zdjs_wanchengbiaoji" or "a_zdjs_weiwancheng", "battle_ui")
    else
        if data.num > data.max_num then
            data.num = data.max_num
        end
        local des_text = LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "des_text", Language:getTextByKey(data.str, data.num, data.max_num))
        des_text.color = data.num>= data.max_num and GlobalConfig.COMMON_COLLOR.COMMON_28 or GlobalConfig.COMMON_COLLOR.COMMON_24
    end
end

return M