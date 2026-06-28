local M = class("FulwinArenaDoorModel", LikeOO.OODataBase)

function M:onCreate()
    self.m_transfer = "scale"
    self:getData()
end

function M:onEnter()

end

return M