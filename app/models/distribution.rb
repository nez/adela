class Distribution < ActiveRecord::Base
  include Versionable
  include Publishable
  include DCATCommons
  include FriendlyId

  friendly_id :title, use: [:slugged, :finders]

  belongs_to :dataset
  audited associated_with: :dataset

  validates_uniqueness_of :title
  validates_uniqueness_of :download_url, allow_nil: true
  validate :validate_modified_not_higher_today

  has_one :catalog, through: :dataset
  has_one :organization, through: :dataset

  after_commit :update_dataset_metadata

  with_options on: :ckan do |distribution|
    distribution.validates :title, :description, :download_url, :publish_date,
                           :format, :modified, :temporal, presence: true
  end

  alias_attribute :identifier, :slug

  def as_csv(options = {})
    if options[:style] == :inventory
      {
        'Responsable': dataset.contact_position,
        'Nombre del conjunto': dataset.title,
        'Nombre del recurso': title,
        '¿De qué es?': description,
        '¿Tiene datos privados?': dataset.public_access ? 'Publico' : 'Privado',
        'Razón por la cual los datos son privados': nil,
        '¿En qué plataforma, tecnología, programa o sistema se albergan?': media_type,
        'Fecha estimada de publicación en datos.gob.mx': dataset.publish_date&.strftime('%F')
      }
    else
      attributes
    end
  end

  private

    def update_dataset_metadata
      return unless dataset
      return unless modified
      return unless dataset.modified
      dataset.update_attribute(:modified, modified) if dataset.modified < modified
    end

    def validate_modified_not_higher_today
      unless modified.nil?
        errors.add(:modified, 'El valor del campo "Fecha de última modificación de datos" debe ser menor a la fecha actual.') if modified > Time.now
      end
    end

    def should_generate_new_friendly_id?
      title_changed? || super
    end
end
