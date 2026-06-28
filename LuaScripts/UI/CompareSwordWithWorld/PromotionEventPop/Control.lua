local M = class("PromotionEventPopControl",LikeOO.OOControlBase)

function M:onEnter()
	self.m_timer_id = self:setTimer(1, handler(self, self.updateTime))
end

function M:onHandle(msg , data)
	if msg == 99999 then 
		self:closeView()
	elseif msg == "btn_report_onClick" then
		--todo:打开回放界面
		local battle_id = data.battle_id
		self:openView("CompareSwordWithWorld.CompareSwordBattleDetail", {battle_id = battle_id, mode = GlobalConfig.BATTLE_MODE.TEAM_SORT_FULL_SERVICE_PROMOTION})
		
	elseif msg == "player_onClick" then
		local uid = data.uid
		self:openView("Pops.PlayerInfo",{uid = uid})
	end
end

function M:updateTime()
	self.m_view:refreshTimeText()
end

function M:destroy()
	self:removeTimer(self.m_timer_id)
	M.super.destroy(self)
end


return M