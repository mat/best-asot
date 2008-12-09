namespace :cache do

  # Cron use via:
  # cd /to/best-asot && /usr/bin/rake RAILS_ENV=production cache:sweep
  desc 'Sweep Cache'
  task :sweep => :environment do
    puts "Sweeping cache..."
    AsotSweeper::sweep
    RAILS_DEFAULT_LOGGER.flush
  end
end

