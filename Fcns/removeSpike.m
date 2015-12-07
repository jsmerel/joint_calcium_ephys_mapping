function [newSpikeTrain, newCalcium, newLL] = removeSpike(oldSpikeTrain,oldCalcium,oldLL,filter,amp,tau,obsCalcium,timeToRemove,indx,Dt,A,timeToRemove_warped)
    
    tau_h = tau(1);
    tau_d = tau(2);
    
    ef_h = filter{1};
    ef_d = filter{2};
    
    newSpikeTrain = oldSpikeTrain;
    newSpikeTrain(indx) = [];
    
    %use infinite precision to scale the precomputed FIR approximation to the calcium transient    
    wk_h = amp*A*exp((timeToRemove_warped - Dt*ceil(timeToRemove_warped/Dt))/tau_h);
    wk_d = amp*A*exp((timeToRemove_warped - Dt*ceil(timeToRemove_warped/Dt))/tau_d);
    
    
    %%%%%%%%%%%%%%%%%
    %handle ef_h first
    newCalcium = oldCalcium;
    tmp = 1+ (floor(timeToRemove_warped):min((length(ef_h)+floor(timeToRemove_warped)-1),length(newCalcium)-1));
    newCalcium(tmp) = newCalcium(tmp) - wk_h*ef_h(1:length(tmp));

    %if you really want to, ef*ef' could be precomputed and passed in
    relevantResidual = obsCalcium(tmp)-oldCalcium(tmp);
    newLL = oldLL - ( wk_h^2*norm(ef_h(1:length(tmp)))^2 + 2*relevantResidual*(wk_h*ef_h(1:length(tmp))'));
%     display(['rem1 indx:' num2str(timeToRemove) ' ' num2str(newLL-oldLL)])
%     keyboard
    oldLL = newLL;
    %%%%%%%%%%%%%%%%%
    
% %     figure; plot(oldCalcium);hold on;plot(newCalcium,'r'); hold off
%     if abs(newLL - sum(-(newCalcium - obsCalcium).^2))>1
%         keyboard
%     end
    oldCalcium = newCalcium;            
    
    %%%%%%%%%%%%%%%%%
    %handle ef_d next
    tmp = 1+ (floor(timeToRemove_warped):min((length(ef_d)+floor(timeToRemove_warped)-1),length(newCalcium)-1));
    newCalcium(tmp) = newCalcium(tmp) - wk_d*ef_d(1:length(tmp));

    %if you really want to, ef*ef' could be precomputed and passed in
    relevantResidual = obsCalcium(tmp)-oldCalcium(tmp);
    newLL = oldLL - ( wk_d^2*norm(ef_d(1:length(tmp)))^2 + 2*relevantResidual*(wk_d*ef_d(1:length(tmp))'));
%     display(['rem1 indx:' num2str(timeToRemove) ' ' num2str(newLL-oldLL)])
%     keyboard
    %%%%%%%%%%%%%%%%
    
%     newLL = -sum((newCalcium-obsCalcium).^2);
%     
%     if(any(newCalcium<-1e-5))
%         figure;plot(newCalcium)
%         keyboard
%     end
    