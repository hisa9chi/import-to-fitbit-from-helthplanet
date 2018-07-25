require_relative '../lib/common_util'

# fitbit 用の設定ファイルへの相対パス
FITBIT_CONFIG_FILE_RELATIVE_PATH = 'config/fitbit.cfg.yml'

class FitbitCfg
  def initialize
    cfg_file_path = File.join( File.dirname(__FILE__), FITBIT_CONFIG_FILE_RELATIVE_PATH )
    @config = load_yml_file( cfg_file_path )
  end

  def get_api_base_url
    @config.api_base_url
  end

  def get_app_info
    @config.app_info
  end

  def get_auth_info
    @config.auth_info
  end

end
