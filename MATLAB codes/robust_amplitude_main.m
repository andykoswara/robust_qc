%% Amplitude robustness analysis master file 

%DESCRIPTION:
    % main file for generating results published in the paper 1 "robustness
        % of controlled quantum dynamics". Please refer to readme.txt file
        % for more info.
% NOTE: 
    % 1. May be combined with Hamiltonian robustness analysis at some 
        % point...  
        
% OUTPUT:
    % All variables concerning robustness calculations
    % Plot of figures published in the reference
    % Display of critical information including:
        % (1) The upper bounds of the terms C_ji^m, U_ji^m and P_ji^m
        % (2) Display of numerical interference data,
        % (3) Display of the significant encoded pathways, and 
        % (4) The difference between moment- and sampled-calculations.

% WRITTEN BY:
    % Andy Koswara
    % Advisor: Prof. Raj Chakrabarti
    % School of Chemical Engineering
    % Purdue University

%REFERENCE
    % Koswara, A., & Chakrabarti, R. (2014). 
    % Robustness of controlled quantum dynamics. 
    % Physical Review A, 90(4), 043414.	

%% Initialization
% Includes input files.
clear all;clc

%options/cases
plotting=1; % if plotting desired
dispbool=1; % if parameter display -------
subsetsys=0; % if subset encoding is invoked
upbndsys=0; % if upper bound calculation ------
saveopt=1; % if saving -----
contind=1;endind=1; % solution index (if more than one field is to be 
    % analyzed)

% loading input files
loadfilenameopt=...
    'robust_calc_test_mod_field_1';
load(loadfilenameopt);

%% System and input parameters
%  System for paper 1 ("robustness of controlled quantum dynamics")
H0=[0.001   0   0   0   
      0     1   0   0   
      0     0  1.5  0
      0     0   0   2];

mu=[0 2 1 0 
    2 0 0 2 
    1 0 0 0
    0 2 0 0];

nq=2*max(omega)/(2*pi); % Nyquist bandwidth
dt=1/(8*nq); % sampling rate
t=dt:dt:T;

%% 

%  System for a possible paper 2 ("Evolutionary Optimization of Controlled 
    % Quantum Dynamics Under Input and System Uncertainties")
% H0=[0.001   0   0   0   0
%       0     0.5 0   0   0
%       0     0   1   0   0
%       0     0   0   1.5 0
%       0     0   0   0   2];
% 
% mu=[0 2 2 1 0
%     2 0 0 2 0
%     2 0 0 0 2
%     1 2 0 0 2
%     0 0 2 2 0];

dim=size(H0,1);
mmax=22; % assumed maximum order of Dyson series

if subsetsys % if subset encoding is invoked
    noparams=sum(subsetmat~=0);
    amparam=nan(1,noparams);
    tempind=1;
    for k=1:nomodes
        if subsetmat(k)~=0
            amparam(tempind)=amp(k);
            tempind=tempind+1;
        end
    end
else % this case is relevant for paper 1
    noparams=nomodes;
    amparam=nan(1,noparams);
    tempind=1;
    for k=1:nomodes
        amparam(k)=amp(k);
    end
end

sigma=0.3*ones(1,noparams); % stdev assoicated with (amplitude) parameters. 
    % There are other values calculated in the paper in the range of
    % 0.1-0.45 as given in Figure 5.

disp('--------System and input parameters---------')
disp(['loadfilenameopt: ' loadfilenameopt]);
disp('');
disp('H0:'); 
disp(H0);
disp('mu:');
disp(mu);
if subsetsys
    disp('subsetmat:');
    disp(subsetmat);
end
disp(['finstate: ' num2str(finstate)]);
disp(['inistate: ' num2str(inistate)]);
disp(['sigma: ' num2str(sigma)]);
disp(['saveopt: ' num2str(saveopt)]);
disp(['subsetsys: ' num2str(subsetsys)]);
disp(['upbndsys: ' num2str(upbndsys)]);
disp(['contind: ' num2str(contind)]);
disp(['endind: ' num2str(endind)]);

%% MI analysis
if subsetsys
    disp('--------MI Analysis with subset encoding---------');
    [fftUamp,gammajk]=MIamp_subset(H0,mu,amp,omega,phi,...
        subsetmat,t,mmax,0);
else
    disp('--------MI Analysis with full encoding---------');
    [fftUamp,gammajk]=MIamp(H0,mu,amp,omega,phi,t,mmax,0);
end

[alpha]=decodeMI(mmax,noparams); %decode amplitude MI
efield=field(amp,omega,phi,t);
Ui=eye(dim);
casetype='heisenberg';
Uint=unitpropagator(H0,mu,efield,t,Ui,casetype); %U_{ji}(T)
[alphaord,alphaind]=sortalpha(alpha);

[errors_fftUamp]=MIerror(Uint,fftUamp,finstate,inistate);
% error in MI
disp(['error in MI: ' num2str(errors_fftUamp(end))]);

%% Upper bound calculations
if upbndsys
    disp('----------Upper Bound Calculations-----------');
    [ampexp]=expectA(amp,sigma,mmax,0);
    % calculating expectation values of A without offset
    [cjiupbnd,ujiexpupbnd]=errupbnd(H0,mu,T,mmax,...
        alphaord,ampexp);
    figure;bar(cjiupbnd);set(gca,'Yscale','log');
    xlabel('m','fontsize',12);
    ylabel('upper bound(C_{ji}^m)','fontsize',12);
    
    figure;bar(ujiexpupbnd);set(gca,'Yscale','log');
    xlabel('m','fontsize',12);
    ylabel('upper bound(E[U_{ji}^m])','fontsize',12);
    
    [pjiexpupbnd,ampprodsum]=pjierrupbnd_rev_rc(H0,mu,T,mmax/2,...
        alphaord,ampexp);
    figure;bar(pjiexpupbnd);set(gca,'Yscale','log');
    xlabel('m','fontsize',12);
    ylabel('upper bound(E[P_{ji}^m])','fontsize',12);
else
    disp('----------Upper Bound Calculations skipped-----------');
end

%% Robustness calculations
disp(' ');
disp('----------Robustness Calculations-----------');

%calculate E[A^\alpha_i]'s with offset (Figure 1 (Top))
[ampoffexp,ampoff,offset]=expectparam(amparam,sigma,mmax*2,1);
[Ujigamexp,Ujigam,Cjioff]=moments(fftUamp,alpha,ampoffexp,ampoff,...
    'first');% E[U_ji^m]
Ujiexp=sum(Ujigamexp,3);

% plotting their norm
fftUampnorm=nan(1,size(fftUamp,3));
for i=1:size(fftUamp,3)
    fftUampnorm(i)=norm(fftUamp(finstate,inistate,i));
end

Ujigamnorm=zeros(1,size(Ujigam,3));
Ujigamexpnorm=zeros(1,size(Ujigam,3));
Cjioffnorm=zeros(1,size(Cjioff,3));
for i=1:size(Ujigam,3)
    Ujigamnorm(i)=norm(Ujigam(2,1,i)); % (Figure 1 (Bottom,blue))
    Ujigamexpnorm(i)=norm(Ujigamexp(2,1,i)); % (Figure 1 (Bottom,red))
    Cjioffnorm(i)=norm(Cjioff(2,1,i));
end

[pjiexpm]=momtransprob_rev(Cjioff,mmax,alphaord,alphaind,ampoffexp,...
    inistate,finstate);
pjiexp=sum(pjiexpm);
[varujim]=vartransamp(Cjioff,mmax,alphaord,alphaind,ampoffexp,...
    inistate,finstate);
varuji=sum(varujim);

if plotting
    figure;bar(ampoffexp(1,1:16)); % (Figure 1 (Top))
    set(gca,'YScale','log');
    xlabel('\alpha','fontsize',12);
    ylabel('E[\beta A^\alpha]/(\beta A^\alpha)','fontsize',12);
    
    figure;bar(Ujigamnorm); % (Figure 1 (Bottom,blue))
    set(gca,'Yscale','linear');
    % set(gca,'Yscale','log');
    xlabel('m','fontsize',12);
    ylabel('|U_{ji}^m|','fontsize',12);
    
    figure;bar(Ujigamexpnorm); % (Figure 1 (Bottom,red))
    set(gca,'Yscale','linear');
    % set(gca,'Yscale','log');
    xlabel('m','fontsize',12);
    ylabel('|E[U_{ji}^m]|','fontsize',12);
end

%% Interference calculations
disp(' ');
disp('----------Interference Calculations-----------');
[interfexpmmp,interfexpall]=mominterf(Cjioff,alphaord,alphaind,...
    ampoffexp,mmax,finstate,inistate); % expected interference (Figure 3 (Bottom))
[pathwaynorm,interf,interfangle,interfm]=interfere(fftUamp,...
    alphaord,alphaind,mmax,finstate,inistate);% interference calculation

% displaying interference data
if dispbool
    for m=2:mmax
        for mp=1:(m-1)
            if abs(interfexpmmp(m,mp))>1E-5
                disp(['order=[' num2str(m-1) ',' num2str(mp-1) ']'...
                    ', E[interf]=' num2str(interfexpmmp(m,mp)) ','...
                    ' nom(interf)=' num2str(interf(m,mp))]);
            else
                continue;
            end
        end
    end
    disp('')
    disp(['sum of nom(interf)= ' num2str(sum(sum(interf)))]);
    disp(['sum of E[interf]= ' num2str(sum(sum(interfexpmmp)))]);
end

if plotting
    figure;bar3(interf(2:11,2:11));
    xlabel('m''','fontsize',12);
    ylabel('m','fontsize',12);
    zlabel('magnitude','fontsize',12);
    
    figure;bar3(interfexpmmp(2:11,2:11));
    xlabel('m''','fontsize',12);
    ylabel('m','fontsize',12);
    zlabel('magnitude','fontsize',12);
end

%% Simulated robustness (via sampling)
tic
disp(' ');
disp('------------Simulating Robustness------------')
% noisy values
dim=size(H0,1);
Ui=eye(dim);
casetype='heisenberg';
noruns=800;
Ujinoi=zeros(dim,dim,noruns);
pjinoi=nan(noruns,1);

for i=1:noruns
    if subsetsys
        ampnoi=amp;
        noise=amparam.*sigma.*randn(1,noparams);
        tempind=1;
        for k=1:nomodes
            if subsetmat(k)~=0
                ampnoi(k)=amp(k)+noise(tempind);
                tempind=tempind+1;
            else
                continue;
            end
        end
    else
        noise=amp.*sigma.*randn(1,noparams);
        ampnoi=amp+noise;
    end
    efieldnoi=field(ampnoi,omega,phi,t);
    Ujinoi(:,:,i)=unitpropagator(H0,mu,efieldnoi,t,Ui,casetype);
    pjinoi(i)=Ujinoi(finstate,inistate,i)*...
        conj(Ujinoi(finstate,inistate,i));
end

meanUjinoi=mean(Ujinoi,3); % mean(U_ji)
meanpjinoi=mean(pjinoi); % mean(P_ji)
realstdUjinoi=std(real(Ujinoi),1,3); % std(Re[U_ji])
imagstdUjinoi=std(imag(Ujinoi),1,3); % std(Im[U_ji])
varUjinoi=realstdUjinoi.^2+sqrt(-1)*imagstdUjinoi.^2; % var(U_ji)

if dispbool
    disp(['initial state(i): ' num2str(inistate) ', final state(j): '...
        num2str(finstate)]);
    disp(['P_{ji}: ' num2str(norm(Uint(finstate,inistate))^2)]);
    disp(['mean(U_{ji}: ' num2str(meanUjinoi(finstate,inistate))]);
    disp(['E[U_{ji}]: ' num2str(Ujiexp(finstate,inistate))]);
    disp(['|E[U_{ji}]-mean(U_{ji})|:'...
        num2str(norm(meanUjinoi(finstate,inistate)-...
        Ujiexp(finstate,inistate),'fro'))]);
    disp(['mean(P_{ji}: ' num2str(meanpjinoi)]);
    disp(['E[P_{ji}]: ' num2str(pjiexp)]);
    disp(['|E[P_{ji}]-mean(P_{ji})|:'...
        num2str(norm(meanpjinoi-pjiexp))]);
    disp(['variance(U_{ji}): ' num2str(varUjinoi(finstate,inistate))]);
    disp(['\sigma^2(U_{ji}): ' num2str(varuji)]);
    disp(['|\sigma^2(U_{ji})-variance(U_{ji})|:'...
        num2str(norm(varuji-varUjinoi(finstate,inistate)))]);
end

disp(['time elapsed in simulated robustness: ' num2str(toc)]);
disp('');
disp('*****************end of analysis****************');
if saveopt
    save([loadfilenameopt '_result.mat']);
end

%% Advanced plotting and display options

%for displaying pathways (Table III)
if dispbool
    tol=1E-3;
    for i=1:size(fftUamp,3)
        if norm(fftUamp(finstate,inistate,i))>tol
            disp(['\alpha: [' num2str(alpha(i,1)) ', '...
                num2str(alpha(i,2)) ', ' num2str(alpha(i,3))...
                '] \gamma: ' num2str(i) ' |U_ji(T,\gamma)|^2: '...
                num2str(norm(fftUamp(finstate,inistate,i)))]);
        else
            continue;
        end
    end
end

% for plotting E[U_ji^m] and U_ji
% Note: This is somewhat verbose...maybe shortened.
if plotting
    % plotting U_ji and U_ji^m (Figure 4 - blue)
    ind=size(Ujigam,3);
    v=zeros(ind,2);
    for i=1:ind
        if abs(Ujigam(finstate,inistate,i))>=1E-3
            v(i,1)=real(Ujigam(finstate,inistate,i));
            v(i,2)=imag(Ujigam(finstate,inistate,i));
        else
            continue;
        end
    end
    
    figure;hold on;
    for i=1:ind
        quiver(0,0,v(i,1),v(i,2),'linewidth',2,'linestyle','-','color','b');
    end
    
    totalv=zeros(1,2);
    totalv(1,1)=real(sum(Ujigam(finstate,inistate,:)));
    totalv(1,2)=imag(sum(Ujigam(finstate,inistate,:)));
    quiver(0,0,totalv(1,1),totalv(1,2),'linewidth',2,'linestyle','-','color','g')
    
    % plotting E[U_ji] and E[U_ji^m] (Figure 4 - black)
    ind=size(Ujigamexp,3);
    v=zeros(ind,2);
    for i=1:ind
        if abs(Ujigamexp(finstate,inistate,i))>=1E-3
            v(i,1)=real(Ujigamexp(finstate,inistate,i));
            v(i,2)=imag(Ujigamexp(finstate,inistate,i));
        else
            continue;
        end
    end
    
    hold on;
    for i=1:ind
        quiver(0,0,v(i,1),v(i,2),'linewidth',2,'linestyle','--',...
            'color','k');
    end
    totalv=zeros(1,2);
    totalv(1,1)=real(sum(Ujigamexp(finstate,inistate,:)));
    totalv(1,2)=imag(sum(Ujigamexp(finstate,inistate,:)));
    quiver(0,0,totalv(1,1),totalv(1,2),'linewidth',2,'linestyle',...
        '--','color','r')
end