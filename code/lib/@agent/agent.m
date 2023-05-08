classdef agent < matlab.mixin.Copyable
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        params = struct('world',[],'subjective',[]);
        pomdp = struct('world',[],'subjective',[]);
        policy
        simulation
        diagnostic
        log
        allow_no_check = false;
    end
    
    methods
        function obj = agent (allow_no_check)
            if nargin == 1
                obj.allow_no_check = allow_no_check;
            end
            while ~ obj.isFullPolicy ()
                obj.params.world = randParams ();
                obj.optimizePolicy ();
            end
        end
        
        function flag = isFullPolicy (obj)
            if isempty (obj.policy)
                flag = false;
                return;
            end
            if obj.allow_no_check
                flag = all(ismember([1,3],obj.policy.action));
            else
                flag = all(ismember([1,2,3],obj.policy.action));
            end
        end
        
        function changeSubjective (obj, paramName)
            obj.policy = [];
            while ~ obj.isFullPolicy ()
                newParams = randParams ();
                if nargin < 2
                    obj.params.subjective = newParams;
                else              
                    % use true params
                    obj.params.subjective = obj.params.world;
                    % except for param of interest
                    obj.params.subjective.(paramName) = newParams.(paramName);
                    
                    % renormalise values 
                    values = [obj.params.subjective.value_wash obj.params.subjective.value_check obj.params.subjective.value_cook_dirty];
                    z = abs(sum(values));                    
                    
                    obj.params.subjective.value_wash = values(1) / z;
                    obj.params.subjective.value_check = values(2) / z;
                    obj.params.subjective.value_cook_dirty = values(3) / z;               
                end
                obj.optimizePolicy ();
            end
            
        end
    end
    
    
end

