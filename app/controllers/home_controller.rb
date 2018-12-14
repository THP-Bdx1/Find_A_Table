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
        print faved_games_sorted
        c+=1
      end
      @best_city = []
      all_cities = []
      Session.all.each do |session|
        all_cities << session.city
      end
      city_name = all_cities.max_by { |i| all_cities.count(i)}
      @best_city << {"city_name" => city_name, "number_of_sessions" => all_cities.count(city_name)}
      puts "ICIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII"
      puts @best_city
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
    @favoris=current_user.favorites
    @games=[]
    @favoris.each do |favor|
        @game=Game.find_by(id: favor.game_id)
        @games << @game
    end
    @users_favorites=FavoritesUser.where(adder_id: current_user.id)
    @params_favorites=[]
    @conversation_last_id=Conversation.maximum(:id).next
    @users_favorites.each do |user_favorite|
      param_favor=Hash.new
      conversation_sender = Conversation.find_by(sender_id: current_user.id, recipient_id: user_favorite.added.id)
      conversation_recipient = Conversation.find_by(recipient_id: current_user.id, sender_id: user_favorite.added.id)
        if conversation_sender != nil
          param_favor={"nickname"=>user_favorite.added.nickname, "di"=> user_favorite.added.id.to_i, "conversation"=>conversation_sender.id}
        elsif conversation_recipient != nil
          param_favor={"nickname"=>user_favorite.added.nickname, "di"=> user_favorite.added.id.to_i, "conversation"=>conversation_recipient.id}
        else
          param_favor={"nickname"=>user_favorite.added.nickname, "di"=> user_favorite.added.id.to_i, "conversation"=>@conversation_last_id}
        end
        @params_favorites << param_favor
      end
      puts "Le params_favorites est #{@params_favorites}"
    end

  #Favorites Games
    def add_to_favorites
        puts "#{params}"
      @user = User.find(params[:user_id])
      @game=Game.find(params[:game_id])
      puts "ça fav"
      respond_to do |format|
        format.html
        format.js {render :layout => false}
      end
    @favorite=Favorite.create!(user_id: current_user.id, game_id: params[:game_id])
  end

    def remove_from_favorites
      @user = User.find(params[:user_id])
      @game=Game.find(params[:game_id])
      puts "ça défav"
      respond_to do |format|
        format.html
        format.js {render :layout => false}
      end
    @favorite=Favorite.find_by(user_id: current_user.id, game_id: params[:game_id])
    @favorite.destroy
  end

  #Favorites Users
    def add_users_to_favorites
        puts "Les params sont#{params}"
      @user = User.find(params[:added_id])
      puts "ça fav"
      respond_to do |format|
        format.html
        format.js {render :layout => false}
      end
    @favorite=FavoritesUser.create!(adder_id: current_user.id, added_id: params[:added_id])
  end

    def remove_users_from_favorites
      puts "Les params du remove sont#{params}"
      @user = User.find(params[:added_id])
      puts "ça défav"
      respond_to do |format|
        format.html
        format.js {render :layout => false}
      end
    @favorite=FavoritesUser.find_by(adder_id: current_user.id, added_id: params[:added_id])
    @favorite.destroy
  end

#Sessions
  def mysessions
    @myhostsessions = []
    @myplayersessions = []
    Session.all.each do |session|
      if session.host == current_user
        @myhostsessions << session
      end
      if session.players.include?(current_user)
        @myplayersessions << session
      end
    end
  end

  def player
    @player = User.find(params[:id])
    @user = User.find(params[:id])
        @common_sessions = []

        if current_user.sessions.ids == @player.sessions.ids
            @common_sessions << @player.sessions.ids
        end
        @favorites=FavoritesUser.all
        if current_user != nil
            @favorite=FavoritesUser.find_by(adder_id: current_user.id, added_id: params[:id])
        end
      
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
      end
    
end
