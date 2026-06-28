---@class SelectSupportHeroControl:OOControlBase
---@field m_model SelectSupportHeroModel
---@field m_view SelectSupportHeroView
local M = class("SelectSupportHeroControl",LikeOO.OOControlBase)

function M:onHandle(msg , data)
    if msg == 99999 then
        self:closeView()
    elseif msg == "select_hero" then
        self:clickHero(data)
        self.m_view:refreshUI()
    elseif msg == "help_btn" then
        self:openHelpPop()
    elseif  msg == "confirm_btn" then
        if self.m_model.m_selected_support_oid~=self.m_model.m_cur_support_oid then
            self:updateMsg("update_hero",{selected_oid=self.m_model.m_selected_support_oid },"HeroBag.AdditionSupportSystem")
        end
        self:closeView()
        --撤销
    elseif  msg == "revocate_btn" then
        self.m_model:setSupportOid(nil)
        if self.m_model.m_selected_support_oid~=self.m_model.m_cur_support_oid then
            self:updateMsg("update_hero",{selected_oid=self.m_model.m_selected_support_oid },"HeroBag.AdditionSupportSystem")
        end
        self:closeView()
    end
end


--点击某个英雄
function M:clickHero(hero_oid)
    if self.m_model.m_selected_support_oid~=nil and self.m_model.m_selected_support_oid==hero_oid then
        self.m_model:setSupportOid(nil)
    else
        self.m_model:setSupportOid(hero_oid)
    end
end

function M:openHelpPop()
    local params = {
        title = Language:getTextByKey("tid#wish1"),
        content = Language:getTextByKey("tid#wish2"),
    }
    self:openView("Pops.CommonFiveLineHelpPop", params)
end


function M:destroy()
    M.super.destroy(self)
end

return M;
