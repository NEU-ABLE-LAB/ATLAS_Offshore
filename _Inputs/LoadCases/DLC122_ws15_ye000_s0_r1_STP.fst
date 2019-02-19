------- FAST v8.16.* INPUT FILE ------------------------------------------------
FAST Certification Test #24: NREL 5.0 MW Baseline Wind Turbine with OC3 Hywind Configuration, for use in offshore analysis
---------------------- SIMULATION CONTROL --------------------------------------
False         Echo            - Echo input data to <RootName>.ech (flag)
"FATAL"       AbortLevel      - Error level when simulation should abort (string) {"WARNING", "SEVERE", "FATAL"}
1200 TMax            - Total run time (s)
     0.0125   DT              - Recommended module time step (s)
          1   InterpOrder     - Interpolation order for input/output time history (-) {1=linear, 2=quadratic}
          0   NumCrctn        - Number of correction iterations (-) {0=explicit calculation, i.e., no corrections}
        1.5   DT_UJac         - Time between calls to get Jacobians (s)
      1E+06   UJacSclFact     - Scaling factor used in Jacobians (-)
---------------------- FEATURE SWITCHES AND FLAGS ------------------------------
          1   CompElast       - Compute structural dynamics (switch) {1=ElastoDyn; 2=ElastoDyn + BeamDyn for blades}
          1   CompInflow      - Compute inflow wind velocities (switch) {0=still air; 1=InflowWind; 2=external from OpenFOAM}
          2   CompAero        - Compute aerodynamic loads (switch) {0=None; 1=AeroDyn v14; 2=AeroDyn v15}
          1   CompServo       - Compute control and electrical-drive dynamics (switch) {0=None; 1=ServoDyn}
          1   CompHydro       - Compute hydrodynamic loads (switch) {0=None; 1=HydroDyn}
          0   CompSub         - Compute sub-structural dynamics (switch) {0=None; 1=SubDyn}
          1   CompMooring     - Compute mooring system (switch) {0=None; 1=MAP++; 2=FEAMooring; 3=MoorDyn; 4=OrcaFlex}
          0   CompIce         - Compute ice loads (switch) {0=None; 1=IceFloe; 2=IceDyn}
---------------------- INPUT FILES ---------------------------------------------
"DLC122_ws15_ye000_s0_r1_STP_ED.dat" EDFile          - Name of file containing ElastoDyn input parameters (quoted string)
"NA"    BDBldFile(1)    - Name of file containing BeamDyn input parameters for blade 1 (quoted string)
"NA"    BDBldFile(2)    - Name of file containing BeamDyn input parameters for blade 2 (quoted string)
"NA"    BDBldFile(3)    - Name of file containing BeamDyn input parameters for blade 3 (quoted string)
"DLC122_ws15_ye000_s0_r1_STP_IW.dat" InflowFile      - Name of file containing inflow wind input parameters (quoted string)
"TestCase_AD15.05.dat"    AeroFile        - Name of file containing aerodynamic input parameters (quoted string)
"DLC122_ws15_ye000_s0_r1_STP_SD.dat" ServoFile       - Name of file containing control and electrical-drive input parameters (quoted string)
"DLC122_ws15_ye000_s0_r1_STP_HD.dat" HydroFile       - Name of file containing hydrodynamic input parameters (quoted string)
"NA"      SubFile         - Name of file containing sub-structural input parameters (quoted string)
"TestCase_MAP.dat"    MooringFile     - Name of file containing mooring system input parameters (quoted string)
"NA"      IceFile         - Name of file containing ice input parameters (quoted string)
---------------------- OUTPUT --------------------------------------------------
False          SumPrint        - Print summary data to "<RootName>.sum" (flag)
          1   SttsTime        - Amount of time between screen status messages (s)
      99999   ChkptTime       - Amount of time between creating checkpoint files for potential restart (s)
     0.0125   DT_Out          - Time step for tabular output (s) (or "default")
          0   TStart          - Time to begin tabular output (s)
          2   OutFileFmt      - Format for tabular (time-marching) output file (switch) {1: text file [<RootName>.out], 2: binary file [<RootName>.outb], 3: both}
True          TabDelim        - Use tab delimiters in text tabular output file? (flag) {uses spaces if false}
"ES10.3E2"    OutFmt          - Format used for text tabular output, excluding the time channel.  Resulting field should be 10 characters. (quoted string)
---------------------- LINEARIZATION -------------------------------------------
False         Linearize       - Linearization analysis (flag)
          2   NLinTimes       - Number of times to linearize (-) [>=1] [unused if Linearize=False]
         30,         60    LinTimes        - List of times at which to linearize (s) [1 to NLinTimes] [unused if Linearize=False]
          1   LinInputs       - Inputs included in linearization (switch) {0=none; 1=standard; 2=all module inputs (debug)} [unused if Linearize=False]
          1   LinOutputs      - Outputs included in linearization (switch) {0=none; 1=from OutList(s); 2=all module outputs (debug)} [unused if Linearize=False]
False         LinOutJac       - Include full Jacobians in linearization output (for debug) (flag) [unused if Linearize=False; used only if LinInputs=LinOutputs=2]
False         LinOutMod       - Write module-level linearization output files in addition to output for full system? (flag) [unused if Linearize=False]
---------------------- VISUALIZATION ------------------------------------------
          0   WrVTK           - VTK visualization data output: (switch) {0=none; 1=initialization data only; 2=animation}
          2   VTK_type        - Type of VTK visualization data: (switch) {1=surfaces; 2=basic meshes (lines/points); 3=all meshes (debug)} [unused if WrVTK=0]
false         VTK_fields      - Write mesh fields to VTK data files? (flag) {true/false} [unused if WrVTK=0]
         15   VTK_fps         - Frame rate for VTK output (frames per second){will use closest integer multiple of DT} [used only if WrVTK=2]
