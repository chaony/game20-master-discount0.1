local M = class("CompareSwordMyRacePlayerInfoView", LikeOO.OOPopBase)

M.m_uiName = "CompareSwordWithWorld/GameOfHeavenAndEarth/CompareSwordMyRacePlayerInfo"
M.m_iphoneXAdapter = true
M.m_size_type = 2

function M:onEnter()

	self:refreshUI()
end

function M:refreshUI()
	self:updateLoopScroll()
	
	self:setTextByLanKey("common_title_text","compare_sword_race_text_050")
end


--[[
	创建英雄列表
]]
function M:updateLoopScroll()
	local data = self.m_model.hero_data
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			one_line_count = 5,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateHeroContent(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				self:updateMsg("select_hero", cell_data)
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--刷新英雄数据
function M:updateHeroContent(obj, cell_data)
	if obj == nil then
		Logger.log("GameUtil fun updateHeroContent obj error！！！")
		return
	end
	--local hero_data,hero_cfg = self.m_model:getHero(cell_data.id)
	local hero_data = cell_data
	local item_cfg =  UserDataManager.hero_data:getHeroConfigByCid(cell_data.id)
	local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, hero_data.id, 1, hero_data.oid})
	--CommonUIUtil:updateHeroElementByData(obj, itemData)
	--CommonUIUtil:updateHeroLvByData(obj, hero_data)
	GameUtil:updateHeroContentByData(obj.gameObject, hero_data, item_cfg, callback)
	--local luaBehaviour = obj:GetComponent("LuaBehaviour")
	--if luaBehaviour then
	--	local duigoudi_img = luaBehaviour:FindGameObject("duigou_img")
	--	local in_team_flag = self.m_model:isInSlot(heroOid)
	--	duigoudi_img:SetActive(in_team_flag)
	--end
	local luaBehaviour = UIUtil.findLuaBehaviour(obj)
	luaBehaviour:InjectionFunc()
end



function M:destroy()

	M.super.destroy(self)
end

return M