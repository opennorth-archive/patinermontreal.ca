class AddSourceToArrondissement < ActiveRecord::Migration
  def change
    add_column :arrondissements, :source, :string
  end
end
