function Hash = MyMLCHash(Ind, Params)
%Rework of initioal hashing method

%Code Hashes the requested output equations and states used by those equations only, Unused states are not included in the hash

InHash = Ind.formal;

nReals = Params.controls - Params.problem_variables.nStates; % Number of acuttal output controler variables


%Loop through each output and each state to determine id states are called
Eval = zeros(1,Params.controls); 
Eval(1:nReals) = 1;

Evaled = zeros(1,Params.controls);

while sum(Eval) ~= 0
    for EquNum = 1: Params.controls
        if Eval(EquNum) == 1
            %Check each state
            for State = 1 : Params.problem_variables.nStates
                if contains(InHash{EquNum}, ['S' num2str(Params.problem_variables.nSensors + State - 1)]);
                    if Evaled(State + nReals) == 0
                       Eval(State + nReals) = 1; 
                    end
                end
            end
            Eval(EquNum) = 0;
            Evaled(EquNum) = 1;
        end
    end
end

FinalHash = InHash(Evaled == 1);

bit32 = DataHash(FinalHash);
Hash = hex2num(bit32(1:16));

end 