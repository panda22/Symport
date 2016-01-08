class ExportColumnGenerator
  attr_reader :column_name

  def initialize(column_name, record_to_cell_func)
    @column_name = column_name
    @record_to_cell_func = record_to_cell_func
  end
  
  def generate(record)
    @record_to_cell_func.(record)
  end
end
