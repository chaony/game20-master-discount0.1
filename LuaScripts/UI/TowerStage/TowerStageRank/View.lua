local M = class("TowerStageRankView",LikeOO.OOPopBase)

M.m_uiName = "TowerStage/TowerStageRank"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("common_title_text", "new_str_0397")
    self:setTextByLanKey("common_no_have_text", "new_str_0351")
    self:setTextByLanKey("own_rank_text", "new_str_0077")
    self:setTextByLanKey("rank_label_text", "new_str_0374")
	self:setTextByLanKey("player_label_text", "new_str_0372")
    self:setTextByLanKey("layer_label_text", "new_str_0113")
    self:setTextByLanKey("pass_time_label_text", "new_str_0398")

    -- self.m_own_info_node = self:findGameObject("own_info_node")
    -- self.m_own_info_prefab = GameUtil:createPrefab("TowerStage/TowerStageRankItem",self.m_own_info_node.transform)
    -- local transform = self.m_own_info_prefab.transform
    -- local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	-- luaBehaviour:RegistButtonClick(handler(self, self.ownItemClick))
    -- UIUtil.setObjectVisible(transform, false, "top_three_rank_img")
    -- UIUtil.setObjectVisible(transform, false, "time_text")
    -- local img = UIUtil.findImage(transform)
    -- img.color = GlobalConfig.COMMON_COLLOR.COMMON_1
    local data = self.m_model:getOwnRankData()
    -- self:updateItemInfo(self.m_own_info_prefab, data, false)

    local user = data.user or {}
    local rank = data.rank or 0
    local name = user.name
    local own_head_node = self:findGameObject("own_head_node")
    GameUtil:setUserAvatar(own_head_node, user,nil,nil,{show_flag = true, scale = 1})
    if name == nil or name == "" then
        self:setTextByLanKey("own_name_text", tostring(user.uid))
    else
        self:setTextByLanKey("own_name_text", tostring(name))
    end
    local score = data.score or 0
    self:setTextByLanKey("own_score_text", "new_str_0452", score)
    if rank < 1 then
        self:setTextByLanKey("own_rank_text", "new_str_0076")
    else
        self:setTextByLanKey("own_rank_text", "new_str_0453", rank)
    end    
    local time = data.time or 0
    if time > 0 then
        local tm = TimeUtil.gmTime(time)
        local time_str = string.format("%d/%02d/%02d", tm.year, tm.month, tm.day)
        self:setTextByLanKey("pass_time_text", time_str)
    else
        self:setTextByLanKey("pass_time_text", "--:--:--")
    end
	self:refreshUI()
end

function M:ownItemClick(obj, name, itag)
	self:updateMsg("look_own")
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getRankData()
    self:setObjectVisible("common_tips_node", #data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("item_click", {id = index})
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
    self:updateItemInfo(cell_object, data, true)
end

function M:updateItemInfo(obj, data, bg_show)
	local transform = obj.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local user = data.user or {}
    local rank = data.rank or 0
    local name = user.name
    local top_three_flag = rank > 0 and rank < 4
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", top_three_flag)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", not top_three_flag)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg_img", bg_show)
    local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[rank]
    if top_three_item then
        LuaBehaviourUtil.setImg(luaBehaviour,"top_three_rank_img", top_three_item.rank, top_three_item.atlas)
    end
        if rank < 1 then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "new_str_0076")
        else
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", tostring(rank))
        end    
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "level_text", "new_str_0075", user.level or 1)
    if name == nil or name == "" then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(user.uid))
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(name))
    end
    local time = data.time or 0
    if time > 0 then
        local tm = TimeUtil.gmTime(time)
        local time_str = string.format("%d/%02d/%02d", tm.year, tm.month, tm.day)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "time_text", "new_str_0120",time_str)
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "time_text", "")
    end
    local head_node = luaBehaviour:FindGameObject("head_node")
    GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 1})
    local score = data.score or 0
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "layers_text", "new_str_0083", score)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "layers_title_text", "new_str_0113")
end

return M