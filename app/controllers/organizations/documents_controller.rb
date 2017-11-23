class Organizations::DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :create_documents_dataset, only: :update

  def update
    if organization_params? && current_organization.update(organization_params)
      flash[:notice] = I18n.t('flash.notice.organization.documents.update')
    else
      flash[:error] = I18n.t('flash.notice.organization.documents.error')
    end

    redirect_to organization_documents_path
    return
  end

  private

    def organization_params
      params.require(:organization).permit(
        designation_files_attributes: [:file],
        memo_files_attributes: [:file],
        ministry_memo_files_attributes: [:file]
      )
    end

    def organization_params?
      params[:organization].present?
    end

    def create_documents_dataset
      return if documents_count > 0
      generator = OrganizationDocumentsDatasetGenerator.new(current_organization)
      generator.generate!
    end

    def documents_count
      organization = current_organization
      organization.memo_files.count + organization.ministry_memo_files.count + organization.designation_files.count
    end
end
