#Implementation de l'algorithme A*

include("Utils.jl")
using DataStructures
using LinearAlgebra


#ici je lance A* pour trouver le chemin optimal d'un AMR de D vers A en respectant les timelines et les obstacles
function Astar(
    G::Matrix{Int64}, 
    D::Tuple{Int64, Int64}, 
    A::Tuple{Int64, Int64}, 
    timelines::Matrix{Vector{Tuple{Float64, Float64}}}, 
    obstacle::Vector{Vector{Tuple{Int64, Int64, Float64}}}, 
    top_depart::Float64
)
        #je prépare toutes les structures nécessaires à l'algorithme oui je sais ce bloc fait peur...
        L , C = size(G)
        nb_intervals = maximum(length(timelines[i,j]) for i in 1:L, j in 1:C)
        #F est la file de priorité, f le coût total estimé, precedent pour reconstruire le chemin
        F = PriorityQueue{Tuple{Int64,Int64,Int64}, Float64}()
        f = Array{Float64}(undef, L, C, nb_intervals)
        precedent = Array{Tuple{Int64,Int64,Int64,Float64}}(undef, L, C, nb_intervals)
        permanent = Array{Bool}(undef, L, C, nb_intervals)
        distance = Array{Float64}(undef, L, C, nb_intervals)
        u::Tuple{Int64,Int64,Int64} = (0,0,0)
        cpt::Int64 = 0
        Path::Vector{Tuple{Int64,Int64,Float64}} = []
        Distance::Float64 = 0.0
        S::Vector{Tuple{Int64,Int64,Int64,Float64}}= []
        
        #cas particulier : départ et arrivée sont la même case
        if A == D 
            Path = [(A[1], A[2])]
            return (Path, Distance, cpt)
        
        #je vérifie que D et A sont bien dans les limites de la grille
        elseif !est_bornee(L,C,D) || !est_bornee(L,C,A)
            println("Ces coordonnées sont hors borne de la map")
            return (Path, 0.0, 0)

        else
            #j'initialise toutes les distances à l'infini et les noeuds comme non permanents
            for i in 1:L 
                for j in 1:C 
                    for k in 1:nb_intervals
                        f[i,j,k]=Inf
                        distance[i,j,k]=Inf
                        #(0,0,0,0.0) signifie que ce noeud n'a pas encore de prédécesseur car non existant 
                        precedent[i,j,k]=(0,0,0,0.0)
                        permanent[i,j,k]=false
                    end
                end
            end

            #je place le noeud de départ dans la file avec son heuristique comme priorité
            distance[D[1], D[2], 1] =top_depart
            s_start = (D[1], D[2], 1)
            enqueue!(F, s_start, heuristic(A, D))

            while !isempty(F)
                #je prends le noeud le plus prometteur dans la file
                u = dequeue!(F)

                #si ce noeud est déjà traité je passe au suivant
                if permanent[u[1], u[2], u[3]]
                    continue
                end

                cpt += 1
                permanent[u[1], u[2], u[3]] = true

                #si j'ai atteint l'arrivée je vide la file pour arrêter la boucle
                if (u[1], u[2]) == A
                     F= PriorityQueue{Tuple{Int64,Int64,Int64}, Float64}()
                end

                #je calcule les successeurs valides de u
                S = Get_Successeurs(G, u, timelines, distance[u[1],u[2],u[3]], obstacle)

                for s in S
                    #je ne traite que les noeuds non encore permanents
                    if !permanent[s[1], s[2], s[3]]
                        t_arrivee = s[4]
                        #je garde la meilleure distance trouvée pour ce successeur
                        d = min(distance[s[1],s[2],s[3]], t_arrivee)
                        if distance[s[1],s[2],s[3]] != d
                            #je mets à jour la distance, le prédécesseur et le coût estimé
                            distance[s[1],s[2],s[3]]  = d
                            precedent[s[1],s[2],s[3]] = (u[1], u[2], u[3], d)
                            f[s[1],s[2],s[3]]          = d + heuristic(A, (s[1],s[2]))
                            F[(s[1],s[2],s[3])]        = f[s[1],s[2],s[3]]
                        end
                    end
                end
            end

            #je cherche quel intervalle de A a été atteint pour démarrer la reconstruction
            k = 1
            while k <= nb_intervals && precedent[A[1], A[2], k] == (0,0,0,0.0)
                k += 1
            end

            #je reconstruis le chemin en remontant les prédécesseurs depuis A jusqu'à D
            if k <= nb_intervals
                p = precedent[A[1], A[2], k]
                if p != (0,0,0,0.0)
                    Distance = distance[A[1], A[2], k]
                    tmp = (A[1], A[2], k, Distance)

                    while (tmp[1], tmp[2]) != D
                        push!(Path, (tmp[1], tmp[2], tmp[4]))
                        p   = precedent[tmp[1], tmp[2], tmp[3]]
                        t_prec = distance[p[1], p[2], p[3]]
                        tmp = (p[1], p[2], p[3], t_prec)
                    end
                    #j'ajoute le point de départ avec son top_depart et je retourne le chemin dans le bon ordre
                    push!(Path, (D[1], D[2], top_depart))
                    reverse!(Path)
                end
            end
        end
    return (Path, Distance, cpt)
end
