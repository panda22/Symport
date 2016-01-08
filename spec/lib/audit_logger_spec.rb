describe AuditLogger do
  subject { described_class }
  let (:user) { create :user, email: "loggy@test.com", password: "Complex1", phone_number: "1234567890" }
  let (:record) { FormStructure.create! name: "Formy", project: proj }
  let (:proj) { Project.create! name: "Proj" }

  before do
    mock_class AuditSupport
    AuditSupport.stubs(:related_records_for).with(record).returns({ form_structure: record, project: proj })
    AuditSupport.stubs(:serialize).with(record).returns({ name: "Formz" })
  end

  describe '.surround_edit' do
    it "serializes the record before and after change, and only saves diffs" do
      AuditSupport.expects(:serialize).with do |record|
        record.name == "Formy"
      end.returns({ name: "Y Form", same: "same data", justOld: 1 })
      AuditSupport.expects(:serialize).with do |record|
        record.name == "Forma"
      end.returns({ name: "A Form", same: "same data", justNew: 2 })
      entry = subject.surround_edit(user, record) do
        record.name = "Forma"
        record.save!
      end
      entry.old_data.should == { name: "Y Form", justOld: 1 }.to_json
      entry.data.should == { name: "A Form", justNew: 2 }.to_json
    end

    it "inclues user, action, and related records" do
      entry = subject.surround_edit(user, record) do
        record.name = "Form A"
        record.save!
      end
      entry.user.should == user
      entry.action.should == "edit"
      entry.form_structure.should == record
      entry.project.should == proj
    end
  end

  describe '.add' do
    it 'serializes the record, merges it with user and action and related records, and creates the log' do
      entry = subject.add(user, record)
      entry.user.should == user
      entry.action.should == "add"
      entry.data.should == { name: "Formz" }.to_json
      entry.old_data.should be_nil
      entry.form_structure.should == record
      entry.project.should == proj
    end
  end

  describe '.view' do
    it 'takes user and action and related records, and creates the log' do
      entry = subject.view(user, record)
      entry.user.should == user
      entry.action.should == "view"
      entry.data.should be_nil
      entry.old_data.should be_nil
      entry.form_structure.should == record
      entry.project.should == proj
    end
  end

  describe '.remove' do
    it 'serializes the record, merges it with user and action and related records, and creates the log' do
      entry = subject.remove(user, record)
      entry.user.should == user
      entry.action.should == "remove"
      entry.old_data.should == { name: "Formz" }.to_json
      entry.data.should be_nil
      entry.form_structure.should == record
      entry.project.should == proj
    end
  end

  describe '.export' do
    it "exports the extracted fields as well as the relevant record" do
      col_gen_1 = ExportColumnGenerator.new "Col1", ->(r) { "hi" }
      col_gen_2 = ExportColumnGenerator.new "Col2", ->(r) { "bye" }
      generator = ExportTableGenerator.new "Daterz", [col_gen_1, col_gen_2]
      entry = subject.export(user, record, "Daterz", ['Col1', 'Col2'])
      entry.user.should == user
      entry.action.should == "export"
      entry.data.should == { exported: { file_name: "Daterz", columns: [ "Col1", "Col2" ] } }.to_json
      entry.old_data.should be_nil
      entry.form_structure.should == record
      entry.project.should == proj
    end
  end

  describe '.record_entry' do
    it "provides a catch-all log creation interface for record-specific logs" do
      entry = subject.record_entry(user, record, "export", data: { 'o' => 'k' })
      entry.user.should == user
      entry.action.should == "export"
      entry.form_structure.should == record
      entry.project.should == proj
      entry.data.should == { 'o' => 'k' }.to_json
    end
  end

  describe '.user_entry' do
    it "provides a catch-all log creation interface for user-specific logs" do
      entry = subject.user_entry(user, "export", form_structure: record, project: proj, data: { 'o' => 'k' })
      entry.user.should == user
      entry.action.should == "export"
      entry.form_structure.should == record
      entry.project.should == proj
      entry.data.should == { 'o' => 'k' }.to_json
    end
  end

  describe '.entry' do
    it "provides a catch-all log creation interface for logs" do
      entry = subject.entry("export", form_structure: record, project: proj, data: { 'o' => 'k' })
      entry.user.should be_nil
      entry.action.should == "export"
      entry.form_structure.should == record
      entry.project.should == proj
      entry.data.should == { 'o' => 'k' }.to_json
    end
  end
end
