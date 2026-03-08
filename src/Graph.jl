#Implémentation des maps et fonctions associés

#fonction prenant en entrée une map et renvoie la matrice associée
function map_to_matrix(filename::String)

    #lignes est un Vector{String} avec chaque éléments correspondant à une ligne du fichier map
    lines = readlines(filename) 

    #récupération de la hauteur et de la largeur 
    #split sert a couper une ligne en mot individuel
    H = parse(Int64, split(lines[2])[2]) 
    W = parse(Int64, split(lines[3])[2])  

    #initialisation de la matrice avec la bonne taille
    G = Matrix{Int64}(undef, H, W)

    #on parcourt les lignes de la carte après les 4 lignes d'en-tête
    for i in 1:H
        L = collect(lines[i+4]) 
        #collect transforme la ligne en Vector{Char}
       
        for j in 1:W
            #si le caractère est '.' on met 1  sinon 0 (ie obstacle)
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


#fonction permettant de retourner tout les successeurs du sommet u
function successeurs(G::Matrix{Int64},u::Tuple{Int64,Int64})

    #Variable utile
    S=Vector{Tuple{Int64,Int64}}()
    l , c =size(G)

    #on définis les directions N/S/O/E selon une coordonée
    Direction::Vector{Tuple{Int64,Int64}}=[(0,1),(1,0),(-1,0),(0,-1)]

    
    for s in Direction
    #on construit le tuple associé à une direction données
        i=u[1]+s[1]
        j=u[2]+s[2]

    #Pour pouvoir affirmer que (i,j) est un successeur il doit appartenir à la matrice et G[i,j]==1
        if 1<= i <= l && 1<= j <= c && G[i,j]!=0
            push!(S,(i,j))
        end
    end
    
    return S

end


#Fonction permettant de vérifier que les points sont inclue dans les dimensions de la matrice 
function est_bornee(L,C,P)
    return (1<= P[1] <= L) && (1<= P[2] <= C)
end


#Fonction permettant une affiche propore des résultats obtenue 
function affiche(Path::Vector{Tuple{Int64,Int64}}, Distance::Number, cpt::Int64,t::Float64)
    #Si path est vide c'est que le chemin n'existe pas
    if isempty(Path)
        println("Aucun chemin trouvé")
    else
        println("Distance D → A : ", Distance)
        println("Number of states evaluated : ", cpt)
        println("Time (s) : ", round(t, digits=6))
        #print("Path D → A : ",Path[1])
        #x = length(Path)
        #if x>1
         #   for i in 2:x
          #  print("→",Path[i])
           # end
        #end

        println()
    end
end

#Fonction heuristique de Manhattan
function heuristic(A,s)
    return Float64(abs(A[1]-s[1]) + abs(A[2]-s[2]))
end