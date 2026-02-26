include("Graph.jl")
include("BFS.jl")
include("Dijkstra.jl")
# Chargement
G = map_to_matrix("test.map")

# Test 1 : chemin simple sans obstacle
path, dist, cpt = BFS(G, (1,1), (1,5))
# chemin attendu : (1,1)→(1,2)→(1,3)→(1,4)→(1,5)
# distance attendue : 4

# Test 2 : départ = arrivée
path, dist, cpt = BFS(G, (1,1), (1,1))
# path attendu : [(1,1)], distance : 0

# Test 3 : chemin avec contournement d'obstacles
path, dist, cpt = BFS(G, (1,1), (5,5))
# doit contourner les '@'

# Test 4 : coordonnées hors borne
path, dist, cpt = BFS(G, (0,0), (5,5))
# attendu : "Ces coordonnées sont hors borne de la map"

# Test 5 : pas de chemin possible
path, dist, cpt = BFS(G, (3,3), (3,5))
# si (3,5) est entouré d'obstacles → path vide

# Test 6 : comparer BFS et Dijkstra sur même chemin
path_bfs, dist_bfs, _ = BFS(G, (1,1), (5,5))
path_dij, dist_dij, _ = Dijkstra(G, (1,1), (5,5))
# sur une map sans poids, dist_bfs == dist_dij
