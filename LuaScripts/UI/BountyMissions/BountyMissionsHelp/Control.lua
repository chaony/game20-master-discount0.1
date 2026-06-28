--悬赏列表
local M = class("BountyMissionsHelpControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cancle_btn" then
        self:closeView()
    elseif msg == "add_hero" then
        local parms = {
            heros = self.m_model.m_heros,
            callback = handler(self,self.callbackGetId)
        }
        self:openView("BountyMissions.BountyMissionsHelpPop", parms)
    elseif msg == "remove_hero" then
        self:removeMercenary(data)
	end
end

function  M:callbackGetId(index, id)
    local function callfunc()
        self.m_model:resfreshData(handler(self, self.updateView))
        --self.m_view:resfreshUI()
    end
    if id then
        self.m_model:getNetData("mercenary_add",{hero_oid = id}, callfunc)	
    end
end

function  M:removeMercenary(id)
    local function callfunc()
        self.m_model:resfreshData(handler(self, self.updateView))
    end
    if id then
        self.m_model:getNetData("mercenary_del",{hero_oid = id}, callfunc)	
    end
end

function M:updateView()
    self.m_view:resfreshUI()
end


return M;
