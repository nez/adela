class RemoveByteSizeFromDistributions < ActiveRecord::Migration
  def change
  	remove_column :distributions, :byte_size
  end
end
