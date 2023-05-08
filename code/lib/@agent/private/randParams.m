function params = randParams (obj)

    v(1) = rand ();
    v(2) = (1 - v(1)) * rand ();
    v(3) = 1 - v(1) - v(2);
    
    v = - v;

    params = struct(                                          ...
        ... mdp
        'discount'               , unifrnd(0 ,1)    , ... % discount factor
        ... transitions
        'prob_getting_dirty'     , unifrnd(0, 1)     , ... % probability of soiling hands while cooking
        'prob_successful_wash'   , unifrnd(0, 1)     , ... % probability of getting hands clean after washing
        ... observations
        'prob_detect_clean'      , unifrnd(0.5, 1)      , ... % probability of correctly detecting that hands are clean
        'prob_detect_dirty'      , unifrnd(0.5, 1)      , ... % probability of correctly detecting that hands are dirty
        ... reward function
        'value_wash'             , v(1)                    , ... % value of washing
        'value_check'            , v(2)                    , ... % value of checking
        'value_cook_dirty'       , v(3)                    , ... % value of cooking with dirty hands
        'value_cook_clean'       , 0                        ... % value of cooking with clean hands
        );

end