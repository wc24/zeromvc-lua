local Zero=zeromvc.class("Zero")
Zero.model=nil
Zero.view=nil
Zero.control=nil
function Zero:ctor(prototype,commandName)
    self.model={}
    self.view=zeromvc.Observer:new(self)
    self.control=zeromvc.Observer:new(self)
    self.mediatorKeyGroup={}
end


function Zero:addCommand(key,commandClass,methodName)
    self.control:addListener(key,commandClass,methodName)
end

function Zero:removeCommand(key,commandClass)
    self.control:removeListener(key,commandClass)
end

function Zero:addMediator(key,mediatorClass)
    self.view:addListener(key, mediatorClass);
end

function Zero:removeMediator(key,mediatorClass)
    self.view:addListener(key, mediatorClass);
end

function Zero:inactivate(key)
    self.view:notify(key,false);

end

function Zero:activate(key)
    self.view:notify(key,true);
end
function Zero:notify(key,...)
    self.control:notify(key,...)
end
function Zero:command(key,...)
    self.control:notify(key,...)
end

function Zero:getProxy(proxyFilename)
    local proxy = self.model[proxyFilename]
    if proxy==nil then
    	proxy= require(proxyFilename):new()
    	self.model[proxyFilename]=proxy
    end
    return proxy
end

return Zero