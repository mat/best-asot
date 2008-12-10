## Best ASOT ever

### Cron jobs


	# On every day at 07:00
	0 7 * * * cd /to/best-asot && /usr/local/bin/rake RAILS_ENV=production cache:sweep >/dev/null 2>&1
	
	# At minute 42 of every hour
	42 * * * * cd /to/best-asot && /usr/local/bin/rake RAILS_ENV=production db:update_latest_asot >/dev/null 2>&1 

	# Backup sqlite db
	# At minute 45 of every hour
	45 * * * * cd ~/backup/asot && rsync -az -q -b --suffix=-`date +%Y-%m-%d-%H-%M-%S` better-idea.org\:/to/best-asot/db/production.sqlite3 . >/dev/null 2>&1 

