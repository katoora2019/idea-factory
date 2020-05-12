class LikesController < ApplicationController
    before_action :authenticate_user!
    
    def create
        idea = Idea.find params[:idea_id]
        like = Like.new(user: current_user, idea: idea)
        if like.save
            flash[:success] = "I Like the idea"
            redirect_to idea
        else
            flash[:danger] = like.errors.full_messages.join(", ")
            redirect_to idea
        end
    end

    def destroy
        like = Like.find params[:id]
        if can? like.destroy,like
            like.destroy
        flash[:success] = "Unlike the idea"
        redirect_to like.idea
        else
            redirect_to like.idea, alert: "can't delete like"
        end
    end
end
