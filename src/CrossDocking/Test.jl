include("Main.jl")

println("=== TEST 1.1 : Sans conflit ===")
liste_tests_1 = [
    ((1,1), (8,10), 0.0),
    ((1,2), (8,9),  5.0),
]
try
    results = Lancement_Configuration(2, liste_tests_1, "MAP_test1.map")
    println("Test 1 terminé.")
catch e
    println("Test 1 échoué.")
end

println("\n=== TEST 2 : Avec conflit ===")
liste_tests_2 = [
    ((1,1),  (8,10), 0.0),
    ((1,10), (8,1),  0.0),
]
try
    results = Lancement_Configuration(2, liste_tests_2, "MAP_test1.map")
    println("Test 2 terminé.")
catch e
    println("Test 2 échoué.")
end  

include("Main.jl")
println("\n=== TEST 3 : Avec conflit ===")
liste_tests = [
    ((1,1), (1,9), 0.0),   # AMR 1 : gauche → droite ligne 1
    ((1,9), (1,1), 0.0),   # AMR 2 : droite → gauche ligne 1, même ligne
]
try
    results = Lancement_Configuration(2, liste_tests, "MAP_test2.map")
    println("Test 2 terminé.")
catch e
    println("Test 2 échoué.")
    @error "Erreur" exception=(e, catch_backtrace())
end 

println("\n=== TEST 4 : Avec conflit ===")
liste_tests = [
    ((1,1), (1,10), 0.0),   # AMR 1 : gauche → droite ligne 1
    ((1,10), (1,1), 0.0),   # AMR 2 : droite → gauche ligne 1, même ligne
]
try
    results = Lancement_Configuration(2, liste_tests, "MAP_test1.map")
    println("Test 2 terminé.")
catch e
    println("Test 2 échoué.")
    @error "Erreur" exception=(e, catch_backtrace())

end 

println("\n=== TEST 5: Avec conflit ===")
liste_tests = [
    ((1,4), (1,10), 0.0),   # AMR 1 : gauche → droite ligne 1
    ((1,7), (1,1), 0.0),   # AMR 2 : droite → gauche ligne 1, même ligne
]
try
    results = Lancement_Configuration(2, liste_tests, "MAP_test1.map")
    println("Test 2 terminé.")
catch e
    println("Test 2 échoué.")
    @error "Erreur" exception=(e, catch_backtrace())

end 

println("\n=== Exemple 1 de la présentation  ===")
liste_ex1 = [
    ((2,1), (2,8), 0.0),   # AMR1 : gauche → droite
    ((2,8), (2,1), 0.0),   # AMR2 : droite → gauche (conflit direct)
]

try
    results1 = Lancement_Configuration(2, liste_ex1, "MAP_Exemple1.map")
    println("\nTest Exemple 1 terminé.")
catch e
    println("\nTest Exemple 1 échoué.")
    @error "Erreur" exception=(e, catch_backtrace())
end

println("\n=== Exemple 2 de la présentation  ===")
liste_ex2 = [
    ((11,19), (1,19),  1.0),   # AMR1 : quai 5 bas → quai 5 haut
    ((4,19),  (11,19), 3.0),   # AMR2 : quai 5 haut → quai 5 bas (conflit avec AMR1)
    ((1,9),   (1,24),  1.0),   # AMR3 : quai 2 haut → quai 6 haut
    ((1,4),   (11,29), 2.0),   # AMR4 : quai 1 haut → quai 7 bas
    ((11,4),  (11,14), 6.0),   # AMR5 : quai 1 bas  → quai 3 bas
]

try
    results2 = Lancement_Configuration(5, liste_ex2, "MAP_Exemple2.map")
    println("\nTest Exemple 2 terminé.")
catch e
    println("\nTest Exemple 2 échoué.")
    @error "Erreur" exception=(e, catch_backtrace())
end