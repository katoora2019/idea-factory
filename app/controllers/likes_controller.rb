class LikesController < ApplicationController
    
    def create
        idea = Idea.find params[:idea_id]
        like = Like.new(user: current_user, idea: idea)
        if like.save
            flash[:success] = "I Like idea"
            redirect_to idea
        else
            flash[:danger] = like.errors.full_messages.join(", ")
            redirect_to idea
        end
    end

    def destroy
        like = Like.find params[:id]
        like.destroy
        flash[:success] = "Unlike the idea"
        redirect_to like.idea
    end
end
