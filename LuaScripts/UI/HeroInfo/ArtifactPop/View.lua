local M = class("ArtifactPopView",LikeOO.OOPopBase)

M.m_size_type = 2
M.m_iphoneXAdapter = true
M.m_uiName = "HeroInfo/ArtifactPop"

local COLOR_1 = Color(41/255, 136/255, 137/255)
local COLOR_2 = Color(0.5, 0.5, 0.5)
function M:onEnter()
	self.result_content = self:findGameObject("result_content")
	self.result_obj_fitter = self.result_content:GetComponent("ContentImmediate")
	self:setImg(self.m_model.m_art_cfg.icon, "item_icon", "art_img")
	self:setTextByLanKey("common_title_text",self.m_model.m_art_cfg.name)
	self:setTextByLanKey("intensify_text", "art_str_003")
	self:setTextByLanKey("eqp_count_text",self.m_model.m_art_cfg.artifact_event or self.m_model.m_art_cfg.level_up[0].artifact_event)
	self:updateLoopScroll()
	self:updateSkillDesc()
	if self.m_model.m_look_model == 1 then
		self:setObjectVisible("btns_node", false)
	else
		self:setObjectVisible("btns_node", true)
	end
	self:setObjectVisible("intensify_btn", not self.m_model:isMaxLv())
	--local red_flag = RedPointUtil:checkArtifact(self.m_model.m_art_data) --神器红点
	--self:setObjectVisible("intensify_red_point_img", red_flag)
	for i = 1, 5 do
		self:setObjectVisible("star_"..i, false)
	end
	for i = 1, self.m_model.m_art_data.lv do
		self:setObjectVisible("star_"..i, true)
	end
end

function M:updateSkillDesc()
	local tab = self.m_model:getSkillDesc()
	for i,v in ipairs(tab) do
		local desc_name = "sk_"..i.."_text"
		local hint_img = "hint_"..i
		if v.activate == true then
			local desc_text = self:setTextByLanKey(desc_name, Language:getTextByKey(v.desc))
			desc_text.color =  COLOR_1
			self:setImg("a_sq_fuhao_1", "common_ui", hint_img)
		else
			local add_text = Language:getTextByKey(v.desc).."（强化至"..v.lv.."星解锁）"
			local desc_text = self:setTextByLanKey(desc_name, add_text)
			desc_text.color =  COLOR_2
			self:setImg("a_sq_fuhao_2", "common_ui", hint_img)
		end
	end
	if self.result_obj_fitter then
		self.result_obj_fitter:ForceRefreshSize()
	end
end

--[[	
	属性列表
]]
function M:updateLoopScroll()
	local data = self.m_model:getAttrs()
	local attrs = UserDataManager:appendAttrs(data)
	local tab = {}
	for i, v in pairs(attrs) do
		table.insert(tab, {i, v})
	end
    if self.m_loop_scroll_view == nil then
        local loopscroll = self:findGameObject("loopscroll")
        local params = {
            show_data = tab,
            one_line_count = 2,
            loop_scroll_object = loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local transform = cell_object.transform
				local cp = GameUtil:getAttrsName(cell_data[1])
				-- 四舍五入保留小数点后一位
				local attr_value = cell_data[2] or 0
				attr_value = math.floor(attr_value * 10 + 0.5)/10
				local num = ""
				if GameUtil:attrTransition(cell_data[1]) == true then
					num = GameUtil:formatNum(attr_value).."%" 
				else
					num =  GameUtil:formatNum(attr_value)
				end
				local attr_name_text = UIUtil.setText(transform, cp.."   "..num, "attr_name_text")
            end,
            click_func = function(index, cell_object, cell_data, click_object, click_name)
                
            end
        }
        self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
    else
        self.m_loop_scroll_view:reloadData(data)
    end
end

return M