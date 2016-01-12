function [Rbin, Ebin, Y, Eavg, width, m3] = MonteBurns(input)
%% [Rbin Ebin  Y Eavg width] = MonteBurns(input)
%   Function calculates the neutron production spectrum of a plasma with
%   arbitrary 3D distribution function f at neutron energies defined by
%   Ea using Monte Carlo integration.
%
%
%   Created By: Patrick Knapp (pfknapp@sandia.gov)
%           On: 7/5/2012
%% Unpack Input Parameters
%%{
params1 = input.Dist1.params;
params2 = input.Dist2.params;
distf1 = input.Dist1.fcn;
distf2 = input.Dist2.fcn;
ISflag = input.Importance;

N = input.N;
nI = input.nI;

reaction = input.Reaction;
Implosion = input.Implosion;
vImp = input.Velocity;

Ea = input.Earray;
view = input.view;
differential = input.differential;

%}
%% Define constants for reaction
switch reaction
    case 'DDn'
        if differential
            cross_section = @dSdO_DD_He3n;
        else
            cross_section = @BH_cross_section_DD_He3n;
        end
        Qk = 3.27;          %Q value of DD reaction in MeV.
        m1 = 3.3446e-27;    %mass of reactant particle 1 in kg. (deuteron)
        m2 = 3.3446e-27;    %mass of reactant particle 2 in kg. (deuteron)
        m3 = 1.6749e-27;      %mass of product particle 3 in kg. (neutron)
        m4 = 5.0084e-27;    %mass of product particle 4 in kg. (3He)
    case 'DDt'
        if differential
           warning(NoDiff,['No differential cross-section data available for D+D->p+T reaction\n',...
               'Using total cross-seciton']) 
        end
        cross_section = @BH_cross_section_DD_pT;
        Qk = 4.13;          %Q value of DD reaction in MeV.
        m1 = 3.3446e-27;    %mass of reactant particle 1 in kg. (deuteron)
        m2 = 3.3446e-27;    %mass of reactant particle 2 in kg. (deuteron)
        m3 = 5.0085e-27;      %mass of product particle 3 in kg. (triton)
        m4 = 1.6726e-27;    %mass of product particle 4 in kg. (proton)
    case 'DT'
        if differential
            cross_section = @dSdO_DT;
        else
            cross_section = @BH_cross_section_DT;
            %cross_sectionH = @BH_cross_section_DT_hiE;
        end
        Qk = 17.6;          %Q value of DT reaction in MeV.
        m1 = 3.3446e-27;    %mass of reactant particle 1 in kg. (deuteron)
        m2 = 5.0085e-27;    %mass of reactant particle 2 in kg. (triton)
        m3 = 1.6749e-27;      %mass of product particle 3 in kg. (neutron)
        m4 = 6.6467e-27;    %mass of product particle 4 in kg. (alpha)
    case 'DHe3'
        if differential
           warning(NoDiff,['No differential cross-section data available for D+3He->p+4He reaction\n',...
               'Using total cross-seciton']) 
        end
        cross_section = @BH_cross_section_DHe3;
        Qk = 18.3;          %Q value of DT reaction in MeV.clc
        m1 = 3.3445e-27;    %mass of reactant particle 1 in kg. (deuteron)
        m2 = 5.0082e-27;    %mass of reactant particle 2 in kg. (3He)
        m3 = 1.6726e-27;      %mass of product particle 3 in kg. (proton)
        m4 = 6.644656e-27;    %mass of product particle 4 in kg. (alpha)
    otherwise
        disp('Error: Invalid Reaction')
        return
end

mu = m1*m2/(m1+m2);     %reduced mass of reacting particles.
eta = m3*(m3+m4)/m4;
Q = Qk*1e6*1.602e-19;    %Q value in Joules

%% Define viewing angle
v3x = sin(view(1))*cos(view(2));
v3y = sin(view(1))*sin(view(2));
v3z = cos(view(1));
v3hat = repmat([v3x v3y v3z],N,1);

%% Initialize variables and create velocity array

R_temp = zeros(nI,Ea(3));
W = zeros(nI,1);

Ebin = linspace(Ea(1),Ea(2),Ea(3));
dE = 1.602e-13*(Ebin(2)-Ebin(1));
Edges = 1.6022e-13*linspace(Ea(1)-dE/2,Ea(2)+dE/2,Ea(3)+1);

for j = 1:nI
    %% generate random particle velocities
    [v1, w1, scale1] = distf1(params1,m1,N,ISflag);
    [v2, w2, scale2] = distf2(params2,m2,N,ISflag);
    %% Include CM velocity shift due to bulk fluid motion/implosion
    switch Implosion
        case 'None'
            V = zeros(N,3);
        case 'Cylindrical'
            phiCM = 2*pi*rand(N,1);
            V = [vImp*cos(phiCM) ...
                vImp*sin(phiCM) ...
                zeros(N,1)];
            
        case 'Spherical'
            xth = linspace(0,pi,100);
            fth = sin(xth);
            thCM = fNgen(fth,xth,N);
            phiCM = 2*pi*rand(N,1);
            
            V = [vImp*sin(thCM).*cos(phiCM) ...
                vImp*sin(thCM).*sin(phiCM) ...
                vImp*cos(thCM)];
            
        case 'LinearX'
            V = zeros(N,3);
            V(:,1) = vImp*ones(N,1);
        case 'LinearY'
            V = zeros(N,3);
            V(:,2) = vImp*ones(N,1);
        case 'LinearZ'
            V = zeros(N,3);
            V(:,3) = vImp*ones(N,1);
    end
    
    %% Calculate Center of mass velocity (vCM)
    vCM_vec = (m1*(v1+V) + m2*(v2+V))/(m1+m2);
    vCM = sqrt(sum(vCM_vec.^2,2));
    
    %% Calculate relative velocity (vr) and vr^2
    vr_vec = v1-v2;
    vrsq = sum(vr_vec.*vr_vec,2);
    Er = 0.5*mu*vrsq;
    
    %% Calculate reaction product velocity in CM and lab frame
    u3 = sqrt((2/eta)*(Q+Er));
    
    cbeta = sum(vCM_vec.*v3hat,2)./vCM;
    v3 = vCM.*cbeta + sqrt(u3.^2 + vCM.^2.*(cbeta.^2 -1));
    E3 = 0.5*m3*v3.^2;
    
    %% Calculate cross-section
    if differential
        % Calculate scattering angle (thCM)
        v3_vec = repmat(v3,1,3).*v3hat;
        u3_p = v3_vec - (v2 + V);
        u1_p = v1 - v2;
        
        u3hat = (u3_p)./repmat(sqrt(sum(u3_p.^2,2)),1,3);
        u1hat = (u1_p)./repmat(sqrt(sum(u1_p.^2,2)),1,3);
        thCM = real(acos(sum(u3hat.*u1hat,2)));
        % Calculate fusion cross section using differential cross-section
        sig = cross_section(Er,thCM);
    else
        % Calculate fusion cross section using total cross-section
        sig = cross_section(Er);
    end
    %% Calc. rate, Bin the product velocities and sum reaction rate
    R = sqrt(vrsq).*sig.*w1.*w2.*E3/(4*pi);%
    [~,bin] = histc(E3,Edges);
    mask = find(bin > 0);
    Rtemp = accumarray(bin(mask),R(mask),[Ea(3) 1]);
    R_temp(j,:) = real(scale1*scale2*Rtemp'/N/dE);
    
    W(j) = sum(w1.*w2)/N;
    
end
Rbin = sum(R_temp,1)/sum(W);
%% Calculate reactivity, 1st (avg. E) and 2nd (variance) spectral moments
Y = 4*pi*trapz(Ebin,Rbin./Ebin);
Eavg = trapz(Ebin,Rbin)/Y;
width = 1e3*2*sqrt(2*log(2)*trapz(Ebin,(Ebin - Eavg).^2.*Rbin./Ebin)/Y);

%% Fusion Cross section functions
% D + D --> He3 + n
    function sigma = BH_cross_section_DD_He3n(qE)
        eq = 1.6e-19;
        qE=qE/eq/1000.0e0;
        
        BG = 31.3970;
        a1 = 5.3701e4; a2 = 3.3027e2; a3 = -1.2706e-1;...
            a4 = 2.9327e-5; a5 = -2.5151e-9;
        b1 = 0.0; b2 = 0.0; b3 = 0.0; b4 = 0.0;
        
        SE = a1+qE.*(a2+qE.*(a3+qE.*(a4+qE*a5)))./...
            (1+qE.*(b1+qE.*(b2+qE.*(b3+qE*b4))));
        sigma=SE./qE./exp(BG./sqrt(qE));
        sigma=1e-3*sigma*(1.0e-24)*1.0e-4;
    end

% D + D --> p + T
    function sigma = BH_cross_section_DD_pT(qE)
        eq = 1.6e-19;
        qE=qE/eq/1000.0e0;
        
        BG = 31.3970;
        a1 = 5.5576e4; a2 = 2.1054e2; a3 = -3.2638e-2;...
            a4 = 1.4987e-6; a5 = 1.8181e-10;
        b1 = 0.0; b2 = 0.0; b3 = 0.0; b4 = 0.0;
        
        SE = a1+qE.*(a2+qE.*(a3+qE.*(a4+qE*a5)))./...
            (1+qE.*(b1+qE.*(b2+qE.*(b3+qE*b4))));
        sigma=SE./qE./exp(BG./sqrt(qE));
        sigma=1e-3*sigma*(1.0d-24)*1.0d-4;
    end

% D + T --> He4 + n
    function sigma = BH_cross_section_DT(qE)
        eq = 1.6e-19;
        qE=qE/eq/1000.0e0;
        
        BG = 34.3827;
        a1 = 6.927e4; a2 = 7.454e8; a3 = 2.050e6; a4 = 5.2002e4; a5 = 0.0;
        b1 = 6.38e1; b2 = -9.95e-1; b3 = 6.981e-5; b4 = 1.728e-4;
        
        SE = a1+qE.*(a2+qE.*(a3+qE.*(a4+qE*a5)))./...
            (1+qE.*(b1+qE.*(b2+qE.*(b3+qE*b4))));
        sigma=SE./qE./exp(BG./sqrt(qE));
        sigma=1e-3*sigma*(1.0d-24)*1.0d-4;
    end

% D + T --> He4 + n (Er>530 keV)
    function sigma = BH_cross_section_DT_hiE(qE)
        eq = 1.6e-19;
        qE=qE/eq/1000.0e0;
        
        BG = 34.3827;
        a1 = -1.4714e6; a2 = 0; a3 = 0; a4 = 0; a5 = 0.0;
        b1 = -8.4127e-3; b2 = 4.7983e-6; b3 = -1.0748e-9; b4 = 8.5184e-14;
        
        SE = a1+qE.*(a2+qE.*(a3+qE.*(a4+qE*a5)))./...
            (1+qE.*(b1+qE.*(b2+qE.*(b3+qE*b4))));
        sigma=SE./qE./exp(BG./sqrt(qE));
        sigma=1e-3*sigma*(1.0d-24)*1.0d-4;
    end

% D + 3He --> He4 + p
    function sigma = BH_cross_section_DHe3(qE)
        eq = 1.6e-19;
        qE=qE/eq/1000.0e0;
        
        BG = 68.7508;
        a1 = 5.7501e6; a2 = 2.5226e3; a3 = 4.5566e1; a4 = 0.0; a5 = 0.0;
        b1 = -3.1995e-3; b2 = -8.553e-6; b3 = 5.9014e-8; b4 =0.0;
        
        SE = a1+qE.*(a2+qE.*(a3+qE.*(a4+qE*a5)))./...
            (1+qE.*(b1+qE.*(b2+qE.*(b3+qE*b4))));
        sigma=SE./qE./exp(BG./sqrt(qE));
        sigma=1e-3*sigma*(1.0d-24)*1.0d-4;
    end

end