local M = class("BattleTalkPopModel", LikeOO.OODataBase)

function M:onCreate()
	M.super.onCreate(self)
	--self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.talk_stack = LikeOO.OOStack.new()
	self.callBack = self.m_params.callBack
	if self.m_params.isRepeat == true then
		self.repeat_talk = self.m_params.cfg
		--self.cur_repeat_id = self.repeat_talk.start
	else
		self:addTalk(self.m_params.cfg)
	end
end

function M:addTalk(cfg)
	--if self.cur_talk_cfg == nil then
	--	self.cur_talk_cfg = cfg
	--	self.cur_talk_id = cfg.start
	--else
		self.talk_stack:addData(cfg)
	--end
end

function M:getNextId()
	if self.cur_talk_cfg == nil and self.talk_stack:hasData() ~= true then
		return self:getRepeatId()
	else
		if self.cur_talk_cfg == nil then
			self.cur_talk_cfg = self.talk_stack:pop()
			self.cur_talk_id = self.cur_talk_cfg.start
		else
			self.cur_talk_id = self.cur_talk_cfg.index[self.cur_talk_id]
		end
		if self.cur_talk_id == nil then
			LikeOO.BattleTalkControl:lastTalkFinish()
			if self.talk_stack:hasData() then
				self.cur_talk_cfg = self.talk_stack:pop()
				self.cur_talk_id = self.cur_talk_cfg.start
				return self.cur_talk_cfg.groups[self.cur_talk_id]
			else
				return self:getRepeatId()
			end
		else
			return self.cur_talk_cfg.groups[self.cur_talk_id]
		end
	end
end

function M:getRepeatId()
	if self.repeat_talk == nil then
		return nil
	else
		self.cur_repeat_id = self.repeat_talk.index[self.cur_repeat_id] or self.repeat_talk.start
		return self.repeat_talk.groups[self.cur_repeat_id]
	end
end

return M
