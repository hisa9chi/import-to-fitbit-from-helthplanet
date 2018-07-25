require_relative '../lib/common_util'

# helthplanet 用の設定ファイルへの相対パス
HELTHPLANET_CONFIG_FILE_RELATIVE_PATH = 'config/helthplanet.cfg.yml'

class HelthplanetCfg
  def initialize
    cfg_file_path = File.join( File.dirname(__FILE__), HELTHPLANET_CONFIG_FILE_RELATIVE_PATH )
    @config = load_yml_file( cfg_file_path )
  end

  def get_api_base_url
    @config.api_base_url
  end

  def get_user_info
    @config.user_info
  end

  def get_app_info
    @config.app_info
  end

  def get_data_tags
    @config.data_tags
  end

end
