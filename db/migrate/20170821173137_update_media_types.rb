class UpdateMediaTypes < ActiveRecord::Migration
  def change
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
