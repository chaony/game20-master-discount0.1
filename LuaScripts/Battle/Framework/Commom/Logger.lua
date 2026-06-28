----------------Logger
local M = {}

local Debug;
local Log
local LogError
local LogWarning

local __upload_error_mark = "Unhandled Exception: LuaScriptException: "

if GameVersionConfig.IS_SERVER then
	Log = print
	LogError= print
    LogWarning = print
else
	Log = U3DUtil:Log()
	LogError= U3DUtil:LogError()
    LogWarning = U3DUtil:LogWarning()
end


function M.log(var, name)
	if GameVersionConfig.Debug then
		M.logAlways(var, name)
	end
end

function M.logAlways(var, name)
	name = name or "var"
	name = _VERSION .. ">> " .. name .. " : type = " .. type(var) .. ", value"
	if(var == nil)then
		Log("----- var is nil : " .. name)
		return
	end
	if type(var) == "table" then
		Log(name .. " = " .. table.dump(var, true, 5))
	else
		Log(name .. " = " .. tostring(var))
	end
end

function M.logError(var, name)
	if GameVersionConfig.Debug then
		M.logErrorAlways(var, name)
	end
end

function M.logErrorAlways(var, name)
	name = name or "var"
	name = _VERSION .. ">> " .. name .. " : type = " .. type(var) .. ", value"
	if(var == nil)then
		LogError("----- var is nil : " .. name)
		return
	end
	if type(var) == "table" then
		LogError(__upload_error_mark .. name .. " = " .. table.dump(var, true, 5))
	else
		LogError(__upload_error_mark .. name .. " = " .. tostring(var))
	end
end

function M.logWarning(var, name)
	if GameVersionConfig.Debug then
		M.logWarningAlways(var, name)
	end
end

function M.logWarningAlways(var, name)
	name = name or "var"
	name = _VERSION .. ">> " .. name .. " : type = " .. type(var) .. ", value"
	if(var == nil)then
		LogWarning("----- var is nil : " .. name)
		return
	end
	if type(var) == "table" then
		LogWarning(name .. " = " .. table.dump(var, true, 5))
	else
		LogWarning(name .. " = " .. tostring(var))
	end
end

return M