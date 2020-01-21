class IdeasController < ApplicationController
    before_action :authenticate_user!, except: [:show, :index]
    before_action :find_idea, only: [:show, :edit, :update, :destroy]
    before_action :authenticate!, only: [:edit, :update, :destroy]

    def index
        @ideas = Idea.order(created_at: :desc)
    end

    def new
        @idea = Idea.new
    end

    def create
        @idea = Idea.new idea_params
        @idea.user = current_user
        if @idea.save
            flash[:success] = "Idea created"
            redirect_to idea_path(@idea)
        else
            render :new
        end
    end

    def show
        @review = Review.new
        @reviews = @idea.reviews
    end

    def edit
    end

    def update
        if @idea.update idea_params
            flash[:success] = "Idea updated"
            redirect_to idea_path(@idea)            
        else
            render :edit
        end        
    end

    def destroy
        @idea.destroy 
        flash[:success] = "Idea deleted"
        redirect_to root_path    
    end

    private

    def idea_params
        params.require(:idea).permit(:title, :description)
    end

    def find_idea
        @idea = Idea.find params[:id]
    end

    def authenticate!
        unless can? :crud, @idea
            flash[:danger] = "Not authorized"
            redirect_to idea_path(@idea)
        end
    end

end
