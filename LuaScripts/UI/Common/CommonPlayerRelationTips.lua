--- 玩家克制信息
local M = class("CommonPlayerRelationTips",LikeOO.OOUIbase)

M.m_uiName = "Common/CommonPlayerRelationTips"
M.m_iphoneXAdapter = true

function M:onCreate()
end

function M:onEnter()
    self.m_content = self:findGameObject("content")
    self.effect = self:findGameObject("effect_rotation")
    self:refreshUI()    
end

function M:refreshUI()
    if self.m_params then
        if self.m_params.relation == 1 then
            local vec3 = self.effect.transform.rotation.eulerAngles;
            vec3.z = 0;
            self.effect.transform.rotation = Quaternion.Euler(vec3.x, vec3.y, vec3.z)
            self.effect.transform.localPosition = Vector3(0,-0.32,0)
            GameUtil:setLanImgText(self:findRectTransform("relationship"), "a_ui_shilijiaceng_buli")
        else
            local vec3 = self.effect.transform.rotation.eulerAngles;
            vec3.z = 180;
            self.effect.transform.localPosition = Vector3(0,0,0)
            self.effect.transform.rotation = Quaternion.Euler(vec3.x, vec3.y, vec3.z)
            GameUtil:setLanImgText(self:findRectTransform("relationship"), "a_ui_shilijiaceng_youli")
        end
        self:setObjectVisible("content", false)
        self.m_control:setOnceTimer(0.1, function()
            self:TipsHandler(self.m_params.player:get_position())
            self:setObjectVisible("content", true)
        end)
    end
end

function M:TipsHandler(data)
    local pos_3d = UIUtil.ScenePosToUI(data);
    if not IsNull(self.m_content) then
        self.m_content.transform.position = pos_3d 
    end
end

function M:destroy()
    self.m_content = nil
	M.super.destroy(self)
end

return M