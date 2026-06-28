--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:{author}
    time:2020-01-19 16:44:55
]]

---@class FixVector3 @Vector3的定点数的数据结构
local FixVector3 = {}

local math  = math
local acos	= math.acos
local sqrt 	= math.sqrt
local max 	= math.max
local min 	= math.min
local cos	= math.cos
local sin	= math.sin
local abs	= math.abs
local setmetatable = setmetatable
local type = type
local setmetatable = setmetatable
local rawset = rawset
local rawget = rawget


FixVector3.__index = FixVector3

--实例化方法
function FixVector3.New(x, y, z)	
	if SceneManager.FixVector3_New_Num == nil then
		SceneManager.FixVector3_New_Num = 0;
	else
		SceneManager.FixVector3_New_Num = SceneManager.FixVector3_New_Num + 1;
	end
    local t = {x = x or 0, y = y or 0, z = z or 0}
    setmetatable(t, FixVector3 )		
    t.x = GlobalTools:ToFix(t.x);
    t.y = GlobalTools:ToFix(t.y)
    t.z = GlobalTools:ToFix(t.z)
	return t
end

function FixVector3.GetPop(x,y,z)
    local fixVec = TablePoolUtil:pop(1);
	fixVec.x = GlobalTools:ToFix(x);
	fixVec.y = GlobalTools:ToFix(y);
	fixVec.z = GlobalTools:ToFix(z);
	return fixVec;
end



function FixVector3.NewPop(x,y,z)
	local fixVec = TablePoolUtil:pop(1);
	fixVec.x = GlobalTools:ToFix(x);
	fixVec.y = GlobalTools:ToFix(y);
	fixVec.z = GlobalTools:ToFix(z);
	return fixVec;
 end

-- local _new = FixVector3.New
local _new = FixVector3.NewPop


function FixVector3._New(x,y,z)
	local fixVec = _new(0, 0, 0)
	fixVec.x = x
	fixVec.y = y
	fixVec.z = z
	return fixVec
end

--实例化
local _new_no = FixVector3._New


FixVector3.__call = function(t,x,y,z)
	local t = _new(x,y,z)
	return t
end


function FixVector3:IamIsFixVector3()
	
end

	
function FixVector3:Set(x,y,z)	
	self.x = GlobalTools:ToFix(x)
	self.y = GlobalTools:ToFix(y)
	self.z = GlobalTools:ToFix(z)
end


function FixVector3:SetVector3( vec )
	self.x = GlobalTools:ToFix(vec.x)
	self.y = GlobalTools:ToFix(vec.y)
	self.z = GlobalTools:ToFix(vec.z)
end

function FixVector3.Get(v)		
	return v.x, v.y, v.z	
end

--克隆
function FixVector3:Clone()
	local clone = _new(0, 0, 0)
	clone.x = self.x;
	clone.y = self.y;
	clone.z = self.z;
	return clone
end

function FixVector3:CloneNew()
	local clone = FixVector3.New(0, 0, 0)
	clone.x = self.x;
	clone.y = self.y;
	clone.z = self.z;
	return clone
end


--点积
function FixVector3.Dot(lhs, rhs)
	--2个定点数向量相乘
	local x_mul = GlobalTools:Mul(lhs.x, rhs.x)
	--2个定点数向量相乘
	local y_mul = GlobalTools:Mul(lhs.y, rhs.y)
	--2个定点数向量相乘
	local z_mul = GlobalTools:Mul(lhs.z, rhs.z)
	--定点数结果
	local dot_re = x_mul + y_mul + z_mul
	return dot_re
end

--距离
function FixVector3:Magnitude()
	
	local num = GlobalTools:FastSqart(self.x,self.z)
	--距离
	--return math.floor( num );
	return num
end


----距离
--function FixVector3:Magnitude()
--	--定点数乘法
--	local x_mul = GlobalTools:Mul(self.x,self.x);
--	--定点数乘法
--	local y_mul = GlobalTools:Mul(self.y,self.y);
--	--定点数乘法
--	local z_mul = GlobalTools:Mul(self.z,self.z);
--	--
--	local num = GlobalTools:Sqrt(x_mul + y_mul + z_mul)
--	--距离
--	--return math.floor( num );
--	return num
--end

--距离的平方
function FixVector3:SqrMagnitude()
	--定点数乘法
	local x_mul = GlobalTools:Mul(self.x,self.x);
	--定点数乘法
	local y_mul = GlobalTools:Mul(self.y,self.y);
	--定点数乘法
	local z_mul = GlobalTools:Mul(self.z,self.z);
	local dis = x_mul + y_mul + z_mul
	return dis
end

--归一化
function FixVector3.Normalize(v)
	local num = v:Magnitude();
	--得到一个长度
	if num > 1e-5 then
		local _new_one = _new(0, 0, 0)
		_new_one.x = GlobalTools:Div(v.x,num);
		_new_one.y = GlobalTools:Div(v.y,num);
		_new_one.z = GlobalTools:Div(v.z,num);
		return _new_one
	end
	return FixVector3.zero()
end


--归一化自己
function FixVector3:SetNormalize()
	--距离
	local num = self:Magnitude();
	if num > 1e-5 then    
        self.x = GlobalTools:Div( self.x, num )
		self.y = GlobalTools:Div( self.y, num )
		self.z = GlobalTools:Div( self.z, num )
    else    
		self.x = 0
		self.y = 0
		self.z = 0
	end 
	return self
end

--X积
function FixVector3.Cross(lhs, rhs)
	local _new_one = _new(0,0,0)
	_new_one.x = GlobalTools:Mul(lhs.y,rhs.z) - GlobalTools:Mul(lhs.z,rhs.y)
	_new_one.y = GlobalTools:Mul(lhs.z,rhs.x) - GlobalTools:Mul(lhs.x,rhs.z)
	_new_one.z = GlobalTools:Mul(lhs.x,rhs.y) - GlobalTools:Mul(lhs.y,rhs.x)
	return _new_one;
end
	
--判断相等
function FixVector3:Equals(other)
	return self.x == other.x and self.y == other.y and self.z == other.z
end


FixVector3.__div = function(va, d)
	local _new_one = _new(0, 0, 0)
	_new_one.x = GlobalTools:Div( va.x ,d );
	_new_one.y = GlobalTools:Div( va.y ,d );
	_new_one.z = GlobalTools:Div( va.z ,d );
	return _new_one
end

FixVector3.__mul = function(va, d)
	local _new_one = _new(0, 0, 0)
	_new_one.x = GlobalTools:Mul( va.x , d );
	_new_one.y = GlobalTools:Mul( va.y , d );
	_new_one.z = GlobalTools:Mul( va.z , d );
	return _new_one
end

FixVector3.__add = function(va, vb)
	return _new_no(va.x + vb.x, va.y + vb.y, va.z + vb.z)
end

FixVector3.__sub = function(va, vb)
	return _new_no(va.x - vb.x, va.y - vb.y, va.z - vb.z)
end

FixVector3.__unm = function(va)
	return _new_no(-va.x, -va.y, -va.z)
end

FixVector3.__eq = function(a,b)
	if b.x == nil or a.x == nil then
		return false;
	end
	if a.x == b.x and a.y == b.y and a.z == b.z then
       return true;
	end
	return false;
end

function FixVector3.up()
	return _new(0,1,0)
end

function FixVector3.forward()
	return _new(0,0,1)
end

function FixVector3.right()
	return _new(1,0,0)
end

function FixVector3.one()
	return _new(1,1,1)
end

function FixVector3.zero()
	return _new(0,0,0)
end

--[[
    @desc: 返回Unity 3D向量类
    author:{author}
    time:2020-01-19 16:51:42
    @return:
]]
function FixVector3:toVector3()
	local x_float = GlobalTools:ToFloat(self.x)
	local y_float = GlobalTools:ToFloat(self.y)
	local z_float = GlobalTools:ToFloat(self.z)
    return Vector3(x_float, y_float, z_float )
end


FixVector3.__tostring = function(self)
	return "["..(self.x or 0)..","..(self.y or 0)..","..(self.z or 0).."]"
end

setmetatable(FixVector3, FixVector3)
return FixVector3