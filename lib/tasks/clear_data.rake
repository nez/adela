namespace :clear_data do
    desc "Update issued column"
    task update_issued_column: :environment do
        def data_fusion_query(dataset_id)
            url = "https://api.datos.gob.mx/v1/data-fusion?id=#{dataset_id}"
            response = HTTParty.get(url)
        
            JSON.parse(response.body)
        rescue SocketError => e
            puts e
            sleep 10
            retry
        end

        Dataset.find_each do |dataset|
            data_fusion_results = data_fusion_query(dataset.id)['results']
            next if data_fusion_results.blank?
      
            ckan_dataset = data_fusion_results.first['ckan']['dataset']
            next unless ckan_dataset
      
            issued = ckan_dataset['metadata-modified']
            next unless issued
      
            dataset.update_column(:issued, issued)
            dataset.distributions.where(
              state: [
                'published',
                'refined',
                'refining'
              ]
            ).update_all(issued: issued)
        end
    end

    desc "Update state dataset"
    task update_state_dataset: :environment do
        Dataset.where.not(issued: nil).update_all(state: 'published')
        Dataset.where(state: nil).update_all(state: 'broke')
        Dataset.where(state: 'broke').map(&:document)
    end

    desc "Update invalid dataset periodicity"
    task datasete_invalid_periodicity: :environment do
        Dataset.where(accrual_periodicity: nil).update_all(accrual_periodicity: 'irregular')
    end

    desc "Fix invalid dataset's title"
    task fix_invalid_title_dataset: :environment do
        invalid_datasets = Dataset.select(&:invalid?).select do |dataset|
            dataset.errors.messages.has_key?(:title)
        end
      
        invalid_datasets.each do |dataset|
            organization = dataset.catalog.organization.title
            dataset.title = "#{dataset.title} de #{organization}"
      
            unless dataset.save
              created_at = dataset.created_at.strftime('%F %H:%M')
              dataset.title = "#{dataset.title} creado el #{created_at}"
      
              dataset.save
            end
        end
    end

    desc "Destroy datasets without distributions"
    task destroy_datasets_without_distributions: :environment do
        Dataset.includes(:distributions).where(distributions: { id: nil }).destroy_all
    end

    desc "Fix invalid distributions"
    task fix_invalid_distributions: :environment do
        invalid_distributions = Distribution.select(&:invalid?)
        invalid_distributions.each do |distribution|
          organization = distribution.catalog.organization&.title
          next unless organization
    
          distribution.title = "#{distribution.title} de #{organization}"
    
          unless distribution.save
            created_at = distribution.created_at.strftime('%F %H:%M')
            distribution.title = "#{distribution.title} creado el #{created_at}"
    
            distribution.save
          end
        end
    end

    desc "Fix media type"
    task fix_media_type: :environment do
        Distribution.where("media_type ILIKE 'csv'").each do |distribution|
            distribution.update_columns(media_type: 'text/csv', format: 'csv')
        end
    
        Distribution.where("media_type ILIKE 'Excel (Delimitado por comas)'").each do |distribution|
        distribution.update_columns(media_type: 'text/csv', format: 'csv')
        end
    
        Distribution.where("media_type ILIKE 'CSV, EXCEL'").each do |distribution|
        distribution.update_columns(media_type: 'application/vnd.ms-excel', format: 'xls')
        end
    
        Distribution.where("media_type ILIKE 'Documento Excel.'").each do |distribution|
        distribution.update_columns(media_type: 'application/vnd.ms-excel', format: 'xls')
        end
    
        Distribution.where("media_type ILIKE 'excel CSV'").each do |distribution|
        distribution.update_columns(media_type: 'application/vnd.ms-excel', format: 'xls')
        end
    
        Distribution.where("media_type ILIKE 'excel'").each do |distribution|
        distribution.update_columns(media_type: 'application/vnd.ms-excel', format: 'xls')
        end
    
        Distribution.where("media_type ILIKE 'excell'").each do |distribution|
        distribution.update_columns(media_type: 'application/vnd.ms-excel', format: 'xls')
        end
    
        Distribution.where("media_type ILIKE 'excel '").each do |distribution|
        distribution.update_columns(media_type: 'application/vnd.ms-excel', format: 'xls')
        end
    
        Distribution.where("media_type ILIKE 'MS Excel'").each do |distribution|
        distribution.update_columns(media_type: 'application/vnd.ms-excel', format: 'xls')
        end
    
        Distribution.where("media_type ILIKE 'Recurso contenido en Excel'").each do |distribution|
        distribution.update_columns(media_type: 'application/vnd.ms-excel', format: 'xls')
        end
    
        Distribution.where("media_type ILIKE 'xls'").each do |distribution|
        distribution.update_columns(media_type: 'application/vnd.ms-excel', format: 'xls')
        end
    
        Distribution.where("media_type ILIKE 'xlsx'").each do |distribution|
        distribution.update_columns(media_type: 'application/vnd.ms-excel', format: 'xls')
        end
    
        Distribution.where("media_type ILIKE 'json'").each do |distribution|
        distribution.update_columns(media_type: 'application/json', format: 'json')
        end
    
        Distribution.where("media_type ILIKE 'kml'").each do |distribution|
        distribution.update_columns(media_type: 'application/vnd.google-earth.kml+xml', format: 'kml')
        end
    
        Distribution.where("media_type ILIKE 'shp'").each do |distribution|
        distribution.update_columns(media_type: '', format: 'shp')
        end
    
        Distribution.where("media_type ILIKE 'shape'").each do |distribution|
        distribution.update_columns(media_type: '', format: 'shp')
        end
    
        Distribution.where("media_type ILIKE 'kmz'").each do |distribution|
        distribution.update_columns(media_type: 'application/vnd.google-earth.kmz', format: 'kmz')
        end
    
        Distribution.where('format IS NULL').each do |distribution|
        new_format = distribution.media_type
        distribution.update_columns(media_type: '', format: new_format)
        end
    end

    desc "Split temporal data"
    task split_temporal_data: :environment do
        Dataset.where.not(temporal: nil).map do |dataset|
            begin
              temporal = dataset[:temporal].split('/').map do |date|
                ISO8601::Date.new(date)
              end
      
              next if temporal.size != 2
      
              dataset.update(
                temporal_init_date: temporal[0].to_s,
                temporal_term_date: temporal[1].to_s
              )
            rescue => error
              puts error
              next
            end
        end
      
        Distribution.where.not(temporal: nil).map do |distribution|
            begin
                temporal = distribution[:temporal].split('/').map do |date|
                ISO8601::Date.new(date)
                end
        
                next if temporal.size != 2
        
                distribution.update(
                temporal_init_date: temporal[0].to_s,
                temporal_term_date: temporal[1].to_s
                )
            rescue => error
                puts error
                next
            end
        end
    end

    desc "Update media type"
    task update_media_type: :environment do
        csv_url  = 'https://gist.githubusercontent.com/babasbot/3ca79415d045fb70846355af7798c1ab/raw/c2cb482fca67555dfa512754487d4e34b1a629ec/cambios-de-formato.csv'
        csv_file = open(csv_url)
    
        CSV.foreach(csv_file, headers: true) do |row|
          begin
            distribution = Distribution.find(row['id'])
            distribution.update_column(:format, row['final-format'])
          rescue StandardError => error
            puts "{ 'error': '#{error}', 'distribution_id': #{row['id']}}"
          end
        end
    end
end