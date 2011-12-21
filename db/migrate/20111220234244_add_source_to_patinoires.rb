class AddSourceToPatinoires < ActiveRecord::Migration
  def change
    add_column :patinoires, :source, :string
  end
end
