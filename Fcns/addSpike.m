function [newSpikeTrain, newTrace, newLL] = addSpike(oldSpikeTrain,oldTrace,oldLL,filter,amp,tau,obsTrace,timeToAdd,indx,Dt,A,timeToAdd_warped)

    tau_h = tau(1);
    tau_d = tau(2);

    ef_h = filter{1};
    ef_d = filter{2};

    %     newSpikeTrain = [oldSpikeTrain timeToAdd]; %possibly inefficient, change if problematic (only likely to be a problem for large numbers of spikes)
    newSpikeTrain = [oldSpikeTrain(1:indx-1) timeToAdd oldSpikeTrain(indx:end)]; %adds in place rather than at end

    %use infinite precision to scale the precomputed FIR approximation to the transient
    wk_h = amp*A*exp((timeToAdd_warped - Dt*ceil(timeToAdd_warped/Dt))/tau_h);
    wk_d = amp*A*exp((timeToAdd_warped - Dt*ceil(timeToAdd_warped/Dt))/tau_d);
    
    %%%%%%%%%%%%%%%%%
    %handle ef_h first
    newTrace = oldTrace;
    tmp = 1 + (floor(timeToAdd_warped):min((length(ef_h)+floor(timeToAdd_warped)-1),length(newTrace)-1));
    newTrace(tmp) = newTrace(tmp) + wk_h*ef_h(1:length(tmp));

    %if you really want to, ef*ef' could be precomputed and passed in
    relevantResidual = obsTrace(tmp)-oldTrace(tmp);
    newLL = oldLL - ( wk_h^2*norm(ef_h(1:length(tmp)))^2 - 2*relevantResidual*(wk_h*ef_h(1:length(tmp))'));
    oldTrace = newTrace;
    oldLL = newLL;
    %%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%
    %handle ef_d next
    tmp = 1 + (floor(timeToAdd_warped):min((length(ef_d)+floor(timeToAdd_warped)-1),length(newTrace)-1));
    newTrace(tmp) = newTrace(tmp) + wk_d*ef_d(1:length(tmp));

    %if you really want to, ef*ef' could be precomputed and passed in
    relevantResidual = obsTrace(tmp)-oldTrace(tmp);
    newLL = oldLL - ( wk_d^2*norm(ef_d(1:length(tmp)))^2 - 2*relevantResidual*(wk_d*ef_d(1:length(tmp))'));

%     newLL = -sum((newTrace-obsTrace).^2);
