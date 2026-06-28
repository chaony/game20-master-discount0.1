
--标记类buff
---@class BufWorkMark_View : BufWork_View @
---@field super BufWork_View @BufWork_View
local M = class("BufWorkMark_View", BufWork_View)

M.marks = nil

M.effectList = nil

M.count = 0

M.maxCount = 0

M.time = nil

M.interval = nil

M.intervalReduce = nil

M.effect = nil

M.countEffect = nil

function M:init( buf, model )
	M.super.init(self, buf, model)
	self:addEventListener_Local(Battle.EventType.MV_BufWorkModelMarkPlayerEffect, {self, self.MV_BufWorkModelMarkPlayerEffect})
end

function M:MV_BufWorkModelMarkPlayerEffect(eventName, data)
	self:effectLoadFinish();
end

function M:effectLoadFinish()
	if self.model.showCount == 1 then
		for i = 1, table.nums(self.playerBuf.effect) do
			local effect = self.playerBuf.effect[i]
			if effect ~= nil then
				local effectObj = self.playerBuf.mgr:getBuffEffect(effect["prefab"])
				if IsNull(effectObj) == false and self.playerBuf.player.hpBar ~= nil then
					if IsNull(self.countEffect) == false then
						self.effectObj = effectObj
						self.countEffect = ResourceUtil:GetUIItem("Battle/MarkLabel", self.playerBuf.player.hpBar.m_obj, "ui_prefabs")
						self.countEffect.transform.localPosition = Vector3.New(0,0,0)
						self.countTran = self.countEffect.transform:Find("Text")
						self.countText = self.countTran:GetComponent("Text")
						self.countText.text = "x"..self.model.count
					end
				end
			end
		end
	end
end


function M:update(dt)
	M.super.update(self,dt)
	if IsNull(self.countEffect) == false and IsNull(self.effectObj.m_obj) == false then
		self.countEffect.transform.position = SceneManager:getCurSceneView().cameraController:worldToUI(self.effectObj.m_obj.transform.position);
	end
end


function M:stop()
	M.super.stop(self)
	if self.countEffect ~= nil then
		ResourceUtil:ReturnItem(self.countEffect)
	end
end

return M