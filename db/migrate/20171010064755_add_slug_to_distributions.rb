class AddSlugToDistributions < ActiveRecord::Migration
  def change
    add_column :distributions, :slug, :string
    add_index :distributions, :slug, unique: true
  end
end
