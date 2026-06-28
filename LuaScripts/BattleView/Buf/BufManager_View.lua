---@class BufManagerView 场景内的Buf管理器
---@field bufList Battle_List @PlayerBuf_View
---@field iconData Battle_List @BattleView_BuffIcon
---@field buffIcons table
local M = class("BufManager")


--初始化buf管理
function M:init( player )
	self.player = player
	self.bufList = Battle.List.new()
	self.effectList = {}
	self.iconDataCache = nil
	self.iconData = Battle.List.new()
	self.hideEffect = false
	--特效数据
	if Battle.ClassPathUtil:Exists("BattleView.Buf.buff_effect") then
		self.bufEffect = require("BattleView.Buf.buff_effect")
	else
		self.bufEffect = require("DataCenter.Config.buff_effect")
	end
	self.player:addEventListener_Local(Battle.EventType.MV_PlayerBufModelCreateFinish, {self, self.PlayerBufModelCreateFinish})
	self.player:addEventListener_Local(Battle.EventType.MV_BufManagerModelRefreshIcon, {self, self.MV_BufManagerModelRefreshIcon})
end


function M:initIcon()
	self.buffIcons = {}
end

function M:addIcon( image )
	table.insert(self.buffIcons, image)
end

function M:setEffectHide(hide)
	self.hideEffect = hide
	if hide == true then
		for k,v in pairs(self.effectList) do
			if IsNull(v.obj) == false and IsNull(v.obj.m_obj) == false then
				v.obj.m_obj:SetActive(false)
			end
		end
	else
		for k,v in pairs(self.effectList) do
			if IsNull(v.obj) == false and IsNull(v.obj.m_obj) == false then
				v.obj.m_obj:SetActive(true)
			end
		end
	end
end


--通知刷新图标
function M:MV_BufManagerModelRefreshIcon( eventName, data )
	self:refreshBuffIcon();
end

--buf数据创建完成
function M:PlayerBufModelCreateFinish(eventName, data)
	local player_buf_model = data;
	local player_buf_view = require("BattleView.Buf.PlayerBuf_View").new()
	--注册 model 和 view 的事件发送
	SceneManager.MV_EventMgr:register(player_buf_view, player_buf_model);
	player_buf_view:init(self.player, self, player_buf_model)
	self.bufList:add(player_buf_view)
end
	
--清除buf
function M:clearBuf(  )
	self.player = nil
	self.effectList = {}
	self.bufList:clear()
	self.iconData:clear();
end

--刷新buf图标
function M:refreshBuffIcon()
	if self.buffIcons ~= nil then
		local iconDataShow = {}
		for i = 1, self.iconData.Count do
			local index = (i - 1) % 5
			iconDataShow[index] = self.iconData:get(i - 1)
		end
		for i = 0, 4 do
			local icon = iconDataShow[i]
			local icon_obj = self.buffIcons[i + 1]
			if IsNull(icon_obj) == false then
				if icon ~= nil then
					icon_obj.image.gameObject:SetActive(true)
					icon_obj.image.sprite = ResourceUtil:GetSprite(icon.name,"battle_ui")
					icon_obj.count_text.gameObject:SetActive(icon.showNum)
					icon_obj.count_text.text = tostring(icon.count)
				else
					icon_obj.image.gameObject:SetActive(false)
				end
			end
		end
	end
end

function M:addBuffIcon(iconName, showNum)
	local is_new = true
	for i = 1, self.iconData.Count do
		local icon = self.iconData:get(i - 1)
		if icon.name == iconName then
			icon.count = icon.count + 1
			is_new = false
			break
		end
	end
	if is_new == true then
		local icon = {name = iconName, count = 1, showNum = showNum or false}
		self.iconData:add(icon)
	end
	self:refreshBuffIcon()
end

function M:removeBuffIcon(iconName, count)
	for i = 1, self.iconData.Count do
		local icon = self.iconData:get(i - 1)
		if icon.name == iconName then
			icon.count = icon.count - count
			if icon.count <= 0 then
				self.iconData:removeAt(i - 1)
			end
			break
		end
	end
	self:refreshBuffIcon()
end


--添加buf特效
function M:addEffect(effectName, effectItem)
	if effectName == nil or effectItem == nil then
		Logger.logError("添加的特效 名字或特效object为 nil")
		return true
	end
	if self.effectList[effectName] == nil then
		self.effectList[effectName] = { count = 1, effectItem = effectItem };
		return true;
	else
		local effectItem = self.effectList[effectName];
		effectItem.count = effectItem.count + 1
		return false;
	end
end

---获取已经创建过并加入管理的特效
function M:getAddedEffect(effectName)
	if self.effectList[effectName] and self.effectList[effectName].count > 0 then
		return self.effectList[effectName]
	end
	return false
end

--尝试去删除buf特效
function M:tryRemoveEffect(effectName)
	if effectName == nil then
		Logger.logError("移除的特效 名字为 nil")
		return true
	end 
	if self.effectList[effectName] == nil then
		return true
	end
	self.effectList[effectName].count = self.effectList[effectName].count - 1
	if self.effectList[effectName].count == 0 then
		self.effectList[effectName] = nil;
		return true
	end
	return false
end

--获取buf特效
function M:getBuffEffect(effectName)
	if self.effectList[effectName] ~= nil then
		return self.effectList[effectName].obj
	end
	return nil
end

function M:destroy()
	self:clearBuf()
end

return M