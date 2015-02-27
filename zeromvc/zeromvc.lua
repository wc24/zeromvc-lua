----------------------------------
-- zeromvc
-- @field [parent=#global] zeromvc#zeromvc zeromvc

----------------------------------
-- Proxy
-- @field [parent=#zeromvc] Proxy#Proxy Proxy

----------------------------------
-- Command
-- @field [parent=#zeromvc] Command#Command Command

----------------------------------
-- Mediator
-- @field [parent=#zeromvc] Mediator#Mediator Mediator

----------------------------------
-- Observer
-- @field [parent=#zeromvc] Observer#Observer Observer

----------------------------------
--class
-- @function [parent=#zeromvc] class
-- @param #string classname
-- @param #Obejct super
-- @return table#table


----------------------------------
--classMediator
-- @function [parent=#zeromvc] classMediator
-- @param #string classname
-- @return Mediator#Mediator

----------------------------------
--classCommand
-- @function [parent=#zeromvc] classCommand
-- @param #string classname
-- @return Command#Command

----------------------------------
--classProxy
-- @function [parent=#zeromvc] classProxy
-- @param #string classname
-- @return Proxy#Proxy

----------------------------------
--classObserver
-- @function [parent=#zeromvc] classObserver
-- @param #string classname
-- @return Observer#Observer

----------------------------------
--classZero
-- @function [parent=#zeromvc] classZero
-- @param #string classname
-- @return Zero#Zero

zeromvc={}
function zeromvc.class(classname, SuperClass)
    local cls={}
    cls.ctor = function(self,prototype,...)
        if prototype.SuperClass and prototype.SuperClass.ctor then
            self:super(prototype,...)
        end
      end
    cls.__cname = "Class:"..classname
    cls.SuperClass = SuperClass
    if SuperClass==nil then
        cls.__create = function()
            return {}
        end
    elseif SuperClass.__create~=nil then
        cls.__create = function(...)
            local instance = SuperClass:__create(...)
            for key,var in pairs(SuperClass) do
                instance[key] = var
            end
            return instance
        end
    elseif (SuperClass[".isclass"] or SuperClass.__ctype == 1) then
        cls.__create = function()
            return SuperClass:create()
        end
    else
        print("不知道什么情况")
    end
    --    setmetatable(cls, {__index = cls.SuperClass})
    setmetatableindex(cls, cls.SuperClass)
    cls.new = function(...)
        local instance
        if cls.__create then
            instance = cls.__create(...)
        else
            instance = {}
        end
        for key,var in pairs(cls) do
            instance[key] = var
        end
        setmetatableindex(instance, cls)
        instance.class = cls
        instance.__cname = classname
        instance:ctor(...)
        return instance
    end
    cls.super = function(self,prototype,...)
        prototype.SuperClass.ctor(self,prototype.SuperClass,...)
    end
    
    return cls
end

zeromvc.Proxy=require("zeromvc.Proxy")
zeromvc.Command=require("zeromvc.Command")
zeromvc.Mediator=require("zeromvc.Mediator")
zeromvc.Observer=require("zeromvc.Observer")
zeromvc.Zero=require("zeromvc.Zero")

zeromvc.classProxy=function(className)
    return zeromvc.class(className,zeromvc.Proxy)
end
zeromvc.classCommand=function(className)
    return zeromvc.class(className,zeromvc.Command)
end
zeromvc.classMediator=function(className)
    return zeromvc.class(className,zeromvc.Mediator)
end
zeromvc.classObserver=function(className)
    return zeromvc.class(className,zeromvc.Observer)
end
zeromvc.classZero=function(className)
    return zeromvc.class(className,zeromvc.Zero)
end

