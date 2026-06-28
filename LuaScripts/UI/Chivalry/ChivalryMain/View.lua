local M = class("ChivalryMainView", LikeOO.OOPopBase)

M.m_uiName = "Chivalry/ChivalryMain"
M.m_iphoneXAdapter = true



function M:onEnter()
    self:setLanuage() --设置本地化文本
    self:refreshRedPoint() --刷新红点
end

--刷新ui
function M:refreshUI()
   
end

--设置本地化文本
function M:setLanuage()
    self.avtive_data = self.m_model:getActiveData()
    self:setTextByLanKey("close_title_text", self.avtive_data.name)
    self.active_tab = self.m_model:getActiveTab()
    for i, v in ipairs(self.active_tab) do
        local btn_name = "btn"..i.."_text"
        self:setTextByLanKey(btn_name,Language:getTextByKey(v.btn_name))
    end
end

--刷新红点
function M:refreshRedPoint()
    local items = self.m_model:getAllActiveTab()
    for k, v in pairs(items) do
        local isShowRedPoint = RedPointUtil:hasRedPointById(v.open_id)
        if v.open_id == 314 and isShowRedPoint == false then
            isShowRedPoint = RedPointUtil:hasRedPointById(396)--诗书绘卷包含抽奖和兑换
        end
        self:setObjectVisible("btn_red_point_img"..v.id, isShowRedPoint)
    end
end

function M:destroy()
    M.super.destroy(self)
end

return M
