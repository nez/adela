namespace :clear_data do

    desc "Destroy distributions whtiout datasets"
    task destroy_ditributions_without_datasets: :environment do
        Distribution.where(dataset: nil).delete_all
    end
    #NO FUNCIONA
    desc "Destroy datasets without distributions"
    task destroy_datasets_without_distributions: :environment do
        Dataset.includes(:distributions).where(distributions: {id: nil}).destroy_all
    end

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
        class Dataset < ActiveRecord::Base
            belongs_to :catalog
            validates_uniqueness_of :title
        end

        repited_titles = Dataset.where(title: Dataset.select('title').group('title').having('count(*) > 1').pluck(:title) )
        total = repited_titles.size

        #Contador de titulos repetidos
        counts = Hash.new

        repited_titles.each_with_index do |dataset, index|
            #no deberia ser necesaria esta linea
            next unless dataset.catalog && dataset.catalog.organization 

            #rescatando titulo original
            origin_title = dataset.title
            
            #inicializacion de conteo
            counts[origin_title] = 0 unless counts[origin_title]

            #titulo nivel 0
            dataset.title = "#{dataset.title} de #{dataset.catalog.organization.title}"

            unless dataset.save
                #titulo nivel 1
                dataset.title = "#{dataset.title} creado el #{dataset.created_at.strftime('%F %H:%M')}"
            
                unless dataset.save
                    #titulo nivel 2 (con consecutivo no deberia haber repetidos)
                    dataset.title = "#{dataset.title} (#{counts[origin_title] - 1})"
                    dataset.save
                end
            end
            puts "#{index + 1} de #{total} - ID: #{dataset.id}"
            counts[origin_title] += 1
        end
    end

    desc "Fix invalid distribution's title"
    task fix_invalid_title_distribution: :environment do
        class Distribution < ActiveRecord::Base
            belongs_to :dataset
            has_one :catalog, through: :dataset
            has_one :organization, through: :dataset
            validates_uniqueness_of :title
        end
        #Consulta distribucion con titulo repetido
        repited_titles = Distribution.where(title: Distribution.select('title').group('title').having('count(*) > 1').pluck(:title) )
        total = repited_titles.size

        #Contador de titulos repetidos
        counts = Hash.new

        repited_titles.each_with_index do |distribution, index|
            #no deberia ser necesaria esta linea
            next unless distribution.catalog && distribution.catalog.organization 

            #rescatando titulo original
            origin_title = distribution.title

            #inicializacion de conteo
            counts[origin_title] = 0 unless counts[origin_title]

            # titulo nivel 0
            distribution.title = "#{distribution.title} de #{distribution.catalog.organization.title}"
            unless distribution.save
                #titulo nivel 1
                distribution.title = "#{distribution.title} creado el #{distribution.created_at.strftime('%F %H:%M')}"
                unless distribution.save
                    #titulo nivel 2 (con consecutivo no deberia haber repetidos)
                    distribution.title = "#{distribution.title} (#{counts[origin_title] - 1})"
                    distribution.save
                end
            end
            puts "#{index + 1} de #{total} - ID: #{distribution.id}"
            counts[origin_title] += 1
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

    desc "update distribution publish date like dataset"
    task update_distribution_publish_date_like_dataset: :environment do
        Distribution.joins(:dataset).each do |distribution|
            distribution.update_column(:publish_date, distribution.dataset.publish_date)
        end
    end

    desc "Split temporal data distribution"
    task split_temporal_data_distribution: :environment do
        distributions =  Distribution
                            .select("id, temporal, temporal_init_date, temporal_term_date")
                            .where("temporal ~* ?", '^\d{4}\-\d{2}\-\d{2}\/\d{4}\-\d{2}\-\d{2}')
        total = distributions.size
        distributions.each_with_index do |distribution, index|
            begin
                temporal = distribution[:temporal].split('/').map do |date|
                    ISO8601::Date.new(date)
                end
        
                distribution[:temporal_init_date]= temporal[0].to_s
                distribution[:temporal_term_date]= temporal[1].to_s
                distribution.save(:validate=>false)
      
            rescue => error
                puts error
            end
            puts "#{index + 1 } de #{total} ID: #{distribution.id}"
        end
    end

    desc "Split temporal data dataset"
    task split_temporal_data_dataset: :environment do
        datasets =  Dataset
                            .select("id, temporal, temporal_init_date, temporal_term_date")
                            .where("temporal ~* ?", '^\d{4}\-\d{2}\-\d{2}\/\d{4}\-\d{2}\-\d{2}')
        total = datasets.size
        datasets.each_with_index do |dataset, index|
            begin
                temporal = dataset[:temporal].split('/').map do |date|
                    ISO8601::Date.new(date)
                end
                puts dataset.class
                dataset[:temporal_init_date]= temporal[0].to_s
                dataset[:temporal_term_date]= temporal[1].to_s
                dataset.save(:validate=>false)
      
            rescue => error
                puts error
            end
            puts "#{index + 1 } de #{total} ID: #{dataset.id}"
        end
    end
end