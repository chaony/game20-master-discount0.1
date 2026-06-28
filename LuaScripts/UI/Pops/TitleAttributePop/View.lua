local M = class("Pro_PopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/TitleAttributePop"
M.m_size_type = 2

function M:onEnter()
	self:refreshUI()
    self:setTextByLanKey("title_text", "titleAtr_text_0001")
end

function M:refreshUI()
	self:updateListScroll()
end

function M:updateListScroll()
    local data = self.m_model.m_attrsList
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                self:setCellHander(cell_object, cell_data, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
        self.m_list_scroll.m_scroll_rect.onValueChanged:AddListener(handler(self, self.onValueChanged))
    else
        self.m_list_scroll:reloadData(data)
    end
end

function M:onValueChanged(pos)
    self:updateJianTou()
end

function M:setCellHander(obj, data, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", data[1])
        if type(data[2]) == "number" then
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num_text", GameUtil:formatValueToString(data[2]))
        else
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "num_text", data[2])
        end
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_bg_img", index % 2 ~= 0)
    end
end

function M:updateJianTou()
    if self.m_list_scroll and self.m_list_scroll.m_line_count > 3 then
        if self.m_list_scroll:getVerticalNormalizedPosition() < 0.1 then
            self:setObjectVisible("jiantou_img", false)
        else
            self:setObjectVisible("jiantou_img", true)
        end
    else
        self:setObjectVisible("jiantou_img", false)      
    end
end

return M