---@class OptionsSettingPopModel:OODataBase
local M = class("OptionsSettingPopModel", LikeOO.OODataBase)

function M:onCreate()
	self.m_transfer = "scale"
	M.super.onCreate(self)
	self:getData()
end

function M:onEnter()
	self:setEffectShow(1)
	self.m_setting_mode = 1
end


-- 0 表示关闭 1 表示开启
function M:setEffectShow(value)
	UserDataManager.local_data:setLocalDataByKey("effectShow",value)
	CS.wt.framework.AssetLoaderHelper.Inst:ShowEffect(value==1);
end

--设置抗锯齿
function M:setAntiAliasing(value)
	UserDataManager.local_data:setLocalDataByKey("phone_antiAliasing",value)
	CS.wt.framework.AssetLoaderHelper.Inst:SetQuailty(value);
end

--设置fps状态
function M:setFPS(value)
	UserDataManager.local_data:setLocalDataByKey("gameFPS",value)
end

--设置描边  0:关闭  1:开启
function M:setStroke(value)
	if value == 1 then
		if UserDataManager.local_data:getLocalDataByKey("shadow") == 1 then
			CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(2);
		else
			CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(1);
		end
	else
		CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(0);
	end
	UserDataManager.local_data:setLocalDataByKey("stroke",value)
end

--设置阴影  0:关闭  1:开启
-- 200 初始渲染 描边 阴影  
-- 150 初始渲染 描边 圆圈
-- 100 初始渲染 圆圈			
function M:setShadow(value)
	if value == 1 then
		CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(2);
	else
		if UserDataManager.local_data:getLocalDataByKey("stroke") == 1 then
			CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(1);
		else
			CS.wt.framework.AssetLoaderHelper.Inst:SetShaderLOD(0);
		end
	end
	UserDataManager.local_data:setLocalDataByKey("shadow",value)
end


--设置高帧率(60帧)  
-- 0:关闭  1:开启
function M:setHfr(value)
	if value == 1 then
		CS.wt.framework.AssetLoaderHelper.Inst:SetTargetFrameRate(60);
	else
		CS.wt.framework.AssetLoaderHelper.Inst:SetTargetFrameRate(30);
	end
	UserDataManager.local_data:setLocalDataByKey("hfr",value)
end


--设置分辨率 0,1,2
function M:setPower(value)
	LODUtil:setPower(value);
	--CS.wt.framework.AssetLoaderHelper.Inst:SetScreenSize(value);
	UserDataManager.local_data:setLocalDataByKey("power",value)
end


--设置场景质量 0,1,2
function M:setScene(value)
	CS.wt.framework.AssetLoaderHelper.Inst:SetSceneLOD(value);
	UserDataManager.local_data:setLocalDataByKey("sceneLod",value)
end


--设置特效质量 0,1,2
function M:setEffect(value)
	CS.wt.framework.AssetLoaderHelper.Inst:SetEffectLOD(value);
	UserDataManager.local_data:setLocalDataByKey("effectLod",value)
end


--设定音乐音量
function M:setMusicVolume(value)
	audio.music_volume = value
	audio:SetBgmVol(value) 
	U3DUtil:PlayerPrefs_SetFloat("music_volume", value)
end

--设定效果音量
function M:setEffectVolume(value)
	audio.effect_volume = value
	audio:SetSkillsVol(value)
	audio:SetUIVol(value)
	U3DUtil:PlayerPrefs_SetFloat("effect_volume", value)
end

--设定Cv音量
function M:setCVVolume(value)
	audio.cv_volume = value
	audio:SetCVVol(value)
	U3DUtil:PlayerPrefs_SetFloat("cv_volume", value)
end


return M
