----------------------------------
-- commandName
-- @field [parent=#Command] #string commandName

----------------------------------
-- type
-- @field [parent=#Command] #string type

----------------------------------
--init
--@function [parent=#Command] init
--@param self #Command 

----------------------------------
--activate
--@function [parent=#Command] activate
--@param self #Command 

----------------------------------
--inactivate
--@function [parent=#Command] inactivate
--@param self #Command 

----------------------------------
--dispose
--@function [parent=#Command] dispose
--@param self #Command 

----------------------------------
--command
--@function [parent=#Command] command
--@param self #Command 
--@param ...

----------------------------------
--getProxy
--@function [parent=#Command] getProxy
--@param self #Command 
--@param proxyFilename #string 

local Command=zeromvc.class("Command")
Command.commandName="Command"
Command.type=""
function Command:ctor(prototype,commandName)
    self.commandName=commandName
end

function Command:dispose()
    self.zero.control:dispose(self.type,self.filename)
end

function Command:_init(zero,type,filename)
    self.zero=zero
    self.type=type
    self.filename=filename
    if self.init~=nil then
        self:init()
    end
end

function Command:activate(key)
    self.zero:activate(key)
end

function Command:inactivate(key)
    self.zero:inactivate(key)
end

function Command:command(key,...)
    self.zero:command(key,...)
end
function Command:getProxy(proxyFilename)
    return self.zero:getProxy(proxyFilename)
end


return Command