local M = class("ShareLvHeroPopView",LikeOO.OOPopBase)

M.m_uiName = "ShareLv/ShareLvHeroPop"
M.m_size_type = 2

function M:onEnter()
	self:setTextByLanKey("common_title_text", "shareLv_str_0018")
	self.m_down_time = {}
	self.open_btn = self:findGameObject("open_btn")
	self:refreshUI()
	self:initDownTime()
end

function M:refreshUI()
	self:updateListScroll()
	local user_data = UserDataManager.user_data
	local crystal = user_data:getUserStatusDataByKey("crystal")
	self:setText("crystal_text", crystal)
	local diamond = user_data:getUserStatusDataByKey("diamond")
	self:setText("diamond_text", diamond)
	local num = 0
	for i,v in ipairs(self.m_model.m_data.crystal_slot) do
		if v.hid and v.hid ~= "" then
			num = num + 1
		end
	end
	self:setText("num_text", tostring(num) .. "/" .. #self.m_model.m_data.crystal_slot)
	self.open_btn:SetActive(#self.m_model.m_data.crystal_slot < self.m_model.m_data.max_slot_num)
end

function M:updateListScroll()
    local data = self.m_model.m_list
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("hero_scroll")
        local params = {
        	ui_name = self.m_uiName,
            show_data = data,
            one_line_count = 7,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
                local transform = cell_object.transform
                local data = cell_data
                self:listHandle(cell_object, index)
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                -- self:cellBtnHandle(click_name, index)
            end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data)
    end
end

function M:listHandle(obj, id)
	UIUtil.setScale(obj.transform,0.9)
	local luaBehaviour = obj:GetComponent("LuaBehaviour")
	local down_time_text = luaBehaviour:FindText("down_time_text")
	down_time_text.gameObject:SetActive(false)
	self.m_down_time[down_time_text] = nil
	local data = self.m_model:getSoltDataByIndex(id)
	local red_point_img = luaBehaviour:FindGameObject("red_point_img")--红点
	red_point_img:SetActive(false)
	if data then
		if data.hid and data.hid ~= "" then
			local oid = data.hid
			local data, cfg = UserDataManager.hero_data:getHeroDataById(oid)
	        local function clickCall()
	            self:updateMsg("remove_hero", {id, oid})
	        end 
	        if cfg then
	        	GameUtil:updateItemElement(obj, {RewardUtil.REWARD_TYPE_KEYS.HEROS,cfg.id,1,oid}, false, false, clickCall)
	        end
			local luaBehaviour = obj:GetComponent("LuaBehaviour")
			local tips_img = luaBehaviour:FindGameObject("tips_img")
			tips_img:SetActive(false)
			-- local lv_text = luaBehaviour:FindGameObject("lv_text")
			-- lv_text:SetActive(true)
			-- lv_text:GetComponent("Text").text = "Lv" .. data.lv
		else
			local down_time = data.etime - UserDataManager:getServerTime()
			if down_time > 0 then
				local function callback(obj, data)
					self:updateMsg("remove_time", data)
				end
				GameUtil:updateItemElementNoData(obj, RewardUtil.REWARD_TYPE_KEYS.HEROS, id, callback)
				local luaBehaviour = obj:GetComponent("LuaBehaviour")
				local tips_img = luaBehaviour:FindGameObject("tips_img")
				tips_img:SetActive(true)
				local add_img = luaBehaviour:FindGameObject("add_img")
				add_img:SetActive(false)
				local tips_text = luaBehaviour:FindText("tips_text")
				tips_text.text = Language:getTextByKey("shareLv_str_0011")
				local down_time_text = luaBehaviour:FindText("down_time_text")
				down_time_text.gameObject:SetActive(true)
				self.m_down_time[down_time_text] = id
			else
				local function callback(obj, data)
					self:updateMsg("add_hero", data)
				end
				GameUtil:updateItemElementNoData(obj, RewardUtil.REWARD_TYPE_KEYS.HEROS, id, callback)
				local luaBehaviour = obj:GetComponent("LuaBehaviour")
				local tips_img = luaBehaviour:FindGameObject("tips_img")
				tips_img:SetActive(false)
				local add_img = luaBehaviour:FindGameObject("add_img")
				add_img:SetActive(true)
				red_point_img:SetActive(true)
			end
			
		end
	else
		if id == #self.m_model.m_data.crystal_slot + 1 then
			local function callback(obj, data)
				self:updateMsg("open_slot", data)
			end
			GameUtil:updateItemElementNoData(obj, RewardUtil.REWARD_TYPE_KEYS.HEROS, id, callback)
			local luaBehaviour = obj:GetComponent("LuaBehaviour")
			local lock_image = luaBehaviour:FindGameObject("lock_image")
			UIUtil.findImage(lock_image.transform).enabled = false
			lock_image:SetActive(true)
			local tips_img = luaBehaviour:FindGameObject("tips_img")
			tips_img:SetActive(false)
		else
			local function callback(obj, data)
				GameUtil:lookInfoTips(self.m_control, {msg = Language:getTextByKey("shareLv_str_0001"), delay_close = 2})
			end
			GameUtil:updateItemElementNoData(obj, RewardUtil.REWARD_TYPE_KEYS.HEROS, id, callback)
			local luaBehaviour = obj:GetComponent("LuaBehaviour")
			local lock_image = luaBehaviour:FindGameObject("lock_image")
			UIUtil.findImage(lock_image.transform).enabled = false
			lock_image:SetActive(true)
			local tips_img = luaBehaviour:FindGameObject("tips_img")
			tips_img:SetActive(true)
			local tips_text = luaBehaviour:FindText("tips_text")
			tips_text.text = ""
		end
	end
end

function M:initDownTime()
	local function tick(dt)
		for k,v in pairs(self.m_down_time) do
			local data = self.m_model:getSoltDataByIndex(v)
			local down_time = data.etime - UserDataManager:getServerTime()
			if down_time >= 0 then
				k.text = GameUtil:formatTimeBySecond(down_time)
			else
				self:updateMsg("fresh_data")
			end
		end
	end
	self.m_control:setTimer(1,tick)
	tick()
end

return M