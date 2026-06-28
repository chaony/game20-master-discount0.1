local M = class("ToKensEntrancPopModel", LikeOO.OODataBase)

M.point = {}

function M:onCreate()
	self.m_transfer = "scale"
	self:getData()
end

function M:onEnter()
	self.m_common_data = self:getCommonData()
end

function M:getCommonData()
	local tab = table.copy(ConfigManager:getCommonValueById(463, {}))
	local new_tab = {}
	for k,v in pairs(tab) do
		if self:checkActiveStatus(v) == true then
			table.insert(new_tab, v)
		end
	end
	return new_tab
end

function M:getThreeChargeCfgById(limit_cfg_id)
	local three_charge_cfg = {}
	local limit_cfg_id = tonumber(limit_cfg_id)
	local gift_tab = ConfigManager:getCfgByName("limit_gift")
	if gift_tab and gift_tab[limit_cfg_id] and gift_tab[limit_cfg_id]["show_type"] then
		local show_type = gift_tab[limit_cfg_id]["show_type"]
		if show_type == 0 then
			local three_charge_id = gift_tab[limit_cfg_id]["three_charge"] or 0
			if three_charge_id > 0 then
				local total_three_charge  = ConfigManager:getCfgByName("three_charge") or {}
				if total_three_charge[three_charge_id] then
					three_charge_cfg = total_three_charge[three_charge_id]
				end
			end
		end
	end
	return three_charge_cfg
end

function M:checkChoiceGifts()
	local choice_gifts = UserDataManager.m_choice_gifts
	local choice_group_map = {}
	for i, v in pairs(choice_gifts) do
		local limit_cfg_id = tonumber(i)
		local three_charge_cfg = self:getThreeChargeCfgById(limit_cfg_id)
		if three_charge_cfg and next(three_charge_cfg) then
			choice_group_map[tostring(limit_cfg_id)] = v.ets
		end
	end
	return choice_group_map
end

function M:checkActiveStatus(id)
	if id == 153 then --盗帅
		return UserDataManager:getActivesByOpenId(140)
	elseif id == 115 then --锦囊
		return UserDataManager:getActivesByOpenId(118)
	elseif id == 171 then --聚宝山
		local red_flag, tips_str = BtnOpenUtil:isBtnOpen(id)
		if red_flag == true then
			local server_time = UserDataManager:getServerTime()
			local time_data = TimeUtil.gmTime(server_time)
			if time_data.wday == 6 or time_data.wday == 0 then
				return true
			else
				return false
			end
		end
		return false
	elseif id == 122 then --飞云乘龙
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 123 then --乘龙有礼
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 124 then --天降瑞象
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 227 then --辞旧迎新，好运屋
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 236 then --月影礼包
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 230 then --灵鹿迎新礼包屋
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 248 then --魅影礼包
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 244 then --极阴礼包
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 245 then --极阴礼包
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 261 then -- 新年活动
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 275 then -- 元宵节
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 288 then -- 秘境探宝
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 286 then -- 模拟人生战令
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 264 then -- 新年活动
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 265 then -- 新年活动
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 292 then -- 花朝节礼包
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 294 then -- 罗天摘星
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 284 then  --古剑商铺
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 313 then -- 赛季商店
		local show_flag = ConfigManager:getCommonValueById(722, 1) == 0
		if UserDataManager:getActivesRechargeByOpenId(id) and self:checkSeasonPreviewOpen() and show_flag then
			return true
		else
			return false
		end
	elseif id == 309 then  --四方争霸
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 310 then  --游园
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 314 then
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 324 then
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 329 then
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 330 then
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 339 then
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 364 then  -- 武林遗宝
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 371 then --华服共赏
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 373 then --七夕佳节
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 380 then --浣熊特惠
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 385 then --三侠五义
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 87 then --推送礼包
		local push_gifts = UserDataManager.m_limit_push
		if next(push_gifts) ~= nil then
			return true
		end
		return false
	elseif id == 384 then --限时侠客
		return UserDataManager:getActivesRechargeByOpenId(id)
	elseif id == 393 then --侠客行李白
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 403 then --风云际会
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 408 then --国色天香
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 419 then --周年庆
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 433 then --瑞兔小斋
		return UserDataManager:getActivesRechargeByOpenId(id)
		--return UserDataManager:getActivesByOpenId(id)
	elseif id == 436 then --忠义无双
		return UserDataManager:getActivesByOpenId(id)
	elseif id == 450 then --忠义无双
		return BtnOpenUtil:isBtnOpen(id)
	else
		if UserDataManager:getActivesByOpenId(id) then
			return true
		else
			return UserDataManager:getActivesRechargeByOpenId(id)
		end
	end
end

function M:checkSeasonPreviewOpen()
	local openSeasonPreviewFlag = true
	local tips_str = ""
	local open_flag1, tips_str1 = BtnOpenUtil:isBtnOpen(218)
	if open_flag1 == false then
		openSeasonPreviewFlag = false
		tips_str = tips_str1
	end
	if openSeasonPreviewFlag and GameUtil:isSeasonPreviewOpen() == false then
		openSeasonPreviewFlag = false
		tips_str = Language:getTextByKey("new_str_1032")
	end
	local is_have_next = self:isHaveNextSeason()
	if openSeasonPreviewFlag and is_have_next == false then
		openSeasonPreviewFlag = false
		tips_str = Language:getTextByKey("new_str_1032")
	end
	return openSeasonPreviewFlag, tips_str
end

function M:isHaveNextSeason()
	local cur_cfg = {}
	local cur_season = UserDataManager:getCurSeason() + 1
	local season_notice_cfg = ConfigManager:getCfgByName("season_notice")
	if season_notice_cfg and season_notice_cfg[cur_season] then
		return true
	end
	return false
end

return M