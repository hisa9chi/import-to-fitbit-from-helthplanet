require 'date'

require_relative './lib/api_util'
require_relative './helthplanet_cfg'

class HelthplanetExporter
  def get_data( targets, from_date, to_date )
    helthplanet_cfg = HelthplanetCfg.new()
    api_util = APIUtil.new()

    # 認可 code の取得
    code = api_util.get_auth_code
    puts "auth code: #{code}"

    # アクセストークンの取得
    access_token = api_util.get_token( code )
    puts "access token: #{access_token}"

    data_tags = helthplanet_cfg.get_data_tags

    # targets からコードを設定
    get_innerscan_data_lists = []
    targets.each do |target|
      get_innerscan_data_lists.push( data_tags[target] )
    end

    # データ取得
    result_data = api_util.get_innerscan_data( access_token, get_innerscan_data_lists, from_date, to_date )

    results = {}
    if result_data.length > 0
      targets.each { |target|
        results[target] = []
      }
    
      result_data.each do |data|
        index = get_innerscan_data_lists.index( data['tag'] )
        results[targets[index]].push( data )
      end
    end
    results
  end
end
