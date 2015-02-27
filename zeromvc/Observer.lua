----------------------------------
-- commandName
-- @field [parent=#Observer] #table target

----------------------------------
--init
--@function [parent=#Observer] init
--@param self #Observer

----------------------------------
--hasListener(type,filename)
--@function [parent=#Observer] hasListener
--@param self #Observer
--@param type #string
--@param filename #string

----------------------------------
--addListener(type,filename)
--@function [parent=#Observer] addListener
--@param self #Observer
--@param type #string
--@param filename #string

----------------------------------
--removeListener(type,filename)
--@function [parent=#Observer] removeListener
--@param self #Observer
--@param type #string
--@param filename #string

----------------------------------
--clearListener(type,filename)
--@function [parent=#Observer] clearListener
--@param self #Observer
--@param type #string
--@param filename #string

----------------------------------
--dispose(type,filename)
--@function [parent=#Observer] dispose
--@param self #Observer
--@param type #string
--@param filename #string

----------------------------------
--notify(notifyType,...)
--@function [parent=#Observer] notify
--@param self #Observer
--@param notifyType #string
--@param ...
--
local Observer=zeromvc.class("Observer")
Observer.target=nil
Observer.pool=nil
Observer.instancePool=nil
function Observer:ctor(prototype,target)
    if target~=nil then
        self.target=target
    else
        self.target=self
    end
    self.pool={}
    self.instancePool={}
end

function Observer:hasListener(type,filename,methodName)
    local happen =false
    if filename ==nil then
        happen = self.pool[type]~=nil
    else
        if self.pool[type]==nil then
            happen=false
        else
            for key, var in ipairs(self.pool[type]) do
                if filename==var.owner and methodName==var.methodName then
                    happen=true
                    break
                end
            end
        end
    end
    return happen
end

function Observer:addListener(type,filename,methodName)

    if methodName==nil then
        methodName="execute"
    end

    local happen =false
    if  self:hasListener(type)==false then
        self.pool[type]={}
        self.instancePool[type]={}
    end
    if  self:hasListener(type,filename,methodName)==false then
        local observerMethod={owner=filename,methodName=methodName}
        table.insert(self.pool[type],observerMethod)
        happen=true
    end
    return happen
end
--不清实例
function Observer:removeListener(type,filename)
    local happen =false
    if  self:hasListener(type) then
        self.pool[type][filename]=nil
    end
    return happen
end

function Observer:clearListener(type,filename)
    local happen =false
    if  self:hasListener(type) then
        self.pool[type]=nil
    end
    return happen
end

function Observer:dispose(type,filename)
    local happen =false
    if filename ==nil then
        if self.instancePool[type]~=nil then
            self.instancePool[type]={}
            happen = true
        else
            happen = false
        end
    else
        if self.instancePool[type][filename]~=nil then
            self.instancePool[type][filename]=nil
            happen = true
        else
            happen = false
        end
    end
    return happen
end

function Observer:notify(type,...)
    local happen = 0;
    if self:hasListener(type) then
        for key , observerMethod in pairs(self.pool[type]) do
            local filename = observerMethod.owner;
            local methodName = observerMethod.methodName;
            local neure
            if self.instancePool[type][filename] ~=nil then
                neure=self.instancePool[type][filename]
            else
                local classType=require(filename)
                neure = classType:new()
                self.instancePool[type][filename]=neure
                if neure._init ~=nil then
                    neure._init(neure,self.target,type,filename)
                end
            end
            if neure[methodName] ~=nil then
                neure[methodName](neure,...)
            else
                print(filename.." "..methodName.." not found")
            end
            happen=happen+1
        end
    else
        print(type.." 命令还要定义")
    end
    return happen
end
return Observer

--function Observer:notify(notifyType,...)
--    local type
--    local method
--    if string.find(notifyType,":") then
--        type=string.sub(notifyType,0,string.find(notifyType,":")-1)
--        method=string.sub(notifyType,string.find(notifyType,":")+1)
--    else
--        type=notifyType
--        method="execute"
--    end
--    local happen = 0;
--    if self:hasListener(type) then
--        for key , filename in pairs(self.pool[type]) do
--            local neure
--            if self.instancePool[type][filename] ~=nil then
--                neure=self.instancePool[type][filename]
--            else
--                local classType=require(filename)
--                neure = classType:new()
--                self.instancePool[type][filename]=neure
--                if neure._init ~=nil then
--                    neure._init(neure,self.target,type,filename)
--                end
--            end
--            if neure[method] ~=nil then
--                neure[method](neure,...)
--            else
--                print(filename.." not found")
--            end
--            happen=happen+1
--        end
--        else
--        print(type.." 命令还要定义")
--    end
--    return happen
--end
--return Observer
