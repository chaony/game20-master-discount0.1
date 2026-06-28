local M = class("Pro_PopView",LikeOO.OOPopBase)

M.m_uiName = "Pops/Pro_Pop"
M.m_size_type = 2

function M:onEnter()
    --标题
    if self.m_model.m_title_text then
        self:setTextByLanKey("title_text", self.m_model.m_title_text )
    else
        self:setTextByLanKey("title_text", "pro_pop_title_text" )
    end
    --描述
    if self.m_model.m_des_text then
        self:setObjectVisible("des_text", true)
        self:setTextByLanKey("des_text", self.m_model.m_des_text )
    else
        self:setObjectVisible("des_text", false)
    end
	self:refreshUI()
end

function M:refreshUI()
	self:updateListScroll()
end

function M:updateListScroll()
    local data = self.m_model.m_attrs
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            one_line_count = 1,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:setCellHander(cell_object, index, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:cellBtnHandle(click_name, index)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
        self.m_list_scroll.m_scroll_rect.onValueChanged:AddListener(handler(self, self.onValueChanged))
    else
        self.m_list_scroll:reloadData(data)
    end
    --调整背景高度
    local bg_img = self:findImage("bg")
    UIUtil:setLocalDelta(bg_img.transform, 320, #data >= 6 and 500 or 360)
end

function M:onValueChanged(pos)
    self:updateJianTou()
end

function M:setCellHander(obj, id, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_bg_img", id % 2 == 0)

    end
    local cfg_id = data[3]
    local name = GameUtil:getAttrsName(data[1],cfg_id)
    UIUtil.setTextByLanKey(obj.transform, "name_text", name)
    local num = data[2]
    num = math.floor(num + 0.5)
    if GameUtil:attrTransition(data[1]) == true then
        UIUtil.setText(obj.transform, GameUtil:formatValueToString(num).."%", "num_text")
    else
        UIUtil.setText(obj.transform, GameUtil:formatValueToString(num), "num_text")
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