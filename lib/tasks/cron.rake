# The advertised totals on the Sherlock page are sometimes incorrect. The
# correct figure appears in parentheses below.
#
# Ahuntsic-Cartierville: XML is missing "de Beauséjour" and "des Hirondelles"
# and has "Camille", another "Berthe-Louard" and another "Saint-Paul-de-la-Croix".
# Lachine: XML is missing one "Duff Court" and has "club pêcheurs/chasseurs" and "Rosewood".
# Le Plateau-Mont-Royal: XML has another "Sir-Wilfrid-Laurier".
# Le Sud-Ouest: XML is missing one "de la Vérendrye" and has "Polyvalente Saint-Henri".
# Rosemont–La Petite-Patrie: XML is missing one "Cité Jardin".
# Ville-Marie: XML is missing "Bassin Bonsecours".
# Villeray–Saint-Michel–Parc-Extension: XML is missing "René-Goupil", "Sainte-Yvette"
# and one "Nicolas-Tillemont" and has "de Normanville" and another "François-Perrault".
#
# Total Borough                                  Sherlock XML Other
#    19 Ahuntsic-Cartierville                     16       17     0 *
#     7 Anjou                                      7        0     0
#    21 Beaconsfield                               0        0    21
#     5 Côte-Saint-Luc                             0        0     5
#    23 Côte-des-Neiges—Notre-Dame-de-Grâce       22       22     1
#    29 Dollard-des-Ormeaux                        ? (29)   0     0
#     7 Dorval                                     0        0     7
#     5 Kirkland                                   0        0     5
#     8 L'Île-Bizard–Sainte-Geneviève              9  (8)   0     0
#     9 LaSalle                                    8        0     1
#    14 Lachine                                   12       13     0 *
#    13 Le Plateau-Mont-Royal                     11 (12)  13     0 *
#    14 Le Sud-Ouest                              13       13     0 *
#    21 Mercier—Hochelaga-Maisonneuve             21       21     0
#     6 Montréal-Nord                              6        0     0
#     3 Montréal-Ouest                             0        0     3
#    10 Outremont                                 10        0     0
#    14 Pierrefonds-Roxboro                       25 (14)   0     0
#     9 Pointe-Claire                              0        0     9
#    18 Rivière-des-Prairies—Pointe-aux-Trembles  18       18     0
#    18 Rosemont–La Petite-Patrie                 18       17     0 *
#    27 Saint-Laurent                             24        0     3
#     8 Saint-Léonard                              8        0     0
#     5 Sainte-Anne-de-Bellevue                    0        0     5
#     3 Senneville                                 0        0     3
#    12 Verdun                                    12        0     0
#     6 Ville-Marie                                6        5     0 *
#    18 Villeray–Saint-Michel–Parc-Extension      15 (16)  15     0 *
#     7 Westmount                                  0        0     7
#                                                         154    63
task :cron => :environment do
  Rake::Task['import:donnees'].invoke
  Rake::Task['import:dorval'].invoke
end
