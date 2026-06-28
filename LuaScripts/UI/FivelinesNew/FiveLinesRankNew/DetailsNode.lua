--- 详情
local M = class("DetailsNodeNew",LikeOO.OOUIbase)

M.m_uiName = "FivelinesNew/DetailsNodeNew"

--M.m_iphoneXAdapter = true
function M:onEnter()
    local function callFunc(data)
        if self.m_model.receive_data == nil then
            local function callback(net_data)
                self:refreshUI()
            end
            self.m_model:getNetData("filv_friends_data", nil, callback)
        else
            self:refreshUI()
        end
        
    end
    self.m_model:initData(callFunc)
end

function M:refreshUI()
   self:updateLoopScroll()
end

--[[
	创建列表
]]
function M:updateLoopScroll()
    local data = self.m_model:getCombatData()
	if self.m_loop_scroll_view == nil then
		local loopscroll = self:findGameObject("loopscroll")
		local params = {
			show_data = data,
			loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				self:updateScrollViewCell(index, cell_object, cell_data)
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
                if click_name == "race_img" then
                    self:updateMsg("score_look",{click_transform = click_object.transform, msg = Language:getTextByKey("new_str_0074"), top = true})
                else
                    self:updateMsg("item_click", {id = index})
                end
			end,
            ui_name = self.m_uiName
		}
		self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.m_loop_scroll_view:reloadData(data)
	end
end

--Scroll内cell的回调
function M:updateScrollViewCell(index, cell_object, cell_data)
    local data = cell_data
    local transform = cell_object.transform
    local luaBehaviour = UIUtil.findLuaBehaviour(transform)
    if luaBehaviour then
        local headNode = luaBehaviour:FindGameObject("head_node")
        if headNode then
            GameUtil:setUserAvatar(headNode, cell_data, nil,nil,{show_flag = true, scale = 1})
        end
        for i = 1,  #cell_data.battle_log_info do
            local log_info = cell_data.battle_log_info[i]
            local type_id = self.m_model:getDataByFloor(log_info[1])
            local img_name = "elem_img_"..i 
            local enem_type = GlobalConfig.FIVE_ELEMENT_TYPE[type_id]
            GameUtil:setLanImgText(luaBehaviour:FindRectTransform(img_name), enem_type.img)
        end
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "combat_text", cell_data.combat)
        LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "name_text", tostring(cell_data.name))
        LuaBehaviourUtil.setObjectVisible(luaBehaviour, "relation_text", false)
    end
end

return M