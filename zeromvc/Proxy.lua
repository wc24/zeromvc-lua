----------------------------------
--bind
--@function [parent=#Proxy] bind
--@param self #Proxy 
--@param mediatorType #string
--@param callBack #function 

----------------------------------
--bind
--@function [parent=#Proxy] unbind
--@param self #Proxy 
--@param mediatorType #string
--@param callBack #function 


----------------------------------
--update
--@function [parent=#Proxy] update
--@param self #Proxy 

local Proxy=zeromvc.class("Proxy")
function Proxy:ctor(prototype)
    self.pool = {}
end
function Proxy:bind(mediatorType,callback)
    self.pool[mediatorType]=callback
end

function Proxy:unbind(mediatorType,callback)
    self.pool[mediatorType]=callback
end

function Proxy:update()
    for mediatorType, callback in pairs(self.pool) do
    	callback(self)
    end
end

return Proxy