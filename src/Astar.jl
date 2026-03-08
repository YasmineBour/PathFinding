#Implementation de l'algorithme A*

include("Graph.jl")
using DataStructures

function Astar(G,D,A)
    t = @elapsed begin
        #Variable utile
        L , C = size(G)
        F = PriorityQueue{Tuple{Int64,Int64}, Float64}()
        f=Matrix{Float64 }(undef, L, C)
        distance=Matrix{Float64 }(undef, L, C)
        precedent=Matrix{Tuple{Int64,Int64}}(undef, L, C)
        permanent=Matrix{Bool}(undef, L, C)
        u::Tuple{Int64,Int64}=(0,0)
        cpt::Int64 = 0
        Path::Vector{Tuple{Int64,Int64}} = []
        Distance::Float64 = 0.0
        
        if A == D 
            Path = [A]
            affiche(Path, 0.0, 0, 0.0)
            return (Path, Distance, cpt)
        
        elseif !est_bornee(L,C,D) || !est_bornee(L,C,A)
            println("Ces coordonnées sont hors borne de la map")
            return (-1, 0, Tuple{Int,Int}[])

        else
            #initialisation des variables
            for i in 1:L 
                for j in 1:C 
                    f[i,j]=Inf
                    distance[i,j]=Inf
                    precedent[i,j]=(0,0) #car ce point existe pas 
                    permanent[i,j]=false
                end
            end
            distance[D[1],D[2]]=0.0
            enqueue!(F,D,heuristic(A, D))

            while !isempty(F)
                u=dequeue!(F)
                if u == A 
                    F=PriorityQueue{Tuple{Int64,Int64}, Float64}()
                else 
                    cpt=cpt+1
                    permanent[u[1],u[2]]=true
                    S = successeurs(G, u) 

                    for s in S
                        if !permanent[s[1], s[2]]
                            d=min(distance[s[1],s[2]],distance[u[1],u[2]] + Float64(G[s[1],s[2]]))
                            if distance[s[1],s[2]]!=d
                                f[s[1], s[2]]= d + heuristic(A,s)
                                distance[s[1],s[2]]=d
                                precedent[s[1],s[2]]=u
                                F[s]= f[s[1], s[2]]
                            end
                        end
                    end
                end
            end
            
            #reconstruction du chemin si A a été atteint
            if precedent[A[1], A[2]] != (0,0)
                tmp::Tuple{Int64,Int64} = A
                Distance =distance[tmp[1],tmp[2]]
                while tmp != D 
                    push!(Path, tmp)
                    tmp = precedent[tmp[1], tmp[2]]
                end
                push!(Path, D)    #On ajoute D car dans la boucle on l'atteind pas (cond arret)
                reverse!(Path)    #on remet le chemin dans l'ordre D → A
            end
        end
    end
    
    affiche(Path, Distance, cpt,t)
    return (Path, Distance, cpt)
end