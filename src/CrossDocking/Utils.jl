#Implémentation des maps et fonctions associés

#ici je lis le fichier map et je le convertis en matrice
function map_to_matrix(filename::String)

    #lignes est un Vector{String} avec chaque éléments correspondant à une ligne du fichier map
    lines = readlines(filename) 

    #je récupère la hauteur et la largeur depuis les métadonnées du fichier
    #split sert a couper une ligne en mot individuel
    H = parse(Int64, split(lines[2])[2]) 
    W = parse(Int64, split(lines[3])[2])  

    #j'initialise la matrice avec la bonne taille
    G = Matrix{Int64}(undef, H, W)

    #je parcours les lignes de la carte en sautant les 4 lignes d'en-tête
    for i in 1:H
        #collect transforme la ligne en Vector{Char}
        L = collect(lines[i+4]) 
       
        for j in 1:W
            #j'encode chaque type de case 
            if L[j] == '.'
                G[i,j] = 1
            elseif  L[j] == 'W'
                G[i,j] = 8
            elseif L[j] == 'S'
                G[i,j] = 5
            else
                G[i,j] = 0
            end
        end
    end

    return G 

end


#ici je cherche où se trouve un obstacle à un instant t précis
function position_obstacle(obs::Vector{Tuple{Int64,Int64,Float64}},t::Float64)
    P=(0,0)
        for pos in obs 
            #je compare avec une tolérance car t est un Float64 et ça m'a joué des tours!!!
            if abs(pos[3] - t) < 1e-6 
                    P=(pos[1],pos[2])
            end
        end
    return P
end


#ici je détecte si deux AMR s'échangent leur case au même instant 
function swap_detecte(u::Tuple{Int64,Int64,Int64}, i::Int64, j::Int64,
                      t_depart::Float64, t_arrivee::Float64,
                      obstacle::Vector{Vector{Tuple{Int64,Int64,Float64}}})
    for obs in obstacle
        #je saute les obstacles vides
        if isempty(obs)
            continue
        end
        #je récupère la position de l'obstacle au départ et à l'arrivée
        pos_dep = position_obstacle(obs, t_depart)
        pos_arr = position_obstacle(obs, t_arrivee)
        #si l'obstacle fait le chemin inverse du mien c'est un swap je refuse
        if pos_dep == (i, j) && pos_arr == (u[1], u[2])
            return true
        end
    end
    return false
end


#ici je vérifie qu'aucun obstacle n'occupe la case (i,j) au temps t
function collision(i::Int64, j::Int64, t::Float64,obstacle::Vector{Vector{Tuple{Int64,Int64,Float64}}})
    for obs in obstacle
        #je saute les obstacles vides
        if isempty(obs)
            continue
        end
        #si un obstacle est sur ma case à ce temps là c'est une collision
        if position_obstacle(obs, t) == (i, j)
            return true
        end
    end
    return false
end


#ici je calcule tous les successeurs valides du noeud u en tenant compte des timelines et des obstacles
function Get_Successeurs(G::Matrix{Int64},u::Tuple{Int64,Int64,Int64},timelines::Matrix{Vector{Tuple{Float64,Float64}}},TimeTrack::Float64, obstacle::Vector{Vector{Tuple{Int64,Int64,Float64}}})

    
    S=Vector{Tuple{Int64,Int64,Int64,Float64}}()
    l , c =size(G)

    #je définis les 4 directions possibles : N/S/E/O (sur place pour le wait mais pas implémenté pour le moment)
    Direction::Vector{Tuple{Int64,Int64}}=[(0,1),(1,0),(-1,0),(0,-1)]

    #je note quand je peux partir de u au plus tôt et au plus tard
    start_u = TimeTrack
    end_u= timelines[u[1],u[2]][u[3]][2]
    
    for s in Direction
        #je calcule les coordonnées du voisin dans cette direction
        i=u[1]+s[1]
        j=u[2]+s[2]

        #je vérifie que le voisin est dans la grille et que la case est praticable sinon outofbounds :(
        if (1<= i <= l && 1<= j <= c) && (G[i,j]!=0 )
            #le coût de déplacement dépend du type de terrain 
            m_time    = Float64(G[i,j])

            #je parcours tous les intervalles disponibles sur la case voisine
            for k in 1:length(timelines[i,j])

                start_s=timelines[i,j][k][1]
                end_s=timelines[i,j][k][2]

                #je calcule l'heure d'arrivée au plus tôt sur la case voisine càd de u à s 
                t_arrivee = max(TimeTrack + m_time, start_s)
                t_depart  = t_arrivee - m_time

                #si j'arrive trop tard dans l'intervalle ou que je pars trop tard de u je rejette
                if t_arrivee > end_s || t_depart > end_u
                    continue
                end

                #je vérifie qu'aucun AMR n'occupe cette case à mon heure d'arrivée double vérif en complément de timelines
                if collision(i, j, t_arrivee, obstacle)
                    continue
                end

                #je vérifie qu'on ne s'échange pas la case avec un autre AMR
                if swap_detecte(u, i, j, t_depart, t_arrivee, obstacle)
                    continue
                end

                #si le successeur à passé tout les tests, il est valide, je l'ajoute à la liste
                push!(S, (i, j, k, t_arrivee))
            end
        end
    end
    
    return S

end


#ici je calcule l'heuristique de Manhattan entre le noeud s et l'arrivée A
function heuristic(A,s)
    return Float64(abs(A[1]-s[1]) + abs(A[2]-s[2]))
end

#ici je vérifie que le point P est bien dans les dimensions de la grille
function est_bornee(L,C,P)
    return (1<= P[1] <= L) && (1<= P[2] <= C)
end


#ici j'affiche un résumé textuel des résultats de tous les AMR
function affiche(results::Vector, Time::Float64)
    #si aucun résultat je quitte directement
    if isempty(results)
        println("Aucun résultat")
        return
    end

    #je cherche le temps maximum auquel tous les AMR sont arrivés
    t_max = 0.0
    tous_arrives = true
    for res in results
        path_amr = res[2]
        if isempty(path_amr)
            tous_arrives = false
        else
            t_max = max(t_max, path_amr[end][3])
        end
    end

    if tous_arrives
        println("Tous les AMR ont atteint leur destination t=", round(t_max))
    end

    println()

    #j'affiche les détails de chaque AMR 
    for res in results
        id_amr   = res[1]
        path_amr = res[2]
        distance = res[3]

        if isempty(path_amr)
            println("  AMR",id_amr, ": aucun chemin trouvé")
        else
            nb_pas  = length(path_amr) - 1
            t_debut = round(path_amr[1][3])
            t_fin   = round(path_amr[end][3])
            println("  AMR",id_amr, ":", nb_pas ,"pas, coût=",round(distance),  "(mission t=", (t_debut) , "→t=" , (t_fin))
        end
    end

    println()
    println("Temps de calcul : ", round(Time, digits=6), "s")
end


#ici je retrouve la position d'un AMR sur son chemin à un instant t précis
function position_a_t(Path::Vector{Tuple{Int64,Int64,Float64}}, t::Int64)
    #si le chemin est vide je ne peux rien retourner
    if isempty(Path)
        return nothing
    end
    
    #si t est avant le départ l'AMR est encore sur sa case de départ
    if t <= Path[1][3]
        return (Path[1][1], Path[1][2])
    end
    
    #si t est après l'arrivée l'AMR reste sur sa case finale
    if t >= Path[end][3]
        return (Path[end][1], Path[end][2])
    end
    
    #je cherche entre quelles étapes du chemin se situe l'instant t
    for i in 1:(length(Path) - 1)
        if Path[i][3] <= t < Path[i+1][3]
            return (Path[i][1], Path[i][2])
        end
    end
    
    return nothing
end


#ici j'anime la simulation pas à pas dans le terminal pour visualiser les déplacements
function affiche_Magnifique(G::Matrix{Int64}, results::Vector)
    #je cherche le temps de fin de la simulation (le dernier AMR arrivé)
    t_max = 0.0
    for res in results
        path_amr = res[2]
        if !isempty(path_amr) && path_amr[end][3] > t_max
            t_max = path_amr[end][3]
        end
    end
    temps_total = Int64(round(t_max))
    
    L, C = size(G)
    
    #je boucle sur chaque instant de 0 à t_max pour afficher l'état de la grille
    for t in 0:temps_total
        #j'efface la console et je replace le curseur en haut
        print("\e[2J\e[H") 
        
        println("=====================================")
        println("  SIMULATION CROSS-DOCKING : t = $t")
        println("=====================================\n")
        
        #j'initialise la grille d'affichage avec des cases libres
        #j'utilise 2 caractères par case pour garder l'alignement sinon c'est moche
        Grille_Affichage = fill(". ", L, C)
        
        #je dessine les éléments fixes de la carte 
        for i in 1:L
            for j in 1:C
                if G[i,j] == 0
                    Grille_Affichage[i,j] = "@ "
                elseif G[i,j] == 8
                    Grille_Affichage[i,j] = "W "
                elseif G[i,j] == 5
                    Grille_Affichage[i,j] = "S "
                end
            end
        end
        
        #je place les cases d'arrivée de chaque AMR sur la grille
        for res in results
            id_amr = res[1]
            path_amr = res[2]
            if !isempty(path_amr)
                cible = path_amr[end]
                Grille_Affichage[cible[1], cible[2]] = "A$(id_amr)"
            end
        end
        
        #je place chaque AMR à sa position réelle à l'instant t par-dessus les cibles
        for res in results
            id_amr = res[1]
            path_amr = res[2]
            pos = position_a_t(path_amr, t)
            if pos !== nothing
                Grille_Affichage[pos[1], pos[2]] = "$(id_amr) " #trop pratique $
            end
        end
        
        #j'imprime la grille ligne par ligne
        for i in 1:L
            for j in 1:C
                print(Grille_Affichage[i,j], " ")
            end
            println()
        end
        
        #je marque une pause pour créer l'effet d'animation WOW
        sleep(1)
    end
    println(" Simulation terminée avec succès ! Voici le récapitulatif :")
end
