---------------------------------------------------------------------------------------------------------------
-- zeromvc lua 完整版
--

-- 创建lua类------------------------------------------------------------------------------------------- createClass
local classPool = {}
local function createClass(classname, superClass)
    local zeroClass = {}
    zeroClass.superClass = superClass
    zeroClass.classname = classname
    zeroClass.__cname = classname
    if superClass == nil then
    else
        setmetatable(zeroClass, { __index = superClass })
    end
    zeroClass.new = function(...)
        local instance = {}
        for key, var in pairs(zeroClass) do
            instance[key] = var
        end
        setmetatable(instance, { __index = zeroClass })
        instance.class = zeroClass
        instance:ctor(...)
        return instance
    end
    zeroClass.super = function(self, ...)
        self.superClass.ctor(self, ...)
    end
    classPool[classname] = zeroClass
    return zeroClass
end

--从反射表中取得类
local function getClass(className)
    return classPool[className] or require(className)
end

--从反射表中新建实例
local function new(className, ...)
    return getClass(className):new(...)
end

-- 伪单例观察者------------------------------------------------------------------------------------------- Observer
local Observer = createClass("Observer")
function Observer:ctor(prototype, target)
    self:reset(target)
end

--检测监听
function Observer:hasListener(type, className, methodName)
    if className ~= nil then
        return self.pool[type] ~= nil and self.pool[type][className] == methodName or "execute"
    else
        if self.pool[type] ~= nil then
            for k, v in pairs(self.pool[type]) do
                if v ~= nil then
                    return true
                end
            end
        end
        return false
    end
end

--添加监听
function Observer:addListener(type, className, methodName)
    if self.pool[type] == nil then
        self.pool[type] = {}
    end
    self.pool[type][className] = methodName or "execute";
end

--移除监听
function Observer:removeListener(type, className)
    if self.pool[type] ~= nil then
        self.pool[type][className] = nil;
    end
end

--消除type类型下所有临听
function Observer:clearListener(type)
    self.pool[type] = nil
end

--释放 释放无法再使用
function Observer:dispose()
    self.pool = nil
    self.instancePool = nil
end

--重置
function Observer:reset(target)
    self.pool = {}
    self.target = target or self
    self.instancePool = {}
end

--消除缓存
function Observer:clear(className)
    self.instancePool[className] = nil
end

--通知
function Observer:notify(key, ...)
    local happen = 0;
    local methods = self.pool[key]
    assert(type(key) == "string", "notify 第一个参数格式不对")
    if methods == nil then
        print(key .. " 命令未定义")
    else
        for k, v in pairs(methods) do
            self:callSingle(key, k, v, ...)
            happen = happen + 1
        end
    end
    return happen
end

--调用伪单例（伪单例针对本实例一个类有且只有一个实例）
function Observer:callSingle(key, className, methodName, ...)
    local neure = self.instancePool[className]
    if neure == nil then
        local classType = getClass(className)
        assert(classType.classname ~= nil, "文件：" .. className .. " 不是类文件")
        neure = classType:new(self.target, className)
        self.instancePool[className] = neure
        if neure.init ~= nil then
            neure:init()
        end
    end
    neure.key = key
    local method = neure[methodName or "execute"]
    if method ~= nil then
        method(neure, ...)
    end
    neure = nil
end

-- mvc框架主类--------------------------------------------------------------------------------------------- Zero
local Zero = createClass("Zero")
Zero.model = nil
Zero.view = nil
Zero.control = nil
function Zero:ctor(prototype)
    self.model = {}
    self.view = Observer:new(self)
    self.control = Observer:new(self)
end

--添加逻辑
function Zero:addCommand(key, className, methodName)
    self.control:addListener(key, className, methodName)
end

--移除逻辑
function Zero:removeCommand(key, className)
    self.control:removeListener(key, className)
end

--添加视图
function Zero:addMediator(key, className)
    self.view:addListener(key, className, nil);
end

--移除视图
function Zero:removeMediator(key, className)
    self.view:removeListener(key, className);
end

--调用视图方法,（用于框架扩展不建议在罗辑中建议）
function Zero:callView(key, ...)
    self.view:notify(key, ...)
end

--激活视图
function Zero:activate(key, ...)
    self.view:notify(key, nil, ...)
end

--删除视图
function Zero:inactivate(key)
    self.view:notify(key, "clear")
end

--调用指命
function Zero:command(key, ...)
    self.control:notify(key, ...)
end

--释放 释放无法再使用
function Zero:dispose()
    self.model = nil
    self.view:dispose()
    self.control:dispose()
end

--一次性调用立马释放
function Zero:commandOne(className, methodName, ...)
    self.control:callSingle(nil, className, methodName, ...)
end

--获取数据
function Zero:getProxy(proxyName)
    local proxy = self.model[proxyName]
    if proxy == nil then
        local ProxyFile = getClass(proxyName)
        if ProxyFile == nil then
            proxy = {}
            print("新建代理数据" .. proxyName)
        else
            proxy = ProxyFile:new()
        end
        self.model[proxyName] = proxy
    end
    return proxy
end

-- 逻辑代码基类------------------------------------------------------------------------------------------ Command
local Command = createClass("Command")
function Command:ctor(prototype, zero, commandName)
    self.zero = zero
    self.commandName = commandName
end

--清理 清理后再次执行会重新初始化
function Command:clear()
    self.zero.control:clear(self.commandName)
end

--释放 释放后再次执行本逻辑不反应
function Command:dispose()
    self:clear()
    self.zero.control:removeListener(self.key, self.commandName)
end

--执行命令
function Command:command(key, ...)
    self.zero:command(key, ...)
end

--获取数据
function Command:getProxy(proxyName)
    return self.zero:getProxy(proxyName)
end

-- 视图代码基类--------------------------------------------------------------------------------------------- Mediator
local Mediator = createClass("Mediator")
function Mediator:ctor(prototype, zero, mediatorKey)
    self._pool = {}
    setmetatable(self._pool, { __mode = "k" });
    self.zero = zero
    self.mediatorKey = mediatorKey
    --    if self.init ~= nil then
    --        self:init()
    --    end
end

--实现执行方法
function Mediator:execute(method, ...)
    if method and self[method] then
        self[method](...)
    end
end

--添加关心数据
function Mediator:addProxy(proxy, callBack)
    proxy:bind(self, callBack);
    self._pool[proxy] = callBack
end

--移除关心数据
function Mediator:removeProxy(proxy)
    proxy:unbind(self)
    self._pool[proxy] = nil
end

--清理 清理后所有关心数据都不关心  清理后再次执行会重新初始化
function Mediator:clear()
    for proxy, callBack in pairs(self._pool) do
        self:removeProxy(proxy)
    end
    self.zero.view:clear(self.mediatorKey)
end

--释放
function Mediator:dispose()
    self:clear()
    self.zero.view:removeListener(self.key, self.mediatorKey)
end

--执行
function Mediator:command(key, ...)
    self.zero:command(key, ...)
end

--获取数据
function Mediator:getProxy(proxyKey)
    return self.zero:getProxy(proxyKey)
end

-- 数据基业--------------------------------------------------------------------------------------------- Proxy
local Proxy = createClass("Proxy")
function Proxy:ctor(prototype)
    self._pool = {}
    setmetatable(self._pool, { __mode = "k" });
    if self.init ~= nil then
        self:init()
    end
end

--绑定
function Proxy:bind(mediator, callback)
    self._pool[mediator] = callback
end

--解除绑定
function Proxy:unbind(mediator)
    self._pool[mediator] = nil
end

--更新
function Proxy:update(...)
    for mediator, callback in pairs(self._pool) do
        callback(mediator, self, ...)
    end
end

-- lua 框架整合--------------------------------------------------------------------------------------------- zeromvc
local zeromvc = {}
zeromvc.createClass = createClass
zeromvc.getClass = getClass
zeromvc.new = new
zeromvc.Zero = Zero
zeromvc.Observer = Observer
zeromvc.Command = Command
zeromvc.Mediator = Mediator
zeromvc.Proxy = Proxy
function zeromvc.classProxy(className)
    return createClass(className, Proxy)
end

function zeromvc.classCommand(className)
    return createClass(className, Command)
end

function zeromvc.classMediator(className)
    return createClass(className, Mediator)
end

function zeromvc.classObserver(className)
    return createClass(className, Observer)
end

function zeromvc.classZero(className)
    return createClass(className, Zero)
end

return zeromvc
