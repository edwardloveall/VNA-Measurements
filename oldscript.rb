require 'pp'

class ColumnThing

  def initialize
    @text_output = [[]]
    @columns = {
      "S11" => [1,2,3],
      "S22" => [1,8,9],
      "S21" => [1,4,5],
      "S12" => [1,6,7]
    }
    @all_the_stuff = []
  end

  attr_accessor :text_output, :all_the_stuff

  def pullColumns(*file_names)
    file_names.each do |file_name|
      File.new(file_name, 'r').each_with_index do |line, i|
        # Check for a file that starts with one of the columns names
        prefix = file_name[/S\d\d/]

        @columns[prefix].each do |column|
          # Check to make sure the line starts with actual data, not header info
          if line =~ /^\d/
            line_parts = line.split(' ')
            if @text_output[i].nil?
              @text_output[i] = line_parts[column]
            else
              @text_output[i] << line_parts[column]
            end
          end
        end
        @all_the_stuff << @text_output
        @text_output = []
      end
    end
  end
end

ct = ColumnThing.new

ct.pullColumns('S11_foil.s2p', 'S21_foil.s2p')
pp ct.text_output