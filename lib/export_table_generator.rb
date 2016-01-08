class ExportTableGenerator

  attr_reader :table_name
  attr_reader :column_generators
  def initialize(table_name, column_generators)
    @table_name = table_name
    @column_generators = column_generators
  end
end
