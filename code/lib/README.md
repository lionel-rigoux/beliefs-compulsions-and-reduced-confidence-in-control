# Agent

## Create new agent with veridical parameters

```matlab
allow_no_check = true;
a = agent (allow_no_check);
```

## Randomly pertub subjective parameters

```matlab
% all parameters 
a.changeSubjective ()
% single parameters
a.changeSubjective ('prob_successful_wash')
% display delta between subjective and world parameters
a.getDelta ()
```

## Run N simulations of length T for a given agent

```matlab
a.simulate (N,T);
```

## Assess compulsion metrics, etc.

```matlab
a.diagnose ();
```
