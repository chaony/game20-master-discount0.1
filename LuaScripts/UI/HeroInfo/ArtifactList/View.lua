local M = class("ArtifactListView",LikeOO.OOPopBase)


M.m_size_type = 2
M.m_uiName = "HeroInfo/ArtifactList"


function M:onEnter()
    self.m_gray_img = self:findImage("gray_img")
    self.have_tab = {}
    self.no_tab = {}
    self:setTextByLanKey("common_title_text", "art_str_002")
    self:restoreUI()
end

function M:restoreUI()
    self:updateLoopScroll()
end

--[[
	创建神器列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getArtfactList()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateArtifact(cell_object, cell_data)
			end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                local a_data, a_cfg = self.m_model:getArtifactData(cell_data) 
                if click_name == "replace_btn" and a_data and a_data.h_id then
                    self:updateMsg("replace_btn", a_data.h_id)
                elseif click_name =="check_btn" then   
                    self:updateMsg("check_btn", a_data)
                elseif click_name == "hint_btn" then
                    local click_obj = click_object
                    local c_lv = a_data ~= nil and a_data.lv or 0 
                    self:updateMsg("hint_btn", {click_transform = click_object.transform, lv =c_lv, cfg = a_cfg})
                end
			end,
			ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

function M:updateArtifact(obj, data)
    local luaBehaviour = UIUtil.findLuaBehaviour(obj)
    local a_data, a_cfg = self.m_model:getArtifactData(data) 
    if luaBehaviour then
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "replace_btn", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_btn", false)
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "owner_obj", false)
        if a_cfg then
            local art_icon = LuaBehaviourUtil.setImg(luaBehaviour, "art_icon", a_cfg.icon, "item_icon")
            LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Artifact_WpGlow_001", false)
            if a_data then
                if a_data.h_id then
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "owner_obj", true)
                    if a_data.h_id ~= self.m_model.m_heroid then
                        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "replace_btn", true)
                    end
                    local parent = luaBehaviour:FindGameObject("item_owner")
                    self:creatHeroNode(parent, a_data.h_id)
                else
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "check_btn", true)
                    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "owner_obj", false)   
                end 
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "UI_Artifact_WpGlow_001", true)
                art_icon.material = nil
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", false)
            else
                art_icon.material = self.m_gray_img.material    
                LuaBehaviourUtil.setObjectVisible(luaBehaviour, "lock_img", true)
            end
            local des = self.m_model:getParam_des(a_data, a_cfg)
            LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "get_text", des)    
            local name = Language:getTextByKey(a_cfg.name)
            local count_text = LuaBehaviourUtil.setText(luaBehaviour, "equip_name_text", name)
        end
    end
end

function M:creatHeroNode(parent, id)
    local data, cfg = self.m_model:getHeroById(id)
    local itemData = RewardUtil:getProcessRewardData({RewardUtil.REWARD_TYPE_KEYS.HEROS, data.id, 1, data.oid})
    local icon = GameUtil:createItemElementByData(itemData, false, false, nil, parent.transform)
    local LuaBehaviour = UIUtil.findLuaBehaviour(icon)
    if LuaBehaviour then
        LuaBehaviourUtil.setObjectVisible(LuaBehaviour, "lv_bg_img", false)
    end
end

return M