require 'sinatra'

get '/' do
  erb :index
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
  
  def parse_file(file_name)
    parsed = []
    
    # file_name = ARGV[0]
    data_prefix = file_name.gsub(/_.+$/, "") # strip everything but the first part
    no_ext = file_name.gsub(/\..+$/, "") # no extention
    ext = file_name.gsub(/^.+\./, "") # just the extention

    file = File.open("public/#{file_name}", 'r')
    out_file = File.open("public/#{no_ext}_out.#{ext}", 'w')
    file.each do |line|
      next if file.lineno <= 9 # skip the first 9 lines
  
      out_row = [] # new array for data
  
      line.split(' ').each_with_index do |datum, i|
        out_row << datum if which_columns(data_prefix, i+1)
      end
  
      # out_file.write(out_row.join(' '))
      # out_file.write("\n")
      
      parsed << out_row.join(" ")
    end # file.each do |line|
    
    parsed
  end # parse_file()
end # Parser

def test
  p "columns"
end

post '/' do
  # unless params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])
    # return haml(:index)
  # end
  file_name = params[:file][:filename]
  
  p = Parser.new
  @f = p.parse_file(file_name)
  
  erb :index
end