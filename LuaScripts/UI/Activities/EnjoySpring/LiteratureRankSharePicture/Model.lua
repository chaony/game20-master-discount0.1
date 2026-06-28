local M = class("LiteratureRankSharePictureModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
    self:getData()
end

function M:onEnter()

end


return M
