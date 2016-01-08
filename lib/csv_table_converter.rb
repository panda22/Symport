class CsvTableConverter
	class << self
		def convert(grid, headings=[])
			temp_str = ""
			final_arr = []
			headings.each do |heading|
				temp_str += ('"' + heading.to_s + '"' + ",")
			end
			if temp_str.length > 0
				temp_str.chop!
				final_arr.push(temp_str)
			end
			grid.each do |row|
				temp_str = ""
				row.each do |cell|
					cell_str = cell.to_s
					cell_str.gsub!("\u200D", "")
					cell_str.gsub!('"', "'")
					temp_str += ('"' + cell_str  + '"' + ",")
				end
				temp_str.chop!
				final_arr.push(temp_str)
			end
			return final_arr.join("\n")
		end
	end
end