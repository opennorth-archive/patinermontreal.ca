task cron: :environment do
  Rake::Task['import:montreal'].invoke
  Rake::Task['import:dorval'].invoke
end
