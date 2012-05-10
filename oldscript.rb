require 'rubygems'
require 'sinatra'

get '/' do
  erb :index
end

post '/' do # after form submit
  content_type 'application/octet-stream'
  attachment("test.csv")
  @file_collection = Array.new
  @file_collection_string = String.new
  
  @error = "No file selected" if params.empty?
  
  params[:files].each do |file|
    deal_with_file(file)
  end
  
  @all = combine_files(@file_collection)
  
  string_file = stringify(@all)
  # erb :results
end

def deal_with_file(file)
  file_string = '' # empty string for file
  
  unless file &&                       ## check if file was uploaded
         (tmpfile = file[:tempfile]) &&
         (file_name = file[:filename])
    
    return erb :index # go back to the index if it can't use that file
  end
  
  while blk = tmpfile.read(65536) # read the file
    file_string << blk            # put it into this string
  end
  
  parser = Parser.new                                            # new parser
  @file_collection << parser.parse_file(file_string, file_name) # run the parser
end

def combine_files(file_array)
  combined_files = []
  
  file_array.each do |file|
    file.each_with_index do |line, i|
      combined_files[i] = [] if combined_files[i].class != Array
      combined_files[i] += line
    end
  end
  
  combined_files.each_with_index do |row, i|
    combined_files[i] = row.join("," ) # delimiter
  end
  
  combined_files
end

def stringify(file)
  stringed_file = ''
  
  file.each do |line|
    stringed_file = stringed_file + "\n" + line
  end
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
    skip = 9                                  # number of lines to skip at the start
    row_collection = []                       # for all of the row data
    data_prefix = file_name.gsub(/_.+$/, "")  # strip everything but the first part: S11, S21, etc
    no_suffix = file_name.gsub(/\..+$/, "") # stip the file extension
    
    first_row = []
    
    (1..9).each do |col|
      first_row << "#{no_suffix}[#{col}]" if which_columns(data_prefix, col)
    end
    
    row_collection[0] = first_row

    file_contents.split("\n").each_with_index do |line, i|  # split by new line
      next if i < skip                                      # skip the first 9 lines
  
      out_row = []                                          # new array for columns
  
      line.split(' ').each_with_index do |datum, j|         # split by column
        out_row << datum if which_columns(data_prefix, j+1) # only add the proper columns to the array
      end
      # row_collection[i - skip] = []
      row_collection << out_row
    end # file_contents.split("\n")
    row_collection
  end # parse_file()
  
end # Parser

def dl_file(text)
  t = Time.now
  file_name = "#{t.strftime('%H%M%S')}.csv"
  file_contents = text
  # send_data(file_contents, file_name)
  send_data("hello", filename: file_name)
end

get '/public/tmp/:file' do
  file_name ="./public/tmp/#{params[:file]}"
  send_file(file_name, :filename => file_name)
end