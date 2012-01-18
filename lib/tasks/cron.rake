# The advertised totals on the Sherlock page are sometimes incorrect. The
# correct figure appears in parentheses below.
#
# 
#
# Ahuntsic-Cartierville: XML is missing "de Beauséjour" and "des Hirondelles"
# and has "Camille", another "Berthe-Louard" and another "Saint-Paul-de-la-Croix".
# Côte-des-Neiges—Notre-Dame-de-Grâce: XML has "Dunkerque".
# Lachine: XML is missing one "Duff Court" and has "club pêcheurs/chasseurs" and "Rosewood".
# Le Plateau-Mont-Royal: XML has another "Sir-Wilfrid-Laurier".
# Le Sud-Ouest: XML has "Polyvalente Saint-Henri".
# Outremont: XML is missing one "Pratt".
# Rosemont–La Petite-Patrie: XML is missing one "Cité Jardin" and has another "Beaubien".
# Saint-Léonard: XML is missing "Coubertin", "Guiseppe-Garibaldi" and two "Saint-Léonard"
# and has two "C.C.S.L." and "Luigi-Pirandello".
# Ville-Marie: XML is missing "Bassin Bonsecours" and has another "Walter-Stewart".
# Villeray–Saint-Michel–Parc-Extension: XML is missing "René-Goupil" and has
# "de Normanville" and another "François-Perrault".
#
# Total Borough                                  Sherlock XML Other
#    19 Ahuntsic-Cartierville                     16       17     0 *
#     7 Anjou                                      7        0     0
#       Baie-d'Urfé
#    21 Beaconsfield                               0        0    21
#    24 Côte-des-Neiges—Notre-Dame-de-Grâce       22       23     1 *
#     5 Côte-Saint-Luc                             0        0     5
#    29 Dollard-des-Ormeaux                        ? (29)   0     0
#     7 Dorval                                     0        0     7
#       Hampstead
#     5 Kirkland                                   0        0     5
#    14 Lachine                                   12       13     0 *
#     9 LaSalle                                    8        0     1
#    13 Le Plateau-Mont-Royal                     11 (12)  13     0 *
#    14 Le Sud-Ouest                              13       14     0 *
#     8 L'Île-Bizard–Sainte-Geneviève              9  (8)   0     0
#       L'Île-Dorval
#    21 Mercier—Hochelaga-Maisonneuve             21       21     0
#       Montréal-Est
#     6 Montréal-Nord                              6        0     0
#     3 Montréal-Ouest                             0        0     3
#       Mont-Royal
#    10 Outremont                                 10        9     0 *
#    14 Pierrefonds-Roxboro                       25 (14)   0     0
#     9 Pointe-Claire                              0        0     9
#    18 Rivière-des-Prairies—Pointe-aux-Trembles  18       18     0
#    19 Rosemont–La Petite-Patrie                 17 (18)  18     0 *
#     5 Sainte-Anne-de-Bellevue                    0        0     5
#    27 Saint-Laurent                             24        0     3
#    11 Saint-Léonard                              8        7     0 *
#     3 Senneville                                 0        0     3
#    12 Verdun                                    12        0     0
#     9 Ville-Marie                                6        6     2 *
#    18 Villeray–Saint-Michel–Parc-Extension      15 (16)  17     0 *
#     7 Westmount                                  0        0     7
#                                                         176    72
#
# http://depot.ville.montreal.qc.ca/patinoires/data.xml
# http://www11.ville.montreal.qc.ca/sherlock2/servlet/template/sherlock%2CAfficherDocumentInternet.vm/nodocument/154
task :cron => :environment do
  Rake::Task['import:donnees'].invoke
  Rake::Task['import:dorval'].invoke
end
