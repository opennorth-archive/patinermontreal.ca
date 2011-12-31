class AddSlugToPatinoires < ActiveRecord::Migration
  def change
    add_column :patinoires, :slug, :string
  end
end
