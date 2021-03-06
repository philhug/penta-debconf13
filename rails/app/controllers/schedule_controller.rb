class ScheduleController < ApplicationController

  include ScheduleHelper

  before_filter :init

  def index
  end

  def css
    response.headers['Content-Type'] = 'text/css'
    render( :text => @conference.css.to_s )
  end

  def day
    @day = Conference_day.select_single({:conference_id=>@conference.conference_id,:public=>'t',:conference_day=>params[:id]})
    @content_title = local('schedule::schedule') + ' ' + format_conference_day( @day )
    @rooms = Conference_room.select({:conference_id=>@conference.conference_id, :public=>'t'})
    @events = View_schedule_event.select({:conference_day=>{:le=>@day.conference_day},:conference_id=>@conference.conference_id,:translated=>@current_language},{:order=>[:title,:subtitle]})
  end

  def event
    @event = View_event.select_single({:conference_id=>@conference.conference_id,:translated=>@current_language,:event_id=>params[:id],:event_state=>'accepted',:event_state_progress=>'confirmed'})
    @events = View_schedule_event.select({:conference_id=>@conference.conference_id,:translated=>@current_language},{:order=>[:title,:subtitle]})
    @content_title = @event.title
  end

  def events
    @events = View_schedule_event.select({:conference_id=>@conference.conference_id,:translated=>@current_language},{:order=>[:title,:subtitle]})
    @showevents=@events
  end

  def speaker
    @speakers = View_schedule_person.select({:conference_id=>@conference.conference_id},{:order=>[:name]})
    @person = View_person.select_single({:person_id=>params[:id]})
    @speaker = Conference_person.select_or_new({:conference_id=>@conference.conference_id,:person_id=>params[:id]})
    @content_title = @person.name
  end

  def speakers
    @speakers = View_schedule_person.select({:conference_id=>@conference.conference_id},{:order=>[:name]})
    @content_title = local(:speakers)
  end

  def track_event
    @track = Conference_track.select_single({:conference_id=>@conference.conference_id,:conference_track=>params[:track]})
    @event = View_event.select_single({:conference_id=>@conference.conference_id,:translated=>@current_language,:event_id=>params[:id]})
    @events = View_schedule_event.select({:conference_id=>@conference.conference_id,:conference_track=>@track.conference_track,:translated=>@current_language}, {:order=>[:title,:subtitle]})
    @content_title = @event.title
  end

  def track_events
#    @content_title = "Lectures and workshops"
    @track = Conference_track.select_single({:conference_id=>@conference.conference_id,:conference_track=>params[:track]})
    @events = View_schedule_event.select({:conference_id=>@conference.conference_id,:conference_track=>@track.conference_track,:translated=>@current_language}, {:order=>[:title,:subtitle]})
  end

  protected

  def init
    @conference = Conference.select_single(:acronym=>params[:conference])
    @days = Conference_day.select({:conference_id=>@conference.conference_id,:public=>'t'},{:order=>:conference_day})
    @tracks = Conference_track.select(:conference_id=>@conference.conference_id)
    @current_language = params[:language] || 'en'
    @showevents = View_schedule_event.select({:conference_id=>@conference.conference_id,:translated=>@current_language},{:order=>[:title,:subtitle]})
  end

  def check_permission
    POPE.permission?('submission_login')
  end

end
