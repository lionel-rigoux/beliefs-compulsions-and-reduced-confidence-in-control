# Beliefs, compulsive behavior and reduced confidence in control

This repository contains all the code necessary to reproduce the simulations and analysis of the paper 'Beliefs, compulsive behavior and reduced confidence in control'.

## Requirements

First, make sure you clone this repository including the submodules which are necessary to run the code, all located in `code/third-party`:

```
git clone --recurse-submodules https://github.com/lionel-rigoux/beliefs-compulsions-and-reduced-confidence-in-control.git
```

All the scripts are to be run in Matlab, but depend on a binary executable which can be found in `code/lib/@agent/private/pomdp-solve-*`. Precompiled binaries are provided for MacOS and Unix. If you need to run this code on another machine, you will need to compile the code in `code/third-party/pompdp-solve-5.4` and replace the executable in the `@agent/private` folder. 

## Tutorial

The main building block of this code is the `agent` object. Methods of this objects allow to initialise the POMDP problem, optimize the policy, then simulate and diagnose the resulting behaviour. See [code/lib/](code/lib/) for more details.

A [demo code](code/demo.m) provides a minimal working example demonstrating how to 1) create a new world, 2) define an agent with an underestimation of the success of washing, and 3) quantify and visualize the compulsive behaviour resulting from this belief distortion.

## Manuscript

The set of simulations reported in the paper can be regenerated by running `code/simulations/main.m`. The number of worlds/agents/simulations to be run, defined in `code/simulations/config.yaml`, is here set to the bare minimum to allow the pipeline to run on a desktop computer. However, in order to reproduce the data as reported in the paper, those numbers need to be scaled up as follow:

```
N_WORLDS: 100
N_AGENTS_PER_GROUP: 50
N_SIMULATIONS: 200
T_SIMULATIONS: 1000
```

Note that depite the fact that the code is parallelized (if you have the Parallel Toolbox for Matlab), the complete simulation can take up to two weeks on a high performance cluster. 

The analysis of the simulations can be performed in one go by running `code/analyses/main.m`. The first step of this routine is to cleanup the simulations into simpler summary files in `code/analyses/scratch`. If you do not want to run the simulations yourself, you can download pre-made summary files from the [release page](https://github.com/lionel-rigoux/beliefs-compulsions-and-reduced-confidence-in-control/releases) in the `scratch` folder before running the `main.m` script.

Note that the analysis pipeline will generate plots, tables, and markdown files which will be saved (overriding existing files) in the `/figures`, `/tables`, and `/texts` folder respectively.

An exaustive overview of all the generated results can be exported to pdf using [pandemics](https://pandemics.gitlab.io/) by running `pandemics publish report.md` in this directory.
