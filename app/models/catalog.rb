class Catalog < ActiveRecord::Base
  include Auditable
  include Loggable

  belongs_to :organization

  has_many :datasets, dependent: :destroy
  has_many :distributions, through: :datasets

  validates_presence_of :organization_id

  accepts_nested_attributes_for :datasets

  def inventory_datasets
    datasets.where(public_access: true, editable: true).select do |dataset|
      dataset.valid?(:inventory)
    end
  end

  def catalog_datasets
    datasets.includes(:distributions).where(public_access: true).select do |dataset|
      dataset.valid?(:catalog)
    end
  end

  def editable_datasets
    datasets.where(editable: true)
  end

  def non_editable_datasets
    datasets.where(editable: false)
  end
end
