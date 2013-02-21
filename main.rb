require 'rubygems'
require 'sinatra'

get '/' do
  erb :index
end

post '/' do # after form submit
  t = Time.now
  file_name = "VNA_#{t.strftime('%Y%m%d')}.csv"
  @file_collection = Array.new

  content_type 'application/octet-stream'
  attachment(file_name)

  params[:files].each do |file_each|
    file = Array.new
    file = read_file(file_each)
    @file_collection << parse_file(file[0], file[1])
  end
  @test = combine_files(@file_collection)
  @test
  # erb :blank
end

def read_file(file)
  tempfile = file[:tempfile]
  file_name = file[:filename].sub(/\s/, '_')
  file_data = ''
  while blk = tempfile.read(65536) # read the file
    file_data << blk           # put it into this string
  end

  [file_name, file_data]
end

def which_columns(array, col)
  columns = {
    'S11' => [1,2,3],
    'S12' => [1,6,7],
    'S21' => [1,4,5],
    'S22' => [1,8,9]
  }

  true if columns[array].include?(col)
end

def parse_file(file_name, file_contents)
  skip = 9                                  # number of lines to skip at the start
  row_collection = []                       # for all of the row data
  type_prefix = file_name.gsub(/_.+$/, "")  # strip everything but the first part: S11, S21, etc
  no_suffix = file_name.gsub(/\..+$/, "")   # stip the file extension

  first_row = Array.new

  (1..9).each do |col|
    first_row << "#{no_suffix}[#{col}]" if which_columns(type_prefix, col)
  end

  row_collection[0] = first_row

  file_contents.split("\n").each_with_index do |line, i|  # split by new line
    next if i < skip                                      # skip the first 9 lines

    out_row = Array.new                                   # new array for columns

    line.split(' ').each_with_index do |datum, j|         # split by column (space)
      out_row << datum if which_columns(type_prefix, j+1) # only add the proper columns to the array
    end
    row_collection << out_row
  end
  row_collection
end # parse_file()

def combine_files(file_array)
  combined_files = []
  file_string = ''

  file_array.each do |file|
    file.each_with_index do |line, i|
      combined_files[i] = [] if combined_files[i].class != Array
      combined_files[i] += line
    end
  end

  # turn inner array into a single line separated by commas
  # combined_files.each_with_index do |row, i|
  #   combined_files[i] = row.join(",") # delimiter
  # end

  # turn array into a string of text
  combined_files.each_with_index do |row, i|
    file_string += row.join(",") + "\n"
  end

  file_string
end