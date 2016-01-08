class ExportCsvGenerator
  class << self
    def generate(table_generator, records)
      CSV.generate do |data|
        data << table_generator.column_generators.map(&:column_name)
        records.each do |rec|
          data << table_generator.column_generators.map do |col_gen|
            col_gen.generate(rec)
          end
        end
      end
    end
  end
end
