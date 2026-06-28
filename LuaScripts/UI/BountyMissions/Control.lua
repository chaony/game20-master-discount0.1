--悬赏列表
local M = class("BountyMissionsControl",LikeOO.OOControlBase)

function M:onEnter()
	self:UpdateTime()
	self:setTimer(1,handler(self,self.UpdateTime))
	self.m_guide_file_name = "UI.BountyMissions.Guide"
end

function M:onHandle(msg , data)
	if msg == 99999 then    -- 返回
		self:updateMsg("refresh_red_point" ,nil ,"parent")
        self:closeView()
	elseif msg == "cancle_btn" then--返回按钮
		self:closeView()
	elseif msg == "reset_btn" then--刷新
		self:refreshTask()
	elseif msg == "offer_lv" then --等级
		self:openView("BountyMissions.BountyMissionsLv", {lv = self.m_model.bounty_lv, single_rank = self.m_model.single_rank , team_rank = self.m_model.team_rank})
	elseif msg == "tiwn_tog" then --单人悬赏
		self.m_model.cur_type = 1
		self.m_view:seleteTag(1)
	elseif msg == "team_tog" then --团队悬赏
		self.m_model.cur_type = 2
		self.m_view:seleteTag(2)
	elseif msg == "hint_btn" then --提示
		local params = {}
		params.title = "bounty_str_0001"
		params.content = "bounty_str_0002"
		params.history = "bounty_str_0003"
		self:openView("Pops.CommonHelpPop", params)
	elseif msg == "open_send" then --派遣
		local params = {
			id = data.id, 
			reward = data.reward,
			self_hero = self.m_model.self_hero,
			master_hero = self.m_model.m_master_info.hero_info or {},
			uid = self.m_model.m_master_info.uid
		}
		self:openView("BountyMissions.BountyMissionsSend", params)
	elseif msg == "get_reward" then --领取
		self:getReward(data)
	elseif msg == "aid_btn" then --我的外援
		self:openView("BountyMissions.BountyMissionsHelp")
	elseif msg =="resresh" then
		self:refreshData(data)
	end
end

function M:UpdateTime()
	self.m_model.dataTime = self.m_model.dataTime - 1
	self.m_view:setResetTim()
end

function M:refreshTask()
	local count = 50
	local params =
	{  
		no_close_btn = false,
		on_ok_call = function(msg)
			self:beRefreshTask()
		end,   
		text = string.format(Language:getTextByKey("new_str_0214"), count)
	}
	self:openView("Pops.CommonPop",params)
end

function M:beRefreshTask()
	local function callback()
		self.m_view:refreshTask()
	end
	self.m_model:getNetData("bounty_refresh", nil, callback)
end

function M:getReward(id)
	local id = id
	local cfg = self.m_model:getBountyBuId(id)
	local type =cfg.type
	self.m_model:getNetData("bounty_receive",{quest_id = id, quest_type = type,}, handler(self, self.netCallback))	
end

function M:netCallback(response)
	if self.m_view then
        RewardUtil:rewardTipsByData(response.reward)
	end
    self:refreshData()
end

function M:refreshData(data)
	local function callbcak()
		self.m_view:refreshTask(data)
	end
	self.m_model:getNetData("bounty_info",nil,callbcak)
end

return M;
