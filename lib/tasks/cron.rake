task :cron => :environment do
  Rake::Task['import:donnees'].invoke
  Rake::Task['import:dorval'].invoke
end
