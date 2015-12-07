function [newSpikeTrain, newTrace, newLL] = removeSpike_ar(oldSpikeTrain,oldTrace,oldLL,filter,amp,tau,obsTrace,timeToRemove,indx,Dt,A,baseline)
    
    if nargin<12
        baseline = zeros(size(oldTrace));
    end
    
    tau_h = tau(1);
    tau_d = tau(2);
    
    ef_h = filter{1};
    ef_d = filter{2};
    
    newSpikeTrain = oldSpikeTrain;
    newSpikeTrain(indx) = [];
    
    %use infinite precision to scale the precomputed FIR approximation to the calcium transient    
    wk_h = amp*A*exp((timeToRemove - Dt*ceil(timeToRemove/Dt))/tau_h);
    wk_d = amp*A*exp((timeToRemove - Dt*ceil(timeToRemove/Dt))/tau_d);
    
    
    %%%%%%%%%%%%%%%%%
    %handle ef_h first
    newTrace = oldTrace;
    tmp = 1+ (floor(timeToRemove):min((length(ef_h)+floor(timeToRemove)-1),length(newTrace)-1));
    newTrace(tmp) = newTrace(tmp) - wk_h*ef_h(1:length(tmp));

    %if you really want to, ef*ef' could be precomputed and passed in
%     relevantResidual = obsCalcium(tmp)-oldCalcium(tmp);
%     newLL = oldLL - ( wk_h^2*norm(ef_h(1:length(tmp)))^2 + 2*relevantResidual*(wk_h*ef_h(1:length(tmp))'));
    newLL = oldLL;
    newLL(tmp) = obsTrace(tmp) - (newTrace(tmp) + baseline(tmp));

    
    oldTrace = newTrace;            
    %%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%
    %handle ef_d next
    tmp = 1+ (floor(timeToRemove):min((length(ef_d)+floor(timeToRemove)-1),length(newTrace)-1));
    newTrace(tmp) = newTrace(tmp) - wk_d*ef_d(1:length(tmp));

    %if you really want to, ef*ef' could be precomputed and passed in
    relevantResidual = obsTrace(tmp)-oldTrace(tmp);
    newLL(tmp) = obsTrace(tmp) - (newTrace(tmp) + baseline(tmp));

    