local M = class("LibrarySelectControl",LikeOO.OOControlBase)

function M:onEnter()

end

function M:onHandle(msg , data)
    if msg == 99999 then    -- 返回
        self:closeView()
    elseif msg == "cancle_btn" then
        self:updateMsg(99999)
    elseif msg == "ok_btn" then
        self:libraryTroopAdd()
    end
end

--  羁绊添加英雄
-- type_id: 1    羁绊组id hero_oid: 8-1587524311-noTZVH  英雄唯一id target_uid: 2097151   所选英雄的拥有者
function M:libraryTroopAdd()
    if self.m_model.m_select_cell_data and not self.m_model.m_select_cell_data.select_flag then
        local function receivetCallback(response)
            if self.m_view then
                self.m_model:initData(response)
                self:updateMsg("refresh_ui", nil, "Library.LibraryDetail")
                self:updateMsg(99999)
                GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0316"), delay_close = 2})
            end
        end
        local params = {type_id = self.m_model.m_type_id, hero_oid = self.m_model.m_select_cell_data.hero_id, target_uid = self.m_model.m_select_cell_data.uid}
        self.m_model:getNetData("library_troop_add", params, receivetCallback)
    else
        self:updateMsg(99999)
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("new_str_0317"), delay_close = 2})
    end
end

return M
