local M = class("ArtOptionNode",LikeOO.OOUIbase)

M.m_uiName = "Map/ArtOptionNode"


function M:onEnter()
	self.map = self.m_params.map
	self.option_tran = self.m_params.option_tran
	self.opt_data = self.m_params.opt_data
	--self:updateArtLoopScroll(self.m_params.opt_data, self.m_params.art_id)
	self:refreshData(self.opt_data)
end

function M:refreshData(data)
	self.art_loopscroll = self:findGameObject("art_opt")
	local rect = self.art_loopscroll:GetComponent("RectTransform")
	rect.position = self.option_tran.position
	for i = 1, 3 do
		local cell = self:findGameObject("opt_cell"..i)
		if cell ~= nil then
			if data[i] ~= nil then
				cell:SetActive(true)
				local opt_data = self.map.article_opt_table[data[i].index]
				self:setTextByLanKey("opt_cell"..i.."_text", tostring(opt_data.option_txt))
			else
				cell:SetActive(false)
			end
		end
	end
end

--[[
	创建互动物品选项列表
]]
function M:updateArtLoopScroll(data, art_id)
	local data = data or {}
	if self.option_scroll_view == nil then
		self.art_loopscroll = self:findGameObject("art_opt_loopscroll")
		local rect = self.art_loopscroll:GetComponent("RectTransform")
		rect.position = self.option_tran.position
		local params = {
			show_data = data,
			loop_scroll_object = self.art_loopscroll,
			update_cell = function(index, cell_object, cell_data)
				local opt_data = self.map.article_opt_table[cell_data.index]
				local luaBehaviour = UIUtil.findLuaBehaviour(cell_object)
				LuaBehaviourUtil.setTextByLanKey(luaBehaviour, "tip_text", tostring(opt_data.option_txt))
			end,
			click_func = function(index, cell_object, cell_data, click_object, click_name)
				cell_data.finish(cell_data.index)
				local opt_data = self.map.article_opt_table[cell_data.index]
				if opt_data.voice_open ~= "" and opt_data.voice_open ~= 0 then
					audio:SendEvtUI(opt_data.voice_open)
				end
				if opt_data.animation_open == 1 then
					LikeOO.Map2DControl:cameraShake(2, 0.3)
				end
				self:closeArtLoopscroll()
				if opt_data.map_id ~= 0 then
					LikeOO.Map2DControl:openMap2D(opt_data.map_id)
				end
			end
		}
		self.option_scroll_view = LoopScrollViewUtil.new(params)
	else
		self.option_scroll_view:reloadData(data)
	end
end

function M:closeArtLoopscroll()
	self:destroy()
end

function M:onButtonClick(obj, name)
	--返回上一层
	if name == "close_btn" then
		self:destroy()
	elseif string.find(name, "opt_cell") then
		local index = tonumber(string.split(name, "cell")[2])
		local cell_data = self.opt_data[index]
		cell_data.finish(cell_data.index)
		local opt_data = self.map.article_opt_table[cell_data.index]
		if opt_data.voice_open ~= "" and opt_data.voice_open ~= 0 then
			audio:SendEvtUI(opt_data.voice_open)
		end
		if opt_data.animation_open == 1 then
			LikeOO.Map2DControl:cameraShake(2, 0.3)
		end
		self:closeArtLoopscroll()
		if opt_data.map_id ~= 0 then
			LikeOO.Map2DControl:openMap2D(opt_data.map_id)
		end
	end

	--local full_btn_name = self.m_uiName .. "/" .. name
	--GameUtil:playBtnSound(full_btn_name)
end




function M:destroy()
	M.super.destroy(self)
end

return M