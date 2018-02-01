% Precompute using sample counts
% for Nonparametric Bayesian FIRL using sparse Indian buffet process
% Written by Jaedeug Choi
function MAP = npbfirlprecompute(X, alg_params, mdp_data, smpl, verbosity)

if verbosity ~= 0,
    fprintf('Start pre-computing\n');
end
startTm = tic;

X.soln = npbfirlevalstochpolicy(X, mdp_data, smpl.p);
v   = callogpost(X, smpl, mdp_data, alg_params);
hst = savehistory([], X, v, toc(startTm));
if verbosity == 1
    fprintf('%4d | %10.2f %8.2f | %4d %4d/%d\n', ...
        0, v.logPost, v.logLk, size(X.Z, 2), nnz(X.T), length(X.T));
elseif verbosity == 2
    fprintf('%4d | %10.2f %8.2f %6.2f %8.2f %8.2f | %4d %4d/%d\n', ...
        0, v.logPost, v.logLk, v.logPriorW, v.logPriorZ, v.logPriorT, ...
        size(X.Z, 2), nnz(X.T), length(X.T));
end

% Sampling
for iter = 1:alg_params.max_pre_iters
    tic;
    
    % Updataing T
    tAcptPr = 0;
    for i = randperm(length(X.T))
        useLk    = nnz(X.Z(i, :)); %true; %
        [X, nUp] = updatet(X, i, smpl, mdp_data, alg_params, useLk);
        tAcptPr  = tAcptPr + nUp;
    end
    tAcptPr = tAcptPr/length(X.T);
    
    % Updating Z
    zAcptPr = 0;
    for i = randperm(size(X.Z, 1))
        useLk       = X.T(i);
        [X, acptPr] = updatez(X, i, smpl, mdp_data, alg_params, useLk);
        zAcptPr     = zAcptPr + acptPr;
    end
    zAcptPr = zAcptPr/size(X.Z, 1);
    
    % Updating A
    aAcptPr = 0;
    for i = randperm(size(X.A, 1))
        for k = randperm(size(X.A, 2))
            useLk    = X.T(i) && X.Z(i, k);
            [X, nUp] = updatea(X, i, k, smpl, mdp_data, alg_params, useLk);
            aAcptPr  = aAcptPr + nUp;
        end
    end
    aAcptPr = aAcptPr/numel(X.A);
    
    % Updating w
    wAcptPr = 0;
    for i = randperm(length(X.w))
        useLk    = nnz(X.F(:, i)) > 0;
        [X, nUp] = updatew(X, i, smpl, mdp_data, alg_params, useLk);
        wAcptPr  = wAcptPr + nUp;
    end
    wAcptPr = wAcptPr/length(X.w);
    
    % Evaluating the current sample X
    v   = callogpost(X, smpl, mdp_data, alg_params);
    hst = savehistory(hst, X, v, toc(startTm));
    if verbosity == 1
        fprintf('%4d | %10.2f %8.2f | %4d %4d | %6.2f\n', ...
            iter, v.logPost, v.logLk, size(X.Z, 2), nnz(X.T), toc);
    elseif verbosity ~= 0
        fprintf('%4d | %10.2f %8.2f %6.2f %8.2f %8.2f | %4d %4d | %4.2f %4.2f %4.2f %4.2f | %6.2f\n', ...
            iter, v.logPost, v.logLk, v.logPriorW, v.logPriorZ, v.logPriorT, ...
            size(X.Z, 2), nnz(X.T), zAcptPr, aAcptPr, tAcptPr, wAcptPr, toc);
    end
end

% Print timing
endTm = toc(startTm);
if verbosity ~= 0,
    fprintf('Pre-computation completed in %f seconds\n', endTm);
end

% Find MAP estimate
[~, ix]  = max(hst.logPost(1:end));
MAP      = struct('T', hst.X{ix}.T, 'Z', hst.X{ix}.Z, 'A', hst.X{ix}.A, ...
                  'F', hst.X{ix}.F, 'w', hst.X{ix}.w);
MAP.F    = npbfirlgenfeatmtrx(MAP, mdp_data.F);
MAP.r    = repmat(MAP.F*MAP.w, 1, mdp_data.actions);
MAP.soln = npbfirlsolvemdp(MAP.r, mdp_data, hst.X{ix}.soln, true);
if verbosity ~= 0
    fprintf('[MAP ] %10.2f %8.2f : %6.2f %6.2f\n', ...
        hst.logPost(ix), hst.logLk(ix), size(MAP.Z, 2), nnz(MAP.T));
end

end


%% Update (i)-th row of Z
function [X, acptPr] = updatez(X, i, smpl, mdp_data, alg_params, useLk)

ETA   = alg_params.eta;
ALPHA = alg_params.alpha;
BETA  = alg_params.beta;
nUp   = 0;
N     = size(X.Z, 1);

Z         = X.Z;
Z(i, :)   = 0;      % Discard (i)-th row
mu        = sum(Z, 1)/(N + BETA - 1);
activeNdx = find(sum(Z, 1) > 0);

% Update active features using Gibbs sampling
for j = randperm(length(activeNdx)) %1:length(activeNdx) %
    k          = activeNdx(j);
    Xn         = X;
    Xn.Z(i, k) = ~X.Z(i, k);
    Xn.F       = npbfirlupdatefeatmtrx(Xn, mdp_data.F, k);
    
    if useLk
        Xn.soln    = npbfirlevalstochpolicy(Xn, mdp_data, smpl.p);
        logLkRatio = calloglkratio(X, Xn, smpl, ETA);
    else
        logLkRatio = 0;
    end
    logPriorp = X.Z(i, k)*log(mu(k)) + (1 - X.Z(i, k))*log(1 - mu(k));
    logPriorn = Xn.Z(i, k)*log(mu(k)) + (1 - Xn.Z(i, k))*log(1 - mu(k));
    acptRatio = exp(logLkRatio + logPriorn - logPriorp);
    acptRatio = acptRatio/(acptRatio + 1);
    if rand < acptRatio
        X   = Xn;
        nUp = nUp + 1;
    end
end

% Update inactive features using Metropolis-Hasting sampling
knew       = poissrnd(ALPHA*BETA/(BETA + N - 1));
anew       = binornd(1, 0.5, N, knew);
wnew       = initw(knew, alg_params);
Xn         = X;
Xn.Z       = horzcat(X.Z(:, activeNdx), zeros(N, knew));
Xn.Z(i, :) = horzcat(X.Z(i, activeNdx), ones(1, knew));
Xn.A       = horzcat(X.A(:, activeNdx), anew);
Xn.F       = npbfirlgenfeatmtrx(Xn, mdp_data.F);
Xn.w       = vertcat(X.w(activeNdx), wnew);

Xn.soln    = npbfirlevalstochpolicy(Xn, mdp_data, smpl.p);
logLkRatio = calloglkratio(X, Xn, smpl, ETA);
if rand < exp(logLkRatio)
    X   = Xn;
    nUp = nUp + 1;
end

% Probability of acceptance
acptPr = nUp/(length(activeNdx) + 1);

end


%% Update (i,k) element of A using Gibbs sampling
function [X, nUp] = updatea(X, i, k, smpl, mdp_data, alg_params, useLk)

Xn         = X;
Xn.A(i, k) = ~X.A(i, k);
Xn.F       = npbfirlupdatefeatmtrx(Xn, mdp_data.F, k);

if useLk
    Xn.soln    = npbfirlevalstochpolicy(Xn, mdp_data, smpl.p);
    logLkRatio = calloglkratio(X, Xn, smpl, alg_params.eta);
    acptRatio  = exp(logLkRatio);
    acptRatio  = acptRatio/(acptRatio + 1);
else
    acptRatio = 0.5;
end
if rand < acptRatio
    X   = Xn;
    nUp = 1;
else
    nUp = 0;
end

end


%% Update (i)-th element of T using Gibbs sampling
function [X, nUp] = updatet(X, i, smpl, mdp_data, alg_params, useLk)

Xn      = X;
Xn.T(i) = ~X.T(i);
Xn.F    = npbfirlgenfeatmtrx(Xn, mdp_data.F);

if Xn.T(i) == 1
    priorn = alg_params.a + sum(Xn.T) - 1;
    priorp = alg_params.b + length(X.T) - sum(X.T);
else
    priorn = alg_params.b + length(Xn.T) - sum(Xn.T);
    priorp = alg_params.a + sum(X.T) - 1;
end
if useLk
    Xn.soln    = npbfirlevalstochpolicy(Xn, mdp_data, smpl.p);
    logLkRatio = calloglkratio(X, Xn, smpl, alg_params.eta);
    acptRatio  = exp(logLkRatio)*priorn/priorp;
else
    acptRatio = priorn/priorp;
end
acptRatio = acptRatio/(acptRatio + 1);
if rand < acptRatio
    X   = Xn;
    nUp = 1;
else
    nUp = 0;
end

end


%% Update (i)-th element of weight using Metropolis-Hasting sampling
function [X, nUp] = updatew(X, i, smpl, mdp_data, alg_params, useLk)

Xn      = X;
Xn.w(i) = normrnd(X.w(i), alg_params.lambda);

if useLk
    Xn.soln    = npbfirlevalstochpolicy(Xn, mdp_data, smpl.p);
    logLkRatio = calloglkratio(X, Xn, smpl, alg_params.eta);
else
    logLkRatio = 0;
end
logPriorp  = callogprw(X.w(i), alg_params);
logPriorn  = callogprw(Xn.w(i), alg_params);
acptRatio  = exp(logLkRatio + logPriorn - logPriorp);
if rand < acptRatio
    X   = Xn;
    nUp = 1;
else
    nUp = 0;
end

end


%% Calculate log posterior
function v = callogpost(X, smpl, mdp_data, alg_params)

logLk     = calloglk(X, smpl, mdp_data, alg_params.eta);
logPriorW = callogprw(X.w, alg_params);
logPriorZ = callogprz(X.Z, alg_params.alpha, alg_params.beta);
logPriorT = callogprt(X.T, alg_params.a, alg_params.b);
logPost   = logLk + logPriorW + logPriorZ + logPriorT;
v = struct('logPost', logPost, 'logLk', logLk, ...
    'logPriorW', logPriorW, 'logPriorZ', logPriorZ, 'logPriorT', logPriorT);

end


%% Calculate log likelihood
function logLk = calloglk(X, smpl, mdp_data, ETA)

% Solve MDP with given features and weight
X.soln = npbfirlevalstochpolicy(X, mdp_data, smpl.p);
sfmx   = callogsoftmax(X.soln.q, ETA);
logLk  = calloglkfromsoftmax(smpl, sfmx);

end


function logLkRatio = calloglkratio(Xp, Xn, smpl, ETA)

sfmxp      = callogsoftmax(Xp.soln.q, ETA);
sfmxn      = callogsoftmax(Xn.soln.q, ETA);
logLkRatio = calloglkfromsoftmax(smpl, sfmxn - sfmxp);

end


function logLk = calloglkfromsoftmax(smpl, sfmx)

logLk = sum(sum(sfmx.*smpl.cnt));
logLk = full(logLk);

end


function sfmx = callogsoftmax(q, ETA)

Q    = ETA.*q;
Q    = bsxfun(@minus, Q, max(Q, [], 2));
nQ   = log(sum(exp(Q), 2));
sfmx = bsxfun(@minus, Q, nQ);

end


%% Calculate log Pr(Z) using IBP
function logPr = callogprz(Z, ALPHA, BETA)

[N, Kplus] = size(Z);
mK         = full(sum(Z, 1));
K1         = zeros(N, 1);
for n = 1:N
    K1(n) = sum(Z(n, sum(K1) + 1:end));
end

% pr1 = (ALPHA*BETA)^Kplus/prod(factorial(K1));
% pr2 = exp(-ALPHA*sum(BETA./(BETA + (1:N) - 1)));
% pr3 = prod(beta(mK, N - mK + BETA));
% prF = pr1*pr2*pr3;

logPr1 = Kplus*log(ALPHA*BETA) - sum(log(factorial(K1)));
logPr2 = -ALPHA*sum(BETA./(BETA + (1:N) - 1));
logPr3 = sum(betaln(mK, N - mK + BETA));
logPr  = logPr1 + logPr2 + logPr3;

end


%% Calculate log Pr(weight)
function logPr = callogprw(w, alg_params)

x = w;
s = alg_params.sigma;

if alg_params.normal_prior          % normal prior
    logPr = -(x'*x)/(2*s^2);
else                                % Uuiform prior
    logPr = 0;
end

end


%% Calculate log Pr(T)
function logPr = callogprt(T, A, B)

logPr = 0;
N     = length(T);
for i = 1:N
    if T(i) == 1
        pr = A + sum(T) - 1;
    else
        pr = B + N - sum(T);
    end
    pr    = pr/(A + B + N);
    logPr = logPr + log(pr);
end

end


%% Initialize feature construction matrix
function [Z, A] = initza(N, ALPHA, BETA)

Z = ones(1, poissrnd(ALPHA));
for i = 2:N
    [n, K] = size(Z);
    sumK   = sum(Z, 1)/(BETA + i - 1);
    fnew   = binornd(1, sumK, 1, K);
    knew   = poissrnd(ALPHA*BETA/(BETA + i - 1));
    Z      = [Z, zeros(n, knew); fnew, ones(1, knew)];
end

% A = zeros(size(Z));
% while nnz(A) == 0
%     A = binornd(1, 0.5, size(Z));
% end

for i = 1:1000
    A = binornd(1, 0.5, size(Z));
    if nnz(A) > 0
        break;
    end
end

end


%% Initialize weight
function w = initw(N, alg_params)

if alg_params.normal_prior          % normal prior
    w = normrnd(0, alg_params.sigma, N, 1);
else                                % Uniform prior
    w = rand(N, 1);
end

end


%% Initialize base feature selection prior
function T = initt(N, a, b)

T = zeros(N, 1);
while nnz(T) == 0
    rho = betarnd(a, b);
    T   = binornd(1, rho, N, 1);
end

end


%% Save history
function hst = savehistory(hst, X, v, tm)

if isempty(hst)
    hst      = struct('logPost', v.logPost, 'logLk', v.logLk, ...
                      'logPriorW', v.logPriorW, 'logPriorZ', v.logPriorZ, ...
                      'logPriorT', v.logPriorT, 'tm', tm);
    hst.X{1} = X;
else
    hst.logPost   = vertcat(hst.logPost, v.logPost);
    hst.logLk     = vertcat(hst.logLk, v.logLk);
    hst.logPriorW = vertcat(hst.logPriorW, v.logPriorW);
    hst.logPriorZ = vertcat(hst.logPriorZ, v.logPriorZ);
    hst.logPriorT = vertcat(hst.logPriorT, v.logPriorT);
    hst.X         = vertcat(hst.X, X);
    hst.tm        = vertcat(hst.tm, tm);
end

end

