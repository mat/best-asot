require 'benchmark'
require 'lib/asot'

ActiveRecord::Base.logger = nil
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  'db/test.sqlite3'
)

Asot.delete_all
srand(42)

def create_some_asots
  1.upto(200) do |i|
    Asot.create!(:no => i, :airdate => Time.at(rand(1_500_000_000)), :votes => rand(120) + 1)
  end
end

create_some_asots

n = 5000
Benchmark.bm(20) do |x|
  Asot.calc_ranks
  x.report("rank:")                 { Asot.all.each{|a| a.rank} }
  x.report("rank (2nd run):")       { Asot.all.each{|a| a.rank} }
  x.report("rank (3nd run):")       { Asot.all.each{|a| a.rank} }
  x.report("yearrank:")             { Asot.all.each{|a| a.yearrank} }
  x.report("yearrank (2nd run):")   { Asot.all.each{|a| a.yearrank} }
  x.report("yearrank (3nd run):")   { Asot.all.each{|a| a.yearrank} }
end

