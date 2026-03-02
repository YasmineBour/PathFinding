## Structure des fichiers

```
src/
├── Graph.jl          # Fonctions de base pour manipuler les maps.
├── BFS.jl            # Algorithme BFS
├── Dijkstra.jl       # Algorithme Dijkstra
├── Astar.jl          # Algorithme A*
├── Glouton.jl        # Algorithme Glouton
├── testBFS.jl        # Tests BFS
├── testDijkstra.jl   # Tests Dijkstra
├── testAstar.jl      # Tests A*
├── testGlouton.jl    # Tests Glouton
└── test.map          # Map de test 
```

## Format des fichiers .map

```
type octile
height int
width int
map
<contenu>
```

Les caractères utilisés sont :
- `.` case libre (coût 1)
- `@` obstacle 
- `W` eau (coût 8)
- `S` sable (coût 5)

## Lancer les tests

Depuis le REPL Julia, se placer dans le dossier `src/` puis :

```julia
#Pour tester BFS
include("testBFS.jl")

#Pour tester  Dijkstra
include("testDijkstra.jl")

#Pour tester  A*
include("testAstar.jl")

#Pour tester  Glouton
include("testGlouton.jl")
```

## Utiliser les algorithmes directement

```julia
include(*Algo de votre choix noté X ici**)

G = map_to_matrix(*Map de votre choix*)
path, distance, cpt = X(G,P1,P2)
```

Chaque algorithme retourne un tuple `(Path, Distance, cpt)` avec:
- `Path` : vecteur de tuples représentant le chemin
- `Distance` : coût total du chemin
- `cpt` : nombre de sommets évalués