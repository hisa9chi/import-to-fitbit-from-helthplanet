require "faraday"
require 'faraday-cookie_jar'
require 'oga'
require 'nkf'
require 'json'

require_relative '../../lib/common_util'
require_relative '../helthplanet_cfg'

# 対象のスコープ
TARGET_SCOPE = 'innerscan'

# oauth のレスポンスタイプ（現在は code のみ対応）
TARGET_RESPONSE_TYPE = 'code'

# 認可のタイプ
TARGET_GRANT_TYPE = 'authorization_code'

# データ取得時の日付タイプ（0:登録日付, 1:測定日付）
FROM_TO_DATE_TYPE = '1'

class APIUtil
  def initialize
    @helthplanet_cfg = HelthplanetCfg.new()

    app_info = @helthplanet_cfg.get_app_info
    @client_id = ENV['HELTHPLANET_CLIENT_ID'] ||= app_info.client_id
    @client_secret = ENV['HELTHPLANET_CLIENT_SECRET'] ||= app_info.client_secret
    @redirect_uri = app_info.redirect_uri

    @api_base_url = @helthplanet_cfg.get_api_base_url

    @conn = Faraday.new( :url => @api_base_url ) do |builder|
      builder.request  :url_encoded
      builder.response :logger
      builder.use      :cookie_jar
      builder.adapter  Faraday.default_adapter
    end
  end

  # 認証認可ページでのログイン実施
  def login_oauth
    user_info = @helthplanet_cfg.get_user_info
    login_id = ENV['HELTHPLANET_LOGIN_ID'] ||= user_info.login_id
    password = ENV['HELTHPLANET_LOGIN_PASSWORD'] ||= user_info.password

    res = @conn.post do |req|
      req.url 'login_oauth.do'
      req.body = {
        :loginId => login_id,
        :passwd => password,
        :send => '1',
        :url => "#{@api_base_url}/oauth/auth?client_id=#{@client_id}&redirect_uri=#{@redirect_uri}&scope=#{TARGET_SCOPE}&response_type=#{TARGET_RESPONSE_TYPE}"
      }
    end

    # 成功した場合は 302 のリダイレクトが返却
    unless res.status == 302
      return false
    end

    return true
  end

  # 認可を実施
  def approval_oauth( oauth_token )
    # Post /oauth/approval.do
    res = @conn.post do |req|
      req.url '/oauth/approval.do'
      req.body = {
        :approval => 'true',
        :oauth_token => oauth_token
      }
    end

  end

  # oauth 認証を行い code を取得
  def get_auth_code
    res = @conn.get do |req|
      req.url '/oauth/auth'
      req.params[:client_id] = @client_id
      req.params[:redirect_uri] = @redirect_uri
      req.params[:scope] = TARGET_SCOPE
      req.params[:response_type] = TARGET_RESPONSE_TYPE
    end

    # ログイン
    unless login_oauth
      puts 'failure: login error.'
      exit(1)
    end

    # 再度リクエスト
    res = @conn.get do |req|
      req.url '/oauth/auth'
      req.params[:client_id] = @client_id
      req.params[:redirect_uri] = @redirect_uri
      req.params[:scope] = TARGET_SCOPE
      req.params[:response_type] = TARGET_RESPONSE_TYPE
    end

    # レスポンスから oauth_token 取り出し
    document = Oga.parse_html( NKF.nkf( '-Sw', res.body ) )
    oauth_token = document.at_xpath( '//input[@name="oauth_token"]' ).get( 'value' )

    # 認証結果を取得
    res = approval_oauth( oauth_token )

    # レスポンスから認可 code 取り出し
    document = Oga.parse_html( NKF.nkf( '-Sw', res.body ) )
    code = document.at_xpath( '//textarea[@id="code"]' ).text
  end

  # 認可コードを�?にaccess_token, refresh_token を取�?
  def get_token( code )
    access_token = ''

    res = @conn.post do |req|
      req.url '/oauth/token'
      req.body = {
        :client_id => @client_id,
        :client_secret => @client_secret,
        :redirect_uri => @redirect_uri,
        :code => code,
        :grant_type => TARGET_GRANT_TYPE
      }
    end

    if res.success?
      if res.status == 200 
        access_token = JSON.parse(res.body)['access_token']
      end
    end

    access_token
  end

  # �?定したデータタグを取得（タグは配�?�で�?定�?
  def get_innerscan_data( access_token, data_tag_list, from_date, to_date )
    data = ''
    tags = data_tag_list.join( ',' )

    res = @conn.get do |req|
      req.url '/status/innerscan.json'
      req.params[:access_token] = access_token
      req.params[:date] = FROM_TO_DATE_TYPE
      req.params[:from] = from_date
      req.params[:to] = to_date
      req.params[:tag] = tags
    end

    if res.success?
      if res.status == 200
        data = JSON.parse( res.body )['data']
      end
    end

    data
  end

end
