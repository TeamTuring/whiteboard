# GradingRule represents the correspondence between points earned and letter grades. The mapping rule is given by the
# course instructor.
#
# GradingRule is configurable by clicking on "Configure course" in "Initial Course Configuration", both of which could
# be found on the index page of each course. In the configuration page, professor can choose grading criteria between
#   points and letter grades. If professor adopts letter grades, then professor needs to fill the table which maps out
#   point and letter grades.
#
# GradingRule follows the grading policy of CMU@SV. We provide the following options for letter grades: A, A-, B+, B,
#   B-, C+, C, C-.
#
# We provide the following functions to map out points and letter grades.
# * convert_points_to_letter_grade maps out points to letter grades.
# * convert_letter_grade_to_points maps out letter grades to points.
# * get_grade_in_prof_format convert points to
# * get_raw_grade returns points. If the grade type is letter, we will apply the grading rule to convert it.

class GradingRule < ActiveRecord::Base
  attr_accessible :grade_type,
                  :A_grade_min,
                  :A_minus_grade_min,
                  :B_plus_grade_min,
                  :B_grade_min,
                  :B_minus_grade_min,
                  :C_plus_grade_min,
                  :C_grade_min,
                  :C_minus_grade_min,
                  :course_id

  belongs_to :course

  def convert_points_to_letter_grade (points)
    if points>=self.A_grade_min
      return "A"
    elsif points>=self.A_minus_grade_min
        return "A-"
    elsif points>=self.B_plus_grade_min
      return "B+"
    elsif points>=self.B_grade_min
      return "B"
    elsif points>=self.B_minus_grade_min
      return "B-"
    elsif points>=self.C_plus_grade_min
      return "C+"
    elsif points>=self.C_grade_min
      return "C"
    elsif points>=self.C_minus_grade_min
      return "C-"
    else
      return 0.to_s
    end
  end

  def convert_letter_grade_to_points (letter_grade)
    case letter_grade
      when "A"
        return 100.0
      when "A-"
        return (self.A_grade_min-0.1)
      when "B+"
        return (self.A_minus_grade_min-0.1)
      when "B"
        return (self.B_plus_grade_min-0.1)
      when "B-"
        return (self.B_grade_min-0.1)
      when "C+"
        return (self.B_minus_grade_min-0.1)
      when "C"
        return (self.C_plus_grade_min-0.1)
      when "C-"
        return (self.C_grade_min-0.1)
      else
        return -1.0
    end
  end

  def self.get_grade_in_prof_format(course_id, raw_grade)
    grading_rule = GradingRule.find_by_course_id(course_id)
    if grading_rule.nil?
      return raw_grade
    end

    case grading_rule.grade_type
      when "letter"
        return grading_rule.convert_points_to_letter_grade(raw_grade)
      when "points"
        return raw_grade
    end
  end

  def self.get_raw_grade(course_id, grade)
    grading_rule = GradingRule.find_by_course_id(course_id)
    if grading_rule.nil?
      return grade
    end

    case grading_rule.grade_type
      when "letter"
        return grading_rule.convert_letter_grade_to_points(grade)
      when "points"
        return grade
    end
  end

end
