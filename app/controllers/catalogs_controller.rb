class CatalogsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_opening_plan

  def index
    redirect_to catalog_datasets_path(current_organization.catalog)
    return
  end

  def check
    @datasets = catalog_params['dataset_ids']&.map { |id| Dataset.find(id) } || []
    @distributions = catalog_params['distribution_ids']&.map { |id| Distribution.find(id) } || []
    (@datasets << @distributions&.map(&:dataset)).flatten!.uniq!
  end

  def publish
    @catalog = current_organization.catalog
    publish_catalog
    redirect_to catalog_versions_path
    return
  end

  private

  def catalog_params
    params.require(:catalog).permit(dataset_ids: [], distribution_ids: [])
  end

  def notify_administrator
    administrator = @catalog.organization.administrator
    CatalogMailer.publish_email(@catalog.id, administrator.user.id).deliver_now if administrator
  rescue StandardError => error
    logger.error(error)
  end

  def publish_catalog
    @catalog.publish_date = Time.current
    @catalog.save
    publish_datasets_and_distributions
    harvest_catalog
    notify_administrator
  end

  def publish_datasets_and_distributions
    publish_datasets
    publish_distributions
  end

  def publish_datasets
    catalog_params['dataset_ids']&.each do |id|
      dataset = Dataset.find(id)
      dataset.update_column(:state, 'published')
      dataset.update_column(:issued, Time.current) if dataset.issued.blank?
    end
  end

  def publish_distributions
    catalog_params['distribution_ids']&.each do |id|
      distribution = Distribution.find(id)
      distribution.update_column(:state, 'published')
      distribution.update_column(:issued, Time.current) if distribution.issued.blank?
    end
  end

  def harvest_catalog
    catalog_url = organization_catalog_url(@catalog.organization, format: :json).to_s
    ShogunHarvestWorker.perform_async(catalog_url)
  end

  def require_opening_plan
    return if current_organization.catalog && catalog_contains_editable_and_published_datasets?
    render :error
    return
  end

  def catalog_contains_editable_and_published_datasets?
    current_organization.catalog.datasets.where(editable: true).present?
  end
end
