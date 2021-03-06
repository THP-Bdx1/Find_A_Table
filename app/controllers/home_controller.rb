class HomeController < ApplicationController

    def index

      @faved_games = []
      all_faved_games = []
      Favorite.all.each do |favorite|
        all_faved_games << favorite.game_id
      end
      faved_games_sorted = all_faved_games.sort_by { |u| all_faved_games.count(u) }.reverse
      c = 0
      while faved_games_sorted != [] && c<=5
        @currentgameid = faved_games_sorted[0]
        @currentgameoccurence = faved_games_sorted.count(@currentgameid)
        @faved_games << {"game_id" => @currentgameid, "favs" => @currentgameoccurence}
        faved_games_sorted = faved_games_sorted[@currentgameoccurence..-1]
        c+=1
      end
      @best_city = []
      @most_played_games = []
      all_cities = []
      all_sessions_games = []
      Session.all.each do |session|
        all_cities << session.city
        if session.done? == true
          all_sessions_games << session.game_id
        end
      end
      puts all_cities
      city_name = all_cities.max_by { |i| all_cities.count(i)}
      @best_city = {"city_name" => city_name, "number_of_sessions" => all_cities.count(city_name)}
      @location = Geocoder.search(@best_city["city_name"])
      @city_coordinates = [@location.first.coordinates[0], @location.first.coordinates[1]]
      # @circle= [(@location.first.coordinates[0]+@adress.first.coordinates[0])/2,(@location.first.coordinates[1]+@adress.first.coordinates[1])/2]
      most_played_games_sorted = all_sessions_games.sort_by { |u| all_sessions_games.count(u) }.reverse
      c=0
      while most_played_games_sorted != [] && c<=5
        @currentgameid = most_played_games_sorted[0]
        @currentgameoccurence = most_played_games_sorted.count(@currentgameid)
        @most_played_games << {"game_id" => @currentgameid, "number_of_played_session" => @currentgameoccurence}
        most_played_games_sorted = most_played_games_sorted[@currentgameoccurence..-1]
        c+=1
      end
    end

    def profile
    end

    def list_users
    session[:conversations] ||= []

    @users = User.all.where.not(id: current_user)
    @conversations = Conversation.includes(:recipient, :messages)
                                .find(session[:conversations])
    end

#Favorites part

    def favoris
      @games=current_user.games
      @users_favorites=current_user.addeds
      @params_favorites=[]
      @converses=Conversation.all
      if @converses != []
        @conversation_last_id=Conversation.maximum(:id).next
        @users_favorites.each do |user_favorite|
          param_favor=Hash.new
          conversation_sender = Conversation.find_by(sender_id: current_user.id, recipient_id: user_favorite.id)
          conversation_recipient = Conversation.find_by(recipient_id: current_user.id, sender_id: user_favorite.id)
          if conversation_sender != nil
            param_favor={"nickname"=>user_favorite.nickname, "di"=> user_favorite.id.to_i, "conversation"=>conversation_sender.id}
          elsif conversation_recipient != nil
            param_favor={"nickname"=>user_favorite.nickname, "di"=> user_favorite.id.to_i, "conversation"=>conversation_recipient.id}
          else
            param_favor={"nickname"=>user_favorite.nickname, "di"=> user_favorite.id.to_i, "conversation"=>@conversation_last_id}
          end
          @params_favorites << param_favor
        end
      else 
          @users_favorites.each do |user_favorite|
            param_favor=Hash.new
            param_favor={"nickname"=>user_favorite.nickname, "di"=> user_favorite.id.to_i, "conversation"=>1}
            @params_favorites << param_favor
          end

      end
    end

  #Favorites Games
    def add_to_favorites
      @user = User.find(params[:user_id])
      @game=Game.find(params[:game_id])
      respond_to do |format|
        format.html
        format.js {render :layout => false}
      end
    @favorite=Favorite.create!(user_id: current_user.id, game_id: params[:game_id])
  end

    def remove_from_favorites
      @user = User.find(params[:user_id])
      @game=Game.find(params[:game_id])
      respond_to do |format|
        format.html
        format.js {render :layout => false}
      end
    @favorite=Favorite.find_by(user_id: current_user.id, game_id: params[:game_id])
    @favorite.destroy
  end

  #Favorites Users
    def add_users_to_favorites
      @user = User.find(params[:added_id])
      respond_to do |format|
        format.html
        format.js {render :layout => false}
      end
      current_user.addeds << @user
  end

    def remove_users_from_favorites
      @user = User.find(params[:added_id])
      respond_to do |format|
        format.html
        format.js {render :layout => false}
      end
      current_user.addeds.delete(@user)
    end

#Likes
    def like_user
      @user = User.find(params[:liked_id])
      @session_id = Session.find(params[:session_id]).id
      respond_to do |format|
        format.html
        format.js {render :layout => false}
      end
    @like=LikesToUser.create!(liker_id: current_user.id, liked_id: params[:liked_id], session_id: params[:session_id])
  end

    def unlike_user
      @user = User.find(params[:liked_id])
      @session_id = Session.find(params[:session_id]).id
      respond_to do |format|
        format.html
        format.js {render :layout => false}
      end
    @like=LikesToUser.find_by(liker_id: current_user.id, liked_id: params[:liked_id], session_id: params[:session_id])
    @like.destroy
  end


#Sessions
  def mysessions
    @myhostsessions = []
    @myplayersessions = []
    @myplayersessionsdone = []
    Session.all.each do |session|
      if session.host == current_user && session.done? == false
        @myhostsessions << session
      end
      if session.players.include?(current_user) && session.done? == false && session.host != current_user
        @myplayersessions << session
      end
      if session.players.include?(current_user) && session.done? == true
        @myplayersessionsdone << session
      end
    end
    @likes=LikesToUser.all

  end

  def player

    @player = User.find(params[:id])
    @user = User.find(params[:id])

    #Sessions communes
    @common_sessions = []
    if current_user.sessions.ids == @player.sessions.ids
      @common_sessions << @player.sessions.ids
    end
    @favorites=FavoritesUser.all
    if current_user != nil
      @favorite=FavoritesUser.find_by(adder_id: current_user.id, added_id: params[:id])
    end

    #Conversations
    @converses=Conversation.all
    if @converses != []
      @conversation_last_id=Conversation.maximum(:id).next
      conversation_sender = Conversation.find_by(sender_id: current_user.id, recipient_id: @user.id)
      conversation_recipient = Conversation.find_by(recipient_id: current_user.id, sender_id: @user.id)
      if conversation_sender != nil
        @conversation_id=conversation_sender.id
      elsif conversation_recipient != nil
        @conversation_id=conversation_recipient.id
      else
        @conversation_id=@conversation_last_id
      end
    else
      @conversation_id=1
    end
    #Likes
    @likes=LikesToUser.where(liked_id: @user.id)

    #Favoris
    @favorites_games=Favorite.where(user_id: @user.id)
  end
end
