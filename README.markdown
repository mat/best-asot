## Best ASOT ever

### Cron jobs

	# On every THURSDAY, at 10:00
	0 10 * * 4      cd /to/best-asot/current && /usr/local/bin/rake RAILS_ENV=production db:add_episode_for_today >/dev/null 2>&1

	# On every THURSDAY, at 20:08, 20:16, 20:24, ...
	*/8 20-21 * * 4 cd /to/best-asot/current && /usr/local/bin/rake RAILS_ENV=production db:update_latest_asot >/dev/null 2>&1

	# On every THURSDAY, from 20:05 - 20:15
	5-20 20 * * 4   cd /to/best-asot/current && /usr/local/bin/rake RAILS_ENV=production db:set_playing_track_url >/dev/null 2>&1

	# On every THURSDAY at 22:10: Update graphs
	10 22 * * 4     cd /to/best-asot/current && /usr/local/bin/rake RAILS_ENV=production votes_by_year_png >/dev/null 2>&1

	# On every THURSDAY at 22:12: Nuke "running now" label
	12 22 * * 4     cd /to/best-asot/current && /usr/local/bin/rake RAILS_ENV=production cache:sweep >/dev/null 2>&1

	# On every day at 07:00
	0 7 * * *       cd /to/best-asot/current && /usr/local/bin/rake RAILS_ENV=production cache:sweep >/dev/null 2>&1
	
	# At minute 42 of every hour
	42 * * * *      cd /to/best-asot/current && /usr/local/bin/rake RAILS_ENV=production db:update_latest_asot >/dev/null 2>&1 

	# Backup sqlite db
	# At minute 45 of every hour
	45 * * * * /to/best-asot/script/backup-asot-db

[backup-asot-db](http://github.com/mat/best-asot/tree/master/script/backup-asot-db)



