local M = class("ArtifactPopControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.m_callback then
			self.m_model.m_callback()	
		end
        self:closeView()
    elseif msg == "CloseBtn" then
        self:updateMsg(99999)
    elseif msg == "get_off_btn" then
        self:getOff()
    elseif msg == "intensify_btn" then
        self:openView("HeroInfo.ArtifactLevelUp", {art_id = self.m_model.m_artid, hero_id = self.m_model.m_heroid})
        self:closeView()
    elseif msg == "replace_btn" then
        self:openView("HeroInfo.ArtifactList", { heroid = self.m_model.m_heroid})
        self:closeView()
    end
end

function M:getOff()
    local function callfunc()
        self:updateMsg("update_equip", nil, "HeroBag")
        self:updateMsg(99999)
    end
    self.m_model:getNetData("artifact_down",{ hero_oid = self.m_model.m_heroid}, callfunc)	
end

return M
