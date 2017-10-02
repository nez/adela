class DatasetsController < ApplicationController
  include DatasetActions
  before_action :authenticate_user!

  private

  def index_customization
    @catalog = current_organization.catalog
    @datasets = @datasets.includes(:distributions).where(
      public_access: true
    ).order("#{params[:sort]} #{params[:direction]}")
  end

  def edit_customization
    @dataset.dataset_sector || @dataset.build_dataset_sector
  end

  def update_customization
    if @dataset.valid?
      redirect_to edit_dataset_path(@dataset)
      return
    end
    render 'edit'
  end

  def dataset_params
    params.require(:dataset).permit(
      :title,
      :description,
      :publish_date,
      :accrual_periodicity,
      :contact_name,
      :contact_position,
      :mbox,
      :data_dictionary,
      :temporal_init_date,
      :temporal_term_date,
      :spatial,
      :keyword,
      :comments,
      :quality,
      dataset_sector_attributes: [:sector_id]
    )
  end
end
