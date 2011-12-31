class CreatePatinoires < ActiveRecord::Migration
  def change
    create_table :patinoires do |t|
      t.string :nom
      t.string :description
      t.string :genre
      t.string :disambiguation
      t.boolean :ouvert
      t.boolean :deblaye
      t.boolean :arrose
      t.boolean :resurface
      t.string :condition
      t.string :parc
      t.string :adresse
      t.string :tel
      t.string :ext
      t.float :lat
      t.float :lng
      t.references :arrondissement

      t.timestamps
    end
    add_index :patinoires, :arrondissement_id
  end
end
