class Catalog::DatasetSerializer < DatasetSerializer
  has_many :distributions, root: :distribution, serializer: DistributionSerializer

  def distributions
    object.distributions.where(state: 'published')
  end
end
