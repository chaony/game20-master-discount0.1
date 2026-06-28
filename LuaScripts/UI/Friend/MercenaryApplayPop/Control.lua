local M = class("MercenaryApplayPopControl",LikeOO.OOControlBase)

function M:onEnter()
  
end

function M:onHandle(msg , data)
    if msg == 99999 then 
        self:closeView()
    elseif msg == "back_btn" then
        self:closeView()
    elseif msg == "applay_btn" then
    	local oneData = self.m_model:getDataByIndex(data)
    	if oneData.applied then
    		self:cancelRequest(data)
    	else
    		self:applayRequest(data)
    	end
    elseif msg == "unapplay_btn" then
        self:cancelRequest(data)
    elseif msg == "hero_click" then
    	local player_data = {heros = {[data.hero.oid] = data.hero}}
        player_data.user = data.user
        self:openView("HeroBag", {player_data = player_data, mode = 3, oid = data.hero.oid})
    end
end

function M:applayRequest(index)
	local data = self.m_model:getDataByIndex(index)
	local function applayback(response)
        self.m_model:updateData(index, response)
        self.m_view:refreshUI()
        local num = self.m_model:getApplayNum()
        if num == 1 then
            self:updateMsg("applay_mercenary", {id = response.apostle.hero.id, flag = true}, "Friend")
        end
        GameUtil:lookInfoTips(self, {msg = Language:getTextByKey("friend_str_0035"), delay_close = 2})
    end
    local params = {}
    params.target_uid = data.user.uid
    params.hero_oid = data.hero.oid
    self.m_model:getNetData("apostle_apply", params, applayback)
end

function M:cancelRequest(index)
	local data = self.m_model:getDataByIndex(index)
	local function cancelback(response)
        self.m_model:updateData(index, response)
        self.m_view:refreshUI()
        local num = self.m_model:getApplayNum()
        if num == 0 then
            self:updateMsg("applay_mercenary", {id = response.apostle.hero.id, flag = false}, "Friend")
        end
    end
    
    local params =
        {
            on_ok_call = function(msg)
                local params = {}
                params.target_uid = data.user.uid
                params.hero_oid = data.hero.oid
                self.m_model:getNetData("apostle_cancel_apply", params, cancelback)
            end,
            no_close_btn = false,
            text = Language:getTextByKey("friend_str_0034")
        }
    self:openView("Pops.CommonPop", params)
end

return M;
