describe ExportCsvGenerator do
  subject { described_class }
  describe '.generate' do
    it "transforms records into a table" do
      col_1_gen = ExportColumnGenerator.new "Who", ->(r) { r[:name] }
      col_2_gen = ExportColumnGenerator.new "What", ->(r) { r[:event] }
      col_3_gen = ExportColumnGenerator.new "When", ->(r) { r[:time] }
      col_4_gen = ExportColumnGenerator.new "Where", ->(r) { r[:location] }
      table_gen = ExportTableGenerator.new "Invitation", [col_1_gen, col_2_gen, col_3_gen, col_4_gen]
      records = [
        { name: "Alice", event: "A-list party", time: "After dinner", location: "Apartment" },
        { name: "Bob", event: "Birthday", time: "Before supper", location: "Burger King" },
        { name: "Charlie", event: "Chat", time: "Close to noon", location: "Chinatown" },
        { name: "Daniel", event: "Dirge", time: "Dusk", location: "Danube" },
      ]
      output = subject.generate(table_gen, records).should == <<EOS
Who,What,When,Where
Alice,A-list party,After dinner,Apartment
Bob,Birthday,Before supper,Burger King
Charlie,Chat,Close to noon,Chinatown
Daniel,Dirge,Dusk,Danube
EOS
    end
  end
end
