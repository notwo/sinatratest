require 'csv'

class RecordRequestJob
  def initialize(request_numbers:)
    @request_numbers = (request_numbers || [])
  end

  def perform
    puts @request_numbers.inspect
    return if @request_numbers.blank?

    output_dir = 'C:/Users/07k11/Desktop/work/sinatratest'
    filename = "#{output_dir}/requests_#{Time.now.in_time_zone('Tokyo').strftime('%Y%m%d%H%M%S')}.csv"

    # csv出力
    csv_nils = Array.new(47)
    CSV.open(filename, 'w') do |row|
      @request_numbers.each do |request_number|
        row << csv_nils + [request_number]
      end
    end

    # pythonスクリプトの実行
    result = system('python .\test.py')
    puts result
  end
end