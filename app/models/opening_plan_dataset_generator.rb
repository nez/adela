class OpeningPlanDatasetGenerator
  include Rails.application.routes.url_helpers
  attr_reader :inventory

  def initialize(inventory)
    @inventory = inventory
  end

  def generate
    if inventory_dataset.present?
      update_dataset_and_distribution
    else
      create_dataset_and_distribution
    end
  end

  private

  def update_dataset_and_distribution
    update_dataset
    update_distribution
  end

  def update_dataset
    dataset = inventory_dataset
    dataset.modified = Time.current.iso8601
    dataset.distributions.first
    dataset.save
  end

  def update_distribution
    distribution = inventory_dataset.distributions.first
    distribution.modified = Time.current.iso8601
    distribution.temporal = build_temporal(distribution.modified)
    distribution.save
  end

  def inventory_dataset
    @inventory.organization.catalog.datasets.where("title LIKE 'Plan de Apertura Institucional%'").last
  end

  def create_dataset_and_distribution
    dataset = build_dataset
    build_distribution(dataset)
    build_sector(dataset) if @inventory.organization.sectors.present?
    dataset.save
  end

  def build_dataset
    @inventory.organization.catalog.datasets.build do |dataset|
      dataset.title = "Plan de Apertura Institucional de #{@inventory.organization.title}"
      dataset.description = "Plan de Apertura Institucional de #{@inventory.organization.title}"
      dataset.keyword = 'plan de apertura'
      dataset.modified = Time.current.iso8601
      dataset.contact_position = ENV_CONTACT_POSITION_NAME
      dataset.mbox = organization_administrator.try(:email)
      dataset.temporal = Time.current.year
      dataset.data_dictionary = @inventory.organization.landing_page
      dataset.accrual_periodicity = 'irregular'
      dataset.publish_date = DateTime.new(2015, 8, 28)
      dataset.editable = false
    end
  end

  def organization_administrator
    @inventory.organization.administrator.try(:user)
  end

  def build_sector(dataset)
    dataset.build_dataset_sector do |dataset_sector|
      dataset_sector.sector_id = @inventory.organization.sectors.first.id
    end
  end

  def build_temporal(date)
    "2015-08-28/" + date.strftime("%Y-%m-%d")
  end

  def build_distribution(dataset)
    dataset.distributions.build do |distribution|
      distribution.title = "Plan de Apertura Institucional de #{@inventory.organization.title}"
      distribution.description = "Plan de Apertura Institucional de #{@inventory.organization.title}"
      distribution.download_url = organization_inventory_url(@inventory.organization, format: :csv).to_s
      distribution.media_type = 'csv'
      distribution.publish_date = DateTime.new(2015, 8, 28)
      distribution.temporal = build_temporal(dataset.modified)
      distribution.modified = dataset.modified
    end
  end
end
