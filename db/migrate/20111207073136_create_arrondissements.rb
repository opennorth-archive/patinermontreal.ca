class CreateArrondissements < ActiveRecord::Migration
  def change
    create_table :arrondissements do |t|
      t.string :nom_arr
      t.string :cle
      t.datetime :date_maj
      t.text :remarques

      t.timestamps
    end
  end
end
