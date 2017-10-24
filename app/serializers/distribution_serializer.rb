class DistributionSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :title,
    :description,
    :issued,
    :modified,
    :license,
    :spatial,
    :downloadURL,
    :mediaType,
    :format,
    :temporal,
    :tools,
    :publishDate,
    :codelist,
    :codelistLink,
    :dataset,
    :copyright,
    :createdAt,
  )

  def license
    'https://datos.gob.mx/libreusomx/'
  end

  def downloadURL
    object.download_url
  end

  def mediaType
    object.media_type
  end

  def publishDate
    object.publish_date
  end

  def codelistLink
    object.codelist_link
  end

  def dataset
    {
      accrualPeriodicity: object.dataset&.accrual_periodicity,
    }
  end

  def createdAt
    object.created_at
  end
end
