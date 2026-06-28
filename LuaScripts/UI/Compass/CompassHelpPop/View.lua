local M = class("CompassHelpPopView",LikeOO.OOPopBase)

M.m_uiName = "Compass/CompassHelpPop"
M.m_size_type = 2

function M:onEnter()
    local str = string.gsub(Language:getTextByKey("tid#roulette4" or "???"), "\\n", "\n")
    self:setText("txt_help",str)
    self:switchTabNode(1)
    self:refreshUI()
    self:setTextByLanKey("tag_name_text_2", "compass_str_006")
    self:setTextByLanKey("tag_name_text_1", "gailv_text")
end

function M:refreshUI()
    self:updateListScroll()
end

function M:switchTabNode(index)
    if index == 1 then
        self:setTextByLanKey("common_title_text", "predestined_str_010")
        self:setObjectVisible("tab_select_1", true)
        self:setObjectVisible("tab_select_2", false)
        self:setObjectVisible("list_scroll", true)
        self:setObjectVisible("txt_help", false)
        self:setObjectVisible("content_bg_img", false)
    else
        self:setTextByLanKey("common_title_text", "compass_str_006")
        self:setObjectVisible("tab_select_1", false)
        self:setObjectVisible("tab_select_2", true)
        self:setObjectVisible("list_scroll", false)
        self:setObjectVisible("txt_help", true)
        self:setObjectVisible("content_bg_img", true)
    end
end

function M:updateListScroll()
    local data = self.m_model.data
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 7,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                self:updateData(cell_object, cell_data)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                self:updateMsg("select_hero", cell_data)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data, true)
    end
end

function M:updateData(obj, data)
    local luaBehaviour = obj:GetComponent("LuaBehaviour")
    local item = luaBehaviour:FindGameObject("ItemNode")
    GameUtil:updateItemElement(item, data.reward, true, true)
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour,"probability_text", data.probability .. "%")
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Reward_LingQu_003", data.reward_grade ~= 5)
end

function M:destroy()
    M.super.destroy(self)
end

return M