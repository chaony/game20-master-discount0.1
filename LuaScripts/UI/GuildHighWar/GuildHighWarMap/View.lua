
local M = class("GuildHighWarMapView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarMap"
M.m_size_type = 1
M.m_iphoneXAdapter = true

--101 118 201 209  301 306  
local green_color = Color( 80/255, 125/255, 92/255)   --绿色
local blue_color = Color( 58/255, 72/255, 94/255)  --白底 
local yellow_color = Color( 141/255, 80/255, 15/255) --黄底
local city_bottom_img = {"a_dfbhz_baidi","a_dfbhz_huangdi","a_dfbhz_huidi","a_dfbhz_lvdi"} --底框的images
local city_state_img = {"a_dfbhz_icon_dunpai","a_dfbhz_icon_jiaozhan"} --表示状态的images  main_ui2

local r_city = "_city"

function M:onEnter()
	self:setTextByLanKey("common_title_text","guild_high_war_text_0090")
	self:updateCitysState()
end

function M:updateCitysState()
	--Logger.log(self.m_model.m_parent_model.m_ghw_stage)
	local m_array_data = self.m_model.m_parent_model.m_array_data
	local m_line_data = self.m_model.m_parent_model.m_line_data
	local m_fight_data = self.m_model.m_parent_model.m_fight_data
	--local bottom_image = city_bottom_img[1]
	--local txt_color = blue_color
	--local build_name = ""
	--local battle_state_image = city_state_img[1]
	
	for city_id, v in pairs(self.m_model.guild_high_war_build) do
		local bottom_image = city_bottom_img[1]
		local txt_color = blue_color
		local build_name = ""
		local battle_state_image = city_state_img[1]
		local owner_name = self.m_model.m_parent_model:getOwnerNameByCityId(city_id)    --拥有者的名字
		local city_go = self:findGameObject(tostring(city_id .. r_city))
		local city_luabehaviour = UIUtil.findLuaBehaviour(city_go)
		build_name = Language:getTextByKey(v.build_name)

		if self.m_model.m_parent_model.m_is_watch == 1 then --观战

		elseif self.m_model.m_parent_model.m_is_watch == 0 then --对战
			--宣战 准备 布阵   本帮会城池绿底 可宣战黄底 其他白色
			if self.m_model.m_parent_model.m_ghw_stage == 6 or self.m_model.m_parent_model.m_ghw_stage == 3 or self.m_model.m_parent_model.m_ghw_stage == 4 or self.m_model.m_parent_model.m_ghw_stage == 9 then
				if next(m_array_data) then
					for k2,v2 in ipairs(m_array_data) do
						if city_id == v2.id then
							--Logger.log("我自己城市的id" .. city_id .. owner_name)
							bottom_image = city_bottom_img[4]
							txt_color = green_color
						end
					end
				end
				if next(m_line_data) then   --周围可以宣战的城池处理
					for k1,v1 in ipairs(m_line_data) do
						if v1.id == city_id then
							if self.m_model.m_parent_model.m_declare_times > 0 then --还有宣战次数
								--Logger.log("我可以宣战城市的id")
								bottom_image = city_bottom_img[2]
								txt_color = yellow_color
							end
						end
					end
				end
				if next(m_fight_data) then
					for k4,v4 in ipairs(m_fight_data) do
						if v4.id == city_id then
							battle_state_image = city_state_img[2]
							LuaBehaviourUtil.setImg(city_luabehaviour, "state_img",battle_state_image,"main_ui2")
							LuaBehaviourUtil.setObjectVisible(city_luabehaviour, "state_img",true)
						end
					end
				end
			elseif self.m_model.m_parent_model.m_ghw_stage == 5 then --战斗阶段  本帮会城池 显示绿色底板，其他城市为白色底板
				if next(m_array_data) then
					local name = Language:getTextByKey("UnionWar_str_039")
					for k2,v2 in ipairs(m_array_data) do
						if city_id == v2.id then
							bottom_image = city_bottom_img[4]
							txt_color = green_color
							if v2.guild_name ~= name then   --判断是否有挑战者
								LuaBehaviourUtil.setImg(city_luabehaviour, "state_img",battle_state_image,"main_ui2")
								LuaBehaviourUtil.setObjectVisible(city_luabehaviour, "state_img",true)
							end
						end
					end
				end
				if next(m_fight_data) then
					for k4,v4 in ipairs(m_fight_data) do
						if v4.id == city_id then
							battle_state_image = city_state_img[2]
							LuaBehaviourUtil.setImg(city_luabehaviour, "state_img",battle_state_image,"main_ui2")
							LuaBehaviourUtil.setObjectVisible(city_luabehaviour, "state_img",true)
						end
					end
				end
			end
		end
		
		LuaBehaviourUtil.setText(city_luabehaviour,"brand_txt",owner_name ~="" and owner_name or build_name)
		LuaBehaviourUtil.setObjectVisible(city_luabehaviour,"brand_txt",owner_name ~="")
		LuaBehaviourUtil.setObjectVisible(city_luabehaviour,tostring(city_id),owner_name ~="")
		LuaBehaviourUtil.setTextColor(city_luabehaviour,"brand_txt",txt_color)
		LuaBehaviourUtil.setImg(city_luabehaviour, tostring(city_id),bottom_image,"maze_stage_ui")
	end
end

function M:destroy()
	M.super.destroy(self)
end

return M




