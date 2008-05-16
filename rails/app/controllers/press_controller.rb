class PressController < ApplicationController

  before_filter :init

  def index
    @conferences = Conference.select({:f_submission_enabled=>'t'})
  end # def index

  def admin
    @dc_press = DebConf::Dc_press.select()
    @dc_conference_press = DebConf::Dc_conference_press.select(:conference_id=>@conference.conference_id)
  end # def admin

  def thankyou
    @dc_press = DebConf::Dc_press.select_single(:press_id => params[:id] )
  end # def thankyou

  def enter
    @dc_press = DebConf::Dc_press.new()
  end # def enter

  def save_data
    dc_press = write_row( DebConf::Dc_press, params[:dc_press] )

    options = {:press_id => dc_press.press_id,:conference_id=>@conference.conference_id}
    dc_conference_press = write_row( DebConf::Dc_conference_press, options )

    redirect_to( :action => :thankyou, :id => dc_press.press_id )
  end # def save_data

  protected

  def init
    @current_language = POPE.user ? POPE.user.current_language : 'en'
    begin
      @conference = Conference.select_single(:acronym=>params[:conference])
    rescue Momomoto::Error
      if params[:action] != 'index' || params[:conference]
        redirect_to(:controller=>'press', :action => :index, :conference => nil )
        return false
      end # if params
    end # begin
  end # def init

  def auth
    allowed = [ 'index', 'enter', 'thankyou', 'save_data' ]
    return super if not allowed.include?(params[:action]) || params[:id] == 'auth'
    true
  end # def auth

  def check_permission
    POPE.permission?('press_login')
  end # def check_permission



end # class
