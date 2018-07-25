require 'hashie'

# yml ファイルの path を指定して読み込む
def load_yml_file( path )
  yaml = Hashie::Mash.load( path )
end
