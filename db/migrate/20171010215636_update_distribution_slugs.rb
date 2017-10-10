class UpdateDistributionSlugs < ActiveRecord::Migration
  class Distribution < ActiveRecord::Base
    include FriendlyId

    friendly_id :title, use: [:slugged, :finders]
  end

  def change
    Distribution.find_each(&:save)
  end
end
