class PentabarfController < ApplicationController
  before_filter :set_conference
  after_filter :compress
  session(:off)

  def index
  end

  def person
    begin
      @person = Person.select_single( :person_id => params[:id].to_i )
    rescue
      return redirect_to(:action=>:person,:id=>'new') if params[:id] != 'new'
      @person = Person.new(:person_id=>0)
    end
  end

  def event
    begin
      @event = Event.select_single( :event_id => params[:id].to_i )
    rescue Momomoto::Nothing_found
      return redirect_to(:action=>:event,:id=>'new') if params[:id] != 'new'
      @event = Event.new(:event_id=>0)
      @event.conference_id = @current_conference.conference_id
    end
    @conference = Conference.select_single(:conference_id=>@event.conference_id)
  end

  def save_event
    event = Event.select_or_new( {:event_id=>params[:id].to_i},{:copy_values=>false} )
    event.conference_id = @current_conference.conference_id if event.new_record?
    params[:event].each do | key, value |
      next if key.to_sym == :event_id
      event[key] = value
    end
    event.write
    redirect_to( :action => :event, :id => event.event_id)
  end

  def conference
    begin
      @conference = Conference.select_single( :conference_id => params[:id].to_i )
    rescue
      return redirect_to(:action=>:conference,:id=>'new') if params[:id] != 'new'
      @conference = Conference.new(:conference_id=>0)
    end
  end

  def save_conference
    conference = Conference.select_or_new( {:conference_id=>params[:id]},{:copy_values=>false} )
    params[:conference].each do | key, value |
      next if key.to_sym == :conference_id
      conference[key] = value
    end
    conference.write
    redirect_to( :action => :conference, :id => conference.conference_id)
  end

  protected
  def set_conference
    @current_conference = Conference.select_or_new(:conference_id => 1)
  end

end

