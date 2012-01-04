class AddFieldsToArrondissements < ActiveRecord::Migration
  def change
    add_column :arrondissements, :name, :string
    add_column :arrondissements, :email, :string
    add_column :arrondissements, :tel, :string
    add_column :arrondissements, :ext, :string
    remove_column :arrondissements, :remarques, :string
  end
end
