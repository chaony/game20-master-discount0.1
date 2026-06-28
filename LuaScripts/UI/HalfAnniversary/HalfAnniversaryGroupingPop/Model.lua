---@class HalfAnniversaryGroupingPopModel: OODataBase
local M = class("HalfAnniversaryGroupingPopModel", LikeOO.OODataBase)


function M:onCreate()
    M.super.onCreate(self)
    self:getData()
end

function M:onEnter()
    self:initData()

end

function M:initData()
    self.m_curDayGiftList = self.m_params.curDayGiftList
    self.m_version = self.m_params.version
end

function M:getCurDayGiftList()
    return self.m_curDayGiftList
end

function M:getVersion()
    return self.m_version
end


return M