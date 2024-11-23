require "bundler/setup"
require 'sinatra'
require 'sinatra/reloader'
require "sinatra/activerecord"
#require 'sinatra/bootstrap'
require 'fileutils'
require 'active_support/all'

require 'sinatra/flash'

require 'pagy'
require 'pagy/extras/array'
require 'pagy/extras/bootstrap'

helpers Pagy::Frontend
include Pagy::Backend

require_relative './jobs/record_request_job'

require 'bundler'
Bundler.require

#register Sinatra::Bootstrap::Assets

enable :sessions

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: './db/csv_test.db'
)

class Estimate < ActiveRecord::Base
  self.primary_key = :id

  validates :number, presence: true
end

STATUS_ENUM = { wait: 0, proceed: 1, finish: 2 }
def status_string(val)
  case val
  when 0
    '処理待ち'
  when 1
    '処理中'
  when 2
    '処理完了'
  else
    '処理待ち'
  end
end

CSV_AU_COLUMN = 48

DEFAULT_VIEW_COUNT = 10#300

get '/csv_test' do
  estimates = Estimate.all.order(created_at: :desc)
  @page = (params[:page] || 1).to_i rescue 1
  @full_count = estimates.size
  @view_count = (params[:view_count] || DEFAULT_VIEW_COUNT).to_i rescue DEFAULT_VIEW_COUNT
  Pagy::DEFAULT[:limit] = @view_count
  @pagy, @list = pagy_array(estimates, page: @page)

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

get '/download_csv' do
  redirect to "/csv_test" if params[:filename].blank?

  filename = params[:filename].to_s
  src = "C:\\Users\\07k11\\Desktop\\work\\sinatratest\\#{filename}"
  destination = "C:\\Users\\07k11\\Desktop\\整理中\\#{filename}"
  FileUtils.cp(src, destination)

  flash[:success] = "CSVファイル「#{filename}」をダウンロードしました"
  redirect to "/csv_test"
end


def proceed_single_number(request_number)
  start_time = Time.current
  Estimate.create!(number: request_number, status: STATUS_ENUM[:wait], csv_filename: "個別入力")
  end_time = Time.current

  flash[:success] = "番号「#{request_number}」をリクエストしました"

  # delayedjobに登録
  Delayed::Job.enqueue RecordRequestJob.new(request_numbers: [request_number], start_time: start_time, end_time: end_time)
end

def proceed_multple_numbers(request_number_csv)
  file = params[:request_number_csv]

  if file["type"] != "text/csv"
    flash[:fail] = "ファイル形式が異なります。CSVファイルを選択してください。"
    return
  end

  request_numbers = []
  CSV.foreach(file["tempfile"]) do |row|
    request_numbers.push row[CSV_AU_COLUMN-1]
  end

  start_time = Time.current
  estimates = request_numbers.uniq.map { |request_number| { number: request_number, status: STATUS_ENUM[:wait], csv_filename: file["filename"], created_at: Time.current, updated_at: Time.current } }
  Estimate.insert_all estimates
  end_time = Time.current

  # delayedjobに登録
  Delayed::Job.enqueue RecordRequestJob.new(request_numbers: request_numbers, start_time: start_time, end_time: end_time)

  flash[:success] = "csvファイル「#{file["filename"]}」記載の番号をリクエストしました"
end
