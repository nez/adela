class Dataset < ActiveRecord::Base
  belongs_to :catalog

  has_many :distributions, dependent: :destroy

  has_one :dataset_sector, dependent: :destroy
  has_one :sector, through: :dataset_sector

  accepts_nested_attributes_for :dataset_sector

  def publisher
    catalog.organization.title
  end

  def keywords
    "#{keyword},#{sectors}".chomp(',').lchomp(',').downcase.strip
  end

  private

  def sectors
    catalog.organization.sectors.map(&:slug).join(',')
  end
end
