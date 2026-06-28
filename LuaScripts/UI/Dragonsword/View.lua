local M = class("DragonswordView",LikeOO.OOPopBase)


M.m_iphoneXAdapter = true
M.m_uiName = "Dragonsword/Dragonsword"



function M:onEnter()
    self:setTextByLanKey("active_time_text","dragonsword_text_0001")
    if self.m_model.m_data["end"] == 1 then
        self:updateMsg("refresh_main")
    else
        local active_data = self.m_model:getActiveData(self.m_model.m_data.open_id)
        self:setActiveTime(active_data)
        local open_table = self.m_model:getActiveName(self.m_model.m_data.open_id)
        if open_table ~= nil and open_table.name ~= nil then
            self:setTextByLanKey("close_title_text",open_table.name)
        end
        self:refreshUI()
    end
end

--刷新
function M:refreshUI()
	self:refreshRedPoint()
end

--设置活动时间
function M:setActiveTime(active_data)
    local start_month,start_data = self:getTime(active_data.start_time)
    local end_month,end_data = self:getTime(active_data.end_time)
    local time_text = Language:getTextByKey("dragonsword_text_0002",start_month,start_data,end_month,end_data)
    self:setTextByLanKey("time_text",time_text)
end

--转换时间格式
function M:getTime(time_string)
    local time_table = string.split(time_string," ")
    local data_table = string.split(time_table[1],"-")
    return data_table[2],data_table[3]
end

--刷新红点
function M:refreshRedPoint()
    local star_light_red_point = self.m_model:isHasQuestRed() or self.m_model:isHasMilepost()
    local story_red_point = self.m_model:isHasStoryRed() --龙泉异闻是否有红点
    self:setObjectVisible("story_active_red_point",story_red_point)
    self:setObjectVisible("star_light_active_red_point",star_light_red_point)
end

function M:destroy()
    M.super.destroy(self)
end

return M