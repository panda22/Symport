describe FormResponseAnswersUpdater do
  subject { described_class }

  describe '.update' do
    let (:question1) { FormQuestion.create prompt: 'Foo?', variable_name: 'var1', sequence_number: 1, display_number: "1", question_type: 'zipcode', personally_identifiable: true }
    let (:answer1) { FormAnswer.create answer: 'foo', form_question: question1 }
    let (:question2) { FormQuestion.create prompt: 'Bar?', variable_name: 'var2', sequence_number: 2, display_number: "2", question_type: 'email' }
    let (:answer2) { FormAnswer.create answer: 'bar', form_question: question2 }
    let (:question3) { FormQuestion.create prompt: 'Baz?', variable_name: 'var3', sequence_number: 3, display_number: "3", question_type: 'email', personally_identifiable: true }
    let (:answer3) { FormAnswer.create answer: 'baz', form_question: question3 }
    let (:question4) { FormQuestion.create prompt: 'Baz?', sequence_number: 4, display_number: "4", question_type: 'pagebreak', personally_identifiable: true }
    let (:structure) { FormStructure.create name: 'structcha', project: project, form_questions: [question1, question2, question3, question4] }
    let (:form_response) { FormResponse.create form_structure: structure, form_answers: [answer1, answer2, answer3] }
    let (:project) { Project.create name: "Projy" }
    let (:user) { User.new }

    it 'updates answers' do
      Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns(true)
      data = [
          { answer: 'oof', question: question1.id },
          { answer: 'rab', question: question2.id },
          { answer: 'zab', question: question3.id },
      ]
      FormQuestionAnswerUpdater.expects(:update).with(user, question1, form_response, data).returns({})
      FormQuestionAnswerUpdater.expects(:update).with(user, question2, form_response, data).returns({})
      FormQuestionAnswerUpdater.expects(:update).with(user, question3, form_response, data).returns({})
      FormQuestionAnswerUpdater.expects(:update).with(user, question3, form_response, data).never
      subject.update(user, form_response, data)
    end

    it "ignores answers for questions that have been deleted" do
      Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns(true)
      data = [
          { answer: 'oof', question: question1.id },
          { answer: 'rab', question: question2.id },
          { answer: 'zab', question: question3.id },
      ]
      question2.destroy
      structure.reload
      FormQuestionAnswerUpdater.expects(:update).with(user, question1, form_response, data).returns({})
      FormQuestionAnswerUpdater.expects(:update).with(user, question2, form_response, data).never
      FormQuestionAnswerUpdater.expects(:update).with(user, question3, form_response, data).returns({})
      subject.update(user, form_response, data)
    end

    it "ignores answers for formatting questions" do
      Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns(true)
      data = [
          { answer: 'oof', question: question1.id },
          { answer: 'rab', question: question2.id },
          { answer: 'zab', question: question3.id },
      ]
      question2.question_type = "header"
      question2.save!
      structure.reload
      FormQuestionAnswerUpdater.expects(:update).with(user, question1, form_response, data).returns({})
      FormQuestionAnswerUpdater.expects(:update).with(user, question2, form_response, data).never
      FormQuestionAnswerUpdater.expects(:update).with(user, question3, form_response, data).returns({})
      subject.update(user, form_response, data)
    end

    it "does not update phi questions by default" do
      Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns(false)
      data = [
          { answer: 'oof', question: question1.id },
          { answer: 'rab', question: question2.id },
          { answer: 'zab', question: question3.id },
      ]
      FormQuestionAnswerUpdater.expects(:update).with(user, question1, form_response, data).never
      FormQuestionAnswerUpdater.expects(:update).with(user, question2, form_response, data).returns({})
      FormQuestionAnswerUpdater.expects(:update).with(user, question3, form_response, data).never
      subject.update(user, form_response, data)
    end

    it 'raises errors' do
      Permissions.expects(:user_can_view_personally_identifiable_answers_for_project?).with(user, project).returns(true)
      data = [
          { answer: 'oof', question: question1.id },
          { answer: 'rab', question: question2.id },
          { answer: 'zab', question: question3.id },
      ]
      FormQuestionAnswerUpdater.expects(:update).with(user, question1, form_response, data).returns({3 => "no"})
      FormQuestionAnswerUpdater.expects(:update).with(user, question2, form_response, data).returns({})
      FormQuestionAnswerUpdater.expects(:update).with(user, question3, form_response, data).returns({1 => "oh"})
      expect {
        subject.update(user, form_response, data)
      }.to raise_error { |err|
        err.error[:validations][:answers].should == {1 => "oh", 3 => "no"}
      }
    end
  end


describe '.get_errors' do
    let (:question1) { FormQuestion.create prompt: 'Foo?', variable_name: 'var1', sequence_number: 1, display_number: "1", question_type: 'zipcode', personally_identifiable: true }
    let (:answer1) { FormAnswer.create answer: 'foo', form_question: question1 }
    let (:question2) { FormQuestion.create prompt: 'Bar?', variable_name: 'var2', sequence_number: 2, display_number: "2", question_type: 'email' }
    let (:answer2) { FormAnswer.create answer: 'bar', form_question: question2 }
    let (:question3) { FormQuestion.create prompt: 'Baz?', variable_name: 'var3', sequence_number: 3, display_number: "3", question_type: 'email', personally_identifiable: true }
    let (:answer3) { FormAnswer.create answer: 'baz', form_question: question3 }
    let (:question4) { FormQuestion.create prompt: 'Baz?', sequence_number: 4, display_number: "4", question_type: 'pagebreak', personally_identifiable: true }
    let (:structure) { FormStructure.create name: 'structcha', project: project, form_questions: [question1, question2, question3, question4] }
    let (:form_response) { FormResponse.create form_structure: structure, form_answers: [answer1, answer2, answer3] }
    let (:project) { Project.create name: "Projy" }
    let (:user) { User.new }

    it 'validates good answers' do
      data = [
          { answer: 'oof', question: question1.id },
          { answer: 'rab', question: question2.id },
          { answer: 'zab', question: question3.id },
      ]
      FormQuestionAnswerUpdater.expects(:validate).with(user, question1, data).returns({})
      FormQuestionAnswerUpdater.expects(:validate).with(user, question2, data).returns({})
      FormQuestionAnswerUpdater.expects(:validate).with(user, question3, data).returns({})
      FormQuestionAnswerUpdater.expects(:validate).with(user, question3, data).never
      subject.get_errors(user, form_response, data)
    end

    it "ignores answers for questions that have been deleted" do
      data = [
          { answer: 'oof', question: question1.id },
          { answer: 'rab', question: question2.id },
          { answer: 'zab', question: question3.id },
      ]
      question2.destroy
      structure.reload
      FormQuestionAnswerUpdater.expects(:validate).with(user, question1, data).returns({})
      FormQuestionAnswerUpdater.expects(:validate).with(user, question2, data).never
      FormQuestionAnswerUpdater.expects(:validate).with(user, question3, data).returns({})
      subject.get_errors(user, form_response, data)
    end

    it "ignores answers for formatting questions" do
      data = [
          { answer: 'oof', question: question1.id },
          { answer: 'rab', question: question2.id },
          { answer: 'zab', question: question3.id },
      ]
      question2.question_type = "header"
      question2.save!
      structure.reload
      FormQuestionAnswerUpdater.expects(:validate).with(user, question1, data).returns({})
      FormQuestionAnswerUpdater.expects(:validate).with(user, question2, data).never
      FormQuestionAnswerUpdater.expects(:validate).with(user, question3, data).returns({})
      subject.get_errors(user, form_response, data)
    end

    it 'raises errors' do
      data = [
          { answer: 'oof', question: question1.id },
          { answer: 'rab', question: question2.id },
          { answer: 'zab', question: question3.id },
      ]
      FormQuestionAnswerUpdater.expects(:validate).with(user, question1, data).returns({3 => "no"})
      FormQuestionAnswerUpdater.expects(:validate).with(user, question2, data).returns({})
      FormQuestionAnswerUpdater.expects(:validate).with(user, question3, data).returns({1 => "oh"})
      expect {
        subject.get_errors(user, form_response, data)
      }.to raise_error { |err|
        err.error[:validations][:answers].should == {1 => "oh", 3 => "no"}
      }
    end
  end












end
