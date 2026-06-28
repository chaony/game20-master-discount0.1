local M = class("UnionBossLogView",LikeOO.OOPopBase)

M.m_uiName = "UnionBoss/UnionBossLog"
M.m_size_type = 2
M.m_iphoneXAdapter = true
function M:onEnter()
	self:setTextByLanKey("common_title_text", "world_boss_str_0005")
	self:setTextByLanKey("no_text", "world_boss_str_0007")
	self.no_panel = self:findGameObject("no_panel")
	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getShowData()
	self.no_panel:SetActive(#data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg(click_name, {id = index , cell_data = cell_data})
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
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    local user = UserDataManager.user_data.user_status
    local name = user.name
    if name == nil or name == "" then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", "new_str_0141")
    else
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(name))
	end

    local head_node = luaBehaviour:FindGameObject("head_node")
	GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 1})

	local score_text = luaBehaviour:FindText("score_text")
	score_text.text = string.format(Language:getTextByKey("world_boss_str_0010"), cell_data[1])
end
return M