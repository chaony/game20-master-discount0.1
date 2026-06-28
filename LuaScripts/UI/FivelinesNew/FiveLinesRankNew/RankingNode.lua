--- 排名
local M = class("RankingNodeNew",LikeOO.OOUIbase)

M.m_uiName = "FivelinesNew/RankingNodeNew"

--M.m_iphoneXAdapter = true
function M:onEnter()
	local function callFunc(data)
        self:refreshUI()
    end
    self.m_model:initData(callFunc)
end

function M:refreshUI()
	self:updateLoopScroll()
	local cur_data = self:findGameObject("self_data")
	local owner_data = self.m_model:getOwnRankData()
	self:updateItemInfo(cur_data, owner_data, owner_data.rank)
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getRankData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("list_scroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "race_img" then
                    self:updateMsg("score_look",{click_transform = click_object.transform, msg = Language:getTextByKey("new_str_0074"), top = true})
                else
                    self:updateMsg("item_click", {id = index})
                end
			end,
            ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    self:updateItemInfo(cell_object, data, index)
end

function M:updateItemInfo(obj, data, id)
    local user = data.user or {}
    local rank = data.rank or 0
    local transform = obj.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    if id then
        local top_three_flag = id < 4
		UIUtil.setObjectVisible(transform, not top_three_flag, "rank_text")
		UIUtil.setObjectVisible(transform, top_three_flag, "tank_img")
        local top_three_item = GlobalConfig.RANK_TOP_THREE_IMG[id]
        if top_three_item then
            LuaBehaviourUtil.setImg(luaBehaviour,"tank_img", top_three_item.rank, top_three_item.atlas)
        end
		UIUtil.setText(transform, tostring(rank), "rank_text")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "floor_text", "层数: "..data.score)
		local tm = TimeUtil.gmTime(data.time)
		local time_str = string.format("%d/%02d/%02d %02d:%02d:%02d", tm.year, tm.month, tm.day, tm.hour, tm.min, tm.sec)
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "time_text", "通关时间: "..time_str)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "time_text", data.time ~= 0)
		local headNode = luaBehaviour:FindGameObject("HeadNode")
		if headNode then
			GameUtil:setUserAvatar(headNode, user, nil, nil, {show_flag = true, scale = 1})
		end
    end
    if user.name == nil or user.name == "" then
        UIUtil.setText(transform, tostring(user.uid), "name_text")
    else
        UIUtil.setText(transform, tostring(user.name), "name_text")
    end
    UIUtil.setTextByLanKey(transform, "level_text", "new_str_0075", user.level or 1)
    local gender = user.gender or 0
    UIUtil.setObjectVisible(transform, gender > 0, "gender_img")
    local head_node = luaBehaviour:FindGameObject("head_node")
    GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 1})
end

return M