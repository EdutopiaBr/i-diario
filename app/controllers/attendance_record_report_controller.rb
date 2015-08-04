class AttendanceRecordReportController < ApplicationController
  before_action :require_current_teacher
  before_action :require_current_school_calendar
  before_action :require_current_test_setting

  def form
    @attendance_record_report_form = AttendanceRecordReportForm.new(school_calendar_year: current_school_calendar.year)
    fetch_collections
  end

  def report
    @attendance_record_report_form = AttendanceRecordReportForm.new(resource_params)

    if @attendance_record_report_form.valid?
      attendance_record_report = AttendanceRecordReport.build(current_entity_configuration,
                                                              current_teacher,
                                                              current_school_calendar.year,
                                                              @attendance_record_report_form.start_at,
                                                              @attendance_record_report_form.end_at,
                                                              @attendance_record_report_form.daily_frequencies)

      send_data(attendance_record_report.render, filename: 'registro-de-frequencia.pdf', type: 'application/pdf', disposition: 'inline')
    else
      @attendance_record_report_form.school_calendar_year = current_school_calendar.year
      fetch_collections
      render :form
    end
  end

  private

  def fetch_collections
    fetcher = UnitiesClassroomsDisciplinesByTeacher.new(current_teacher.id,
                                                        @attendance_record_report_form.unity_id,
                                                        @attendance_record_report_form.classroom_id,
                                                        @attendance_record_report_form.discipline_id)
    fetcher.fetch!
    @unities = fetcher.unities
    @classrooms = fetcher.classrooms
    @disciplines = fetcher.disciplines
    @number_of_classes = current_school_calendar.number_of_classes
  end

  def resource_params
    params.require(:attendance_record_report_form).permit(:unity_id,
                                                          :classroom_id,
                                                          :discipline_id,
                                                          :class_numbers,
                                                          :start_at,
                                                          :end_at,
                                                          :school_calendar_year,
                                                          :global_absence)
  end
end

