
  desc "Start Thin server."
  task :start do
    `nohup thin -C thin/development_config.yml -R thin/config.ru start`
  end

  desc "Stop Thin server."
  task :stop do
    `nohup thin -C thin/development_config.yml -R thin/config.ru stop`
  end

  desc "Restart Thin server."
  task :restart => [:stop, :start] do
    #nothing
  end

  desc "Start Thin server in prodcution environment."
  task 'start:production' do
    `nohup thin -C thin/production_config.yml -R thin/config.ru start`
  end

