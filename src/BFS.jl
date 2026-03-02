#Implementation de l'algorithme BFS 

using DataStructures
include("Graph.jl")

function BFS(G, D, A)

    #Variables utiles à l'affichage 
    cpt::Int64 = 0
    Path::Vector{Tuple{Int64,Int64}} = []
    Distance::Int64 = 0

    #Variable utile
    L , C = size(G)

    if A == D 
        Path = [A]
        affiche(Path, Distance, cpt)
        return (Path, Distance, cpt)
    
    elseif !est_bornee(L,C,D) || !est_bornee(L,C,A)
        println("Ces coordonnées sont hors borne de la map")
        return (-1, 0, Tuple{Int,Int}[])

    else
        
        #initialisation d'une matrice répertoriant le parent de chaque nœud visité.
        V = Matrix{Tuple{Int64,Int64}}(undef, L, C)
        for i in 1:L
            for j in 1:C
             V[i,j] = (0,0)
            end
         end

        #initialisation de la file 
        F = Queue{Tuple{Int64,Int64}}()
        enqueue!(F, D)
        V[D[1], D[2]] = D

        while !isempty(F) 

            #mise à jour du compteur de tours
            cpt = cpt + 1

            u = dequeue!(F) 

            #quand on atteint A on arrête la recherche et on vide la file
            if u == A 
                F = Queue{Tuple{Int64,Int64}}()
            
            else 
                
                #sinon on récupère les successeurs et on met à jour la matrice de visite
                S = successeurs(G,u) 
                for s in S 
                    if V[s[1], s[2]] == (0,0)
                        V[s[1], s[2]] = u
                        enqueue!(F, s)
                    end
                end
            end
        end

        #reconstruction du chemin si A a été atteint
        if V[A[1], A[2]] != (0,0)
            tmp::Tuple{Int64,Int64} = A
            while tmp != D 
                push!(Path, tmp)
                Distance = Distance + 1 #ou G[tmp[1], tmp[2]]?
                tmp = V[tmp[1], tmp[2]]
            end
            push!(Path, D)   
            reverse!(Path)    
        end

        affiche(Path, Distance, cpt)
        return (Path, Distance, cpt)

    end
end

