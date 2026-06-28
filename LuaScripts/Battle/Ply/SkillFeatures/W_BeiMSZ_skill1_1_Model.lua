--悲魔山庄 镇狱破天劲
--战斗开始时，悲魔山庄会获得50层“破天劲”，每层破天劲会为其增加1%的减伤效果，每当悲魔山庄受到一次普通攻击，破天劲便会减少1层，破天劲最多叠加50层

---@class W_BeiMSZ_skill1_1_Model : SkillFeatures_Model @
---@field super SkillFeatures_Model @SkillFeatures_Model
local M = class("W_BeiMSZ_skill1_1_Model", SkillFeatures_Model)

--初始化
function M:init(ply, skill,className)
    M.super.init(self, ply, skill,className)
	self.buffId = self:getParam(1) -- Buff[] 效果buff
	self.initStack = self:getParam(2) -- Fix[1-100] 初始层数
	self.maxStack = self:getParam(3) -- Fix[1-100] 最大层数
	self.resatdValue = self:getParam(4) -- Fix[1-100] 每层提供免伤
	self.removeStack = self:getParam(5) -- Fix[1-100] 受普攻后，减少层数
	self.addStack = self:getParam(6) -- Fix[1-100] 打出普攻后，增加层数

	self.curPtStack = self.initStack --当前破天劲层数
	self.isAddBuf = false
	self.avoidReduce = false  -- 阻止降低层数
	self.lastResatdValue = 0	  -- 当前免伤数

	EventDispatcher:registerEvent("injure", {self, self.injureHandle})
	EventDispatcher:registerEvent("SkillEnd", {self,self.skillEndHandler})
end

function M:spawnFinish()
	self:checkPtBuff()
	M.super.spawnFinish(self)
end

---@param data Battle_HandleData_Injure
function M:injureHandle(eventName, data)
	if self.player:equal(data.victim) then
		if data.attackData.skillConfig and data.attackData.skillConfig.anim_name == "attack1" then
			self:reducePtStack(1)
		end
	end
end

---@param data Battle_HandleData_SkillEnd
function M:skillEndHandler(eventName, data)
	if self.player:equal(data.player) and data.skillConfig and data.skillConfig.anim_name == "attack1" then
		self:improvePtStack(self.addStack)
	end
end

--- 减少破天劲层数
function M:reducePtStack(stack)
	if self.avoidReduce then		-- 有此标记，不会减少破天劲层数（skill3会修改此标记）
		return
	end

	if self.curPtStack > 0 then
		self.curPtStack = self.curPtStack - stack
		self:checkPtBuff()
	end
end

--- 提升破天劲层数
function M:improvePtStack(stack)
	if self.curPtStack < self.maxStack then
		self.curPtStack = Mathf.Min(self.curPtStack + stack, self.maxStack)
		self:checkPtBuff()
	end
end

function M:checkPtBuff()
	if self.isAddBuf then
		if self.curPtStack <= 0 then
			self.player.bufMgr:removeBufById(self.buffId, true)
		end
	else
		if self.curPtStack > 0 then
			self.isAddBuf = true
			self.player.bufMgr:addBufById(self.buffId, self.player, self.skill)
		end
	end

	-- 修改免伤
	if self.lastResatdValue > 0 then
		self.player.data.resatd:removeFromMulList(self.lastResatdValue)
	end
	self.lastResatdValue = GlobalTools:Mul(self.resatdValue, GlobalTools:ToFix(self.curPtStack))
	if self.lastResatdValue > 0 then
		self.player.data.resatd:addToMulList(self.lastResatdValue)
	end
end

function M:destroy()
	EventDispatcher:unRegisterEvent("SkillEnd", {self,self.skillEndHandler})
	EventDispatcher:unRegisterEvent("injure", {self, self.injureHandle})
	M.super.destroy(self)
end

return M