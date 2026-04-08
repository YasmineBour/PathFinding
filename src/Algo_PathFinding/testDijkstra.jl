include("Graph.jl")
include("Dijkstra.jl")

G = map_to_matrix("test.map")

println("***** départ = arrivée *****")
path, dist, cpt = Dijkstra(G, (1,1), (1,1))
#on s'attend à Path : [(1,1)], Distance : 0, cpt : 0

println("*****chemin simple sans obstacle *****")
path, dist, cpt = Dijkstra(G, (1,1), (1,5))
#on s'attend à Path : (1,1)→(1,2)→(1,3)→(1,4)→(1,5), Distance : 4.0

println("*****hors borne départ *****")
path, dist, cpt = Dijkstra(G, (0,0), (5,5))
#on s'attend à : "Ces coordonnées sont hors borne de la map"

println("*****hors borne arrivée *****")
path, dist, cpt = Dijkstra(G, (1,1), (6,6))
#on s'attend à : "Ces coordonnées sont hors borne de la map"

println("*****chemin avec poids W *****")
path, dist, cpt = Dijkstra(G, (1,1), (5,5))
#on s'attend à Path : (1,1)→(2,1)→(3,1)→(4,1)→(5,1)→(5,2)→(5,3)→(5,4)→(5,5), Distance : 15.0

println("*****chemin court sans poids *****")
path, dist, cpt = Dijkstra(G, (3,3), (3,5))
#on s'attend à Path : (3,3)→(3,4)→(3,5), Distance : 2.0

println("*****aucun chemin possible *****")
G2 = copy(G)
G2[2,1] = 0
G2[3,2] = 0
G2[4,1] = 0
path, dist, cpt = Dijkstra(G2, (3,1), (5,5))
#on s'attend à : "Aucun chemin trouvé"