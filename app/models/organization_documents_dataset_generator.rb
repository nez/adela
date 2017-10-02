class OrganizationDocumentsDatasetGenerator
  include Rails.application.routes.url_helpers

  def initialize(organization)
    @organization = organization
  end

  def generate!
    dataset = build_dataset
    dataset.sector = Sector.friendly.find('otros')
    build_distribution(dataset)
    dataset.save
  end

  private

    def build_dataset
      @organization.catalog.datasets.build do |dataset|
        dataset.title = "Oficios y Documentos Institucionales de #{@organization.title}"
        dataset.description = "Contiene el Oficio de designación del Enlace y Administrador de Datos vigente, "\
        "así como las minutas celebradas por el Consejo Institucional de Datos Abierto de #{@organization.title}."
        dataset.accrual_periodicity = 'irregular'
        dataset.publish_date = Time.current + 1.week
        dataset.contact_position = ENV_CONTACT_POSITION_NAME
        dataset.mbox = @organization.administrator&.user&.email
        dataset.temporal = "#{Date.current.iso8601}/#{Date.new(2018, 11, 30).iso8601}"
        dataset.keyword = 'oficio,minutas,documentos'
        dataset.data_dictionary = 'https://datos.gob.mx/guia/docs/oficio_designacion_enlace_administrador.docx'
        dataset.editable = false
      end
    end

    def build_distribution(dataset)
      dataset.distributions.build do |distribution|
        distribution.title = "Oficios y Documentos Institucionales de #{@organization.title}"
        distribution.description = "Contiene el Oficio de designación del Enlace y Administrador de Datos vigente, "\
        "así como las minutas celebradas por el Consejo Institucional de Datos Abierto de #{@organization.title}."
        distribution.download_url = documents_api_v1_organization_url(@organization).to_s
        distribution.media_type = 'application/json'
        distribution.format = 'json'
        distribution.modified = Time.current
        distribution.temporal = "#{Date.current.iso8601}/#{Date.new(2018, 11, 30).iso8601}"
        distribution.publish_date = Time.current + 1.week
      end
    end
end
