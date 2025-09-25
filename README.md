

# CarouselGreedy (MATLAB)

MATLAB implementation of the **Carousel Greedy** metaheuristic for combinatorial optimization problems.  
This toolbox provides a modular and extensible implementation, mirroring the design of the Python and Julia versions.

---

## ✨ Features

- Modular architecture with a single entry-point class: `carouselgreedy.CarouselGreedy`
- Supports user-defined feasibility and greedy scoring functions
- Compatible with any set-based combinatorial problem (e.g., Minimum Vertex Cover, Minimum Label Spanning Tree)
- Distributed as a MATLAB Toolbox (`.mltbx`) for one-click installation

---

## 📦 Installation

Download or obtain the file `CarouselGreedy.mltbx` (generated in the `toolbox/` folder).  
Install by double-clicking in MATLAB or using:

```matlab
matlab.addons.toolbox.installToolbox('CarouselGreedy.mltbx')
```

After installation, MATLAB automatically adds the toolbox to the path.

---

## 🚀 Quick Start

```matlab
% Define candidates
candidates = num2cell(1:10);

% Define feasibility: stop when at least 4 elements selected
feas = @(obj,sol) numel(sol) >= 4;

% Define greedy score: here, random selection for demo purposes
greedy = @(obj,sol,cand) rand;

% Create CarouselGreedy object
cg = carouselgreedy.CarouselGreedy(feas, greedy, candidates);

% Run minimization
solution = cg.minimize();

% Display result
disp(solution)
```

---

## 📚 Documentation

Further documentation and examples can be found in the project source code.

---

## 📄 License

Distributed under the [MIT License](LICENSE).