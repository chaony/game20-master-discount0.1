local M = class("PrestigeHeroFetterPopView",LikeOO.OOPopBase)
--==================================
-- file:  View.lua
-- brief:  威望系统 侠客羁绊
-- author:  LiuMiao
-- date:  2022/8/1
--==================================
M.m_uiName = "Prestige/PrestigeHeroFetter"
M.m_size_type = 2
M.m_iphoneXAdapter = true


function M:onEnter()
	self.m_gray_material = self:findImage("gray_img").material
	self:setTextByLanKey("common_title_text", "prestige_jiban_text_001")
	self:refreshUI()
end


--刷新UI
function M:refreshUI()
	self:updateLoopScroll()
end

----创建侠客列表------------------------------------------------------------------------------------------
function M:updateLoopScroll()
	local data = self.m_model:getXiaKeData()
	if self.m_scroll_view == nil then
		local loopscroll = self:findGameObject("scroll_view")
		local params = {
            show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateTeam(cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
        		--self.m_control:openView("Pops.PlayerInfo", {uid = cell_data.user.uid, look_model = 1})
			end
		}
		self.m_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_scroll_view:reloadData(data)
	end
	--prestige_text_x_005 = "取消",
	--prestige_text_x_006 = "分解",
	--prestige_text_x_007 = "侠客羁绊",
end

function M:updateTeam(cell_object, cell_data)
	local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
	if luaBehaviour then
		for i=1,5 do
			local bg_Obj = luaBehaviour:FindGameObject("hero_node_"..i)
			local cell_luaBehaviour = UIUtil.findLuaBehaviour(bg_Obj)
			if cell_data.itemNdoeList[i] then
				GameUtil:updateItemElementByData(bg_Obj, cell_data.itemNdoeList[i].hero_data, false, true)
				local item_img = cell_luaBehaviour:FindImage("item_img")
				local camp_img = cell_luaBehaviour:FindImage("camp_img")
				item_img.material = nil
				camp_img.material = nil
				if cell_data.itemNdoeList[i].status == 0 then
					item_img.material = self.m_gray_material
					camp_img.material = self.m_gray_material
				end
			else
				LuaBehaviourUtil.setObjectVisible(luaBehaviour,"hero_node_"..i,false)
			end
		end
		local fetter_name = luaBehaviour:FindImage("fetter_name")
		fetter_name.material = nil
		if cell_data.all_status == 0 then
			fetter_name.material = self.m_gray_material
		end
		--刷新名字
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cell_data.name or "")
		--刷新说明
		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "effect_text", cell_data.real_des or "")
	end
	--if luaBehaviour then
	--	if next(cell_data) ~= nil then
	--		if cell_data.rank <= 3 and cell_data.rank > 0 then
	--			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", true)
	--			LuaBehaviourUtil.setImg(luaBehaviour, "top_three_rank_img", "a_phb_icon_"..cell_data.rank, "common_ui")
	--		else
	--			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
	--		end
	--		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", cell_data.rank)
	--		local head_node = luaBehaviour:FindGameObject("head_node")
	--		GameUtil:setUserAvatar(head_node, cell_data.user,nil,nil,{show_flag = true, scale = 1})
	--		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", cell_data.user.name)
	--		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "level_text", cell_data.user.level)
	--		LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", GameUtil:formatValueToString(cell_data.score))
	--		if cell_data.rank == 0 then
	--			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "rank_text", "kingsoft_text_0042")
	--		end
	--	else
	--		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "top_three_rank_img", false)
	--		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_bg", false)
	--		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "rank_text", false)
	--		if my and my == true then
	--			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "none_rank_text", "未上榜")
	--			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", UserDataManager.user_data:getUserStatusDataByKey("name"))
	--			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "level_text", UserDataManager.user_data:getUserStatusDataByKey("level"))
	--			LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "race_score_text", "0")
	--			local head_node = luaBehaviour:FindGameObject("head_node")
	--			local user = UserDataManager.user_data.user_status
	--			GameUtil:setUserAvatar(head_node, user, nil, nil, {show_flag = true, scale = 1})
	--		end
	--	end 
	--end
end



return M