class PressController < ApplicationController

  before_filter :init

  def index
    @conferences = Conference.select({:f_submission_enabled=>'t'})
  end # def index

  def admin
    @dc_press = DebConf::Dc_view_press.select({:conference_id=>@conference.conference_id},{:order=>Momomoto.lower(:association,:name)})
  end # def admin

  def thankyou
    @dc_press = DebConf::Dc_press.select_single(:press_id => params[:id] )
  end # def thankyou

  def edit
      @dc_press = DebConf::Dc_press.select_single(:press_id=>params[:id])
  end

  def enter
      @dc_press = DebConf::Dc_press.new()
  end # def enter

  def save_real_data
    params[:dc_press][:press_id] = params[:id] if params[:id].to_i > 0
    params[:dc_press][:id_check] = random_string
    dc_press = write_row( DebConf::Dc_press, params[:dc_press] )

    options = {:press_id => dc_press.press_id,:conference_id=>@conference.conference_id}
    
    dc_conference_press = DebConf::Dc_conference_press.select_or_new( options ).write
    dc_press.press_id
  end # def save_real_data

  def save_data
    id = save_real_data
    if POPE.user
      redirect_to( :action => :admin )
    else
      redirect_to( :action => :thankyou, :id => id)
    end
  end # def save_data

  def save_new_data
    id = save_real_data
    redirect_to( :action => :thankyou, :id => id )
  end # def save_new_data

  def send_mail
    from = params[:mail][:from].empty? ? @conference.email :  params[:mail][:from]
    contacts = DebConf::Dc_view_press.select({:conference_id=>@conference.conference_id},{:order=>Momomoto.lower(:association,:name)})
    variables = [:email, :name, :press_id, :person_id]
    conference_variables = [:acronym, :title]
    contacts.each do |pc|
        body = params[:mail][:body].dup
        subject = params[:mail][:subject].dup + "#{@conference.email}"
        variables.each do | v |
          body.gsub!(/\{\{#{v}\}\}/i, pc[v].to_s)
          subject.gsub!(/\{\{#{v}\}\}/i, pc[v].to_s)
        end
        conference_variables.each do | v |
          body.gsub!(/\{\{conference_#{v}\}\}/i, @conference.send(v))
          subject.gsub!(/\{\{conference_#{v}\}\}/i, @conference.send(v))
        end
        Notifier::deliver_general(pc.email, subject, body, from)
    end
    redirect_to(:action => :admin)
  end

  def delete
    row = DebConf::Dc_press.select_single({:press_id => params[:id]})
    row.delete
    redirect_to(:action => :admin)
  end

  def update_data
    @dc_press = DebConf::Dc_press.new()
  end

  def get_id_check
    @dc_press = DebConf::Dc_press.select_single(params[:dc_press]) rescue false
    if @dc_press
      body = <<EOF
Here is your edit link, it will only work once, so you'll need to request a new one for further changes:

#{url_for(:action => :edit, :id => @dc_press.press_id, :id_check => @dc_press.id_check)}


And with this link you can be permanently removed from our press contact database:

#{url_for(:action => :self_delete, :id => @dc_press.press_id, :id_check => @dc_press.id_check)}

Thanks for keeping your data updated and accurate.
The #{@conference.title} press team.
EOF
      Notifier::deliver_general(@dc_press.email, "Your editing link for your press contact info for #{@conference.title}", body, @conference.email)
    else
      redirect_to( :action => :update_data )
    end
  end

  def self_delete
    row = DebConf::Dc_press.select_single({:press_id => params[:id]}) rescue false
    row.delete if row
    redirect_to(:action => :index)
  end


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
    allowed = [ 'index', 'enter', 'thankyou', 'save_new_data', 'get_id_check', 'update_data']
    if ['save_data', 'edit', 'self_delete'].include?(params[:action]) && params[:id]
      dc_press = DebConf::Dc_press.select_single(:press_id => params[:id])
      return true if dc_press.respond_to?(:id_check) && dc_press.id_check == params[:id_check] #self change
    end
    return super if !allowed.include?(params[:action]) || params[:id] == 'auth'
    true
  end # def auth

  def check_permission
    POPE.permission?('press_login')
  end # def check_permission

  def random_string
    sprintf("%064X", rand(2**256))
  end



end # class
