---@class AnimEvtAction_Model @动画帧
---@field player PlayerModel
---@field frames Battle_List<AnimEvtFrame_Model>
---@field hitEffectFrames table<string, AnimEvtFrame_Model>
---@field shootEffectFrames table<string, AnimEvtFrame_Model>
local M = class("AnimEvtAction_Model")

--动作名称
M.animName = ""

--技能等级
M.level = 0

--动作时长
M.animLength = 0

--动作中包含的关键帧
M.frames = nil

--优化遍历
M.frameIndex = 1

M.plusSkillNameExtra = {
	skill0_plus = "skill0_plus",
	skill1_plus = "skill1_plus",
	skill2_plus = "skill2_plus",
	skill3_plus = "skill3_plus",
	skill0_plus_1 = "skill0_plus",
	skill1_plus_1 = "skill1_plus",
	skill2_plus_1 = "skill2_plus",
	skill3_plus_1 = "skill3_plus",
	skill3_plus_loop = "skill3_plus",
}
--所有帧重新开始
function M:start()
	self.frameIndex = 1
	for i=1,self.frames.Count do
		self.frames:get(i-1):start()
	end
end

--解析加载，绑定关键帧
---@param player PlayerModel
function M:load( data, player )
	if self.frames == nil then
		self.frames = Battle.List.new()
	end
	if self.shootEffectFrames == nil then
		self.shootEffectFrames = { }
	end
	if self.hitEffectFrames == nil then
		self.hitEffectFrames = { }
	end
	self.player = player
	self.animName = data["animName"]
	self.animLength = data["animLength"]
	self.isLoop = data["isLoop"]

	local frame = require("Battle.SM.AnimEvt.AnimEvtFrame_Model")
	self.level = 1
	local realSkillName = ""
	if self.plusSkillNameExtra[self.animName] then
		realSkillName = self.plusSkillNameExtra[self.animName]
	else
		local names = string.split(self.animName, "_")
		realSkillName = names[1]
	end
	
	local skillItem = player:getPlayer(false).plySkill:getSkillByName(realSkillName)
	if skillItem ~= nil then
		self.level = skillItem.cur_skill_config.level
	end
	for i = self.level, 1, -1 do
		if data["events"]["level"..i] ~= nil then
			local hitStart = nil
			local hitFinish = nil
			local forceSelect = false
			for k,v in ipairs(data["events"]["level"..i]) do
				local frameIns = frame.new()
				frameIns:load(v, player, self)
				if v.eventId ~= nil then
					frameIns.eventId = GlobalTools:ToFloat(v.eventId)
				else
					frameIns.eventId = k
				end
				frameIns.eventKey = v.eventKey
				if v["eventName"] == "Hit" or v["eventName"] == "Shoot" then
					forceSelect = forceSelect or frameIns:checkForceSelect()
					if hitStart == nil then
						hitStart = frameIns
					end
					hitFinish = frameIns
				end
				if v["eventName"] == "ShootEffect" then
					--射击显示特效
					local effectid = v["effectId"]
					self.shootEffectFrames[effectid] = frameIns
				elseif v["eventName"] == "HitEffect" then
					--攻击显示特效
					local effectid = v["effectId"]
					self.hitEffectFrames[effectid] = frameIns
				else
					self.frames:add(frameIns)
				end
			end
			if forceSelect then
				for i = 1, self.frames.Count do
					self.frames:get(i - 1).forceSelect = true
				end
			else
				if hitStart ~= nil and hitFinish ~= nil then
					hitStart.hitStart = true
					hitFinish.hitFinish = true
				end
			end
			break
		end
	end
	self.frames:sort(function(data1,data2)
		return data1.triggerTime > data2.triggerTime
	end)
end


--更新当前动作
function M:update(time)
	for i=self.frameIndex,self.frames.Count do
		local work = self.frames:get(i-1):update(time)
		if work then
			self.frameIndex = i + 1
		else
			break
		end
	end
end

--更新当前动作
function M:update_frame(frame)
	for i=1,self.frames.Count do
		self.frames:get(i-1):update_frame(frame)	 
	end
end

-- 新导出技能脚本请示用getFrameByKey
--通过 eventId 获取帧
---@return AnimEvtFrame_Model
function M:getFrameByIndex(eventName, index)
	for i=1,self.frames.Count do
		local frame = self.frames:get(i - 1)
		if frame.eventId == index and frame.data.eventName == eventName then
			return frame
		end
	end
	return nil
end

--通过 eventKey 获取帧
---@return AnimEvtFrame_Model
function M:getFrameByKey(eventName, key)
	for i=1,self.frames.Count do
		local frame = self.frames:get(i - 1)
		if frame.eventKey == key and frame.data.eventName == eventName then
			return frame
		end
	end
	return nil
end

function M:getHitEffectData(effectId)
	local data = self.hitEffectFrames[effectId]
	if self.animName == "common" then
		data = self.player.evtMgr.common_event["ms"].hitEffectFrames[effectId]
	end
	return data
end

function M:getShootEffectData(effectId)
	local data = self.shootEffectFrames[effectId]
	if self.animName == "common" then
		if self.player.evtMgr then
			data = self.player.evtMgr.common_event["ms"].shootEffectFrames[effectId]
		end
	end
	return data
end

return M