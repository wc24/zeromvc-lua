----------------------------------
-- Observer
-- @field [parent=#Mediator] #string type

----------------------------------
--init
--@function [parent=#Mediator] init
--@param self #Mediator 

----------------------------------
--addProxy
--@function [parent=#Mediator] addProxy
--@param self #Mediator 
--@param proxy Proxy#Proxy
--@param callBack #function 

----------------------------------
--removeProxy
--@function [parent=#Mediator] removeProxy
--@param self #Mediator 
--@param proxy Proxy#Proxy

----------------------------------
--activate
--@function [parent=#Mediator] activate
--@param self #Mediator 

----------------------------------
--inactivate
--@function [parent=#Mediator] inactivate
--@param self #Mediator 

----------------------------------
--dispose
--@function [parent=#Mediator] dispose
--@param self #Mediator 

----------------------------------
--command
--@function [parent=#Mediator] command
--@param self #Mediator 
--@param ...

----------------------------------
--getProxy
--@function [parent=#Mediator] getProxy
--@param self #Mediator 
--@param proxyFilename #string 


local Mediator=zeromvc.class("Mediator")
Mediator.group=nil
Mediator.type=nil
Mediator.pool=nil
function Mediator:ctor(prototype,group)
    self.group=group
    self.pool={}
end

function Mediator:_init(zero,type,filename)
    self.zero=zero
    self.type=type
    self.filename=filename
    if self.init~=nil then
        self:init()
    end
end

function Mediator:execute(isShow)
    if isShow then
        self:_activate()
    else
        self:_inactivate()
    end
end

function Mediator:addProxy(proxy,callBack)
    self.pool[proxy]=callBack
end

function Mediator:removeProxy(proxy)
    self.pool[proxy]=nil
end
function Mediator:_activate()
    if self.group~=nil then
        if self.zero.mediatorKeyGroup[self.group]~=nil then
            self.zero:inactivate(self.zero.mediatorKeyGroup[self.group])
        end
        self.zero.mediatorKeyGroup[self.group]=self.type
    end
    for proxy,callBack in pairs(self.pool) do
        proxy:bind(self.type,callBack);
    end

    if self.activate~=nil then
        self:activate()
    end
end

function Mediator:_inactivate()
    for proxy,callBack in ipairs(self.pool) do
        proxy:unbind(self.type,callBack);
    end

    if self.inactivate~=nil then
        self:inactivate()
    end
end

function Mediator:dispose()
    self.zero:inactivate(self.type);
    self.zero.view:dispose(self.type);
end

function Mediator:command(key,...)
    self.zero:command(key,...)
end
function Mediator:getProxy(proxyFilename)
    return self.zero:getProxy(proxyFilename)
end

return Mediator