# lib/tasks/deadweight.rake
begin
  require 'deadweight'
rescue LoadError
end

desc "run Deadweight CSS check (requires script/server)"
task :deadweight do
  dw = Deadweight.new
  dw.root = 'http://localhost:4567'
  dw.stylesheets = ["/asot.css"]
  dw.pages = ["/", "/by-rank"]
  dw.ignore_selectors = /td.onair|flash_error|errorExplanation|fieldWithErrors/
  puts dw.run
end
