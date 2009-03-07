namespace :thin do

  desc "Start Thin server."
  task :start do
    `nohup thin -C thin/development_config.yml -R thin/config.ru start`
  end

  desc "Stop Thin server."
  task :stop do
    `nohup thin -C thin/development_config.yml -R thin/config.ru stop`
  end
end

