class ReviewsController < ApplicationController
    before_action :find_review, only: [:edit, :update, :destroy]
    before_action :find_idea, only: [:create, :edit, :update, :destroy]
    before_action :authenticate_user!, only: [:create,:edit, :update, :destroy]
    before_action :authenticated!, only: [:edit, :update, :destroy]

    def create
        @review = Review.new review_params
        @review.idea = @idea
        @review.user = current_user
        if @review.save
            flash[:success] = "Review are created"
            redirect_to @idea
        else
            @reviews = @idea.reviews.order(created_at: :desc)
            redirect_to 'ideas#show'
        end
    end
    
    def edit
    end
    
    def update
        if @review.update review_params
            flash[:notice] = 'Thank you for your reviews updates'
            redirect_to idea_path(@review.idea)
        else
            render :edit
        end 
    end
    
    def destroy
        @review.destroy
        flash[:alert] = "Reviews been deleted"
        redirect_to idea_path(@review.idea)  
    end
    
    private
    
    def review_params
        params.require(:review).permit(:body)
    end
    
    def find_idea
        @idea = Idea.find params[:idea_id]
    end

    def find_review
        @review = Review.find params[:id]
    end

    def authenticated!
        unless can? :crud, @review 
            redirect_to root_path, alert: "Not Authorized??"
        end
    end
end
