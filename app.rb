require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/bootstrap'

require 'kaminari'

require 'bundler'
Bundler.require

register Sinatra::Bootstrap::Assets

ActiveRecord::Base.establish_connection(
	adapter: 'sqlite3',
	database: './db/csv_test.db'
)

class Estimate < ActiveRecord::Base
  self.primary_key = :id

  validates :number, presence: true
end

CSV_AU_COLUMN = 48

get '/csv_test' do
  estimates = Estimate.all
  page = params[:page].to_i rescue 1
  @list = estimates.page(page).reverse_order.per(10)

  erb :csv_test_index
end

post '/csv_test_create' do
  if params.key?(:request_number)
    proceed_single_number(params[:request_number].to_i)
  elsif params.key?(:request_number_csv)
    proceed_multple_numbers(params[:request_number_csv])
  end

  redirect to "/csv_test"
end

def proceed_single_number(request_number)
  Estimate.create!(request_number: request_number, status: 0)
  flash[:success] = "番号#{request_number}をリクエストしました"

  # delayedjobに登録
  #RecordRequestJob.perform_later(request_numbers: [request_number])
end

def proceed_multple_numbers(request_number_csv)
  if request_number_csv.content_type != "text/csv"
    flash[:fail] = "ファイル形式が異なります。CSVファイルを選択してください。"
    return
  end

  file = request_number_csv.tempfile
  request_numbers = []
  CSV.foreach(file) do |row|
    request_numbers.push row[CSV_AU_COLUMN-1]
  end

  estimates = request_numbers.uniq.map { |request_number| { request_number: request_number, status: 0, created_at: Time.current, updated_at: Time.current } }
  Estimate.insert_all estimates

  # delayedjobに登録
  #RecordRequestJob.perform_later(request_numbers: request_numbers)

  flash[:success] = "csvファイル「#{request_number_csv.original_filename}」記載の番号をリクエストしました"
end
