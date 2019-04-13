%DYN_SYS2    parameters script for MLC
%    Type mlc=MLC('dyn_sys2') to create corresponding MLC object
parameters.size=1000;
parameters.sensors=3;
parameters.controls=3;
parameters.range=10;
parameters.precision=4;
parameters.opsetrange=[1 2 3];
parameters.maxdepth=15;
parameters.maxdepthfirst=5;
parameters.mindepth=2;
parameters.mutmindepth=2;
parameters.mutmaxdepth=15;
parameters.mutsubtreemindepth=2;
parameters.generation_method='mixed_ramped_gauss';
parameters.gaussigma=3;
parameters.ramp=[2 3 4 5 6 7 8];
parameters.elitism=1;
parameters.probrep=0.1;
parameters.probmut=0.2;
parameters.procro=0.7;
parameters.selectionmethod='fitness_proportional';
parameters.tournamentsize=7;
parameters.lookforduplicates=1;
parameters.simplify=0;
parameters.badvalues_elimswitch=1;
parameters.evaluation_method='multithread_function';
parameters.evaluation_function='dyn_sys_problem';
parameters.indfile='ind.dat';
parameters.Jfile='J.dat';
parameters.exchangedir='/home/tduriez/Dropbox/GP/MLC_withclasses_v4.0/@MLC/evaluator0';
parameters.evaluate_all=0;
parameters.artificialnoise=0;
parameters.execute_before_evaluation='delete my_lyapunov_ev*';
parameters.badvalue=1e+36;
parameters.badvalues_elim='none';
parameters.save=1;
parameters.verbose=[0 0 0 0 0 0];
parameters.fgen=250;
parameters.show_best=1;










