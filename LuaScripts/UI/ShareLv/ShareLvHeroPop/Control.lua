local M = class("ShareLvHeroPopControl",LikeOO.OOControlBase)

function M:onEnter()
    self:refreshData()
end

function M:onHandle(msg , data)
    if msg == 99999 then
        self:updateMsg("refresh_ui", nil, "ShareLv") 
        self:closeView()
    elseif msg == "back_btn" then
        self:updateMsg("refresh_ui", nil, "ShareLv") 
        self:closeView()
    elseif msg == "add_hero" then
    	local function callback(params)
    		self:requestAddHero(params)
    	end
    	self:openView("ShareLv.ShareLvSelectPop", {slot_id = data, level_top = self.m_model.m_data.level_top,callback = callback})
	elseif msg == "remove_hero" then
		local function callback(params)
    		self:requestRemoveHero(data)
    	end
    	self:openView("ShareLv.ShareLvRemoveHeroPop", {data = data, callback = callback})
	elseif msg == "remove_time" then
		local user_data = UserDataManager.user_data
        local diamond = user_data:getUserStatusDataByKey("diamond")
        local reset_cost = self.m_model:getClearTimeCost(data)
        local params =
        {
            on_ok_call = function(msg)
                self:requestRemoveTime(data)
            end,
            cost = {RewardUtil.REWARD_TYPE_KEYS.DIAMOND,0,diamond},
            text = string.format(Language:getTextByKey("shareLv_str_0007"), reset_cost)
        }
        static_rootControl:openView("Pops.CommonPop", params)
	elseif msg == "open_slot" then
		local count = #self.m_model.m_data.crystal_slot
        local reset_cost = GameUtil:getRefreshCost(count, 8)
        local params =
        {
            on_ok_call = function(msg)
                self:requestOpenSlot(2)
            end,
            cost = reset_cost,
            text = string.format(Language:getTextByKey("shareLv_str_0008"), reset_cost[3])
        }
        static_rootControl:openView("Pops.CommonPop", params)
    elseif msg == "open_btn" then
    	local count = #self.m_model.m_data.crystal_slot
        local reset_cost = GameUtil:getRefreshCost(count, 7)
        local params =
        {
            on_ok_call = function(msg)
                self:requestOpenSlot(1)
            end,
            cost = reset_cost,
            text = string.format(Language:getTextByKey("shareLv_str_0009"), reset_cost[3])
        }
        static_rootControl:openView("Pops.CommonPop", params)
    elseif msg == "fresh_data" then
        self:refreshData()
    end
end

function M:requestAddHero(params)
    local flag, name = self.m_model:isHaveSameHero(params.hero_oid)
	local function addCallback(response)
        -- self:openView("ShareLv", {oid = params.hero_oid})
        self.m_model:setSoltData(response)
        self.m_view:refreshUI()
    end
    
    if flag then
        local params =
        {
            on_ok_call = function(msg)
                self.m_model:getNetData("hero_crystal_add", params, addCallback)
            end,
            text = string.format(Language:getTextByKey("shareLv_str_0012"), Language:getTextByKey(name))
        }
        static_rootControl:openView("Pops.CommonPop", params)
    else
        self.m_model:getNetData("hero_crystal_add", params, addCallback)
    end
end

function M:requestRemoveHero(data)
	local function removeCallback(response)
        self.m_model:setSoltData(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.pos = data[1]
    self.m_model:getNetData("hero_crystal_remove", params, removeCallback)
end

function M:requestRemoveTime(data)
	local function removeCallback(response)
        self.m_model:setSoltData(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.pos = data
    self.m_model:getNetData("hero_crystal_clear", params, removeCallback)
end

function M:requestOpenSlot(unlock_type)
	local function openCallback(response)
        self.m_model:setSoltData(response)
        self.m_view:refreshUI()
    end
    local params = {}
    params.unlock_type = unlock_type
    self.m_model:getNetData("hero_crystal_open_slot", params, openCallback)
end

function M:refreshData()
    local function netCallback(response)
        self.m_model:setData(response)
        self.m_view:refreshUI()
    end

    self.m_model:getNetData("hero_crystal_index", nil, netCallback)
end

return M;
