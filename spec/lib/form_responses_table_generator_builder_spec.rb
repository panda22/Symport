# describe FormResponsesTableGeneratorBuilder do
#   subject { described_class }
#   describe '.build' do
#     describe "builds a table generator" do
#       let (:project) { Project.create! name: "Proj_Proj" }
#       let (:question_1) { FormQuestion.create! variable_name: "Foo", sequence_number: 1, question_type: "date", prompt: "ig" }
#       let (:question_2) { FormQuestion.create! variable_name: "Bar", sequence_number: 2, question_type: "date", prompt: "ig" }
#       let (:question_3) { FormQuestion.create! variable_name: "Baz", sequence_number: 3, question_type: "date", prompt: "ig" }
#       let (:question_4) { FormQuestion.create! variable_name: "Gah", sequence_number: 4, question_type: "date", prompt: "ig", personally_identifiable: true }

#       let (:option1) { OptionConfig.create(index: 1, value: 'blah1,lol') }
#       let (:option2) { OptionConfig.create(index: 2, value: 'blah2') }
#       let (:option3) { OptionConfig.create(index: 3, value: 'blah3') }
#       let (:question_5) { FormQuestion.create! variable_name: "Nuh", sequence_number: 5, question_type: "checkbox", prompt: "blah", option_configs: [option1, option2, option3] }

#       let (:answer_1) { FormAnswer.create! answer: "hi", form_question: question_1 }
#       let (:answer_3) { FormAnswer.create! form_question: question_2 }
#       let (:answer_4) { FormAnswer.create! answer: "bye", form_question: question_4 }
#       let (:answer_5) { FormAnswer.create! answer: "blah1,lol#{"\u200C"}blah3", form_question: question_5 }
#       let (:structure) { FormStructure.create! name: "Formalicious", form_questions: [ question_1, question_2, question_3, question_4, question_5 ], project: project }
#       let (:response) { FormResponse.create! form_answers: [ answer_1, answer_3, answer_4, answer_5 ], subject_id: "subject zero" }
#       let (:user) { User.new }

#       before do
#         Permissions.stubs(:user_can_view_personally_identifiable_answers_for_project?).returns(true)
#       end

#       it "specifies table name" do
#         generator = subject.build(true, user, structure)
#         generator.table_name.should =~ /^Proj_Proj-Formalicious-[\d:\/T]+$/
#       end

#       it "specifies table column headers" do
#         generator = subject.build(true, user, structure)
#         generate_headers(generator).should == ["Subject", "Foo", "Bar", "Baz", "Gah", "Nuh"]
#       end

#       it "specifies table column values" do
#         generator = subject.build(true, user, structure)
#         generate_values(generator, response).should == ["subject zero", "hi", nil, nil, "bye", "blah1,lol|blah3"]
#       end

#       it "includes phi if requested" do
#         Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns(true)
#         generator = subject.build(true, user, structure)
#         generate_headers(generator).should == ["Subject", "Foo", "Bar", "Baz", "Gah", "Nuh"]
#         generate_values(generator, response).should == ["subject zero", "hi", nil, nil, "bye", "blah1,lol|blah3"]
#       end

#       it "filters out phi if not requested" do
#         Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).never
#         generator = subject.build(false, user, structure)
#         generate_headers(generator).should == ["Subject", "Foo", "Bar", "Baz", "Gah", "Nuh"]
#         generate_values(generator, response).should == ["subject zero", "hi", nil, nil, nil, "blah1,lol|blah3"]
#       end

#       it "filters out phi if not permitted" do
#         Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns(false)
#         generator = subject.build(true, user, structure)
#         generate_headers(generator).should == ["Subject", "Foo", "Bar", "Baz", "Gah", "Nuh"]
#         generate_values(generator, response).should == ["subject zero", "hi", nil, nil, nil, "blah1,lol|blah3"]
#       end

#       it "omits formatting questions" do
#         Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns(true)
#         question_3.question_type = "header"
#         question_3.save!
#         generator = subject.build(true, user, structure)
#         generate_headers(generator).should == ["Subject", "Foo", "Bar", "Gah", "Nuh"]
#         generate_values(generator, response).should == ["subject zero", "hi", nil, "bye", "blah1,lol|blah3"]
#       end

#       it "add pipe to answers parts of a checkbox question" do
#         Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns(true)
#         generator = subject.build(true, user, structure)
#         generate_values(generator, response).should == ["subject zero", "hi", nil, nil, "bye", "blah1,lol|blah3"]
#       end

#       private 
#       def generate_headers(generator)
#         generator.column_generators.map(&:column_name)
#       end

#       def generate_values(generator, record)
#         generator.column_generators.map do |g|
#           g.generate(record)
#         end
#       end
#     end
#   end
# end
