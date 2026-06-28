--- 逸闻
local M = class("HeroAnecdoteNode",LikeOO.OOUIbase)

M.m_uiName = "HeroInfo/HeroAnecdoteNode"


function M:onEnter()
	self.base_obj = self:findGameObject("base_obj")
	self.anecdote_content = self:findGameObject("anecdote_content")
    self:refreshUI()    
end

function M:refreshUI()
	self:setSpine()
	self:setBaseInfo()
	self:setDescInfo()
end

function M:setBaseInfo()
    if self.m_model.herocfg or self.m_model.tj_cfg then
        local num = self.base_obj.transform.childCount
		for i=1,num do
      	  	local info_bg = self.base_obj.transform:GetChild(i-1)
			local title, count = self.m_model:getBaseInfoCellByIndex(i)
			UIUtil.setTextByLanKey(info_bg,"cell_title_text",title)
			UIUtil.setTextByLanKey(info_bg,"cell_count_text",count)
		end
    end
end

function M:setDescInfo()
	local num = self.anecdote_content.transform.childCount
	for i = 1, num do
		local info_bg = self.anecdote_content.transform:GetChild(i-1)
		local bl = self.m_model:checkAncedoteOpenByIndex(i)
		if bl == true then
			UIUtil.setTextByLanKey(info_bg,"hero_info_text", self.m_model:getAncedoteDescByIndex(i))
		else
			UIUtil.setTextByLanKey(info_bg,"hero_info_text", "anecdote_1",i,self.m_model:getEvoName(i))
		end
	end
end

--[[
    @desc: 英雄动画
]]
function M:setSpine()
	local icon = self.m_model:getHeroBigAnim()
	if self.cacheSpineName == icon then
		return
	else
		self.cacheSpineName = icon	
	end
	local pos_x = 0
	local pos_y = -142
	local play_img = self:findGameObject("hero_spine")
 	local sg = play_img:GetComponent("SkeletonGraphic")
	local hehe = ResourceUtil:GetSk(self.cacheSpineName, "rolespine_"..string.lower(self.cacheSpineName))
	sg.skeletonDataAsset = hehe
	sg:Initialize(true)
	local linshi_pos =self.m_model:getSpinePos()
	pos_x = pos_x + linshi_pos[1]
	pos_y = pos_y + linshi_pos[2]
	UIUtil.setLocalPosition(play_img.transform,pos_x, pos_y, 0)
end

return M