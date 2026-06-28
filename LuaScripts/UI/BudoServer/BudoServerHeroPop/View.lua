local M = class("BudoServerHeroPopView",LikeOO.OOPopBase)

M.m_uiName = "BudoServer/BudoServerHeroPop"
M.m_size_type = 2
--M.m_iphoneXAdapter = true

function M:onEnter()
	self:refreshUI()
	--self:setTextByLanKey("close_title_text", "total_world_rank_" .. self.m_model.m_cur_rank_sort)

end

function M:destroy()
	M.super.destroy(self)
end

function M:refreshUI(is_change_sort)
	--self:setTextByLanKey("rank_title_text2", listName)
	--self:setTextByLanKey("rank_title_text3",titleName)
	self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
	local data = self.m_model.m_heros
	self:setObjectVisible("common_tips_node", #data == 0)
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				if click_name == "cell" and cell_data.user and next(cell_data.user) then
					self:updateMsg("item_click", cell_data.user)
				elseif click_name == "hero_node" then
					self:updateMsg("look_hero", cell_data)
				end
			end
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data, true)
	end
end


--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
	local data = cell_data
	local transform = cell_object.transform
	local luaBehaviour = UIUtil.findLuaBehaviour(transform)
	--LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", GameUtil:formatValueToString(1))
	local hero_node = luaBehaviour:FindGameObject("hero_node")
	self:heroHandle(hero_node, data.hero)
	local bg_img = luaBehaviour:FindImage("cell_bg_img")
	LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_text", GameUtil:formatValueToString(data.hero.combat))
	if data.user and next(data.user) then
		--data.user.title = 30001
		local head_node = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_node", true)
		GameUtil:setUserAvatar(head_node, data.user, false,nil,{show_flag = true, scale = 1})
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_owner_img", false)
		GameUtil:updateResourcesImg( bg_img, "Texture/budoServer/a_qyp_cd1")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "owner_text", data.user.name)
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "head_node", false)
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "no_owner_img", true)
		GameUtil:updateResourcesImg( bg_img, "Texture/budoServer/a_qyp_jhyz")
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "owner_text", "")
	end
end

function M:heroHandle(obj, hero_data)
	local data = hero_data
	local cfg = UserDataManager.hero_data:getHeroConfigByCid(hero_data.id)
	GameUtil:updateHeroContentByData(obj,data,cfg)
end

return M