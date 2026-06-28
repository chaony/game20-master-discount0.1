local M = class("PlayerBackToNewView",LikeOO.OOPopBase)

M.m_uiName = "PlayerBack/PlayerBackToNew"
M.m_size_type = 2

function M:create()
    M.super.create(self)
end

function M:onEnter()
    self:refreshUI()
end

function M:refreshUI()
    self:updateLoopScroll()
end

function M:updateLoopScroll()
    local data = self.m_model:getListData()
    if self.bk_list_scroll == nil then
		local list_scroll = self:findGameObject("loopscroll")
		local params = {
			ui_name = self.m_uiName,
            show_data = data,
			loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:updateLoopScrollCell(index, cell_object, cell_data)
			end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("go_btn", cell_data)
			end
		}
		self.bk_list_scroll = LoopScrollViewUtil.new(params)
	else
		self.bk_list_scroll:reloadData(data, true)
	end
end

function M:updateLoopScrollCell(index, cell_object, cell_data)
    local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
    local server_name = cell_data.server_name
    if server_name == nil or server_name == "" then
        server_name = cell_data.server
    end
    LuaBehaviourUtil.setText(luaBehaviour, "server_name_text", server_name)
    if cell_data.open_time then
        --开服时间超过三天
        if UserDataManager:getServerTime() - cell_data.open_time > 60 * 60 * 24 * self.m_model:getDayLimit() and index ~= 1 then --最新的默认可选
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "plus_btn", false)
            LuaBehaviourUtil.setImg(luaBehaviour,"status_flag_img", "a_xdzf_pw_area_red", "active_ui")
            LuaBehaviourUtil.setTextColor(luaBehaviour, "player_count_text", GlobalConfig.COMMON_COLLOR.COMMON_23)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "player_count_text", "new_str_1068")
        --开服时间少于三天
        else
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "plus_btn", true)
            LuaBehaviourUtil.setImg(luaBehaviour,"status_flag_img", "a_xdzf_pw_area_green", "active_ui")
            LuaBehaviourUtil.setTextColor(luaBehaviour, "player_count_text", GlobalConfig.COMMON_COLLOR.COMMON_14)
            LuaBehaviourUtil.setText(luaBehaviour, "player_count_text", "剩余<color=#1da070>" .. math.random(80, 200) .. "</color>个名额")
        end
    end
end

return M