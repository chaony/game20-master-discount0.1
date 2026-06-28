local M = class("FulwinSecondFightLoadModel", LikeOO.OODataBase)

function M:onCreate()
    self:getData()
end

function M:onEnter()

end

return M