#Implementation de l'algorithme Glouton
 using DataStructures
 include("Graph.jl")

function Glouton(G,D,A)
    t = @elapsed begin
        #Variable utile
        L , C = size(G)
        F = PriorityQueue{Tuple{Int64,Int64}, Float64}()
        precedent=Matrix{Tuple{Int64,Int64}}(undef, L, C)
        u::Tuple{Int64,Int64}=(0,0)
        cpt::Int64 = 0
        Path::Vector{Tuple{Int64,Int64}} = []
        Distance::Float64 = 0.0
        
        if A == D 
            Path = [A]
            affiche(Path, Distance, cpt,0.0)
            return (Path, Distance, cpt)
        
        elseif !est_bornee(L,C,D) || !est_bornee(L,C,A)
            println("Ces coordonnées sont hors borne de la map")
            return (-1, 0, Tuple{Int,Int}[])

        else
            #initialisation des variables
            for i in 1:L 
                for j in 1:C 
                    precedent[i,j]=(0,0) #car ce point existe pas 
                end
            end
            
            enqueue!(F,D,heuristic(A,D))
            precedent[D[1],D[2]]=D

            while !isempty(F)
                cpt=cpt+1
                u=dequeue!(F)

                if u == A 
                    F=PriorityQueue{Tuple{Int64,Int64}, Float64}()

                else 

                    S = successeurs(G, u) 

                    for s in S
                        if precedent[s[1],s[2]]==(0,0)
                            precedent[s[1],s[2]]=u
                            enqueue!(F, s, heuristic(A,s))
                        
                        end
                    end
                end
            end
            
            #reconstruction du chemin si A a été atteint
            if precedent[A[1], A[2]] != (0,0)
                tmp::Tuple{Int64,Int64} = A
                while tmp != D 
                    push!(Path, tmp)
                    Distance = Distance + G[tmp[1], tmp[2]]
                    tmp = precedent[tmp[1], tmp[2]]
                end
                push!(Path, D)  
                reverse!(Path)    
            end
        end
    end

    
    affiche(Path, Distance, cpt,t)
    return (Path, Distance, cpt)

end
    

