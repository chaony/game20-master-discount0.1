local M = class("MasterApprenticeRewardPopView",LikeOO.OOPopBase)

M.m_uiName = "Friend/MasterApprenticeRewardPop"
M.m_size_type = 2


function M:onEnter()
	self:refreshUI()
end

function M:refreshUI()
	self:setObjectVisible("list_scroll", false) --可以领取
	self:setObjectVisible("list_scroll2", false) --单纯展示
	self:setObjectVisible("desc_text", false)
	if self.m_model.m_master and next(self.m_model.m_master)~= nil then
		self:setObjectVisible("list_scroll", true)
		self:updateScrollList()
	else
		if self.m_model:chechMasterStatue() == true then
			self:setObjectVisible("list_scroll", true)
			self:updateScrollList()
		else
			self:setObjectVisible("list_scroll2", true)
			self:setObjectVisible("desc_text", true)
			self:updateScrollList2()
		end
	
	end
end

function M:updateScrollList()
	local data = self.m_model.m_task_list
	self:sort(data)
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll")
        local params = {
            show_data = data,
            loop_scroll_object = list_scroll,
            update_cell = function(index, cell_object, cell_data)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				local data, cfg = self.m_model:getTaskData(cell_data)
				if luaBehaviour then
					local num_show = self.m_model:formNum(data.value) .."/"..cfg.target_value
					LuaBehaviourUtil.setText(luaBehaviour,"cell_title", Language:getTextByKey(cfg.name))
					LuaBehaviourUtil.setText(luaBehaviour,"cell_num", num_show)
					local slider = UIUtil.findSlider(cell_object.transform,"cell_slider")
					slider.value = data.value/cfg.target_value
                end
            end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				local data, cfg = self.m_model:getTaskData(cell_data)
				if  data.value >= cfg.target_value then
					self:updateMsg("get_reward", cell_data)
				else

				end
				
			end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data,true)
    end
end

function M:updateScrollList2()
	local data = self.m_model.m_task_list
	self:sort(data)
    if self.m_list_scroll == nil then
        local list_scroll = self:findGameObject("list_scroll2")
        local params = {
            show_data = data,
            loop_scroll_object = list_scroll,
			update_cell = function(index, cell_object, cell_data)
				local data, cfg = self.m_model:getTaskData(cell_data)
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
                if luaBehaviour then
					LuaBehaviourUtil.setText(luaBehaviour, "cell_name", Language:getTextByKey(cfg.name))
					local content = luaBehaviour:FindGameObject("cell_content")
					if content then
						UIUtil.destroyAllChild(content.transform)
						for k,v in pairs(cfg.reward) do
							self:creatCell(v, content)
						end
					end
                end
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
			
			end
        }
        self.m_list_scroll = LoopScrollViewUtil.new(params)
    else
        self.m_list_scroll:reloadData(data,true)
    end
end

function M:creatCell(data, parent)
	local cell = GameUtil:createItemElement(data,true,false)  -- ResourceUtil:LoadUIGameObject("Friend/MasterApprenticeUndergo_Cell", Vector3.zero,nil)
	cell.transform.localScale = Vector3.New(0.8, 0.8, 1) 
	cell.transform:SetParent(parent.transform, false)
	return cell
end


--[[
    排序
]]
function M:sort(pros)
    pros = pros or {}
    local function sortFunc(id_one, id_two)
        return id_one < id_two
    end
    table.sort(pros, sortFunc)
end

return M