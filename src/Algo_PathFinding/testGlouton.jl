include("Graph.jl")
include("Glouton.jl")

G = map_to_matrix("test.map")

println("***** départ = arrivée *****")
path, dist, cpt = Glouton(G, (1,1), (1,1))
#on s'attend à Path : [(1,1)], Distance : 0, cpt : 0


println("***** chemin simple sans obstacle *****")
path, dist, cpt = Glouton(G, (1,1), (1,5))
#on s'attend à Path : (1,1)→(1,2)→(1,3)→(1,4)→(1,5), Distance : 4.0


println("***** hors borne départ *****")
path, dist, cpt = Glouton(G, (0,0), (5,5))
#on s'attend à : "Ces coordonnées sont hors borne de la map"


println("***** hors borne arrivée *****")
path, dist, cpt = Glouton(G, (1,1), (6,6))
#on s'attend à : "Ces coordonnées sont hors borne de la map"


println("***** objectif sur une case W*****")
path, dist, cpt = Glouton(G, (1,1), (5,5))
# on s'attend à Distance  = 15.0


println("***** chemin court*****")
path, dist, cpt = Glouton(G, (3,3), (3,5))
#on s'attend à Path : (3,3)→(3,4)→(3,5), Distance : 2.0


println("***** test de contournement d'obstacles*****")
path, dist, cpt = Glouton(G, (2,1), (4,5))
#on s'attend à un chemin non optimal mais on sait pas lequel exactement

println("***** aucun chemin possible *****")
G2 = copy(G)
G2[2,1] = 0
G2[3,2] = 0
G2[4,1] = 0
path, dist, cpt = Glouton(G2, (3,1), (5,5))
# on s'attend à : "Aucun chemin trouvé"