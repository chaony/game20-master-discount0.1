local M = class("commonTrainRankListOneView", LikeOO.OOPopBase)
--排行奖励

M.m_uiName = "commonActive/commonTrainRankListOne"
M.m_size_type = 2

function M:onEnter()
    if self.m_model.m_data.update then
		--self:updateMsg("update_data", self.m_model.m_data, "Activities.WorldBoss.HeroBossTrainPop")
        GameUtil:lookInfoTips(static_rootControl, {msg = Language:getTextByKey("world_boss_str_0032"), delay_close = 2})
        self:updateMsg(99999)
	end
    self:setTextByLanKey("common_title_text", "new_str_0235")
    self:refreshUI()
end

function M:refreshUI()
    self:updateRankListUI()
end

function M:updateRankListUI()
	self:createLoopScroll()
    local own_info_Item = self:findGameObject("own_info_Item")
    self:updateRankItem(own_info_Item, 0, nil, true) 
end

--[[
    创建排行列表
]]
function M:createLoopScroll()
    local data = self.m_model:getRanks()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateRankItem(cell_obj, index, cell_data, false)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {index = index, cell_data = cell_data})
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:updateRankItem(obj, index, data, my_bl)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", index <= 3) 
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", index > 3) 
        if my_bl == true then
            local sort, num = self.m_model:getMyRank()
            if sort == 0 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false) 
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_rank_text", true)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_rank_text", "new_str_0076")
            elseif num < 1 then
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false) 
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_rank_text", true)
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_rank_text", "new_str_0076")
            else 
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "none_rank_text", false)
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img",  num >=1 and num <= 3) 
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", num > 3 or num < 1) 
                LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", num)
                LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..num, "common_ui")
            end
        elseif index <= 3 then
            LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..index, "common_ui")
        else
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", index)
        end
        local head_node = luaBehaviour:FindGameObject("head_node")
        if my_bl == true then
            GameUtil:setUserAvatar(head_node, UserDataManager.user_data.user_status, false, false,{show_flag = true, scale = 1})
            local server_name = UserDataManager.server_data:getServerName()
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", UserDataManager.user_data:getUserStatusDataByKey("name"))
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_text", server_name)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", GameUtil:formatValueToString(self.m_model:getMyScore()))
        else 
            local server_data = UserDataManager.server_data:getServerDataById(data.user.server)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", data.user.name)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "server_text", server_data.server_name)    
            GameUtil:setUserAvatar(head_node, data.user, false, false,{show_flag = true, scale = 1})
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", GameUtil:formatValueToString(data.score))
            local battle_id = data.battle_id or 0
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "battle_log_btn", battle_id > 0)
        end
    end    
end

return M