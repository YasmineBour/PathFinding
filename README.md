# Projet — Algorithmes de Pathfinding & Cross-Docking

Ce projet est divisé en deux parties indépendantes :
- **Algo_Pathfinding** : algorithmes de recherche de chemin classiques (BFS, Dijkstra, A*, Glouton)
- **CrossDocking** : planification multi-AMR avec gestion des conflits et des timelines

---

## Partie 1 — Algo_Pathfinding

### Structure des fichiers

```
Algo_Pathfinding/src/
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

### Format des fichiers .map

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

### Lancer les tests

Depuis le REPL Julia, se placer dans le dossier `src/Algo_Pathfinding` puis :

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

### Utiliser les algorithmes directement

```julia
include(*Algo de votre choix noté X ici**)

G = map_to_matrix(*Map de votre choix*)
path, distance, cpt = X(G,P1,P2)
```

Chaque algorithme retourne un tuple `(Path, Distance, cpt)` avec:
- `Path` : vecteur de tuples représentant le chemin
- `Distance` : coût total du chemin
- `cpt` : nombre de sommets évalués

---

## Partie 2 — CrossDocking

### Structure des fichiers

```
CrossDocking/
├── Main.jl       # Point d'entrée : Lancement_Configuration + MAJ
├── Astar.jl      # Algorithme A* adapté multi-AMR avec timelines et obstacles dynamiques
├── Utils.jl      # Fonctions utilitaires : map_to_matrix, Get_Successeurs, collision, affichage...
├── Test.jl       # Configuration de test prête à l'emploi
└── *.map         # Carte(s) utilisée(s) pour la simulation
```

### Lancer la simulation de test

Depuis le REPL Julia, se placer dans le dossier `CrossDocking/` puis :

```julia
include("Test.jl")
```

Tout est préconfiguré, la simulation se lance automatiquement et affiche l'animation dans le terminal.

### Lancer sa propre configuration

Depuis le REPL Julia, se placer dans le dossier `CrossDocking/` puis inclure le point d'entrée :

```julia
include("Main.jl")
```

Ensuite définir la liste des missions et appeler `Lancement_Configuration` :

```julia
# Chaque élément de la liste correspond à un AMR
# L'indice dans la liste est l'identifiant de l'AMR (AMR 1 = indice 1, etc.)
# Chaque tuple est de la forme : (Départ, Arrivée, top_départ)
#   - Départ     : Tuple{Int64, Int64} — coordonnées (ligne, colonne) de la case de départ
#   - Arrivée    : Tuple{Int64, Int64} — coordonnées (ligne, colonne) de la case d'arrivée
#   - top_départ : Float64             — instant auquel l'AMR peut commencer à se déplacer

liste_DAT = [
    ((2, 3), (8, 7), 0.0),   # AMR 1 : part de (2,3), va en (8,7), disponible dès t=0
    ((5, 1), (3, 9), 2.0),   # AMR 2 : part de (5,1), va en (3,9), disponible à t=2
    ((1, 1), (6, 6), 0.0),   # AMR 3 : part de (1,1), va en (6,6), disponible dès t=0
]

Lancement_Configuration(length(liste_DAT), liste_DAT, "votre_carte.map")
```

### Ce que fait `Lancement_Configuration`

1. Charge la carte et initialise les timelines (chaque case disponible de t=0 à +∞)
2. Sélectionne les AMR par ordre de priorité (top_départ le plus petit en premier)
3. Lance A* pour chaque AMR en tenant compte des obstacles générés par les AMR déjà planifiés
4. Met à jour les timelines et la liste des obstacles après chaque chemin trouvé
5. Affiche la simulation animée dans le terminal puis le résumé textuel

### Résultats retournés

`Lancement_Configuration` retourne une liste `results` où chaque élément est un tuple `(id_AMR, Path, Distance, cpt)` avec :
- `id_AMR`    : identifiant de l'AMR
- `Path`      : vecteur de tuples `(ligne, colonne, temps)` représentant le chemin
- `Distance`  : coût total (temps d'arrivée)
- `cpt`       : nombre de noeuds explorés par A*
