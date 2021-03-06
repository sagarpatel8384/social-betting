require 'sinatra'
require_relative 'helpers'
require_relative 'config/session'
require_relative 'models'

# USER SIGN IN
# ===============================

get '/' do
  erb :home
end

post '/session' do

  user = User.first(:email => params[:user][:email])

  if user && password_validation(user, params[:user][:password])
    login!(user)
  else
    redirect '/'
  end

end

# USER REGISTRATION
# ===============================

get '/user/new' do
  @user = User.new
  erb :new_user
end

post '/user' do

  user = User.create(params[:user])

  if user.saved?
    login!(user)
  else
    erb :new_user
  end

end

# USER SIGN OUT
# ===============================

get '/session/logout' do
  log_out!
  redirect '/'
end

# CREATE GROUP
# ===============================

get '/create_group' do
  erb :create_group
end

post '/create_group' do
  new_group = Group.create(params[:group])

  if new_group.saved?
    current_user.groups << new_group
    current_user.save
    redirect '/'
  else
    erb :create_group
  end

end

# JOIN GROUP
# ===============================

get '/join_group' do
  erb :join_group
end

post '/join_group' do

  group = Group.first(:group_name => params[:group][:group_name])

  if password_validation(group, params[:group][:password])
    current_user.groups << group
    current_user.save
    redirect '/'
  else
    erb :join_group
  end

end

# SHOW GROUP
# ===============================
get '/groups/:group_id' do

  redirect '/' unless logged_in? # Before Filter or Helper Method

  @group = Group.get(params[:group_id])
  erb :show_group
end

# CREATE BET
# ===============================

post '/groups/:group_id/bets' do
  current_bettee = User.get(params[:select])
  bet_amount = remove_dollar_sign(params[:bet][:amount])

  bet = Bet.create({  :amount => bet_amount,
                      :expiration => params[:bet][:expiration_date],
                      :description => params[:bet][:description],
                      :bettor => current_user,
                      :bettee => current_bettee,
                      :group_id => params[:group_id]
                  })
  redirect '/'
end

# DELETE BET
# ===============================

delete '/bets/:id' do
  bet = Bet.first(:id => params[:id])
  bet.destroy
  redirect '/'
end

# EDIT PROFILE
# ===============================

get '/profile' do
  erb :edit_profile
end

put '/user' do
  current_user.update(:email => params[:user][:email], :first_name => params[:user][:first_name], :last_name => params[:user][:last_name])
  current_user.save
  redirect '/'
end

# LEAVE GROUP
# ===============================

delete '/groups/:group_id/leave_group' do
  group = Group.get(params[:group_id])
  current_user.groups.delete(group)
  current_user.save
  redirect '/'
end
