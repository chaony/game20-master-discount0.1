local M = class("EquipmentListControl",LikeOO.OOControlBase)

function M:onEnter()
    self.m_guide_file_name = "UI.HeroInfo.ArtifactList.Guide"
end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        if self.m_model.m_callback then
			self.m_model.m_callback()	
		end
        self:closeView()
    elseif msg == "check_btn" then 
    	self:putOnEqp(data)
    elseif msg == "replace_btn" then 
        self:putOnEqp(data)
    elseif msg == "hint_btn" then
        GameUtil:lookArtInfoTips(self, data)
    end
end

--穿上神器
function M:putOnEqp(data)
    local function callfunc(c_data)
        self:updateMsg("update_equip", nil, "HeroBag")
        self:updateMsg("check_guide", nil, "HeroBag")
        self:updateMsg(99999)
    end
    if self.m_model:checkIsHeros(data) == true then --神器是否在其他英雄身上
        self.m_model:getNetData("artifact_wear",{ hero_oid = self.m_model.m_heroid, artifact_owner = data }, callfunc)	
    else
        self.m_model:getNetData("artifact_wear",{ hero_oid = self.m_model.m_heroid, artifact_oid = tonumber(data.oid) }, callfunc)	
    end
   
end

return M
