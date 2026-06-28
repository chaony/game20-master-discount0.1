local M = class("ExclusiveSkillPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()

end


--专属技能
function M:getExclusiveSkill()
	return {}
end

--专属技能描述
function M:getExclusiveDesc()
	return ""
end

return M
