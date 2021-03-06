# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :assignment_individual, :parent=>:assignment do
    is_team_deliverable false
  end

  factory :assignment_team, :parent=>:assignment do
    is_team_deliverable true
  end

  factory :assignment_unsubmissible, :parent=>:assignment do
    is_submittable false
    due_date ""
  end

  factory :assignment_fse, :parent=>:assignment do
    name "fse assignment 1"
    association :course, :factory => :fse
  end

  factory :assignment_seq, :parent=>:assignment  do
    course_id 1
    sequence(:name) {|i| "Assignment #{i}"}
    sequence(:maximum_score) {|i| i*3}
    sequence(:assignment_order) {|i| i}
  end

  ## beg add turing

  factory :assignment_1, :parent=>:assignment do
    is_team_deliverable true
    association :course, :factory => :fse
    name "Assignment 1"
    task_number 1
  end

  factory :assignment_2, :parent=>:assignment do
    is_team_deliverable true
    association :course, :factory => :fse
    name "Assignment 2"
    task_number 2
  end

  factory :assignment_3, :parent=>:assignment do
    is_team_deliverable false
    association :course, :factory => :fse
    name "Assignment 3"
    task_number 3
  end

  ## end add turing
end
