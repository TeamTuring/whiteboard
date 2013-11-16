require "spec_helper"

describe "deliverables" do
  before do

    @assignment = FactoryGirl.create(:assignment_team)
    @team_deliverable = FactoryGirl.create(:team_deliverable)
    @user = @team_deliverable.team.members[0]
    @grade =  FactoryGirl.create(:grade_visible, :course_id => @assignment.course.id)
    Assignment.stub(:list_assignments_for_student).with(@user.id, :current).and_return([@assignment])
    Assignment.stub(:list_assignments_for_student).with(@user.id, :past).and_return([@assignment])
    @assignment.stub(:deliverables).and_return([@team_deliverable])
    @assignment.stub(:get_student_grade).with(@user.id).and_return(@grade)
    @assignment.stub(:get_student_deliverable).with(@user.id).and_return(@team_deliverable)
    @assignment.stub(:maximum_score).and_return(20.0)
    @deliverableAttachment=DeliverableAttachment.create(:attachment_file_name=>"hi",:deliverable_id=>@team_deliverable.id,:submitter_id=>@user.id)

  end

  after do
    #@team_deliverable.delete
    #@user.delete
    #@deliverableAttachment.delete
  end

  context "As a student" do
    before do
     visit('/')
     login_with_oauth @user
     click_link "My Deliverables"
    end

    context "My deliverables" do
      it "renders my deliverables page" do
        page.should have_content("Listing Deliverables")
        page.should have_link("New deliverable")
      end

      it "lets the user create new deliverable"  do
        click_link "New deliverable"
        page.should have_content("New deliverable")
        page.should have_selector("select#deliverable_course_id")
        page.should have_button("Create")
      end
    end

    #turing
    it "I can see who graded me" do
      @faculty_frank = FactoryGirl.create(:faculty_frank_user)
      @assignment1 = FactoryGirl.create(:assignment_team)
      @grade1 = FactoryGirl.create(:last_graded_visible, :course_id => @assignment1.course.id,:assignment_id => @assignment1.id, :last_graded_by => @faculty_frank.id, :student_id =>@user.id)
      @team_deliverable.course = @assignment1.course
      @team_deliverable.assignment = @assignment1
      @team_deliverable.creator = @user
      Assignment.stub(:list_assignments_for_student).with(@user.id, :current).and_return([@assignment1])
      Assignment.stub(:list_assignments_for_student).with(@user.id, :past).and_return([@assignment1])
      @assignment1.stub(:get_student_grade).with(@user.id).and_return(@grade1)
      Grade.stub(:get_grade).and_return(@grade1)
      @assignment1.stub(:maximum_score).and_return(20.0)
      click_link "Resubmit"
      page.should have_content("Graded by")
      page.should have_content(@faculty_frank.human_name)

    end

    it " I can not be able to view professor's notes" do
      grade = @grade.score + "/" + @assignment.maximum_score.to_s
      page.should have_content(grade)
      click_link "Resubmit"
  #   visit deliverable_path(@team_deliverable)

  #    page.should have_content("Attachment Version History")
      page.should have_content("History")
      page.should_not have_content("Professor's Notes")
      page.should_not have_content("My private notes")
    end


    context "when I submit an assignment," do
      before {
        @assignment = FactoryGirl.create(:assignment)
        @course_mfse = FactoryGirl.create(:mfse)
        Registration.create(user_id: @user.id, course_id: @assignment.course.id)
      }

      it "I see all my registered courses " do
        # Add one for the empty option
        visit new_deliverable_path
        page.should have_selector("select#deliverable_course_id > option", count: @user.registered_for_these_courses_during_current_semester.count)
      end

      context "with course_id and assignment_id from the url" do
        before {
          visit new_deliverable_path(course_id: @assignment.course.id, assignment_id: @assignment.id)
        }

        it "it should save when an attachment is present", :skip_on_build_machine => true do
          attach_file 'deliverable_attachment_attachment', Rails.root + 'spec/fixtures/sample_assignment.txt'
          expect { click_button 'Create' }.to change(Deliverable, :count).by(1)
        end

        it "should not save when there is no attachment" do
          expect { click_button 'Create' }.to_not change(Deliverable, :count)

          page.should have_selector("h1", text: "New deliverable")
          page.should have_selector(".ui-state-error")
        end
      end

      it "without course_id and assignment_id selected, then it should not save" do
        visit new_deliverable_path
        expect { click_button 'Create' }.to change(Deliverable, :count).by(0)

        page.should have_selector("h1", text: "New deliverable")
        page.should have_selector(".ui-state-error")
      end
    end
  end


  context "As a professor" do
    before do
      ## beg del Team Turing
      #@faculty = FactoryGirl.create(:faculty_fagan)
      #login_with_oauth @faculty
      #@team_deliverable.course.faculty = [@faculty]
      #
      #@course = FactoryGirl.create(:fse)
      #@faculty_assignment = FactoryGirl.create(:faculty_assignment, :course_id => @course.id,
      #                                         :user_id => @faculty.id)
      #@team_deliverable.course = @course
      ## end del Team Turing


      ## beg add Team Turing
      @faculty = FactoryGirl.create(:faculty_frank_user)
      login_with_oauth @faculty
      @team_deliverable.course.faculty = [@faculty]
      @course = FactoryGirl.create(:fse)
      @faculty_assignment = FactoryGirl.create(:faculty_assignment, :course_id => @course.id,
                                               :user_id => @faculty.id)
      @team_deliverable.course = @course

      #@course_fse = FactoryGirl.create(:fse, faculty: [@faculty])
      #@course_ise = FactoryGirl.create(:ise, faculty: [@faculty])
      @student_sam = FactoryGirl.create(:student_sam)
      #@student_sally = FactoryGirl.create(:student_sally)


      @team_turing =  FactoryGirl.create(:team_turing, :course=>@course)
      @team_test =  FactoryGirl.create(:team_test, :course=>@course)
      @team_assignment = FactoryGirl.create(:team_turing_assignment, :team => @team_turing, :user => @student_sam)

      @assignment1 = FactoryGirl.create(:assignment_1,:course => @course)
      @assignment2 = FactoryGirl.create(:assignment_2,:course => @course)

      @grade1 = FactoryGirl.create(:last_graded_visible, :course => @course,:assignment => @assignment1, :last_graded_by => @faculty.id, :student =>@student_sam)

      @deliverable1 = FactoryGirl.create(:team_turing_deliverable_1,:course => @course, :team => @team_turing, :assignment => @assignment1, :attachment_versions => [])
      @deliverable2 = FactoryGirl.create(:team_turing_deliverable_2,:course => @course, :team => @team_turing,:assignment => @assignment2, :attachment_versions => [])
      @deliverable3 = FactoryGirl.create(:team_test_deliverable_1,:course => @course, :team => @team_test,:assignment => @assignment1, :attachment_versions => [])

      @dav1 =  FactoryGirl.create(:attachment_1, :deliverable => @deliverable1, :submitter => @student_sam)
      @dav2 =  FactoryGirl.create(:attachment_1, :deliverable => @deliverable2, :submitter => @student_sam)
      @dav3 =  FactoryGirl.create(:attachment_1, :deliverable => @deliverable3, :submitter => @student_sam)

      @dav1.attachment_file_name = "Attachment 1"
      @dav2.attachment_file_name = "Attachment 2"
      @dav3.attachment_file_name = "Attachment 3"

      @deliverable1.attachment_versions << @dav1
      @deliverable2.attachment_versions << @dav2
      @deliverable3.attachment_versions << @dav3

      ## end add Team Turing

    end

    after do
#      @faculty.delete
    end


    ## beg add Team Turing

    it "I should be able to view only my teams deliverables", :js => true do
      visit course_deliverables_path(@course)

      #for debugging
      save_and_open_page

      page.should have_content("Task 1")
      page.should have_content("Task 2")
      page.should_not have_content("Task 3")

      page.should have_content("Team Turing")
      page.should_not have_content("Team Test")

      page.should have_link("Assignment 1")
      page.should have_link("Assignment 2")
      page.should_not have_link("Assignment 3")

    end

    it "I should be able see the ungraded icon as default", :js => true do
      visit course_deliverables_path(@course)

      page.should have_xpath("//img[contains(@src, \"deliverables_ungraded.png\")]")

    end

    it "I should be able to click deliverable to open accordion and check content of grading page", :js => true do
      visit course_deliverables_path(@course)

      find("#deliverable_" + @deliverable1.id.to_s).click
    #  page.should have_content("Attachment Version History")
      page.should have_content("History")
      page.should have_content("Professor's Notes")
      page.should have_content("My first deliverable")
      page.should have_content("Last graded by")
      page.should have_content("Send a copy to myself")
      page.should have_button("Save as Draft")
      page.should have_button("Finalize and Email")

    end

    it "I should be able to see who last graded in the grading page", :js => true do
      visit course_deliverables_path(@course)
      find("#deliverable_" + @deliverable1.id.to_s).click
      page.should have_content("Last graded by")
      page.should have_content(@faculty.human_name)
      #pending check the link :)
      #page.should have_link(@faculty.human_name, {:href => '/clowns?ordered_by=clumsyness')

    end

    it "I should be able to see my last filter options after providing grade/feedback ", :js => true do
      pending
      visit course_deliverables_path(@course)

      find("#deliverable_" + @deliverable1.id.to_s).click
      click_button "Finalize and Email"
      #page.should have_content("Task 1")

    end


    it "I should be able to check tooltip for andrew ID", :js => true do
      visit course_deliverables_path(@course)

      pending

      # hover over picture (or name) and show tooltip
      # tooltip should show student's webiso_account
      # page.find('#element').trigger(:mouseover)

      # For debugging:
      #save_and_open_page

    end

    ## end add Team Turing

    ## beg del Team Turing

    #it "I should be able to view deliverable page" do
    #  visit deliverable_path(@team_deliverable)
    #
    #  page.should have_content("Attachment Version History")
    #  page.should have_content("Professor's Notes")
    #  page.should have_content("My private notes")
    #
    #  ## beg add Team Turing
    #  # Check new features
    #  page.should have_content("Last graded by")
    #  page.should have_content("Send a copy to myself")
    #  # TODO: Check new checkboxes passing the label text
    #  #check "Send a copy to myself"
    #  #uncheck "Send a copy to myself"
    #  # TODO: Click buttons
    #  page.should have_button("Save as Draft")
    #  #click_button "Save as Draft"
    #  page.should have_button("Finalize and Email")
    #  #click_button "Finalize and Email"
    #
    #  # For debugging
    #  #save_and_open_page
    #
    #  # end add Team Turing
    #
    #end
    ## end del Team Turing

  end





  it "test user" do
    @student1 = FactoryGirl.create(:student_sam_user)
    @student2 = FactoryGirl.create(:student_sam_user)
    @student1.should == @student2
  end

  context "Professor deliverables" do
    context "grading team deliverable" do
      before {
        @team = @team_deliverable.team
        @assignment = FactoryGirl.create(:assignment, is_team_deliverable: true, course: @team.course)
        Registration.create(user_id: @user.id, course_id: @assignment.course.id)
        login_with_oauth @user
        visit new_deliverable_path(course_id: @assignment.course.id, assignment_id: @assignment.id)
        attach_file 'deliverable_attachment_attachment', Rails.root + 'spec/fixtures/sample_assignment.txt'
        click_button "Create"
        @professor = FactoryGirl.create(:faculty_frank_user)
        @assignment.course.faculty_assignments_override = [@professor.human_name]
        @assignment.course.update_faculty
#        Course.any_instance.stub(:faculty).and_return([@professor])
        visit "/logout"
        login_with_oauth @professor
        # visit deliverable_feedback_path(Deliverable.last)  #if we separate out the feedback page
        visit deliverable_path(Deliverable.last)
        #save_and_open_page
        page.should have_content("Grade Team Deliverable")
      }

      #it "should provide feedback and a grade to each student in the team" do
      #  fill_in "deliverable_deliverable_grades_attributes_0_grade", with: 10
      #  click_button "Submit"
      #  Deliverable.last.deliverable_grades.first.number_grade.should == 10.0
      #  Deliverable.last.status.should == 'Graded'
      #end
      #
      #it "should save as draft" do
      #  fill_in "deliverable_deliverable_grades_attributes_0_grade", with: 10
      #  click_button "Save as draft"
      #  Deliverable.last.deliverable_grades.first.number_grade.should == 10.0
      #  Deliverable.last.status.should == 'Draft'
      #end
    end

    #context "grading individual deliverables" do
    #  before {
    #    @assignment = FactoryGirl.create(:assignment, is_team_deliverable: false)
    #    Registration.create(user_id: @user.id, course_id: @assignment.course.id)
    #    login_with_oauth @user
    #    visit new_deliverable_path(course_id: @assignment.course.id, assignment_id: @assignment.id)
    #    attach_file 'deliverable_attachment_attachment', Rails.root + 'spec/fixtures/sample_assignment.txt'
    #    click_button "Create"
    #    @professor = FactoryGirl.create(:faculty_frank_user)
    #    @assignment.course.faculty_assignments_override = [@professor.human_name]
    #    @assignment.course.update_faculty
    #    login_with_oauth @professor
    #  }
    #
    #  it "should provide feedback and a grade to the student" do
    #    visit deliverable_feedback_path(Deliverable.last)
    #    page.should have_content("Grade Individual Deliverable")
    #    fill_in "deliverable_deliverable_grades_attributes_0_grade", with: 10
    #    click_button "Submit"
    #    Deliverable.last.deliverable_grades.first.number_grade.should == 10.0
    #    Deliverable.last.status.should == 'Graded'
    #  end
    #
    #  it "should save as draft" do
    #    visit deliverable_feedback_path(Deliverable.last)
    #    page.should have_content("Grade Individual Deliverable")
    #    fill_in "deliverable_deliverable_grades_attributes_0_grade", with: 10
    #    click_button "Save as draft"
    #    Deliverable.last.deliverable_grades.first.number_grade.should == 10.0
    #    Deliverable.last.status.should == 'Draft'
    #  end
    #
    #  context "unallowed access" do
    #    before {
    #      @dwight = FactoryGirl.create(:faculty_dwight_user)
    #      login_with_oauth @dwight
    #    }
    #
    #    it "should not allow unassigned faculty to grade" do
    #      visit deliverable_feedback_path(Deliverable.last)
    #      page.should have_selector('.ui-state-error')
    #    end
    #  end
    #end
  end
end
