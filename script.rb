require 'sinatra'

get '/' do
  erb :index
end

post '/' do # after form submit
  @file_collection = Array.new
  @file_string = ''
  
  @error = "No file selected" if params.empty?
  
  params.each do |file|
    next if file[1][:filename].nil?
    
    deal_with_file(file)
  end
  
  erb :results
end

def deal_with_file(file)
  unless file[1] &&                       ## check if file was uploaded
         (tmpfile = file[1][:tempfile]) &&
         (file_name = file[1][:filename])
    
    return erb :index # go back to the index if it can't use that file
  end
  
  while blk = tmpfile.read(65536) # read the file
    @file_string << blk           # put it into this string
  end
  
  parser = Parser.new                        # new parser
  parser.parse_file(@file_string, file_name) # run the parser
end

class Parser
  def which_columns(array, col)
    columns = {
      'S11' => [1,2,3],
      'S12' => [1,6,7],
      'S21' => [1,4,5],
      'S22' => [1,8,9]
    }
    
    true if columns[array].include?(col)
  end
  
  def parse_file(file_contents, file_name)
    skip = 9 # number of lines to skip at the start (not zero indexed)
    
    data_prefix = file_name.gsub(/_.+$/, "")  # strip everything but the first part

    file_contents.split("\n").each_with_index do |line, i|  # split by new line
      next if i < skip                                      # skip the first 9 lines
  
      out_row = []                                          # new array for columns
  
      line.split(' ').each_with_index do |datum, j|         # split by column
        out_row << datum if which_columns(data_prefix, j+1) # only add the proper columns to the array
      end
      @file_collection[i - skip] << out_row.join(",")
    end # file_contents.split("\n")
  end # parse_file()
  
end # Parser