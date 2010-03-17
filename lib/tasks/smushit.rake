
desc "Optimize public/images via smush.it"
task :smushit do
  system("smusher public/images")
end

