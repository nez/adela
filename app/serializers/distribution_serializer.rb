class DistributionSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :issued, :modified, :license, :spatial,
             :downloadURL, :mediaType, :format, :byteSize, :temporal, :tools,
             :publishDate, :codelist

  def license
    'https://datos.gob.mx/libreusomx/'
  end

  def downloadURL
    object.download_url
  end

  def mediaType
    object.media_type
  end

  def byteSize
    object.byte_size
  end

  def publishDate
    object.publish_date
  end
end
