# describe FormResponsesFinder do
#   subject { described_class }
#   describe ".find" do

#     before do
#       AuditLogger.stubs(:view)
#     end

#     let(:structure_record) { FormStructure.create name: 'Cool Struct' }
#     let(:user) { User.new }

#     context "finds the form responses" do
#       before do
#         @per_page = FormResponse.per_page
#         FormResponse.per_page = 3
#         @resp1 = FormResponse.create form_structure: structure_record, subject_id: "aaa"
#         @resp2 = FormResponse.create form_structure: structure_record, subject_id: "aabbb"
#         @resp3 = FormResponse.create form_structure: structure_record, subject_id: "abaaa"
#         @resp4 = FormResponse.create form_structure: structure_record, subject_id: "abbaa"
#         @resp5 = FormResponse.create form_structure: structure_record, subject_id: "bbcaa"
#         @resp6 = FormResponse.create form_structure: structure_record, subject_id: "bbcab"
#         @resp7 = FormResponse.create form_structure: structure_record, subject_id: "ddcaa"
#         @resp8 = FormResponse.create form_structure: structure_record, subject_id: "ddcab"
#         @resp9 = FormResponse.create form_structure: structure_record, subject_id: "ddcac"
#         @resp10 = FormResponse.create form_structure: structure_record, subject_id: "ddddd"
#         Permissions.stubs(:user_can_view_form_responses_for_form_structure?).with(user, structure_record).returns(true)
#       end

#       after do
#         FormResponse.per_page = @per_page
#       end


#       it "according to subject id" do
#         form_responses, current_page, total_pages = subject.find(user, structure_record, "1", "bb")
#         form_responses.should == [@resp5, @resp6]
#         current_page.should == 1
#         total_pages.should == 1
#       end

#       it "for desired page" do
#         form_responses, current_page, total_pages = subject.find(user, structure_record, "2", nil)
#         form_responses.should == [@resp4, @resp5, @resp6]
#         current_page.should == 2
#         total_pages.should == 4
#       end

#       it "finds the form responses according to searching criteria" do
#         form_responses, current_page, total_pages = subject.find(user, structure_record, "2", "dd")
#         form_responses.should == [@resp10]
#         current_page.should == 2
#         total_pages.should == 2
#       end
#     end

#     it "refuses access if lacking permissions" do
#       Permissions.expects(:user_can_view_form_responses_for_form_structure?).with(user, structure_record).returns(false)
#       expect {
#         subject.find(user, structure_record, "2", "a")
#       }.to raise_error PayloadException
#     end

#     it "logs access" do
#       Permissions.stubs(:user_can_view_form_responses_for_form_structure?).with(user, structure_record).returns(true)
#       AuditLogger.expects(:view).with(user, structure_record)
#       subject.find(user, structure_record, "2", "dd")
#     end
#   end
# end
