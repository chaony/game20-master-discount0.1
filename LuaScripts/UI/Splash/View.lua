local M = class("SplashView",LikeOO.OOPopBase)

M.m_uiName = "Splash/Splash"

function M:onEnter()
	
end

function M:healthNotice()
    self:setObjectVisible("byte_bg_img",false)
    self:setObjectVisible("health_img", true)
    self:runAnim("SplashPop", function()
        self:updateMsg(99999)
    end)
end

function M:byteNotice()
    self:setObjectVisible("byte_bg_img",true)
end

function M:destroy()
    M.super.destroy(self)
end

return M