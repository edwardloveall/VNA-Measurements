desc "This task is called by the Heroku cron add-on"
task :purge_tmp do
  dir = './public/tmp/'
  Dir.foreach(dir) do |f|
    if f.match(/^\./)
      next
    else
      # p f
      File.delete(dir + f)
      p "removed #{f}"
    end
  end
end