require_relative 'helthplanet/helthplanet_exporter'
require_relative 'fitbit/fitbit_importer'

# エクスポート/インポート対象のデータ
# helthplanet/config/helthplanet.cfg.yml 内の data_tags のキーを指定
TARGET_DATA = [
  'weight',
  'fat'
]

fitbit_importer = FitbitImporter.new()
helthplanet_exporter = HelthplanetExporter.new()

cmd = ARGV[0]
option = ARGV[1]

def create_import_data

end

case cmd
when 'auth_url'
  # AuthorizationCode 取得用のURL取得
  fitbit_importer.get_auth_url
when 'new_token'
  # AuhorizationCode 引数に与えて AccessToken,RefreshTokenを取得
  fitbit_importer.get_new_token( option )
when 'rsync'
  # データの取得範囲 ( from to ) を設定
  today = Date.today
  from_date = today.strftime( "%Y%m%d%H%M%S" )
  to_date = today.next_day(1).strftime( "%Y%m%d%H%M%S" )

  # Helthplanet からデータを取得して Fitbit へ登録
  datas = helthplanet_exporter.get_data( TARGET_DATA, from_date, to_date )
  puts datas
  # 第二引数でトークンを指定していればそちらを優先
  # 指定していなければ環境変数を利用
  rehresh_token = option ||= ENV['FITBIT_REFRESH_TOKEN']

  fitbit_importer.import_weight_data( rehresh_token, datas )  
else
  puts 'command error.'
end
  