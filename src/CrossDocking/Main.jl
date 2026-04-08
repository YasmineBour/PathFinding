#Lancement de la configuration
include("Astar.jl")
include("Utils.jl")


#ici je cherche l'AMR qui a le top départ le plus petit c'est lui qui part en priorité
function prioritaire(L::Vector{Tuple{Tuple{Int64,Int64},Tuple{Int64,Int64},Float64}})
    val_min    = Inf
    indice_min = 0
    for i in 1:length(L)
        #je garde l'indice du minimum en ignorant les Inf qui désignent les AMR déjà planifiés
        if L[i][3] < val_min
            val_min    = L[i][3]
            indice_min = i
        end
    end
    return indice_min

end


#ici je découpe un intervalle sûr pour retirer la plage [t_debut, t_fin] occupée par un AMR
function MAJ_intervalles(intervalles::Vector{Tuple{Float64,Float64}},t_debut::Float64, t_fin::Float64)
    nv_intervalles=Vector{Tuple{Float64,Float64}}()
    for (x, y) in intervalles
        #si l'intervalle existant ne chevauche pas la plage occupée je le conserve tel quel
        if y <= t_debut || x >= t_fin
            push!(nv_intervalles, (x, y))
        else
            #sinon je découpe 
            if x < t_debut
                push!(nv_intervalles, (x, t_debut))
            end
            if y > t_fin
                push!(nv_intervalles, (t_fin, y))
            end
        end
    end
    return nv_intervalles
end


#ici je convertis le chemin d'un AMR en une liste de positions  pour en faire un obstacle
function path_to_obstacle(Path::Vector{Tuple{Int64,Int64,Float64}})
    obs=Vector{Tuple{Int64,Int64,Float64}}()

    for pos in 1:(length(Path)-1)
        x, y, t_entree = Path[pos]
        t_sortie = Path[pos+1][3]

        #je génère une entrée par unité de temps passée sur chaque case
        for i in t_entree:(t_sortie-1)
            push!(obs,(x,y,i))
        end
    end

    #j'ajoute la dernière case où l'AMR reste indéfiniment
    last = Path[length(Path)]
    push!(obs, (last[1], last[2], last[3]))
    return obs
end 


#ici je lance la planification complète pour tous les AMR l'un après l'autre
function Lancement_Configuration(nb_AMR::Int64,liste_DAT::Vector{Tuple{Tuple{Int64,Int64},Tuple{Int64,Int64},Float64}},map::String)
    Time = @elapsed begin
        results=[]
        #je charge la carte et je récupère ses dimensions
        G = map_to_matrix(map)
        L, C = size(G)
        #j'initialise une liste d'obstacles vide pour chaque AMR
        obstacle = [Vector{Tuple{Int64,Int64,Float64}}() for _ in 1:nb_AMR]
        
        #je crée les timelines : au départ chaque case est disponible de 0 à l'infini
        timelines = Matrix{Vector{Tuple{Float64,Float64}}}(undef, L, C)
        for i in 1:L
            for j in 1:C
                timelines[i,j] = [(0.0,Inf)]
            end
        end

        #je bloque les cases de départ pendant le temps d'attente avant le top_depart de chaque AMR
        for (D, A, t_dep) in liste_DAT
            timelines[D[1], D[2]] = MAJ_intervalles(timelines[D[1], D[2]], 0.0, t_dep) 
        end
        
        for i in 1:nb_AMR

            #je sélectionne l'AMR dont le top de départ est le plus proche
            indice_min=prioritaire(liste_DAT)

            D        = liste_DAT[indice_min][1]
            A        = liste_DAT[indice_min][2]
            top_depart = liste_DAT[indice_min][3]

            #je lance A* pour cet AMR avec les timelines et obstacles mis à jour
            Path, Distance, cpt = Astar(G, D, A, timelines, obstacle, top_depart)
    
            if !isempty(Path)

                #je convertis le chemin en obstacle pour les AMR suivants
                obstacle[indice_min] = path_to_obstacle(Path)

                #je bloque la case de départ dès que l'AMR la quitte
                x_dep, y_dep, _ = Path[1]
                t_quitte = Path[2][3]
                timelines[x_dep, y_dep] = MAJ_intervalles(timelines[x_dep, y_dep], 0.0, t_quitte)# ici c'était pour préparer le terrain pour la fonction Wait 
                #car Astar peut décidé de faire partir un peu plus tard que le top départsi nécessaire

                #je bloque chaque case traversée pendant le temps où l'AMR l'occupe AUSSI PENDANT SA TRAVERSE SINON TROP D'ERREUR
                for pos in 1:(length(Path)-1)
                    x, y, t_entree = Path[pos]
                    t_sortie = Path[pos+1][3]
                    x_next, y_next = Path[pos+1][1], Path[pos+1][2]

                    timelines[x, y] = MAJ_intervalles(timelines[x, y], t_entree, t_sortie)

                    #je réserve aussi la case suivante en avance pour éviter les conflits
                    if pos < length(Path)-1
                        timelines[x_next, y_next] = MAJ_intervalles(timelines[x_next, y_next], t_entree, t_sortie + 1.0)
                    end

                end
                
                #je bloque définitivement la case d'arrivée car l'AMR y reste dans notre configuration 
                last_pos = Path[end]
                timelines[last_pos[1], last_pos[2]] = MAJ_intervalles(timelines[last_pos[1], last_pos[2]],last_pos[3],Inf)
            end   

            #je marque cet AMR comme planifié en mettant son top_depart à Inf comme ça pas de risque de le recalculer
            actuel = liste_DAT[indice_min]
            liste_DAT[indice_min] = (actuel[1], actuel[2], Inf)

            push!(results,(indice_min,Path,Distance,cpt))

        end
    end
    #j'affiche la simulation animée le fameux affichage magnifique 
    affiche_Magnifique(G, results)
    affiche(results,Time)
    
    return results
end
