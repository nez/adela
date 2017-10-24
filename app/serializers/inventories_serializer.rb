class InventoriesSerializer < ActiveModel::Serializer
  has_many :datasets, root: :dataset, serializer: DatasetSerializer

  def attributes
    data ||= {}
    data[:title] = "Plan de Apertura Institucional de #{object.organization&.title}"
    data.merge super
  end
end
