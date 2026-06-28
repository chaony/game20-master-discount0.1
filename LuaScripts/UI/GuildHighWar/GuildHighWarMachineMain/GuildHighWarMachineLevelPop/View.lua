--==================================
-- file:  View.lua
-- brief:  巅峰帮会战结算界面
-- author:  LiuMiao
-- date:  2022/7/28
--==================================
local M = class("GuildHighWarMachineMainView",LikeOO.OOPopBase)

M.m_uiName = "GuildHighWar/GuildHighWarMachineMain/GuildHighWarMachineLevelPop"
M.m_size_type = 2
M.m_iphoneXAdapter = true

function M:onEnter()
	--self.m_attr_node = GameUtil:commonAttrNode(self.m_control, {mode = 18})
	self:setTextByLanKey("close_title_text", "guild_high_war_text_0082")

	self:setTextByLanKey("cur_des_text", "guild_high_war_text_0085")
	self:setTextByLanKey("last_des_text", "guild_high_war_text_0086")
	self:setTextByLanKey("big_close_btn_txt", "guild_high_war_text_0087")
	self:setObjectVisible("guide_btn",false)
	self.grayImage = self:findImage("grayImage")
	self:refreshUI()
end

--刷新UI
local img_path = {
	[1] ="a_icon_sjjzbh",
	[2]="a_icon_sjjzbb",
	[3]="a_icon_sjjzbl"
}
function M:refreshUI()
	self:setImg(img_path[self.m_model.page_id], "item_icon", "coin")
	self:setTextByLanKey("coin_txt",self.m_model.m_point_data.level_cost or 0)
	self:setTextByLanKey("title_txt",self.m_model.m_point_data.name or "")
	self:setTextByLanKey("text_cancel","guild_high_war_yan_text_007")
	self:UpdateText()
	--self:setTextByLanKey("tips_text","城池效果【飞沙走石】<size=24><Color=#AF6C40>1</Color></size>级")
	local max_level = self.m_model.m_point_data.level_max or 5
	local cur_level = self.m_model.m_point_data.cur_level or 0
	for i=1,5 do 
		self:setObjectVisible("xing_Image"..i,false)
	end
	for i=1,max_level do
		self:setObjectVisible("xing_Image"..i,true)
		if cur_level >= i then
			self:setImg("a_ui_currency_xing", "common_ui", "xing_Image"..i)
		else
			self:setImg("a_ui_currency_xing_di", "common_ui", "xing_Image"..i)
		end
	end
	self:setObjectVisible("btn_revert",max_level >cur_level)
	self:setObjectVisible("coin",max_level >cur_level)
	self:setObjectVisible("tips_text2",self.m_model.m_point_data.point_id == 1016)
	self:setTextByLanKey("tips_text2","guild_high_war_new_0058",self.m_model.m_num)
	self:setTextByLanKey("tips_text3","guild_high_war_yan_text_0026",self.m_model.m_point_data.cur_level,self.m_model.m_point_data.level_max)
	self:setTextByLanKey("tips_text4","guild_high_war_yan_text_0025",self.m_model.m_point_data.level_unlock or 1)
	local buy_img = self:findImage("btn_cancel")
	local btn = self:findButton("btn_cancel")
	buy_img.material = nil
	if max_level <=cur_level then
		buy_img.material = self.grayImage.material
		btn.enabled = false
		self:setObjectVisible("btn_cancel",false)
		return
	end
	self:setObjectVisible("btn_cancel",false)
	for m,n in pairs(self.m_model.m_point_data.open_connect) do
		local data = self.m_model:getCurDataByPointId(tonumber(n))
		if data.cur_level >= data.level_unlock or self.m_model.m_point_data.open_unlock ==1 then
			self:setObjectVisible("btn_cancel",true)
			return
		end
	end
end


function M:UpdateText()
	local text= self.m_model.is_cur_text == 1 and "guild_high_war_yan_text_0027" or "guild_high_war_yan_text_0028"
	local des =  self.m_model.is_cur_text == 1 and self.m_model.m_point_data.des or self.m_model:getCurMaxPointData(self.m_model.m_point_data.point_id).des
	self:setTextByLanKey("text_revert",text)
	self:setTextByLanKey("tips_text",des)
end

function M:destroy()

    M.super.destroy(self)
end


return M