require 'csv'

class RecordRequestJob
  def initialize(request_numbers:, start_time:, end_time:) # ←修正！！！！！
    @request_numbers = (request_numbers || [])
    @start_time = start_time # ←追加！！！！！
    @end_time = end_time # ←追加！！！！！
  end

  def perform
    return if @request_numbers.blank? # ←追加！！！！！

    # update_allの場合、1つずつ資料ダウンロードが完了したものから順に更新することはできない
    # これは、見積もり取得ツール完了後に、その旨をコードで受け取ることができないため
    # →Teamsで完了通知が飛んでおり、ユーザは最終的にそちらで状況確認できるため問題なし
    Estimate.where(number: @request_numbers, status: 0, created_at: @start_time..@end_time).update_all(status: 1) # ←修正！！！！！

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

    Estimate.where(number: @request_numbers, status: 1, created_at: @start_time..@end_time).update_all(status: 2) # ←修正！！！！！
  end
end
