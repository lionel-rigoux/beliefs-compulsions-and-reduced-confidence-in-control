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

        function obj = agent (varargin)
            % a = agent () create an agent 
            % by default, all parameters are random and policy is full
            % a = agent (true): allow for policies without any check
            % a = agents (params): set world parameters to params
            if ~ isempty (varargin) 
                if islogical (varargin{1})            
                    obj.allow_no_check = varargin{1};
                elseif isstruct (varargin{1})
                    params = varargin{1};
                end
            end

            if exist ("params","var")
                obj.params.world = params;
                obj.optimizePolicy ();
            else
                while ~ obj.isFullPolicy ()
                    obj.params.world = randParams ();
                    obj.optimizePolicy ();
                end
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
        
        function changeSubjective (obj, paramName, paramValue)
            obj.policy = [];
            if nargin == 3
                obj.params.subjective = obj.params.world;
                obj.params.subjective.(paramName) = paramValue;
                obj.optimizePolicy ();
                return
            end
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

