#install ruby + rubygems + curl
#sudo gem install grosser-smusher --source http://gems.github.com/

desc "Optimize /public/images via smush.it"
task :smushit do
  system("smusher #{RAILS_ROOT}/public/images")
end

