FactoryGirl.define do
  factory :descriptive_exam do
    classroom
    discipline
    opinion_type OpinionTypes::BY_YEAR_AND_DISCIPLINE

    trait :current do
      association :classroom, factory: [:classroom, :current]
    end

    after(:build) do |descriptive_exam|
      teacher_discipline_classroom = create(
        :teacher_discipline_classroom,
        classroom: descriptive_exam.classroom,
        discipline: descriptive_exam.discipline
      )

      descriptive_exam.teacher_id = teacher_discipline_classroom.teacher.id

      if descriptive_exam.step_id.blank?
        school_calendar = create(
          :school_calendar,
          :current,
          :school_calendar_with_trimester_steps,
          unity: descriptive_exam.classroom.unity
        )
        descriptive_exam.step_id = school_calendar.step_by_number(1).id
        descriptive_exam.step_number = 1
      end
    end
  end
end
