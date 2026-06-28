local M = class("MysticGroupDetailsPopView",LikeOO.OOPopBase)

M.m_uiName = "Mystic/MysticGroupDetailsPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("title_text", "mystic_str_0010")
	self:refreshUI()	
end

function M:refreshUI()
	local one_cfg = self.m_model.m_group_cfg
	self:setTextByLanKey("tips_text", one_cfg.name)
	self:setText("number_text", string.format(Language:getTextByKey("mystic_str_0011"), #one_cfg.mystic_id))
	self:updateScroll()
end

function M:updateScroll()
    local data = self.m_model.m_group_cfg.mystic_id
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:setCellHander(cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)

            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data,true)
    end
end

function M:setCellHander(obj, id)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local mystic_cfg = ConfigManager:getCfgByName("mystic")
    local one_cfg = mystic_cfg[id][self.m_model.m_lv]
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", one_cfg.name)
end

return M