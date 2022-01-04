# [THE ARPA-E ATLAS Offshore Wind Challenge COMPETITION](https://arpa-e.energy.gov/?q=site-page/atlas-competition)
The Advanced Research Projects Agency – Energy (ARPA-E) of the U.S. Department of Energy is challenging the research and industrial communities to discover, develop, and test innovative and disruptive Control Co-Design solutions for critical wind energy challenges. The ATLAS (Aerodynamic Turbines with Load Attenuation Systems) Competition is the first ARPA-E effort associated with this advanced design methodology. 

# Purpose
This repository contains the machine learning control (MLC) framework for an attempt at creating a MLC based controller for the atlas competition in 2019. The MLC Framework is based on:

https://github.com/MachineLearningControl/OpenMLC-Matlab

The MLC object used in an upcoming paper can be obtained by reaching out to the developers, as it is not stored on the repository due to file size. 


# Git Repository Structure
Large input and output files are not included in the repository to better manage space. Specifically the following files and folders are included in `.gitignore` and can be downloaded from the ABLE_ATLAS_OffShore Google Team Drive. **You must download these files after cloning the repository.** Additional smaller input and output files are included in the repository. 

  * `_Inputs/LoadCases/Turb/*` (~152MB) - Turbine Load Cases. Additional load cases may be created as described in [Section 5.1](ATLAS-modeling-control-simulation-final.pdf)
	
	* `_BaselineResults/*` (~112MB) - contains output files for the various load cases from simulations using the NREL Baseline Controller Simulink model. The contents of this folder are already populated with the baseline controller results, which have already been simulated for use by the participants in judging their own controller results. *The contents of this folder should not be modified.*
	
	* `_Outputs/*` (~112MB)- collects the output files for the simulated load cases. This depends on the particular challenge selected for simulation as will be described below. The output files are named `x.SFunc.outb`, where the load case name is substituted for the symbol `x` in the file name. The outputs files can be visualized using the tool pyDatview or using the matlab function `_Functions\fReadFASTBinary.m`. *The folder `_Outputs` is automatically updated with the participant output files.* Results from key outputs are uploaded to the Google Drive.

# Setup
Once this repo is cloned, the Fast-Par Repo must be downloaded as well [https://github.com/NEU-ABLE-LAB/ATLAS_FAST-par/tree/MLC_Development]. 

Additionaly the following Directories need to be specified within the scripts: 

* This Repo, MLC_Settings, Line 31:    Should be the full path to the Atlas Fast Par MLC Development folder

* Fast-Par Repo, Main_Par_MLC, Line 10:  Should be the full path to the "OpenMLC-Matlab-2" folder in the MLC Ofshore repo.

* The Default Pre-Eval function /MLC_ProblemFunctions/Files/MLC_PreEval.mdl is a 2020 file and will not run on prior versions of Matlab. THe MLC_PreEval2018.mdl file can be used on MAtlab 2018 B or later. the file used can be changed in MLC_preeval.m Line 32


# Running MLC Program
The program can be run useing the parameters established in the `MLC_Setings.m` script by running the script. If an MLC Object is already created the object can be loaded into the Matlab workspace and the comand `mlc.go()` can be used to initiate the learning process 
