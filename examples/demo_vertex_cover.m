function demo_vertex_cover(~)
%demo_vertex_cover  Benchmark CarouselGreedy on Minimum Vertex Cover
%   using a lightweight state: only degrees + cover mask, no adjacency flips.
%
%   The user still supplies only two callbacks (feasibility + greedy).
%   All performance tweaks live entirely inside this script.

% Genera sempre un grafo random Erdős-Rényi
graph_n = 50; p = 0.10; rng(42);
A = triu(rand(graph_n) < p, 1);
A = A | A.'; % simmetrico
A_orig = logical(A);
n = graph_n;

alpha = 20;
beta  = 0.05;
seed  = 42;

%% ---------------- LIGHTWEIGHT STATE ------------------------------------
% adjacency list
adjList = cell(1,n);
[row,col] = find(triu(A_orig));                  % one direction
for k = 1:numel(row)
    adjList{row(k)}(end+1) = col(k);
    adjList{col(k)}(end+1) = row(k);
end

deg     = full(sum(A_orig,2))';                  % current degrees
inCover = false(1,n);                            % mask of vertices in cover
prevSol = [];                                    % previous solution

%% ---------------- CALLBACKS --------------------------------------------
    function feasible = myFeas(~, sol)
        updateState(sol);
        feasible = max(deg) == 0;
    end

    function score = myGreedy(~,sol, cand)
        %updateState(sol);   
        if ~isequal(sol, prevSol)
            updateState(sol);        % chiamata effettiva solo al bisogno
        end
        score = deg(cand);
    end

    function updateState(sol)
        if isequal(sol, prevSol), return; end

        % logical masks for delta computation
        solMask  = false(1,n); solMask(sol)   = true;
        prevMask = inCover;                   % previous cover

        removedMask  = prevMask & ~solMask;   % nodes leaving cover
        insertedMask = solMask  & ~prevMask;  % nodes entering cover

        % ----- nodes leaving the cover : their incident edges uncovered ---
        for v = find(removedMask)
            for w = adjList{v}
                if ~solMask(w)                % edge (v,w) becomes uncovered
                    deg(v) = deg(v) + 1;
                    deg(w) = deg(w) + 1;
                end
            end
        end

        % ----- nodes entering the cover : their incident edges covered ----
        for v = find(insertedMask)
            for w = adjList{v}
                if ~solMask(w)                % edge (v,w) now covered
                    deg(w) = deg(w) - 1;
                end
            end
            deg(v) = 0;                       % all its edges covered
        end
        % update mask and previous solution
        inCover = solMask;
        prevSol = sol;
        
        % --- full recomputation of degrees (robust) ---------------------
        uncoveredMask = ~inCover;           % vertices NOT in the cover
        deg = zeros(1, n);
        for v = find(uncoveredMask)
            deg(v) = sum(uncoveredMask(adjList{v}));
        end
        
    end

%% ---------------- CREATE CAROUSEL GREEDY -------------------------------
cg = carouselgreedy.CarouselGreedy(@myFeas, @myGreedy, 1:n, ...
                    'Data', struct('original_matrix', A_orig, 'n_nodes', n), ...
                    'Alpha', alpha, 'Beta', beta, ...
                    'RandomTieBreak', true, 'Seed', seed);

%% ---------------- RUN & TIME -------------------------------------------
% Eseguito subito dopo tutto il setup, prima di cg.minimize
fprintf('Inizio timing algoritmo...\n');
pause(0.01); % breve pausa per assestamento
tic;
bestSol = cg.minimize();
elapsed = toc;

%% ---------------- VALIDATION -------------------------------------------
valid = myFeas(cg,bestSol);

%% ---------------- OUTPUT ------------------------------------------------
fprintf('\n--- Erdős‑Rényi (%d nodes) ---\n', n);
fprintf('Greedy size           : %d\n', numel(cg.GreedySolution));
fprintf('Carousel‑Greedy size  : %d\n', numel(cg.CGSolution));
fprintf('Cover valida?         : %d\n', valid);
fprintf('Elapsed time          : %.6f seconds\n', elapsed);


end


