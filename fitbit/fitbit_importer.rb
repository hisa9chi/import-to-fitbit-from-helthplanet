require 'fitbit_api'

require_relative './fitbit_cfg'

UNIT_SYSTEM = 'METRIC'

class FitbitImporter
  def initialize
    @fitbit_cfg = FitbitCfg.new()

    # アプリケーション情報
    app_info = @fitbit_cfg.get_app_info
    @client_id = ENV['FITBIT_CLIENT_ID'] ||= app_info.client_id
    @client_secret = ENV['FITBIT_CLIENT_SECRET'] ||= app_info.client_secret
    @redirect_uri = app_info.redirect_uri
  end

  # AuthorizationCode を取得するためのURLを取得
  def get_auth_url
    client = FitbitAPI::Client.new(
      unit_system: UNIT_SYSTEM,
      client_id: @client_id,
      client_secret: @client_secret,
      redirect_uri: @redirect_uri
    )
    puts client.auth_url
  end

  # AuthorizationCode を用いて AccessToken と RefreshToken を取得
  def get_new_token( auth_code )
    client = FitbitAPI::Client.new(
      unit_system: UNIT_SYSTEM,
      client_id: @client_id,
      client_secret: @client_secret,
      redirect_uri: @redirect_uri
    )

    res = client.get_token( auth_code )
    access_token = res.token
    refresh_token = res.refresh_token

    output_token_to_file( res.token, res.refresh_token )
  end

  # AccessToken を新たに取得して体重と体脂肪を登録
  def import_weight_data( refresh_token, datas )
    # AccessToken/RefreshToken の更新
    client = update_access_token( refresh_token )

    # 体重のインポート
    import_weight( client, datas['weight'] )
    # 体脂肪のインポート
    import_fat( client, datas['fat'] )
  end

  # RehreshToken を用いて AccessToken の更新
  def update_access_token( refresh_token )
    client = FitbitAPI::Client.new(
      unit_system: UNIT_SYSTEM,
      client_id: @client_id,
      client_secret: @client_secret,
      refresh_token: refresh_token
    )
    output_token_to_file( client.token.token, client.token.refresh_token )

    client
  end

  # 体重を登録
  def import_weight( client, datas )
    datas.each { |data|
      req_data = create_request_data( 'weight', data )
      res = client.log_weight( req_data )
      puts res
    }
  end

  # 体脂肪を登録
  def import_fat( client, datas )
    datas.each { |data|
      req_data = create_request_data( 'fat', data )
      res = client.log_body_fat( req_data )
      puts res
    }
  end

  def create_request_data( key, data )
    create_date = Time.parse( data['date'] ).strftime( "%Y-%m-%d" )
    value = data['keydata']

    req_data = { 'date' => create_date, key => value }
  end

  # アクセストークンとリフレッシュトークンをファイルに出力
  def output_token_to_file( access_token, refresh_token )
    puts "AccessToken:#{access_token}"
    puts "RefreshToken:#{refresh_token}"

    File.open( 'token_info', "w") do |file|
      file.puts( "AccessToken:#{access_token}" )
      file.puts( "RefreshToken:#{refresh_token}" )
    end
  end
end
