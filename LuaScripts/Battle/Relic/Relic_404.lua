--盘古幡
--战斗开始后，我方每次使用大招给己方增加一个攻击力增加2%，
--伤害加深1%的BUFF，BUFF可叠加，满层时攻击力最多叠加至10%，
--伤害加深最多叠加5%（满级攻击力增加5%，伤害加深2%，
--最多叠加25%攻击力，伤害加深10%。）
---@class Relic_404 : Relic @
---@field super Relic @Relic
local M = class("Relic_404", Relic)

function M:init(mgr, param, data)
	M.super.init(self, mgr, param, data)
	--攻击力增加2%，伤害加深1%的BUFF
	self.bufId = self:getValue(1)
	--最大叠加层数
	self.count = self:getValue(2)
	self.curCount = 0
end


function M:gameStart()
	self.curCount = 0;
end


function M:skillStart( skillPlayer, skillData )
	M.super.gameStart(self)
	if skillData.type == 1 and skillPlayer.camp == 1 then
		if self.curCount < self.count then
			local players = self.mgr:getTarget("self", "all")
			for i=1,players.Count do
				local ply = players:get(i-1)
				ply.bufMgr:addBufById(self.bufId, ply)
				GlobalTools:PlayEffect(ply,"Fx_Magic_PanGF_01", 2, "head")
			end
			self.curCount = self.curCount + 1;
		end
		
	end
end

return M