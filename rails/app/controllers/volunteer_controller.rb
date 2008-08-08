class VolunteerController < ApplicationController

  before_filter :init
  append_after_filter :set_content_type

  def index
    redirect_to(:action => 'schedule')
  end

  def schedule
    @content_subtitle = 'Schedule'
    @events = View_schedule_volunteer.select({:conference_id => @current_conference.conference_id, :translated => @current_language}, :order => :event_id)
  end

  def volunteer
    @event_person = Event_person.new({:event_id => params[:id], :person_id => POPE.user.person_id, :event_role => params[:event_role]})
    @event_person.write
    redirect_to(:action => 'schedule')
  end

  def remove_from_event
    @event_person = Event_person.select_single({:event_id => params[:id], :person_id => POPE.user.person_id})
    @event_person.delete if @event_person
    redirect_to(:action => 'schedule')
  end

  def save_current_conference
    POPE.user.current_conference_id = params[:conference_id]
    POPE.user.write
    redirect_to( request.env['HTTP_REFERER'] )
  end

  def needed_events
    @content_subtitle = 'Needed events'
    @minutes_ago = params[:minutes_ago] ? params[:minutes_ago] : 30
    @events = View_needed_event_nice.select({:conference_id => @current_conference.conference_id, :start_datetime => {:ge, Time.now - 60*@minutes_ago.to_i}}, :order => :start_datetime )
  end

  protected

  def init
    @current_conference = Conference.select_single(:conference_id => POPE.user.current_conference_id) rescue Conference.new(:conference_id=>0)
    @current_language = POPE.user.current_language || 'en'
    @content_title = 'Volunteer'
  end

  def check_permission
    if POPE.permission?('volunteer_login')
      return true
    end
    redirect_to(:controller=>'submission')
    false
  end

  def set_content_type
    # FIXME: jscalendar does not work with application/xml
    response.headers['Content-Type'] = 'text/html'
  end

end

