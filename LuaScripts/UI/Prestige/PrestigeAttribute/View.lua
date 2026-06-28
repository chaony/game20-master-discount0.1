---@class PrestigeAttributeView : OOPopBase
local M = class("PrestigeAttributeView", LikeOO.OOPopBase)

M.m_uiName = "Pops/PrestigeAttributePop"
M.m_size_type = 2

function M:onEnter()
    self:setTextByLanKey("title_text", "pro_pop_title_text" )
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
end

function M:onValueChanged(pos)
    self:updateJianTou()
end

function M:setCellHander(obj, id, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "cell_bg_img", id % 2 == 0)
    end
    local cfg_id = data[1]
    local hero_enumeration = ConfigManager:getCfgByName("hero_enumeration")
    local name = "'"
    for k,v in pairs(hero_enumeration) do
        if cfg_id == k then
            local name_cfg = v.name1 == "" and v.name or v.name1
            name = Language:getTextByKey(name_cfg)
        end
    end
    UIUtil.setTextByLanKey(obj.transform, "name_text", name)
    local num = data[2]
    local attrData = hero_enumeration[data[1]]
    local is_percent_flag = attrData.is_percent and attrData.is_percent == 1
    if is_percent_flag then
        num = math.floor(num *100 + 0.5)
        UIUtil.setText(obj.transform, GameUtil:formatValueToString(num).."%", "num_text")
    else
        num = math.floor(num + 0.5)
        local final_name = GameUtil:formatValueToString(num)
        if attrData.user_key == "critrate" then
            final_name = final_name .. "%"
        end
        UIUtil.setText(obj.transform,final_name, "num_text")
       
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