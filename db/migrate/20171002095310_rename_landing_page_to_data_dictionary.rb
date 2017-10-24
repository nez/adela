class RenameLandingPageToDataDictionary < ActiveRecord::Migration
  def change
    rename_column :datasets, :landing_page, :data_dictionary
  end
end
