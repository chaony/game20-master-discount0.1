local M = class("DepositoryPopView",LikeOO.OOPopBase)

M.m_uiName = "SutraDepository/MysticDepositoryPopNode"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
    audio:SendEvtUI("UI_LHG_MiJi_Upgrade")
	self:refreshUI()	
end

function M:refreshUI()

	local data, cur_cfg = self.m_model:getMysticData()
	
	local common_title_text = Language:getTextByKey(cur_cfg.name)
	self:setTextByLanKey("common_title_text", common_title_text)

    local attrs = cur_cfg.attrs[data.star - 1] or cur_cfg.attrs[cur_cfg.init_star]
    for i=1, 2 do
        local attr = attrs[i]
        if attr then
            local attr_cfg = GameUtil:getAttrCfg(attr[1])
            self:setTextByLanKey("type_text_" .. i, Language:getTextByKey(attr_cfg.name))
            self:setTextByLanKey("vein_desc_" .. i, "+" .. (attr_cfg.is_percent == 1 and tostring(attr[2]*100) .. "%" or tostring(attr[2])))
        else
            self:setObjectVisible("type_text_" .. i, false)
            self:setObjectVisible("vein_desc_" .. i, false)
        end
    end
    local attrs = cur_cfg.attrs[data.star] or cur_cfg.attrs[cur_cfg.init_star]
    for i=1, 2 do
        local attr = attrs[i]
        if attr then
            local attr_cfg = GameUtil:getAttrCfg(attr[1])
            self:setTextByLanKey("type_new_text_" .. i, Language:getTextByKey(attr_cfg.name))
            self:setTextByLanKey("vein_new_desc_" .. i, "+" .. (attr_cfg.is_percent == 1 and tostring(attr[2]*100) .. "%" or tostring(attr[2])))
        else
            self:setObjectVisible("type_new_text_" .. i, false)
            self:setObjectVisible("vein_new_desc_" .. i, false)
        end
    end
    
    local data = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.MYSTIC, tonumber(self.m_model.m_oid), cur_cfg.quality, oid = self.m_model.m_oid})
    self:updateBooksByData(data,cur_cfg,"MysicItem_left")
    self:updateBooksByData(data,cur_cfg,"MysicItem",true)

    
end


function M:updateBooksByData( data, cfg,obj_name,isUp)
	local object = self:findGameObject(obj_name)
    local luaBehaviour = UIUtil.findLuaBehaviour(object)
    local item_img = LuaBehaviourUtil.setImg(luaBehaviour,"item_img", data.icon_name, data.atlas_name or "item_icon")
    --local count_text = LuaBehaviourUtil.setText(luaBehaviour, "count_text", data.data_num)
    local title_node = luaBehaviour:FindGameObject("title_node")
    local title_text = luaBehaviour:FindText("title_text")
    local duigoudi_img = luaBehaviour:FindGameObject("duigoudi_img")
    local lv_text = luaBehaviour:FindGameObject("lv_text")
    local have_panel = luaBehaviour:FindGameObject("have_panel")
    local no_panel = luaBehaviour:FindGameObject("no_panel")
    local up_image = luaBehaviour:FindGameObject("up_image")
    local lock_image = luaBehaviour:FindGameObject("lock_image")
    local stars = luaBehaviour:FindGameObject("stars")
    local tips_img = luaBehaviour:FindGameObject("tips_img")
    local red_point_img = luaBehaviour:FindGameObject("red_point_img")
    local count_text_bg_img = luaBehaviour:FindGameObject("count_text_bg_img")
    local lv_bg_img = luaBehaviour:FindGameObject("lv_bg_img")
    local ex_we_bg = luaBehaviour:FindGameObject("ex_we_bg")
    local ex_di_bg = luaBehaviour:FindGameObject("ex_di_bg")

    local name_list =  string.split(Language:getTextByKey(cfg.name),"·")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name", name_list[1] or "")
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "cell_name2", name_list[2] or "")
    local type_meridian = GlobalConfig.TYPE_MERIDIAN[cfg.type]
    LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "type_name", type_meridian.short_name)
    LuaBehaviourUtil.setTextColor(luaBehaviour,"type_name",type_meridian.name_color)
	
    red_point_img:SetActive(false)
    have_panel:SetActive(true)
    no_panel:SetActive(false)
    up_image:SetActive(false)
    ex_we_bg:SetActive(false)
    lock_image:SetActive(false)
    duigoudi_img:SetActive(false)
    title_node:SetActive(false)
    tips_img:SetActive(false)
    lv_bg_img:SetActive(false)
    ex_di_bg:SetActive(false)
    count_text_bg_img:SetActive(data.data_num > 1)
    local frame = GlobalConfig.QUALITY_COMMON_SETTING[data.quality]
    LuaBehaviourUtil.setImg(luaBehaviour,"quality_img", frame.frame_name, "equip_icon")
	
     -- 显示升级等级
	local data = self.m_model:getMysticData()
	local star_lv = data and data.star or 0
	if isUp ~= true then
		star_lv = self.m_model.m_old_star or (star_lv - 1)
	end
	for i = 1, 5 do
		local star = luaBehaviour:FindGameObject("star_" .. i)
		if star then
			UIUtil.setImgAlpha(star, 1)
			star:SetActive(i <= star_lv)
		end
	end
	if star_lv >= 1 then
		ex_di_bg:SetActive(true)
	end

	if self.m_model.m_can_lv_up then
		local star = luaBehaviour:FindGameObject("star_" .. (star_lv + 1))
		if star then
			UIUtil.setImgAlpha(star, 0)
			star:SetActive(true)
			U3DUtil.Get_LayoutRebuilder().ForceRebuildLayoutImmediate(star.transform.parent)
			self.m_control:setOnceTimer(0.1, function()
				if not IsNull(luaBehaviour) then
					local UI_MysticDepository_xing_01 = LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_MysticDepository_xing_01", true)
					CommonUIUtil:setObjectPosByTarget(UI_MysticDepository_xing_01, star)
				end
			end)
		else
			LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_MysticDepository_xing_01", false)
		end
	else
		LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_MysticDepository_xing_01", false)
	end
end




function M:destroy()
    M.super.destroy(self)
end

return M