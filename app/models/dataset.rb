class Dataset < ActiveRecord::Base
  include Publishable
  include DCATCommons
  include Auditable

  belongs_to :catalog

  has_many :distributions, dependent: :destroy

  has_one :dataset_sector, dependent: :destroy
  has_one :sector, through: :dataset_sector
  has_one :organization, through: :catalog

  accepts_nested_attributes_for :dataset_sector
  accepts_nested_attributes_for :distributions, allow_destroy: true

  validates_uniqueness_of :title
  validates :distributions, presence: true

  with_options on: :inventory do |dataset|
    dataset.validates :title, :contact_position, :public_access, :publish_date, presence: true
  end

  with_options on: :catalog do |dataset|
    dataset.validates :description, :accrual_periodicity, :public_access, :publish_date, presence: true
  end

  with_options on: :ckan do |dataset|
    dataset.validates :title, :description, :accrual_periodicity, :publish_date,
                      :contact_position, :mbox, :temporal, :sector, :keyword,
                      :data_dictionary, presence: true
  end

  def identifier
    title.to_slug.normalize.to_s
  end

  def publisher
    catalog.organization.title
  end

  def keywords
    "#{keyword},#{sectors}".chomp(',').lchomp(',').downcase.strip
  end

  def openess_rating
    formats = distributions.map(&:format)
    case
    when formats.grep(/^(xls|xlsx)$/i).present?
      2
    when formats.grep(/^(csv|tsv|psv|json|shp|kml|kmz|xml)$/i).present?
      3
    when formats.grep(/^(rdf)$/i).present?
      4
    when formats.grep(/^(lod)$/i).present?
      5
    else
      1
    end
  end

  private
    def sectors
      catalog.organization.sectors.map(&:slug).join(',')
    end

    def gov_type
      catalog.organization&.gov_type
    end
end
