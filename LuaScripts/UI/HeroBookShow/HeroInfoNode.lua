--- 逸闻
local M = class("HeroInfoNode",LikeOO.OOUIbase)

M.m_uiName = "HeroBookShow/HeroInfoNode"
M.m_iphoneXAdapter = true

local BASE_TAB = {
	{1,2},
	{3},
	{6},
	{7},
	{8},
	{9},
	{10}
}

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
	local h_cfg = self.m_model:getCfgByCid(self.m_model.m_cur_id)
	for k,v in pairs(BASE_TAB) do
		local info_bg = self.base_obj.transform:GetChild(k-1)
		if info_bg then 
			local LuaBehaviour = UIUtil.findLuaBehaviour(info_bg)
			local bg_img = UIUtil.findImage(info_bg)
			bg_img.enabled = k%2 == 0
			if LuaBehaviour then
				--LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"cell_bg", )
				if #v > 1 then
					LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"cell_title_2", true)
					LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"cell_count_2", true)
					local title1, count1 = self.m_model:getBaseInfoCellByIndex(v[1])
					LuaBehaviourUtil.setTextByLanKey (LuaBehaviour,"cell_name_1",count1)
					LuaBehaviourUtil.setTextByLanKey (LuaBehaviour,"cell_title_1",title1)
					local title2, count2 = self.m_model:getBaseInfoCellByIndex(v[2])
					LuaBehaviourUtil.setTextByLanKey (LuaBehaviour,"cell_count_2",count2)
					LuaBehaviourUtil.setTextByLanKey (LuaBehaviour,"cell_title_2",title2)
				else
					local title, count = self.m_model:getBaseInfoCellByIndex(v[1])
					LuaBehaviourUtil.setTextByLanKey (LuaBehaviour,"cell_name_1",count)
					LuaBehaviourUtil.setTextByLanKey (LuaBehaviour,"cell_title_1",title)
				end
			end
		end
	end
    if h_cfg then
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
	self.tab_list = {}
	for i = 1, num do
		local info_bg = self.anecdote_content.transform:GetChild(i-1)
		local LuaBehaviour = UIUtil.findLuaBehaviour(info_bg)
		if LuaBehaviour then
			local count_text = LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "hero_info_text", self.m_model:getAncedoteDescByIndex(i))
			LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "cell_info_text",  self.m_model:getAncedotName(i))
			if self.m_model:checkAncedoteOpenByIndex(i) == true then
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"lock", false)
			else	
				LuaBehaviourUtil.setObjectVisible(LuaBehaviour,"lock", true)
				LuaBehaviourUtil.setTextByLanKey(LuaBehaviour, "hero_info_text", self.m_model:getEvoName(i))
			end
			local RGBA = Color.New(245/255, 209/255, 129/255)
			local RGBB = Color.New(0.8, 0.8, 0.8)
			count_text.color = self.m_model:checkAncedoteOpenByIndex(i) == true and  RGBA or RGBB
		end
		table.insert(self.tab_list, info_bg)
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