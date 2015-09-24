class Inventory < ActiveRecord::Base
  mount_uploader :spreadsheet_file, FileUploader
  mount_uploader :authorization_file, FileUploader

  validates_presence_of :spreadsheet_file
  validates :organization, presence: true
  validate :duplicated_datasets, :compliant_elements

  belongs_to :organization

  has_many :inventory_elements, dependent: :destroy

  after_create :create_inventory_elements

  def datasets
    dataset_titles.map do |title|
      inventory_elements.find { |element| element.dataset_title == title }
    end
  end

  private

  def create_inventory_elements
    InventoryXLSXParserWorker.perform_async(id)
  end

  def compliant_elements
    warnings.add(:inventory_elements) unless inventory_elements.all?(&:compliant?)
  end

  def duplicated_datasets
    warnings.add(:inventory_elements, :duplicated) if duplicated_datasets?
  end

  def duplicated_datasets?
    dataset_titles.detect { |e| dataset_titles.count(e) > 1 }.present?
  end

  def dataset_titles
    inventory_elements.chunk(&:dataset_title).map(&:first)
  end
end
