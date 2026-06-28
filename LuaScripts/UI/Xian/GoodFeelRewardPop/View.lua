local M = class("GoodFeelRewardPopView", LikeOO.OOPopBase)

M.m_uiName = "Xian/GoodFeelRewardPop"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:create()
    M.super.create(self)
end

function M:onEnter()
    if self.m_model.m_vip >= 10 then
        self:setObjectVisible("goodfell_level_img", false)
        self:setObjectVisible("goodfell_level_img_1", true)
        self:setObjectVisible("goodfell_level_img_2", true)
        local tens = math.floor(self.m_model.m_vip/10) 
        local unit = self.m_model.m_vip - (tens*10)
        self:setImg(tens, "active_ui", "goodfell_level_img_1")
        self:setImg(unit, "active_ui", "goodfell_level_img_2")
    else
        self:setObjectVisible("goodfell_level_img", true)
        self:setObjectVisible("goodfell_level_img_1", false)
        self:setObjectVisible("goodfell_level_img_2", false)
        self:setImg(self.m_model.m_vip, "active_ui", "goodfell_level_img")    
    end
    self:createLoopScroll()
    self:setTextByLanKey("tips_text", "xian_str_0007", self.m_model.m_vip)
    self:setTextByLanKey("tips_text1", "goodfeel_reward_tips")
    self:setTextByLanKey("title_text", "xian_str_0023")
end

function M:createLoopScroll()
    local data = self.m_model:getFuliList()
    if self.m_scroll_view == nil then
        local loopscroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = loopscroll,
            update_cell = function(index, cell_obj, cell_data)
                self:updateCellItem(cell_obj, cell_data)
            end
        }
        self.m_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_scroll_view:reloadData(data)
    end
end

function M:updateCellItem(obj, cell_data)
    local LuaBehaviour = UIUtil.findLuaBehaviour(obj)
    if LuaBehaviour then
        local show_text = ""
        local show_new = self.m_model:checkIsNew(cell_data.sort)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "new_img", show_new == true)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "cell_new_text", true)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "dian_img", show_new == false)
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "cell_text", false)
        if show_new == true then
            if cell_data.data[2] then
                show_text = Language:getTextByKey(cell_data.data[1]) .. " " .. cell_data.data[2]
            else
                show_text = Language:getTextByKey(cell_data.data[1])
            end
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_new_text", show_text)
        else
            if cell_data.data[2] then
                show_text = Language:getTextByKey(cell_data.data[1]) .. " <color=#D97538>" .. cell_data.data[2] .. "</color>"
            else
                show_text = Language:getTextByKey(cell_data.data[1])
            end
            LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_new_text", show_text)
        end
    end
end

return M