require 'rails_helper'

RSpec.describe AttendanceRecordReport, type: :report do
  it "should be created" do
    entity_configuration = create(:entity_configuration)
    classroom = create(:classroom, :current)
    school_calendar = create(:school_calendar_with_one_step, :current, unity: classroom.unity)

    daily_frequency = create(
      :daily_frequency,
      frequency_date: "04/01/#{school_calendar.year}",
      classroom: classroom,
      school_calendar: school_calendar
    )
    student = create(:student)
    teacher = create(:teacher)

    daily_frequencies = DailyFrequency.all
    students = Student.all

    subject = AttendanceRecordReport.build(
      entity_configuration,
      teacher,
      school_calendar.year,
      "01/01/2016",
      "01/01/2016",
      daily_frequencies,
      students,
      school_calendar.events.by_date_between("01/01/2016", "01/01/2016").extra_school_without_frequency,
      school_calendar
    ).render

    expect(subject).to be_truthy
  end
end
