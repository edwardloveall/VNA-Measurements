dir = './public/tmp/'
Dir.foreach(dir) do |f|
  if f.match(/^\./)
    next
  else
    # p f
    File.delete(dir + f)
  end
end