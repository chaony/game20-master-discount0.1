local M = class("GifTreasureNode", LikeOO.OOUIbase)
--藏宝图
M.m_uiName = "GiftBag/GifTreasureNode"

function M:onEnter()
    self.cell_obj = nil
	self.tx_obj = nil
    self.show_time = false
	self:showUI(false)
end

function M:switchInit(url, callback)
    local function callFunc(data)
		if callback then
            callback(data)
        end
		if data and data["end"] == 1 then
			return
		end
        self:refreshUI()
    end
    self.m_model:initData2(url, callFunc)
end

function M:switchUI()
    self:refreshUI()
end

function M:refreshUI()
	if self.m_model.m_treasure_data == nil or next(self.m_model.m_treasure_data) == nil then
		return
	end
	self:showUI(true)
	self.end_ts = self.m_model:getActiveEndTime(self.m_model.m_treasure_data.actives)
	self:updateTime()
    for i = 1,18 do
        local card_name = "card_img_"..i
        local card_obj = self:findGameObject(card_name)
        if not IsNull(card_obj) then
            self:updateTreasureItem(card_obj,i)
        end
    end
	self:setSpine()
	self:updateBottomCount()
end

function M:updateTreasureItem(obj, index)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local treasure_cfg = self.m_model:getTreasureQuestCfg(index, self.m_model.m_treasure_data.version)
	local treasure_data= table.copy(self.m_model:getTreasureQuests(index)) 
    if luaBehaviour then
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_text", treasure_cfg.name)
		if treasure_data.value > treasure_cfg.target_value then
			treasure_data.value = treasure_cfg.target_value 
		end
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "title_num", treasure_data.value.."/"..treasure_cfg.target_value)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "card_node", treasure_data.status ~= 2)
		self:setObjectVisible("effect_"..index, treasure_data.status == 1)
		luaBehaviour:RegistButtonClick(function (obj, name)
			if name == "card_node" then
				audio:SendEvtUI("UI_DJGZi")
				if treasure_data.value >= treasure_cfg.target_value then
					self:creatClickOpenEffect(index, function ()
						self:updateMsg("treasure_activate",{id = index, version = self.m_model.m_treasure_data.version })	
					end)
				else
					self.m_control:openView("GiftBag.TreasureQuestPop", {id = index, data = self.m_model.m_treasure_data})
				end
			end
		end)
    end
	obj:SetActive(treasure_data.status ~= 2)
end

function M:updateBottomCount()
	self.cur_score = self.m_model:getTresureNum()
	local slider_node = {}
	for i = 1, 5 do
		local activation_item = self:findGameObject("activation_"..i)
		local activ_cfg = self.m_model:getTreasureRewardCfg(i)
		local received_bl = self.m_model:getTreasureReceived(i)
		local num_text = UIUtil.findText(activation_item.transform, "itemtitle_num")
		local itemNode = UIUtil.findTrans(activation_item.transform, "ItemNode")
		num_text.text = activ_cfg.score
		local function callback(obj, data)
			if received_bl == false and self.cur_score >= activ_cfg.score then
				self:updateMsg("get_receive", {id = i, version = self.m_model.m_treasure_data.version })
			end
		end
		local show_d = true
		if received_bl == false and self.cur_score >= activ_cfg.score then
			show_d = false
		end
		GameUtil:updateItemElement(itemNode.gameObject, activ_cfg.reward[1], true, show_d, callback)
		if i == 5 then
			if self.tx_obj == nil then
				self.tx_obj = GameUtil:creatCommonActiveEffect(itemNode)
			end
		end
		local LuaBehaviour = UIUtil.findLuaBehaviour(activation_item)
		if received_bl == true then
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "mask_get", true)
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "light_img", false)	
		else
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "mask_get", false)
			LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "light_img", self.cur_score >= activ_cfg.score)	
		end
	end
	local slider_obj = self:findSlider("sliders")
	slider_obj.value = self.cur_score/9
end

function M:updateTime()
	if self.end_ts and self.end_ts > 0 then
		local time_show = GameUtil:formatTimeBySecond(self.end_ts - UserDataManager:getServerTime())
		self:setTextByLanKey("time_text", time_show)
	end
end

function M:setSpine()
	local treasure_cfg = self.m_model:getTreasureByVersion(self.m_model.m_treasure_data.version)
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(treasure_cfg.hero)
	if cfg then
		local icon = cfg.hero_spine
		if self.cacheSpineName == icon then
			return
		else
			self.cacheSpineName = icon
		end
		local play_img = self:findGameObject("hero_spine")
		GameUtil:updateSpineLoadSet(play_img, "RoleSpine/"..self.cacheSpineName, "idle", 0, true)
	end
end

--创建点击开启特效
function M:creatClickOpenEffect(index, callback)
	local click_effect_parent = self:findGameObject("click_effect_parent_"..index)
	if IsNull(click_effect_parent) then
		if callback then
			callback()
		end
		return
	end
    local item = ResourceUtil:GetUIEffectItem("GiftBag/UI_GifTreasureNode_JieSuo001", click_effect_parent)
	self.m_control.m_view:lockTouch()
	self.m_control:setOnceTimer(1.5, function ()
		UIUtil.destroyObject(item)
		self.m_control.m_view:unlockTouch()
		if callback then
			callback()
		end
	end)
end

function M:showUI(bl)
    self:setObjectVisible("time_text", bl)
    self:setObjectVisible("reward_parent", bl)
    self:setObjectVisible("sliders", bl)
	self:setObjectVisible("TreasureNode", bl)
	self:setObjectVisible("cbt_bottom_img", bl)
end


function M:destroy()
    M.super.destroy(self)
end

return M
